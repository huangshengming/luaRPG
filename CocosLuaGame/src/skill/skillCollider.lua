---
-- 碰撞检测接口模块
-- @module skill
-- @author 陈斌
-- @copyright usugame
-- 
require "Cocos2d"


function GFColliderForSkill(skillObj,targetBioData)
    local castObj   = skillObj:getCollideObj()
    --TODO bioOBj
    local targetObj = targetBioData.bioObj
end


function GFColliderForRect(rectA,rectB)
    ccRectA = cc.rect(rectA.x,rectA.y,rectA.width,rectA.height)
    ccRectB = cc.rect(rectB.x,rectB.y,rectB.width,rectB.height)
    return cc.rectIntersectsRect(ccRectA,ccRectB)
end
