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
-- @param sceneManagement 场景管理
-- @treturn skill obj 技能对象
function skill:create(bioObj,skillId,sceneManagement)
    local obj = skill.new(bioObj,skillId,sceneManagement)
    return obj
end

---
--初始化
function skill:ctor(bioObj,skillId,sceneManagement)
    self._bioObj    = bioObj
    self._skillId   = skillId
    self._sceneManagement = sceneManagement
    
    --self._sceneManagement:addOneSkill(self)
    
    function tempUpdate()
        --self:updateCollider()
    end
    --self.tttempid=  cc.Director:getInstance():getScheduler():scheduleScriptFunc(tempUpdate,0,false)
    
    
    --根据skillId读取人物arm与特效eff配置进行渲染
    
    local skillData = require("skill.skillDataConf"):getInstance()
    --print("WTF____skillData",skillData:getBioArmatureIdBySkillId(1),skillData:getEffArmatureIdBySkillId(1),skillData:getMaxHurtTimesBySkillId(1))
    
    --TODO
    self._bioArmId = skillData:getBioArmatureIdBySkillId(skillId)
    --bioObj:palyAct
    
    local effId = skillData:getEffArmatureIdBySkillId(skillId)
    --TODO 通过bioObj来get
    local bioId = nil
    local dirction = nil
    --local effObj = require(skill.skillEffect):create(skillId,bioId,effId,dirction,sceneManagement)
    --TODO 设置位置
end

---
--中断
function skill:interrupt()
    --self._sceneManagement:removeOneSkill(self)
end
---
--结束
function skill:finish()
    --self._sceneManagement:removeOneSkill(self)
end
---
--技能的事件处理
--event string
--下一个特效开始的回调
function skill:eventHandler(event)
    --nextEffId|id1,id2
end

---
--update碰撞检测,技能释放者bio
function skill:updateCollider()
    --总是与对方阵营生物进行碰撞
    --TODO GFGetBioListInScene
    --TODO GFGetGroupOfBio(bioId)
    --TODO bioObj:getAutoId()
    local myGroup = GFGetGroupOfBio(self._bioObj:getAutoId())
    local bioList = GFGetBioListInScene()
    --TODO bioList bioData
    for bioData in pairs(bioList) do
        if bioData.group ~= myGroup then
            local bIsCollided = GFColliderForArmatureObjs(self,bioData)
            if bIsCollided then
                --TODO 通知有效碰撞发生 
                GFXXXXXXXX(self.bioObj:getAutoId(),bioData.bioObj,self._skillId)
            end
        end 
    end
end


---
--获取碰撞检测需要的技能信息
function skill:getSkillInfo()
    local skillInfo = {}
    skillInfo.armId         = self._bioArmId
    return skillInfo
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
