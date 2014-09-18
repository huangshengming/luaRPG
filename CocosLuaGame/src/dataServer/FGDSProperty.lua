---
-- 生物类 相关属性 方法
-- @submoudle dataServer
-- @author 张微
-- @copyright usugame

require "Cocos2d"

---
-- 生物类 
-- @type BioProperty Node
local BioProperty = class("BioProperty",function()
	return cc.Node:create()
end)

function BioProperty:create()
 
    BioProperty = BioProperty.new()
    BioProperty:retain()

    return BioProperty
end


function BioProperty:ctor()

    self.x = -1
    self.y = -1
    self.schedulerID = nil

    local function onNodeEvent(event)
        if "cleanup" == event then
        end
    end
    self:registerScriptHandler(onNodeEvent)

    --注册 生物相关通信 接收协议
    GFSendAddListioner(self)
end


---
-- 生物类 C2S 接收协议的处理
-- @param prot 协议
-- @treturn bool bool 是否处理此协议
function BioProperty:sendMessageProc(prot)
    print("got send prot2 ",prot.protId)

    if prot.protId == 900100 then
        print("got scene request2     ",prot.protId)


        return true 
    end
    
    return false
end


--相关属性管理操作方法

--相关属性初始化
function BioProperty:init(pdata)
    self.x = pdata.positionX
    self.y = pdata.positionY
    self.mp = pdata.mp
    self.hp = pdata.hp
    self.staticId = pdata.staticId
    self.dynamicId = pdata.dynamicId
    self.lead = pdata.lead
    self.status = pdata.status
    self.hardStraight = pdata.hardStraight
    self.schedulerID = nil
    self.hs = {}
    self.tickTime = nil
    --是否攻击豁免状态
    self.invincible = false
    
    --硬直初始化
    local hsId 
    hsId,self.statusType = self:getHSByStatus(self.status)
    self:initHS(hsId)
    
end

--设置 获取坐标
function BioProperty:setPosition(x,y)
    self.x = x
    self.y = y
end

function BioProperty:getPosition()
    return self.x,self.y
end

--设置 获取 当前状态
--bySelf true 内部逻辑状态转变 false C2S 
function BioProperty:setStatus(status,bySelf)
    self:statusChange(self.status,status,bySelf)

--	self.status = status
end
	
function BioProperty:getStatus()
	return self.status
end

--设置 获取 血量
function BioProperty:setHp(hp)
	self.hp = hp
end

function BioProperty:getHp()
	return self.hp
end

--设置 获取 魔量
function BioProperty:setMp(mp)
	self.mp = mp
end

function BioProperty:getMp()
	return self.mp
end
	


--状态转变
--根据当前状态类型 及相关条件 判断下一个状态
function BioProperty:judgeNextStatus(sType,hsMax,defensee,zero)
	local nextStatus = nil
	if sType == 1 then
	   if hsMax then
            nextStatus = g_bioStateType.beStrikeFly
	   elseif not hsMax and defense then
	       if self.status ~= g_bioStateType.beHit then
                nextStatus = g_bioStateType.beHit
	       end
	   elseif not hsMax and not defensee and zero then
	       if self.status == g_bioStateType.beHit then
                nextStatus = g_bioStateType.standing
	       end
	   end
	elseif sType == 2 then 
        nextStatus = g_bioStateType.beStrikeFly
	elseif sType == 3 then
        nextStatus = g_bioStateType.beStrikeFly
	elseif sType == 4 then
        nextStatus = g_bioStateType.lyingFly
	end
    
    return nextStatus
end 


--当前状态 下一个状态 相关逻辑处理
function BioProperty:statusChange(currentS,nextS,bySelf)
    print("fy-- 状态转换 ",currentS,nextS,bySelf)
	--状态机 根据当前和下一个状态 处理相关逻辑
	if currentS == nextS then 
	   if currentS == g_bioStateType.beStrikeFly then
            --浮空->浮空 进入豁免无敌状态
	       self.invincible = true
	   end   
	else
        local hsId,hsType = self:getHSByStatus(nextS)
        
        if hsType == self.statusType then
            --前后状态为同一种硬直状态
            if self.statusType == 1 then
                if currentS == g_bioStateType.beHit or nextS == g_bioStateType.beHit then
                    --S2C
                    if bySelf then
                        self:sendStatus(nextS)
                    end
                end
            elseif self.statusType == 4 then
                if nextS == g_bioStateType.lyingFly then
                    --豁免
                    self.invincible = true
                    --S2C
                    if bySelf then
                        self:sendStatus(nextS)
                    end
                end
            end
        else
            --前后状态为不同硬直状态 则需要切换硬直
            --[[
            if self.statusType == 1 then 
            self.invincible = false
            self:initHS(hsId)
            --S2C
            if bySelf then
            self:sendStatus(nextS)
                end
            elseif self.statusType == 2 then
                self.invincible = false
                self:initHS(hsId)
                --S2C
                if bySelf then
                    self:sendStatus(nextS)
                end
            elseif self.statusType == 3 then
                self.invincible = false
                self:initHS(hsId)
                --S2C
                if bySelf then
                    self:sendStatus(nextS)
                end
            elseif self.statusType == 4 then
                self.invincible = false
                self:initHS(hsId)
                --S2C
                if bySelf then
                    self:sendStatus(nextS)
                end
            end
            ]]
            self.invincible = false
            self.statusType = hsType
            self:initHS(hsId)
            
            --S2C
            if bySelf then
                self:sendStatus(nextS)
            end
        end
	end
	
	self.status = nextS
