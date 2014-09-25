---
-- 技能模块，驱动人物动作和技能特效播放，执行技能与生物的碰撞
-- @module skill
-- @author 陈斌
-- @copyright usugame
-- 
require "Cocos2d"
require("skill.skillCollider")
---
-- 技能类
-- @type skill cc.Node
local skill = class("skill",function()
    return cc.Node:create()
end)
---
-- 创建并开始播放技能
-- @param bioObj 生物对象
-- @number skillId 技能ID
-- @param sceneManagement 场景管理类
-- @treturn skill obj 技能对象
function skill:create(bioObj,skillId,sceneManagement)
    local obj = skill.new(bioObj,skillId,sceneManagement)
    return obj
end


--初始化
function skill:ctor(bioObj,skillId,sceneManagement)

    self._bioObj    = bioObj
    self._skillId   = skillId
    self._sceneManagement = sceneManagement
    self._bioFaction    = bioObj:getFaction()
    self._collideData   = {}

    --保持
    self:retain()
    
    function tempUpdate()
        self:updateCollider()
    end
    self._schedulerId=  cc.Director:getInstance():getScheduler():scheduleScriptFunc(tempUpdate,0,false)
    
    
    --根据skillId读取人物arm与特效eff配置进行渲染
    
    local skillData = require("skill.skillDataConf"):getInstance()
    local effId = skillData:getEffArmatureIdBySkillId(self._skillId)
    if effId ~= -1 then
        local bioId = self._bioObj:getDynamicId()
        local direction = self._bioObj:getDirection()
        local effObj = require("skill.skillEffect"):create(self._skillId,bioId,effId,direction,self._bioFaction,self._collideData,self._sceneManagement)
        --TODO 根据方向设置不同位置
        local x,y = self._bioObj:getPosition()
        effObj:setPosition(x,y)
        local layer = self._sceneManagement:getlayer()
        if layer then
            layer:addChild(effObj)
        end
    end
end

---
--中断
function skill:interrupt()
    if self._schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerId)
    end
    self:release()
end
---
--结束
function skill:finish()
    if self._schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerId)
    end
    self:release()
end
---
--技能的事件处理,由bio类传递
--eventName string
--下一个特效开始的回调
function skill:eventHandler(bone,eventName,originFrameIndex,currentFrameIndex)
    --nextEff|id1,id2
    local eventData = FGUtilStringSplit(eventName,"|")
    if eventData[1] == "nextEff" then
        local skillList = FGUtilStringSplit(eventData[2],",")
        for i,skillIdStr in ipairs(skillList) do
            local nextEffId = tonumber(skillIdStr)
            
            local bioId = self._bioObj:getDynamicId()
            local direction = self._bioObj:getDirection()
            local effObj = require("skill.skillEffect"):create(self._skillId,bioId,nextEffId,direction,self._bioFaction,self._collideData,self._sceneManagement)
            --TODO 根据方向设置不同位置
            local x,y = self._bioObj:getPosition()
            effObj:setPosition(x,y)
            local layer = self._sceneManagement:getlayer()
            if layer then
                layer:addChild(effObj)
            end
        end
        return
    end
end


--update碰撞检测,技能释放者bio
function skill:updateCollider()
    --总是与对方阵营生物进行碰撞
    local bioList = self._sceneManagement:getBoiList()
    for k,bioObj in pairs(bioList) do
        if GFIsHostileByFaction(bioObj:getFaction(),self._bioFaction) then
            local bIsCollided = GFColliderForSkill(self,bioObj)
            if bIsCollided then
                local targetFaceDir = 1 --1=left，2＝right
                local targetMoveDir = 2
                --TODO 根据技能效果决定target移动方向
                if self._bioObj:getMainPosition() > bioObj:getMainPosition() then
                    targetFaceDir = 2
                    targetMoveDir = 1
                end
                --通知有效碰撞发生 
                self:sendCollideProt(self._bioObj:getDynamicId(),bioObj:getDynamicId(),self._skillId,targetFaceDir,targetMoveDir)
            end
        end 
    end
end

function skill:sendCollideProt(castBioId,targetObjId,skillId,targetFaceDir,targetMoveDir)
    local prot = GFProtGet(ProtBioCollision_C2S_ID)
    prot.attackerDynamicId  = castBioId
    prot.goalDynamicId      = targetObjId
    prot.skillId            = skillId
    prot.faceDirection      = targetFaceDir
    prot.moveDirection      = targetMoveDir
    GFSendOneMsg(prot)
end

--获取碰撞检测需要的技能信息
function skill:getCollideData()
    return self._collideData
end

function skill:getCollideObj()
    return self._bioObj
end

function skill:getSkillId()
    return self._skillId
end

function skill:getBioObj()
    return self._bioObj
end

return skill
