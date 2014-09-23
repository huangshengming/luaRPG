
-- 技能特效类
-- @module skill
-- @author 陈斌
-- @copyright usugame
-- 
require "Cocos2d"
require("armatureRender.armatureDraw")
require("skill.skillCollider")
---
-- 技能特效类
-- @type skillEffect ccs.Armature
local skillEffect = class("skillEffect",function()
    return ccs.Armature:create()
end)
---
--创建特效，
-- @number skillId 技能Id
-- @number bioId 技能释放者动态Id
-- @number effId 特效Id
-- @param direction 施放方向
-- @param sceneManagement 场景管理类
function skillEffect:create(skillId,bioId,effId,direction,bioFaction,collideData,sceneManagement)
    local obj = skillEffect.new(skillId,bioId,effId,direction,bioFaction,collideData,sceneManagement)
    
    return obj
end


--init
function skillEffect:ctor(skillId,bioId,effId,direction,bioFaction,collideData,sceneManagement)
    self._skillId   = skillId
    self._bioId     = bioId
    self._effId     = effId
    self._direction = direction
    self._bioFaction = bioFaction
    self._collideData   = collideData
    self._sceneManagement = sceneManagement
    function tempUpdate()
        self:updateCollider()
    end
    self._schedulerId=  cc.Director:getInstance():getScheduler():scheduleScriptFunc(tempUpdate,0,false)

    --渲染特效
    GFPlayEffect(self,effId)
    
    if self._direction == g_bioDirectionType.left then
        self:setFlipX(true)
    end    
    
    
    --设置监听
    local function tempMovementEvent(effObj,movementType,movementId)
        self:onAnimationMovementEvent(effObj,movementType,movementId)
    end
    local function tempBoneFrameEvent(bone,eventName,originFrameIndex,currentFrameIndex)
        self:onBoneFrameEvent(bone,eventName,originFrameIndex,currentFrameIndex)
    end

    self:getAnimation():setMovementEventCallFunc(tempMovementEvent)
    self:getAnimation():setFrameEventCallFunc(tempBoneFrameEvent)
    
    
    local function onNodeEvent(event)
        if "cleanup" == event then --销毁回调
            if self._schedulerId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerId)
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
end


--整体动画回调
--@param effObj 所属者
--@param movementType 1-非循环动画播放结束,2-循环动画每次动画播放结束
--@param movementId 动画标识str
function skillEffect:onAnimationMovementEvent(effObj,movementType,movementId)
    if movementType==1 then
        local function timingEnter()
            if self._onceSchedulerId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._onceSchedulerId)
            end
            self:removeFromParent()
        end
        self._onceSchedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timingEnter, 0, false)
        
    end
end


--特效的事件处理
--eventName string
function skillEffect:onBoneFrameEvent(bone,eventName,originFrameIndex,currentFrameIndex)
    --nextEff|id1,id2
    --skillEnd
    if eventName == "skillEnd" then
        --TODO
        return
    end
    local eventData = FGUtilStringSplit(eventName,"|")
    if eventData[1] == "nextEff" then
        local skillList = FGUtilStringSplit(eventData[2],",")
            for i,skillIdStr in ipairs(skillList) do
                local nextEffId = tonumber(skillIdStr)
                self:nextEffectActive(nextEffId)
            end
        return
    end
end

function skillEffect:nextEffectActive(nextEffId)
    local nextEff = skillEffect:create(self._skillId,self._bioId,nextEffId,self._direction,self._bioFaction,self._collideData,self._sceneManagement)

    --TODO 根据方向设置不同位置
    local x,y = self:getPosition()
    nextEff:setPosition(x,y)
    local layer = sceneManagement:getlayer()
    if layer then
        layer:addChild(effObj)
    end
end


--update碰撞检测
function skillEffect:updateCollider()
    --特效总是与对方阵营生物进行碰撞
    local bioList = self._sceneManagement:getBoiList()
    for k,bioObj in pairs(bioList) do
        if GFIsHostileByFaction(bioObj:getFaction(),self._bioFaction) then
            local bIsCollided = GFColliderForSkill(self,bioObj)
            if bIsCollided then
                --通知有效碰撞发生 
                self:sendCollideProt(self._bioId,bioObj:getDynamicId(),self._skillId)
            end
        end 
    end
end

function skillEffect:getCollideObj()
    return self
end

function skillEffect:sendCollideProt(castBioId,targetObjId,skillId)
    local prot = GFProtGet(ProtBioCollision_C2S_ID)
    prot.attackerDynamicId  = castBioId
    prot.goalDynamicId      = targetObjId
    prot.skillId            = skillId
    GFSendOneMsg(prot)
end

--获取碰撞检测需要的技能信息
function skillEffect:getCollideData()
    return self._collideData
end
function skillEffect:getSkillId()
    return self._skillId
end


function skillEffect:setFlipX(bFlipX)
    if bFlipX then
        if self:getScaleX()>0 then
            self:setScaleX(self:getScaleX()*-1)
        end
    else
        if self:getScaleX()<0 then
            self:setScaleX(self:getScaleX()*-1)
        end 
    end
end

return skillEffect
