
require "Cocos2d"

local side = {
	left = 1,
	right = 2
}

local operation = {
	click = 1,
	slide = 2,
	doubleclick = 3
}

local GestureManager_shared_instance = nil

local GestureManager = class("GestureManager", function ()
	return cc.Layer:create()
end)

function GestureManager:getInstance()
	if GestureManager_shared_instance == nil then
		GestureManager_shared_instance = GestureManager.new()
		GestureManager_shared_instance:retain()
	end
	return GestureManager_shared_instance
end

function GestureManager:ctor()
	local sz = cc.Director:getInstance():getWinSize()
	self:setContentSize(sz)
    
    local dx, dy = require("gameWinSize"):getInstance():GetSceneOriginPos()
    
	self._nSepa = (-dx + (sz.width+dx)*0.618) / 1.618
	self._nAxis = (-dx + self._nSepa * 0.5) / 1.5
	self._nLeftTL = cc.p(-dx + 50, sz.height + dy - 100)
	self._nLeftBR = cc.p(self._nSepa, -dy + 100)
	self._nDeltaX = 50
	self._nDeltaY = 50
	self._nRightOperation = operation.click
	self._nLeftOperation = operation.click
	self._nLeftLastClickTick = 0
	self._bRightTouchEnable = true

	self._uLeftTouch = nil
	self._uRightTouch = nil

	local function onTouchesBegan(touches, event)
		self:onTouchesBegan(touches, event)
	end

	local function onTouchesMoved(touches, event)
		self:onTouchesMoved(touches, event)
	end

    local function onTouchesCanceled(touches, event)
        self:onTouchesCanceled(touches, event)
    end
    
	local function onTouchesEnded(touches, event)
		self:onTouchesEnded(touches, event)
	end

	local listener = cc.EventListenerTouchAllAtOnce:create()
	listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN)
	listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
	listener:registerScriptHandler(onTouchesCanceled, cc.Handler.EVENT_TOUCHES_CANCELLED)
	listener:registerScriptHandler(onTouchesEnded, cc.Handler.EVENT_TOUCHES_ENDED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    
    self:createRenderObject()
end

function GestureManager:createRenderObject()
    self._rFingerprintG = cc.Sprite:create("green_fingerprint.png")
    self._rFingerprintR = cc.Sprite:create("red_fingerprint.png")
    self._rHyperbola = cc.Sprite:create("hyperbola.png")

    local rL = cc.Sprite:create("l.png")
    local rR = cc.Sprite:create("r.png")
    rL:setPosition(113 - 60, 101)
    rR:setPosition(113 + 60, 101)
    self._rHyperbola:addChild(rL)
    self._rHyperbola:addChild(rR)
    self._rHyperbola:setPositionX(self._nAxis)
    self:addChild(self._rHyperbola)
    self:addChild(self._rFingerprintG)
    self:addChild(self._rFingerprintR)

    self._rFingerprintG:setVisible(false)
    self._rFingerprintR:setVisible(false)
    self._rHyperbola:setVisible(false)
end

function GestureManager:createFingerExitAnimation(touch)
    local _side = nil
    if touch == self._uLeftTouch then
        _side = side.left
    elseif touch == self._uRightTouch then
        _side = side.right
    end
    local color = {"g", "r"}
    local aniName = color[_side].."_finger_exit_"
    local frames = {}
    for i = 1, 2 do
        local frame = cc.Sprite:create(aniName..i..".png"):getSpriteFrame()
        table.insert(frames, frame)
    end
    local animation = cc.Animation:createWithSpriteFrames(frames, 0.05)
    local animate = cc.Animate:create(animation)
    local runNode = cc.Sprite:create()
    local function afterRunning(sender)
        runNode:removeFromParent(true)
    end
    runNode:runAction(cc.Sequence:create(cc.Repeat:create(animate, 1), cc.CallFunc:create(afterRunning)))
    local pos = {cc.p(self._rFingerprintG:getPosition()), self:convertToNodeSpace(touch:getLocation())}
    runNode:setPosition(pos[_side])
    self:addChild(runNode)
end

function GestureManager:setHandler(_module, _handler)
	self._tModule = _module
	self._fHandler = _handler
end

function GestureManager:setRightTouchEnable(bEnable)
	self._bRightTouchEnable = bEnable
end

function GestureManager:sideTest(touch)
	local pos = self:convertToNodeSpace(touch:getLocation())
	if pos.x < self._nSepa then
		return side.left
	else
		return side.right
	end
end

function GestureManager:onTouchesBegan(touches, event)
	for i, touch in ipairs(touches) do
		if self:sideTest(touch) == side.left and self._uLeftTouch == nil then
			--两次点击时差小于300ms判定为双击
			local pos = self:convertToNodeSpace(touch:getLocation())
			local curTick = FGGetTickCountMS()
			if curTick - self._nLeftLastClickTick < 300 then
				self._nLeftOperation = operation.doubleclick
				if pos.x < self._nAxis then
					self._fHandler(self._tModule, side.left, g_walkingType.runLeft)
				elseif pos.x > self._nAxis then
                    self._fHandler(self._tModule, side.left, g_walkingType.runRight)
				end
			else
				self._nLeftOperation = operation.click
				if pos.x < self._nAxis then
                    self._fHandler(self._tModule, side.left, g_walkingType.walkLeft)
				elseif pos.x > self._nAxis then
                    self._fHandler(self._tModule, side.left, g_walkingType.walkRight)
				end
			end
            self._uLeftTouch = touch
            self._nLeftLastClickTick = curTick
            
            self._rFingerprintG:setVisible(true)
            local x, y = self:fixFPPosition(pos)
            self._rFingerprintG:setPosition(x, y)
            self._rHyperbola:setVisible(true)
            x, y = self:fixHBPosition(pos)
            self._rHyperbola:setPositionY(y)
		elseif self._bRightTouchEnable == true and self:sideTest(touch) == side.right and self._uRightTouch == nil then
            local pos = self:convertToNodeSpace(touch:getLocation())
			self._rFingerprintR:setVisible(true)
			self._rFingerprintR:setPosition(pos)
			self._uRightTouch = touch
			self._nRightOperation = operation.click
		end
	end
	return true
end

function GestureManager:onTouchesMoved(touches, event)
	for i, touch in ipairs(touches) do
		if touch == self._uLeftTouch then
			self:leftTouchMoved(touch)
		elseif touch == self._uRightTouch then
			--print("right:touchMoved")
			self:rightToucheMoved(touch)
		end
	end
end

function GestureManager:fixFPPosition(pos)
    local x, y = 0, 0
    x = math.max(pos.x, self._nLeftTL.x)
    x = math.min(x, self._nLeftBR.x)
    y = math.max(pos.y, self._nLeftBR.y)
    y = math.min(y, self._nLeftTL.y)
    return x, y
end

function GestureManager:fixHBPosition(pos)
    local x, y = 0, 0
    x = math.max(pos.x, self._nLeftTL.x + 50)
    x = math.min(x, self._nLeftBR.x - 50)
    y = math.max(pos.y, self._nLeftBR.y)
    y = math.min(y, self._nLeftTL.y)
    return x, y
end

function GestureManager:fixAxis(x)
	local dx = x - self._nAxis
	if math.abs(dx) > 100 then
	   if dx > 0 then
	       self._nAxis = x - 100
	   elseif dx < 0 then
           self._nAxis = x + 100
	   end
	end
end

function GestureManager:leftTouchMoved(touch)
	--改变摇杆位置，和人物方向判定
	--print("left:touchMoved")
    local curPos = self:convertToNodeSpace(touch:getLocation())
	if curPos.x < self._nAxis then
		if self._nLeftOperation == operation.click then
            self._fHandler(self._tModule, side.left, g_walkingType.walkLeft)
		elseif self._nLeftOperation == operation.doubleclick then
            self._fHandler(self._tModule, side.left, g_walkingType.runLeft)
		end
	elseif curPos.x > self._nAxis then
		if self._nLeftOperation == operation.click then
            self._fHandler(self._tModule, side.left, g_walkingType.walkRight)
		elseif self._nLeftOperation == operation.doubleclick then
            self._fHandler(self._tModule, side.left, g_walkingType.runRight)
		end
	end
	
    local x, y = self:fixFPPosition(curPos)
    self._rFingerprintG:setPosition(x, y)
    self:fixAxis(x)
    self._rHyperbola:setPositionX(self._nAxis)
end

function GestureManager:rightToucheMoved(touch)
	local startPos = self:convertToNodeSpace(touch:getStartLocation())
	local curPos = self:convertToNodeSpace(touch:getLocation())
	local dx = curPos.x - startPos.x
	local dy = curPos.y - startPos.y
    self._rFingerprintR:setPosition(curPos)
    
	if math.abs(dx) >= self._nDeltaX then
		--dx > 0 - 右 ,dx < 0 - 左
		if dx > 0 then
			self._fHandler(self._tModule, side.right, g_gestureType.right)
		elseif dx < 0 then
            self._fHandler(self._tModule, side.right, g_gestureType.left)
		end
        self._rFingerprintR:setVisible(false)
		self._nRightOperation = operation.slide
		self._uRightTouch = nil
	end

	if math.abs(dy) >= self._nDeltaY then
		--dy > 0 - 上, dy < 0 - 下
		if dy > 0 then
            self._fHandler(self._tModule, side.right, g_gestureType.up)
		elseif dy < 0 then
            self._fHandler(self._tModule, side.right, g_gestureType.down)
		end
		self._rFingerprintR:setVisible(false)
		self._nRightOperation = operation.slide
		self._uRightTouch = nil
	end
end

function GestureManager:onTouchesCanceled(touches, event)
    for i, touch in ipairs(touches) do
        if touch == self._uLeftTouch then
            self._fHandler(self._tModule, side.left, g_walkingType.standing)
            self._rFingerprintG:setVisible(false)
            self._rHyperbola:setVisible(false)
            self._uLeftTouch = nil
        elseif touch == self._uRightTouch and self._nRightOperation == operation.click then
            self._rFingerprintR:setVisible(false)
            self._fHandler(self._tModule, side.right, g_gestureType.click)
            self._uRightTouch = nil
        end
    end
end

function GestureManager:onTouchesEnded(touches, event)
	for i, touch in ipairs(touches) do
		if touch == self._uLeftTouch then
            self._fHandler(self._tModule, side.left, g_walkingType.standing)
            self._rFingerprintG:setVisible(false)
            self._rHyperbola:setVisible(false)
            self:createFingerExitAnimation(touch)
			self._uLeftTouch = nil
		elseif touch == self._uRightTouch and self._nRightOperation == operation.click then
            self._rFingerprintR:setVisible(false)
            self._fHandler(self._tModule, side.right, g_gestureType.click)
            self:createFingerExitAnimation(touch)
			self._uRightTouch = nil
		end
	end
end

return GestureManager
