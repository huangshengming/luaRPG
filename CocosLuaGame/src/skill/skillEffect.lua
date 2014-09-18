---
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
-- @param dirction 施放方向
-- @param sceneManagement 场景管理
function skillEffect:create(skillId,bioId,effId,dirction,sceneManagement)
    local obj = skillEffect.new(skillId,bioId,effId,dirction,sceneManagement)
    
    return obj
end

---
--init
function skillEffect:ctor(skillId,bioId,effId,dirction,sceneManagement)
    self._skillId   = skillId
    self._bioId     = bioId
    self._effId     = effId
    self._dirction  = dirction
    self._sceneManagement = sceneManagement
    function tempUpdate()
        --self:updateCollider()
    end
    --self.tttempid=  cc.Director:getInstance():getScheduler():scheduleScriptFunc(tempUpdate,0,false)

    --self._sceneManagement:addOneSkill(self)
    --渲染特效
    
end

---
--特效的事件处理
--event string
function skillEffect:eventHandler(event)
    --nextEffId|id1,id2
    --skillEnd
    if event == "skillEnd" then
        --TODO
        return
    end
    local eventData = FGUtilStringSplit(event,"|")
    if eventData[1] == "nextEffId" then
        local skillList = FGUtilStringSplit(eventData[2],",")
            for i,skillIdStr in ipairs(skillList) do
                local nextSkillId = tonumber(skillIdStr)
                self:nextEffectActive()
            end
        return
    end
end

function skillEffect:nextEffectActive()
    local nextEff = skillEffect:create(self._skillId,self._bioId,self._effId,self._dirction,self._sceneManagement)
    --TODO 设置位置
end

---
--update碰撞检测
function skillEffect:updateCollider()
    --特效总是与对方阵营生物进行碰撞
    --TODO GFGetBioListInScene
    --TODO GFGetGroupOfBio(bioId)
    local myGroup = GFGetGroupOfBio(self._bioId)
    local bioList = GFGetBioListInScene()
    for k,bioData in pairs(bioList) do
        if bioData.group ~= myGroup then
            local bIsCollided = GFColliderForArmatureObjs(self,bioData)
            if bIsCollided then
                --TODO 通知有效碰撞发生 
                GFXXXXXXXX(self._bioId,bioData.bioObj,self._skillId)
            end
        end 
    end
end

function skillEffect:getCollideObj()
    return self
end

---
--获取碰撞检测需要的技能信息
function skillEffect:getSkillInfo()
    local skillInfo = {}
    skillInfo.armId         = self._effId
    return skillInfo
end

return skillEffect
