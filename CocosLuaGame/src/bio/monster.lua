-- 普通怪物模块
-- @module monster
-- @author sxm
-- @copyright usugame

require "Cocos2d"
require("armatureRender.armatureDraw")

-- 获得AI相关类
-- @type aiClass
local aiClass = require("bio.aiFSMachine")

-- AI相关类
-- @type aiState
-- @type FSMachine
local aiState, FSMachine = aiClass[1], aiClass[2]


-- 怪物待机状态类
-- @type mstrIdleState aiState
local mstrIdleState = class("mstrIdleState", aiState)

-- 怪物激活状态类
-- @type mstrActivateState aiState
local mstrActivateState = class("mstrActivateState", aiState)

-- 怪物待机状态创建实例函数
-- @param stateType 状态类型
-- @return s 状态实例
function mstrIdleState:create(stateType)
    local s = mstrIdleState.new(stateType)
    return s
end

-- 怪物待机状态初始化回调函数
-- @param stateType 状态类型
function mstrIdleState:ctor(stateType)
    self.super.ctor(self, stateType)
end

-- 怪物待机状态进入回调函数
-- @param owner 状态拥有者
function mstrIdleState:onEnter(owner)
    --开始计算前置反映时间
    if owner.state ~= g_bioStateType.standing then
        owner:enterNextState(g_bioStateType.standing)
    end
    owner._preActivatecd = owner._preActivateDeltaTime
end

-- 怪物待机状态退出回调函数
-- @param owner 状态拥有者
function mstrIdleState:onExit(owner)
    
end

-- 怪物待机状态执行回调函数
-- @param owner 状态拥有者
function mstrIdleState:execute(owner)
    local target = owner:getAttackTarget()
    local targetX = target:getPositionX()
    local myPosX = owner:getPositionX()
    local dx = myPosX - targetX

    if math.abs(dx) <= owner._safeDist then
        owner._bLaunchPreActivateTimer = true
    end

end

-- 怪物待机状态计时任务回调函数
-- @param owner 状态拥有者
-- @param dt 帧时差
function mstrIdleState:timeTaskLoop(owner, dt)
    if owner._bLaunchPreActivateTimer == true and owner._preActivatecd > 0 then
        owner._preActivatecd = owner._preActivatecd - dt
        print("sxcLog: AI激活倒计时", owner._preActivatecd)
        if owner._preActivatecd <= 0 then
            local target = owner:getAttackTarget()
            local targetX = target:getPositionX()
            local myPosX = owner:getPositionX()
            local dx = myPosX - targetX
            if math.abs(dx) <= owner._safeDist then
                owner:getFSM():changeState(mstrActivateState:create(g_aiStateType.activate))
            end
            owner._bLaunchPreActivateTimer = false
            owner._preActivatecd = owner._preActivateDeltaTime
        end
    end
end

-- 怪物待机状态消息处理回调函数
-- @param owner 状态拥有者
-- @param msg 消息枚举
function mstrIdleState:onMessage(owner, msg)
    if msg == g_aiMessage.afterBeingHit then
        owner._bLaunchPreActivateTimer = false
        owner:getFSM():changeState(mstrActivateState:create(g_aiStateType.activate))
    end
end

-- 怪物激活状态创建实例函数
-- @param stateType 状态类型
-- @return s 状态实例
function mstrActivateState:create(stateType)
    local s = mstrActivateState.new(stateType)
    return s
end

-- 怪物激活状态初始化回调函数
-- @param stateType 状态类型
function mstrActivateState:ctor(stateType)
    self.super.ctor(self, stateType)
end

-- 怪物激活状态进入回调函数
-- @param owner 状态拥有者
function mstrActivateState:onEnter(owner)
    owner._bActive = true
    owner:beginPreAtkCD()
    if owner.state ~= g_bioStateType.walking then
        owner:enterNextState(g_bioStateType.walking)
    end
end

-- 怪物激活状态退出回调函数
-- @param owner 状态拥有者
function mstrActivateState:onExit(owner)
    
end

