-- AI有限状态机模块
-- @module aiFSMachine
-- @author sxm
-- @copyright usugame


-- 状态基类
-- @type aiState
local aiState = class("aiState")


-- 创建一个基本的状态实例
-- @param stateType 状态类型
-- @return state 状态实例
-- @usage local s = aiState:create(g_aiStateType.default)
-- function aiState:craete(stateType)
function aiState:craete(stateType)
    local state = aiState.new(stateType)
    return state
end

-- 初始化状态数据
-- @param stateType 状态类型
function aiState:ctor(stateType)
    self:init(stateType)
end

-- 初始化状态数据
-- @param stateType 状态类型
function aiState:init(stateType)
    self._stateType = stateType
end

-- 获取状态类型
-- @return stateType 状态类型
function aiState:getType()
    return stateType
end

-- 进入状态回调
-- @param owner 状态拥有者
function aiState:onEnter(owner)

end

-- 退出状态回调
-- @param owner 状态拥有者
function aiState:onExit(owner)

end

-- 状态执行回调
-- @param owner 状态拥有者
function aiState:execute(owner)

end

-- 状态计时任务回调
-- @param owner 状态拥有者
-- @param dt 帧时差
function aiState:timeTaskLoop(owner, dt)

end

-- 状态消息处理回调
-- @param owner 状态拥有者
-- @param msg 消息枚举
function aiState:onMessage(owner, msg)

end


-- AI有限状态机
-- @type FSMachine
local FSMachine = class("FSMachine")

-- 创建一个有限状态机实例
-- @param owner 状态机拥有者
-- @return fsm 状态机实例
function FSMachine:create(owner)
	local fsm = FSMachine.new(owner)
	return fsm
end

-- 状态机机数据初始化回调
-- @param owner 状态机拥有者
function FSMachine:ctor(owner)
    self:init(owner)
end


-- 状态机数据初始化函数
-- @param owner 状态机拥有者
function FSMachine:init(owner)
    self._owner = owner
    self._curState = aiState:new(g_aiStateType.default)
    self._preState = aiState:new(g_aiStateType.default)
end

-- 状态切换
-- @param newState 新状态实例
function FSMachine:changeState(newState)
    self._preState = self._curState
    self._preState:onExit(self._owner)
    self._curState = newState
    self._curState:onEnter(self._owner)
end

-- 状态机帧回调函数
-- @param dt 帧时差
function FSMachine:step(dt)
    self._curState:timeTaskLoop(self._owner, dt)
    self._curState:execute(self._owner)
end

-- 返回到前一个状态
function FSMachine:revert2PreState()
    self:changeState(self._preState)
end

-- 判断当前状态类型
-- @param stateType 状态类型
function FSMachine:isInState(stateType)
    return self._curState:getType() == stateType 
end

-- 处理消息函数
-- @param msg 消息枚举
function FSMachine:handleMessage(msg)
    self._curState:onMessage(self._owner, msg)
end

return {aiState, FSMachine}