end

--死亡状态处理
function BioProperty:deathHandle()
    self.status = g_bioStateType.death
    self:sendStatus(self.status)
    
    --通知管理类 删除对象
    local manage = require("dataServer.FGDSManage"):getInstance()
    manage:removeByDynamicId(self.dynamicId)
    self:removeInstance()
end

--碰撞检测 技能
--攻击时相关处理 技能CD 魔法消耗 连击等
function BioProperty:attackHandle(skillId)
	
	
end

--受击时相关处理 硬直计算 伤害计算 状态判断
function BioProperty:goalHandle(skillId)
    if not g_tSkillData[skillId] then return end
    
    --是否攻击豁免状态
    if self.invincible then print("fy-- 攻击豁免") return end  
        
    local nowHp = self.hp - g_tSkillData[skillId].damage
    if nowHp <= 0 then 
        nowHp = 0 
        --设置状态为死亡
        self:deathHandle()
    else
        self.hs.current = self.hs.current + g_tSkillData[skillId].hardStraightness
    end
    
    
    self:setHp(nowHp)
    self:sendDamage(g_tSkillData[skillId].damage,0,skillId)
    
end

--请求释放技能 判断CD 魔 状态 是否可以释放
function BioProperty:castSkill(skillId)
	
end


--硬直相关
--根据状态 获取 对应的硬直种类 目前对应self.hardStraight 再对应到g_tHardStraight硬直属性
function BioProperty:getHSByStatus(status)
    for i,v in pairs(g_tStatusHardStraight or {}) do
	   for p,q in pairs(v) do 
	       if q == status then
	           if self.hardStraight[i] then
                    return self.hardStraight[i],i
                end
	       end
	   end
	end
	
	return 1,1
end

--切换硬直调用 新硬直数值初始化 计时器
function BioProperty:initHS(hsId)
    print("fy-- hs change")
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
    end
    
	if not g_tHardStraight[hsId] then 
       self.hs = {}
	   return 
	end 
	
	--若转换为倒地 倒地硬直由上一个状态 按百分比转换而来 低于80%
    local percentage = 0
	if self.statusType == 4 then
        percentage = self.hs.current/self.hs.maxhs
    end
	
	self.hs = {}
    self.hs.maxhs = g_tHardStraight[hsId].max
    self.hs.a = g_tHardStraight[hsId].a
    self.hs.defense = g_tHardStraight[hsId].defense
    if self.statusType == 4 then
        if percentage <= 0.8 then
            self.hs.current = self.hs.maxhs * percentage
        else
            self.hs.current = self.hs.maxhs * 0.8
        end
    else
        self.hs.current = 0
    end

    
    local function tick()
        if self.tickTime == nil then
            self.tickTime = FGGetTickCountMS()
        end
       self:loop()
    end

    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
	
end

--硬直loop
function BioProperty:loop()
    local t = FGGetTickCountMS()
--    print("fy-- hs tick0 ",t)
--    print("fy-- hs tick1 ",self.hs.current)
    if self.hs.current > 0 then
        self.hs.current = self.hs.current + (self.hs.a)*(t-self.tickTime)
    end
    if self.hs.current <= 0 then
        self.hs.current = 0
        -- 硬直衰减为0  当是受击状态时 转换为站立状态
        if self.status == g_bioStateType.beHit then
            local nextS = self:judgeNextStatus(self.statusType,false,false,true)
            if nextS then
                self:setStatus(nextS,true)
            end
        end
    end 
    if self.hs.current > self.hs.defense and self.hs.current < self.hs.maxhs then
        --硬直 超出防御值 当站立相关状态 进入受击状态
        if self.statusType == 1 then
             local nextS = self:judgeNextStatus(self.statusType,false,true,false)
             if nextS then
                self:setStatus(nextS,true)
             end
        end
    end
    if self.hs.current >= self.hs.maxhs then
        --硬直满 则判断当前状态->下一个状态
        local nextS = self:judgeNextStatus(self.statusType,true,false,false)
        if nextS then
            self:setStatus(nextS,true)
        end
    end
    
    self.tickTime = t
--    print("fy-- hs tick2 ",self.hs.current)
end


--S2C相关
--notice status
function BioProperty:sendStatus(status)
    local prot = GFProtGet(ProBioStatusChange_S2C_ID)
    prot.dynamicId = self.dynamicId
    prot.status = status
    GFRecOneMsg(prot)
    print("fy-- S2C状态变化",status)
end

--damage
function BioProperty:sendDamage(damage,dType,skillId)
    local prot = GFProtGet(ProtBioDamage_S2C_ID)
    prot.dynamicId = self.dynamicId
    prot.damage = damage
    prot.dType = dType
    prot.skillId = skillId
    GFRecOneMsg(prot)
    print("fy-- S2C伤害变化",damage)
end


--删除对象
function BioProperty:removeInstance()
	
	if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
    end
    
    self:release()
end


return BioProperty