-- 怪物激活状态计时任务回调函数
-- @param owner 状态拥有者
-- @param dt 帧时差
function mstrActivateState:timeTaskLoop(owner, dt)
    if owner._atkcd > 0 then
        owner._atkcd = owner._atkcd - dt
    end

    if owner._patrolcd > 0 then
        owner._patrolcd = owner._patrolcd - dt
    end

    if owner._bLaunchResponseTimer == true then
        if owner._responsecd > 0 then
            print("sxcLog: AI攻击反映倒计时", owner._responsecd)
            owner._responsecd = owner._responsecd - dt
            if owner._responsecd <= 0 then
                owner._bLaunchResponseTimer = false
                owner:runSelectedSkillBar()
            end
        end
    end
end

-- 怪物激活状态执行回调函数
-- @param owner 状态拥有者
function mstrActivateState:execute(owner)
    owner:tryAttack()
    owner:patrol()
end

-- 怪物激活状态消息处理回调函数
-- @param owner 状态拥有者
-- @param msg 消息枚举
function mstrActivateState:onMessage(owner, msg)
    if msg == g_aiMessage.atkEnd then
        owner:enterNextState(g_bioStateType.walking)
    elseif msg == g_aiMessage.afterStanding then
        owner:enterNextState(g_bioStateType.walking)
    end
end

-- 获取生物类
-- @type bioClass
local bioClass = require("bio.bio")

-- 怪物类
-- @type monster bio
local monster = class("monster", bioClass)

-- 怪物类创建实例函数
-- @param dyId 动态id
-- @param staticId 静态id
-- @param name 名字
-- @param faction 阵营
-- @param x x坐标
-- @param y y坐标
-- @param armatureResId 动画资源id
-- @return mstr 怪物实例
function monster:create(dyId,staticId,name,faction,x,y,armatureResId)
    local mstr = monster.new(dyId,staticId,name,faction,x,y,armatureResId)
    return mstr
end

-- 怪物数据初始化
-- @param dyId 动态id
-- @param staticId 静态id
-- @param name 名字
-- @param faction 阵营
-- @param x x坐标
-- @param y y坐标
-- @param armatureResId 动画资源id
-- @param aiId ai数据id
function monster:ctor(dyId,staticId,name,faction,x,y,armatureResId, aiId)
    self.super.ctor(self,dyId,staticId,name,faction,x,y,armatureResId)
    self.speedWalkVx = self.speedWalkVx / 6
    self._aiId = aiId -- ai数据id
    self._aiId = 1 --临时调试代码
    self._safeDist = self:getMonsterAIDataByFieldName("safeDistance") --警戒距离
    self._atkdt = self:getMonsterAIDataByFieldName("atkDeltaTime") --攻击间隔
    self._precd = self:getMonsterAIDataByFieldName("preAtkTime") --前置攻击时间
    self._atkcd = 0 --攻击cd计算
    self._patrolRadius = 200 --巡逻半径
    self._crossChance = 0.5 --穿过玩家的概率
    self._responseTime = self:getMonsterAIDataByFieldName("responseTime") --怪物攻击反映时间
    self._responsecd = 0 --攻击反映时间cd计算
    self._preActivateDeltaTime = self:getMonsterAIDataByFieldName("preActivateTime") --激活前置时间
    self._preActivatecd = 0
    self._patrolcd = 0
    self._patrolDeltaTime = self:getMonsterAIDataByFieldName("patrolDeltaTime")
    self._gestureIndex = nil
    self._bActive = false
    self._bornCoodX = x
    self._bornCoodY = y
    self._bLaunchResponseTimer = false
    self._fsm = FSMachine:create(self)
    self:getFSM():changeState(mstrIdleState:create(g_aiStateType.idle))

    --兼容demoA的AI
    self._atkDis = 100
    self._atkChance = 0.7
    self._canChangeDir = true
end

-- 获得怪物的状态机
-- @return self._fsm 怪物的状态机
function monster:getFSM()
	return self._fsm
end

-- 怪物攻击cd是否好了
-- @return true 怪物攻击cd冷却好了
-- @return false 怪物攻击cd还在冷却中
function monster:isAtkCoolDown()
    return self._atkcd <= 0
end

-- 开始怪物攻击前置时间计时
function monster:beginPreAtkCD()
    self._atkcd = self._precd
end

