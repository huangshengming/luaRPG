require "Cocos2d"
require "g_constType"
require "armatureRender.armatureTable"
require "Opengl"
require("gameWinSize")
---
-- 加载一个骨骼资源json文件
-- @param id 资源id
-- @param type 资源类型类型
-- @return filename 返回骨骼资源名
function GFLoadArmatureJson(id,stateType,stateZiId,type)
    local jsonPath
    if type==g_tJsonType.bio then
        jsonPath = GFGetAnimationId(id,stateType,stateZiId)..".ExportJson"
    elseif type==g_tJsonType.effect then
        jsonPath = g_tEffectId[id].path
        if jsonPath==nil then
            print("in GFLoadArmatureJson : effect id_"..id.."  is not found in table!")
            return nil
        end
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(jsonPath)
    end

    local filename = string.match(jsonPath, ".+/([^/]*%.%w+)$")
    local idx = filename:match(".+()%.%w+$")  
    if(idx) then  
        return filename:sub(1, idx-1)  
    else  
        return filename  
    end  
end



---
-- 播放一个对象的动画
-- @param Bio   Bio对象
-- @param BioId Bio对象静态id
-- @param g_bioStateType stateType 对象状态
-- @param number stateZiId 状态子id,用于一个状态可能对应多个动画的问题
-- @param weaponId 武器id，供武器换装使用
-- @param id1,id2,id3 暂不用，待扩展
-- @return bool 如果播放成功,返回true,否则返回false
function GFArmaturePlayAction(bio,bioId,stateType,stateZiId,weaponId,bodyId,headId)
    if bio==nil then
        print("in GFAarmaturePlayAction: bio is nil!")
        return false
    end
    --根据bioStaticId加载json资源
    local armatureName = GFLoadArmatureJson(bioId,stateType,stateZiId,g_tJsonType.bio)

    if armatureName==nil then
        return false
    end
    --初始化前清空所有事件
--    bio:getAnimation():setFrameEventCallFunc()
--    bio:getAnimation():setMovementEventCallFunc()

    --初始化armature
    if bio.armatureName~=armatureName then
        bio:init(armatureName)
        bio.armatureName = armatureName
    end
    
    --[[
    --换装
    --武器换装
    GFChangeDisplayPart(bio,g_tPartType.weapon,weaponId)
    --身体换装
    GFChangeDisplayPart(bio,g_tPartType.body,bodyId)
    --头部换装
    GFChangeDisplayPart(bio,g_tPartType.head,headId)
    --]]
    
    --取得所有动画
    local animation = bio:getAnimation()
    if animation==nil then
        print("in GFArmaturePlayAction: animation is nil!")
        return false
    end
    animation:playWithIndex(0)
    
    --保存对碰撞骨骼的引用
    bio._beHitBoneList = GFGetBeHitBones(bio)
    bio._hitBoneList = GFGetHitBones(bio)
    --默认不显示碰撞区域图
    GFSetEditerColliderVisible(bio,g_bIsShowEditerCollider)

end

function GFGetAnimationId(armatureId,stateType,stateZiId)
    --根据bio状态取得动画类型
    local animationType = g_tBioStateMatch[stateType]
    --再根据动画类型取得对应动画名
    local animationId = g_tBioDatas[armatureId][animationType] 
    if animationId == nil then
        print("in GFGetAnimationId = animationId is nil!")
        return nil
    elseif  type(animationId) == "table" then
        animationId = animationId[stateZiId]
    end
    return animationId
end

---
-- 取得骨骼动画对象的攻击范围
-- @param armature armature 骨骼动画对象
-- @return 返回攻击范围列表
function GFGetHitRangeList(armature)
    if armature==nil then
        print("in GFgetHitRangeList: armature is nil!")
        return {}
    end

    local boneDic = armature._hitBoneList
    --从hit1开始
    if boneDic == nil then
        --print("this armature has no hitBones!")  
        return {}
    end
    local rangeList = {}
    for key,bone in pairs(boneDic) do
        local boundBox = bone:getDisplayManager():getBoundingBox()
        local po = cc.p(boundBox.x,boundBox.y)
        --pprint(boundBox)
        local worldPoint = armature:convertToWorldSpaceAR(po)
        if armature:getScaleX()<0 then
            worldPoint.x= worldPoint.x+boundBox.width*gameWinSize:getInstance():GetSceneScale()*armature:getScaleX()
        end
        if armature:getScaleY()<0 then
            worldPoint.y= worldPoint.x+boundBox.width*gameWinSize:getInstance():GetSceneScale()*armature:getScaleY()
        end
        local rect = cc.rect(worldPoint.x,worldPoint.y,boundBox.width*gameWinSize:getInstance():GetSceneScale(),boundBox.height*gameWinSize:getInstance():GetSceneScale())
        table.insert(rangeList,rect)        
    end
    return rangeList
