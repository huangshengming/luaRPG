require("Cocos2d")

local side = {
    left = 1,
    right = 2
}

local ActionTransform_shared_instance = nil

local ActionTransform = class("ActionTransform")

function ActionTransform:getInstance()
    if ActionTransform_shared_instance == nil then
        ActionTransform_shared_instance = ActionTransform.new()
    end
    return ActionTransform_shared_instance
end

function ActionTransform:setHandler(_module, _handler)
	self._tModule = _module
	self._fHandler = _handler
end

function ActionTransform:ctor()
    local gestureMgr = require("gestureManagement.gestureManagement"):getInstance()
    gestureMgr:setHandler(self, self.handler)
end

function ActionTransform:handler(_side, _event)
    if _side == side.left then
        self:leftHandler(_event)
    elseif _side == side.right then
        self:rightHandler(_event)
    end
end

require("bio.playerControl")

function ActionTransform:leftHandler(event)
    --[[
    if event == g_walkingType.walkLeft then
        print("ActionTransform : g_walkingType.walkLeft")
        --self._fHandler(self._tModule, side.left, g_walkingType.walkLeft)
    elseif event == g_walkingType.walkRight then
        print("ActionTransform : g_walkingType.walkRight")
        --self._fHandler(self._tModule, side.left, g_walkingType.walkRight)
    elseif event == g_walkingType.runLeft then
        print("ActionTransform : g_walkingType.runLeft")
        --self._fHandler(self._tModule, side.left, g_walkingType.runLeft)
    elseif event == g_walkingType.runRight then
        print("ActionTransform : g_walkingType.runRight")
        --self._fHandler(self._tModule, side.left, g_walkingType.runRight)
    elseif event == g_walkingType.standing then
        print("ActionTransform : g_walkingType.standing")
        --self._fHandler(self._tModule, side.left, g_walkingType.standing)
    end
    ]]
    GFPlayerLeftControl(event)
end

function ActionTransform:rightHandler(event)
    --[[
    if event == g_gestureType.click then
        print("ActionTransform : g_gestureType.click")
    elseif event == g_gestureType.left then
        print("ActionTransform : g_gestureType.left")
    elseif event == g_gestureType.right then
        print("ActionTransform : g_gestureType.right")
    elseif event == g_gestureType.up then
        print("ActionTransform : g_gestureType.up")
    elseif event == g_gestureType.down then
        print("ActionTransform : g_gestureType.down")
    end
    ]]
    GFPlayerRightControl(event)
end

return ActionTransform
