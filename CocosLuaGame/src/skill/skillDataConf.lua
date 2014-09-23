---
-- 技能模块，驱动人物动作和技能特效播放，执行技能与生物的碰撞
-- @module skill
-- @author 陈斌
-- @copyright usugame
-- 

require("staticData.configuration")

local _skillDataConf=nil


-- 技能类
-- @type skillDataConfDataConf cc.Node
local skillDataConf = class("skillDataConf",function()
    return cc.Node:create()
end)

function skillDataConf:getInstance()

    if _skillDataConf==nil then
        _skillDataConf = skillDataConf.new()
        _skillDataConf:retain()
    end
    return _skillDataConf
end

function skillDataConf:getTagConfBySkillId(skillId)
    return g_tSkillData[skillId]
end

function skillDataConf:getBioArmatureIdBySkillId(skillId)
    return g_tSkillData[skillId].bioArmId
end

function skillDataConf:getEffArmatureIdBySkillId(skillId)
    return g_tSkillData[skillId].effId
end

function skillDataConf:getMaxHurtTimesBySkillId(skillId)
    return g_tSkillData[skillId].maxHurtTimes
end

function skillDataConf:getHurtDeltaTime(skillId)
    return g_tSkillData[skillId].hurtDeltaTime
end

return skillDataConf