-- 怪物ai执行回调函数
-- @param dt 帧时差
function monster:aiExecute(dt)
    if self:getFSM() ~= nil then
        self:getFSM():step(dt)
    end
end

-- 从技能配置表获取怪物技能数据
-- @param skillId 技能id
-- @param fieldName 字段名
-- @param skill[fieldName] 字段名对应的数据
function monster:getSkillDataById(skillId, fieldName)
    local skill = g_tSkillData[skillId]
    return skill[fieldName]
end

-- 从ai配置表中获取数据
-- @param fieldName 字段名
-- @return monsterAI[fieldName] 返回对应字段的数据
function monster:getMonsterAIDataByFieldName(fieldName)
    local monsterAI = g_tMonsterAI[self._aiId]
    return monsterAI[fieldName]
end

-- 怪物攻击尝试
function monster:tryAttack()

    if self.state == g_bioStateType.walking and self._atkcd <= 0 then
        --walking下
        --1，获取目标
        --2，根据目标距离筛选手势
        --3，根据手势随机权重选定一个手势
        --4，选定手势根据概率随机发动手势
        --5，手势发动后无论成功失败攻击尝试进入cd
        --6，如果手势发动成功，开始启动反映计时
        --7，反映计时结束，再次判断目标距离和手势对应技能发动距离
        --8，如果7成立，则真正开始放技手势对应的技能
        local target = self:getAttackTarget()
        local targetPosX = target:getPositionX()
        local myPosX = self:getPositionX()
        local dx = math.abs(targetPosX - myPosX)
        local aiGestureDatas = self:getMonsterAIDataByFieldName("gestureData")
        local tempGestureIndices = {}
        local totalWeight = 0
        for i, v in ipairs(aiGestureDatas) do
            local gestureData = v
            local gestureName = gestureData[1]
            local gestureWeight = gestureData[2]
            local skills = self.skillBar[g_attackOrderType[gestureName]]
            local skillId = skills[1]
            local atkDis = self:getSkillDataById(skillId, "atkDis")
            if atkDis >= dx then
                table.insert(tempGestureIndices, i)
                totalWeight = totalWeight + gestureWeight
            end
        end
        
        if #tempGestureIndices > 0 then
            local rnd = FGRandom(totalWeight)
            print(string.format("sxcLog: totalWeight = %d, rnd = %d", totalWeight, rnd))
            self._gestureIndex = nil
            for i, v in ipairs(tempGestureIndices) do
                local gestureData = aiGestureDatas[v]
                local gestureWeight = gestureData[2]
                rnd = rnd - gestureWeight
                if rnd <= 0 then
                    self._gestureIndex = v; break
                end
            end

            if self._gestureIndex ~= nil then
                local skillData = aiGestureDatas[self._gestureIndex]
                local chance = skillData[3]
                local rnd = FGRandom_0_1()
                print(string.format("sxcLog: rnd = %f, chance = %f", rnd, chance))
                if rnd <= chance then
                    self._bLaunchResponseTimer = true
                    self._responsecd = self._responseTime
                end
            end
        end

        self._atkcd = self._atkdt
    elseif self.state == g_bioStateType.attacking then
        --attcking下
        --1，判断是否是普攻(新规则无效跳过)
        --2，判断是否是当前手势最后一招
        --3，不是最后一招，看看下一招是否已经加入指令队列
        --4，如果指令队列不存在，则判定下一招范围内是否有敌方目标，
        --5，4成立，判定本招发动概率
        --6，5成立则输入普攻指令
        local nextSkillIndex = self.skillBatterCount + 1
        local aiGestureDatas = self:getMonsterAIDataByFieldName("gestureData")
        local gestureData = aiGestureDatas[self._gestureIndex]
        local gestureName = gestureData[1]
        local skills = self.skillBar[g_attackOrderType[gestureName]]
        local skillId = skills[nextSkillIndex]
        local myPosX = self:getPositionX()
        if skillId ~= nil and #self.attackOrderQue == 0 then
            local skillAtkDis = self:getSkillDataById(skillId, "AtkDis")
            --遍历敌对目标队列，查看是否有目标在攻击范围内
            --一旦发现目标，根据连击概率设定将下一招输入攻击指令
            local enemys = self.sceneManagement:getEnemyList(self)
            local bFindTarget = false
            local dir = nil
            for i, v in ipairs(enemys) do
                local enemyX = v:getPositionX()
                local dx = enemyX - myPosX
                if skillAtkDis >= math.abs(dx) then
                    if dx > 0 then
                        dir = g_bioDirectionType.right
                    elseif dx <= 0 then
                        dir = g_bioDirectionType.left
                    end
                    break
                end
            end
            local rnd = FGRandom_0_1()
            local caromChances = self:getMonsterAIDataByFieldName("caromChance")
            local skillCaromChance = caromChances[self._gestureIndex]
            local chance = skillCaromChance[nextSkillIndex-1]
            if bFindTarget == true and rnd < chance then
                self:inputAttackOrder(g_attackOrderType[gestureName], dir)
            end
        end
    end
    
