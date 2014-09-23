---
-- 碰撞检测接口模块
-- @module skill
-- @author 陈斌
-- @copyright usugame
-- 
require "Cocos2d"
local skillData = require("skill.skillDataConf"):getInstance()


function GFColliderForSkill(skillObj,targetObj)
    local castObj   = skillObj:getCollideObj()
    
    local castRectList = GFGetHitRangeList(castObj)
    local targetRectList = GFGetBeHitRangeList(targetObj)

    local collideData   = skillObj:getCollideData()
    local skillId       = skillObj:getSkillId()
    local nowTimeMS     = FGGetTickCountMS()
    local deltaTimeMS   = skillData:getHurtDeltaTime(skillId)
    local targetDyId    = targetObj:getDynamicId()

    for k,castRect in pairs(castRectList) do
        for tk,targetRect in pairs(targetRectList) do
            if cc.rectIntersectsRect(castRect,targetRect) then
                collideData[targetDyId] = collideData[targetDyId] or {}
                collideData[targetDyId].hurtTimes = collideData[targetDyId].hurtTimes or 0
                --collideData[targetDyId].lastHurtTime = collideData[targetDyId].lastHurtTime or 0
                --print("CoWTFFF__",nowTimeMS)
                if collideData[targetDyId].hurtTimes < skillData:getMaxHurtTimesBySkillId(skillId) then 
                    if collideData[targetDyId].lastHurtTime == nil or nowTimeMS - collideData[targetDyId].lastHurtTime > deltaTimeMS then
                        collideData[targetDyId].lastHurtTime = nowTimeMS
                        collideData[targetDyId].hurtTimes = collideData[targetDyId].hurtTimes +1
                        --print("WTF___skillCollided!!!!__",skillId,targetDyId)
                        return true
                    end
                end
            end
        end
    end
    return false
end

--[[
function GFColliderForRect(rectA,rectB)
    return cc.rectIntersectsRect(rectA,rectB)
end
]]
