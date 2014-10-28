-- 手势管理模块
-- @module GestureManager
-- @author sxm
-- @copyright usugame

require "Cocos2d"

-- 边界枚举表
-- @table side
-- @param left 左边
-- @param right 右边
local side = {
	left = 1,
	right = 2
}

-- 操作类型枚举表
-- @param click 单击
-- @param slide 滑动
-- @param doubleclick 双击
local operation = {
	click = 1,
	slide = 2,
	doubleclick = 3
}


-- 手势管理者单例
local GestureManager_shared_instance = nil

-- 手势管理类
-- @type GestureManager Layer
local GestureManager = class("GestureManager", function ()
	return cc.Layer:create()
end)

-- 获取手势管理者单例函数
-- @return GestureManager_shared_instance 手势管理者单例
function GestureManager:getInstance()
	if GestureManager_shared_instance == nil then
		GestureManager_shared_instance = GestureManager.new()
		GestureManager_shared_instance:retain()
	end
	return GestureManager_shared_instance
end

-- 手势管理类初始化回调
function GestureManager:ctor()
	local sz = cc.Director:getInstance():getWinSize()
	self:setContentSize(sz)
    
    local dx, dy = require("gameWinSize"):getInstance():GetSceneOriginPos()
    
	self._nSepa = (-dx + (sz.width+dx)*0.618) / 1.618
	self._nAxis = (-dx + self._nSepa * 0.5) / 1.5
	self._nLeftTL = cc.p(-dx + 50, sz.height + dy - 100)
	self._nLeftBR = cc.p(self._nSepa, -dy + 100)
	self._nDeltaX = 80
	self._nDeltaY = 80
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

-- 渲染对象创建
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

-- 创建手指离开动画
-- @param touch 触摸对象
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

-- 设置手势输入回调模块和回调函数
-- @param _module 模块
-- @param _handler 回调函数
function GestureManager:setHandler(_module, _handler)
	self._tModule = _module
	self._fHandler = _handler
end

-- 设置右边屏幕手势是否可以输入
-- @param bEnable true启用，false禁用
function GestureManager:setRightTouchEnable(bEnable)
	self._bRightTouchEnable = bEnable
end

-- 边界测试
-- @param touch 触摸对象
function GestureManager:sideTest(touch)
	local pos = self:convertToNodeSpace(touch:getLocation())
	if pos.x < self._nSepa then
		return side.left
	else
		return side.right
	end
end

-- 触摸开始回调
-- @param touches 触摸对象集合
-- @param event 事件
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

-- 触摸移动回调
-- @param touches 触摸对象集合
-- @param event 事件
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

-- 修正指纹位置
-- @param pos 指纹位置
function GestureManager:fixFPPosition(pos)
    local x, y = 0, 0
    x = math.max(pos.x, self._nLeftTL.x)
    x = math.min(x, self._nLeftBR.x)
    y = math.max(pos.y, self._nLeftBR.y)
    y = math.min(y, self._nLeftTL.y)
    return x, y
end

-- 修正双曲线位置
-- @param pos 双曲线位置
function GestureManager:fixHBPosition(pos)
    local x, y = 0, 0
    x = math.max(pos.x, self._nLeftTL.x + 50)
    x = math.min(x, self._nLeftBR.x - 50)
    y = math.max(pos.y, self._nLeftBR.y)
    y = math.min(y, self._nLeftTL.y)
    return x, y
end

-- 修正左右方向轴位置
-- @param x 准备使用的x坐标
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

-- 左边界屏幕移动回调
-- @param touch 触摸对象
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

-- 右边界屏幕移动回调
-- @param touch 触摸对象
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

-- 触摸取消回调
-- @param touches 触摸对象集合
-- @param event 事件
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

-- 触摸结束回调
-- @param touches 触摸对象集合
-- @param event 事件
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