end


---
-- 取得骨骼动画对象的受击范围
-- @param armature armature 骨骼动画对象
-- @return 返回受击范围列表
function GFGetBeHitRangeList(armature)
    if armature==nil then
        print("in GFGetBeHitRangeList: armature is nil!")
        return {}
    end

    local boneDic = armature._beHitBoneList
    --从beHit1开始
    if boneDic == nil then
        --print("this armature has no beHitBones!") 
        return {}
    end
    local rangeList = {}
    for key,bone in pairs(boneDic) do
        local boundBox = bone:getDisplayManager():getBoundingBox()
        local po = cc.p(boundBox.x,boundBox.y)
        local worldPoint = armature:convertToWorldSpaceAR(po)
        if armature:getScaleX()<0 then
            worldPoint.x= worldPoint.x+boundBox.width*gameWinSize:getInstance():GetSceneScale()*armature:getScaleX()
        end
        if armature:getScaleY()<0 then
            worldPoint.y= worldPoint.x+boundBox.width*gameWinSize:getInstance():GetSceneScale()*armature:getScaleY()
        end
        local rect = cc.rect(worldPoint.x,worldPoint.y,boundBox.width*gameWinSize:getInstance():GetSceneScale(),boundBox.height*gameWinSize:getInstance():GetSceneScale())
        table.insert(rangeList,rect)         
    end
    --pprint(rangeList)
    return rangeList
end


---
-- 取得骨骼动画对象受击骨骼
-- @param armature armature 骨骼动画对象
-- @return 成功返回骨骼动画对象受击骨骼列表，失败返回nil
function GFGetBeHitBones(armature)
    if armature==nil then
        print("in GFGetBeHitRangeList: armature is nil!")
        return nil
    end

    local boneDic = armature:getBoneDic()
    --从beHit1开始
    if boneDic.beHit1 ~= nil then
        local beHitBoneList = {}
        local temp = "beHit"
        local i = 0
        repeat
            i = i+1
            if boneDic[temp..i]~=nil then
                local bone = boneDic[temp..i]
                beHitBoneList[temp..i] = bone
            else
                return beHitBoneList
            end
        until false
    else
        return nil
    end
end


---
-- 取得骨骼动画对象攻击骨骼
-- @param armature armature 骨骼动画对象
-- @return 成功返回骨骼动画对象攻击骨骼列表，失败返回nil
function GFGetHitBones(armature)
    if armature==nil then
        print("in GFGetBeHitRangeList: armature is nil!")
        return nil
    end

    local boneDic = armature:getBoneDic()
    --从hit1开始
    if boneDic.hit1 ~= nil then
        local hitBoneList = {}
        local temp = "hit"
        local i = 0
        repeat
            i = i+1
            if boneDic[temp..i]~=nil then
                local bone = boneDic[temp..i]
                hitBoneList[temp..i] = bone
            else
                return hitBoneList
            end
        until false
    else
        return nil
    end
end

---
-- 设置骨骼动画对象的碰撞区是否显示
-- @param armature armature 骨骼动画对象
-- @param bool visible  
function GFSetEditerColliderVisible(armature,visible)

    --受击
    local boneDic = armature._beHitBoneList
    if boneDic ~= nil then 
        for key,bone in pairs(boneDic) do
            local DDList = bone:getDisplayManager():getDecorativeDisplayList()
            if visible == true then
                for i,v in pairs(DDList) do
                    v:getDisplay():setVisible(true)
                    v:getDisplay():updateTransform()
                end                
            else
                for i,v in pairs(DDList) do
                    v:getDisplay():setVisible(false)
                    v:getDisplay():updateTransform()
                end           
            end
        end
    end

    --攻击
    local boneDic = armature._hitBoneList
    if boneDic ~= nil then 
        for key,bone in pairs(boneDic) do
            local DDList = bone:getDisplayManager():getDecorativeDisplayList()
            if visible == true then
                for i,v in pairs(DDList) do
                    v:getDisplay():setVisible(true)
                end                
            else
                for i,v in pairs(DDList) do
                    v:getDisplay():setVisible(false)
                end           
            end
        end
    end