end

-- 怪物获取仇恨目标函数
-- @return target 仇恨目标对象
function monster:getAttackTarget()
    local target = g_playerObj
    return target
end


function monster:patrol()
    -- body
    if self.state ~= g_bioStateType.walking or self._patrolcd > 0 then
        return
    end

    local target = self:getAttackTarget()
    local targetDir = target:getDirection()
    local targetPosX = target:getPositionX()
    local myDir = self:getDirection()
    local myPosX = self:getPositionX()
    local dx = targetPosX - myPosX

    local I2Border = {math.abs(myPosX - self.sceneManagement:GetNearBgXLeft()), 
                    math.abs(myPosX - self.sceneManagement:GetNearBgXRight())}

    local max = 300
    local min = 0
    if math.abs(dx) > max then
        if dx > 0 then -- 目标在右边
            self:setDirection(g_bioDirectionType.right)
        elseif dx < 0 then -- 目标在左边
            self:setDirection(g_bioDirectionType.left)
        end
    elseif math.abs(dx) > 0 and math.abs(dx) < min then
        if dx > 0 then -- 目标在右边
            if self:getDirection() == g_bioDirectionType.left then

            elseif self:getDirection() == g_bioDirectionType.right then
                self:setDirection(g_bioDirectionType.left)
            end
        elseif dx < 0 then -- 目标在左边
            if self:getDirection() == g_bioDirectionType.left then
                self:setDirection(g_bioDirectionType.right)
            elseif self:getDirection() == g_bioDirectionType.right then

            end
        end
    end

    self._patrolcd = self._patrolDeltaTime
end

-- 执行已经选中的技能
function monster:runSelectedSkillBar()
    -- 1 ,再次判断目标与怪物的距离是否在攻击范围内
    -- 2, 1成立释放， 不成立不释放
    local target = self:getAttackTarget()
    local targetPosX = target:getPositionX()
    local myPosX = self:getPositionX()
    local dx = targetPosX - myPosX
    --等待释放技能接口
    local aiGestureDatas = self:getMonsterAIDataByFieldName("gestureData")
    local gestureData = aiGestureDatas[self._gestureIndex]
    local gestureName = gestureData[1]
    local skills = self.skillBar[g_attackOrderType[gestureName]]
    local skillId = skills[1]
    local atkDis = self:getSkillDataById(skillId, "atkDis")
    if math.abs(dx) <= atkDis then
        if dx > 0 then
            self:inputAttackOrder(g_attackOrderType[gestureName], g_bioDirectionType.right)
        elseif dx <= 0 then
            self:inputAttackOrder(g_attackOrderType[gestureName], g_bioDirectionType.left)
        end
    end
end

-- 怪物状态转换函数
-- @param state 目标状态
-- @param skillId 技能id
-- @return true 成功
-- @return false 失败
function monster:enterNextState(state,skillId)
    local ret = self.super.enterNextState(self, state, skillId)
    if (state == g_bioStateType.beHit or state == g_bioStateType.beStrikeFly) 
        and ret == true then
         self:getFSM():handleMessage(g_aiMessage.afterBeingHit)
    elseif state == g_bioStateType.standing and ret == true then
        self:getFSM():handleMessage(g_aiMessage.afterStanding)
    end
    return ret
end

return monster
