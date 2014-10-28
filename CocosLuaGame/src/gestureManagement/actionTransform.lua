-- 动作转换模块
-- @module ActionTransform
-- @author sxm
-- @copyright usugame

require("Cocos2d")

-- 边界枚举表
-- @table side
-- @param left 左边
-- @param right 右边
local side = {
    left = 1,
    right = 2
}

-- 动作转换单例
local ActionTransform_shared_instance = nil

-- 动作转换类
-- @type ActionTransform
local ActionTransform = class("ActionTransform")

-- 获取动作转换单例
-- @return ActionTransform_shared_instance 动作转换单例
function ActionTransform:getInstance()
    if ActionTransform_shared_instance == nil then
        ActionTransform_shared_instance = ActionTransform.new()
    end
    return ActionTransform_shared_instance
end

-- 设置动作转换回调模块和回调函数
-- @param _module 模块
-- @param _handler 回调函数
function ActionTransform:setHandler(_module, _handler)
	self._tModule = _module
	self._fHandler = _handler
end

-- 动作转换初始化回调
function ActionTransform:ctor()
    local gestureMgr = require("gestureManagement.gestureManagement"):getInstance()
    gestureMgr:setHandler(self, self.handler)
end

-- 动作转换消息处理
-- @param _side 边界枚举
-- @param _event 事件枚举
function ActionTransform:handler(_side, _event)
    if _side == side.left then
        self:leftHandler(_event)
    elseif _side == side.right then
        self:rightHandler(_event)
    end
end

require("bio.playerControl")

-- 左边界事件处理函数
-- @param event 事件枚举
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

-- 右边界事件处理函数
-- @param event 事件枚举
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