end


---播放独立的skill
function GFPlayEffect(effect,effectId)
    if effect==nil then
        print("in GFPlaySkillInd: effect is nil!")
        return false
    end

    --初始化前清空所有事件
--    effect:getAnimation():setFrameEventCallFunc()
--    effect:getAnimation():setMovementEventCallFunc()

    --根据skillId加载json资源
    local armatureName = GFLoadArmatureJson(effectId,nil,nil,g_tJsonType.effect)
    --初始化armature
    if armatureName==nil then
        return false
    end
    effect:init(armatureName)

    --取得所有动画
    local animation = effect:getAnimation()
    if animation==nil then
        print("in GFPlayAction: animation is nil!")
        return false
    end

    animation:playWithIndex(0)

    --保存对碰撞骨骼的引用
    effect._beHitBoneList = GFGetBeHitBones(effect)
    effect._hitBoneList = GFGetHitBones(effect)

    --默认不显示碰撞区域图
    GFSetEditerColliderVisible(effect,g_bIsShowEditerCollider)
end

--[[
---身体换装接口
function GFChangeDisplayBody(bio,bodyId)
    local displayList = bio:getBone("main"):getDisplayManager():getDecorativeDisplayList()
    if bodyId~=1 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(g_sArmatureResPath..bio.armatureName.."_body_"..bodyId..".plist")
    end
    for i,v in pairs(displayList) do
        local displayName = v:getDisplay():getDisplayName()
        if displayName~=nil then
            local temp = string.match(displayName, ".+_(.+)")
            local newDisplayName = bio.armatureName.."_body_"..bodyId.."_"..temp
            if(newDisplayName~=displayName)then
                local s = ccs.Skin:createWithSpriteFrameName(newDisplayName)
                if s~=nil then
                    bio:getBone("main"):addDisplay(s,i-1)
                else
                    print(newDisplayName.."create skin fault!")           
                end  
            end
        end
    end
end
--]]

---
--换装接口
--param bio对象
--param partType换装类型
--param partId换装id
--
function GFChangeDisplayPart(bio,partType,partId)
    --取得换装的类型
    local part
    if partType==g_tPartType.weapon then
    	part = "weapon"
    elseif partType==g_tPartType.body then
        part = "body"
    else
        part = "head"
    end
    --取得display列表
    local displayList = bio:getBone(part):getDisplayManager():getDecorativeDisplayList()
    --id为1的部位资源已经在人物的json文件加载时加载了。
    if partId~=1 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(g_sArmatureResPath..part.."/"..bio.armatureName.."_"..part.."_"..partId..".plist")
    end
    --遍历每一个displayNode,进行换装
    for i,v in pairs(displayList) do
        local displayName = v:getDisplay():getDisplayName()
        if displayName~=nil then
            local temp = string.match(displayName, ".+_(.+)")
            local newDisplayName = bio.armatureName.."_"..part.."_"..partId.."_"..temp
            if(newDisplayName~=displayName)then
                local s = ccs.Skin:createWithSpriteFrameName(newDisplayName)
                if s~=nil then
                    bio:getBone(part):addDisplay(s,i-1)
                else
                    print(newDisplayName.."create skin fault!")           
                end  
            end
        end
    end
end


---
--预加载armature Json资源
-- @param table armatureIdList 需要预加载的armatureId集合
function GFPreloadJson(armatureIdList)
     if armatureIdList==nil or #armatureIdList==0 then
        return
     end
     for i,v in pairs(armatureIdList) do
        local jsons = g_tBioDatas[v]
        repeat
            if jsons == nil then
                break
            end
            for j,k in pairs(jsons) do
                --如果是table,那么需要再遍历这个table
                if type(k)=="table" then
                    for g,h in pairs(k) do
                        --print("hahahaha"..h)
                        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(h..".ExportJson")
                    end
                else
                    --print("hahahaha"..k)
                    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(k..".ExportJson")
                end
            end
        until true  
     end
end
