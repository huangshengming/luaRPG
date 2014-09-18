require "Cocos2d"
require "g_constType"
require "armatureRender.armatureTable"
require "Opengl"

---
-- 加载一个骨骼资源json文件
-- @param id 资源id
-- @param type 资源类型类型
-- @return filename 返回骨骼资源名
function GFLoadArmatureJson(id,type)
    local jsonPath
    if type==g_tJsonType.bio then
        jsonPath = g_tBioPath[id]
        if jsonPath==nil then
            print("in GFLoadArmatureJson : bio id_"..id.."not found in table!")
            return nil
        end
    elseif type==g_tJsonType.effect then
        jsonPath = g_tEffectPath[id]
        if jsonPath==nil then
            print("in GFLoadArmatureJson : effect id_"..id.."not found in table!")
            return nil
        end
    end

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(jsonPath)

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
-- @param id1,id2,id3 暂不用，待扩展
-- @return bool 如果播放成功,返回true,否则返回false
function GFArmaturePlayAction(bio,bioId,stateType,stateZiId,id1,id2,id3)
    if bio==nil then
        print("in GFAarmaturePlayAction: bio is nil!")
        return false
    end
    --根据bioStaticId加载json资源
    local armatureName = GFLoadArmatureJson(bioId,g_tJsonType.bio)

    if armatureName==nil then
        return false
    end
    --初始化前清空所有事件
    --    bio:getAnimation():setFrameEventCallFunc()
    --    bio:getAnimation():setMovementEventCallFunc()
    --初始化armature
    bio:init(armatureName)

    --取得所有动画
    local animation = bio:getAnimation()
    if animation==nil then
        print("in GFArmaturePlayAction: animation is nil!")
        return false
    end

    --播放对应id动画
    local animationId = GFGetAnimationId(bioId,stateType,stateZiId)
    if animationId == nil then return false end
    animation:play(animationId)

    --保存对碰撞骨骼的引用
    bio._beHitBoneList = GFGetBeHitBones(bio)
    bio._hitBoneList = GFGetHitBones(bio)

    --默认不显示碰撞区域图
    GFSetEditerColliderVisible(bio,g_bIsShowEditerCollider)


    --    local function dddd()
    --        local pos = armature:getBone("main"):getDisplayRenderNode():getBoundingBox()
    --        print(pos.x,pos.y)
    --    end
    --    cc.Director:getInstance():getScheduler():scheduleScriptFunc(dddd,0,false)
    --    return true
end

function GFGetAnimationId(armatureId,stateType,stateZiId)
    --根据bio状态取得动画类型
    local animationType = g_tBioStateMatch[stateType]
    --再根据动画类型取得对应动画名
    local ddd = g_tBioDatas[armatureId]
    local animationId = g_tBioDatas[armatureId][g_tAnimationType[animationType]] 
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
        return nil
    end

    local boneDic = armature._hitBoneList
    --从hit1开始
    if boneDic == nil then
        print("this armature has no hitBones!")  
        return nil
    end
    local rangeList = {}
    for key,bone in pairs(boneDic) do
        local boundBox = bone:getDisplayManager():getBoundingBox()
        rangeList.key = {
            cc.p(boundBox.x,boundBox.y),
            cc.p(boundBox.x+boundBox.width,boundBox.y),
            cc.p(boundBox.x+boundBox.width,boundBox.y+boundBox.height),
            cc.p(boundBox.x,boundBox.y+boundBox.height)
        }              
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
        return nil
    end

    local boneDic = armature._beHitBoneList
    --从beHit1开始
    if boneDic == nil then
        print("this armature has no beHitBones!") 
        return nil
    end
    local rangeList = {}
    for key,bone in pairs(boneDic) do
        local boundBox = bone:getDisplayManager():getBoundingBox()
        rangeList.key = {
            cc.p(boundBox.x,boundBox.y),
            cc.p(boundBox.x+boundBox.width,boundBox.y),
            cc.p(boundBox.x+boundBox.width,boundBox.y+boundBox.height),
            cc.p(boundBox.x,boundBox.y+boundBox.height)
        }              
    end
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
    if boneDic.beHit1 ~= nil then
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
            if #DDList==0 then
                print(" DDLIST IS ZERO")
            end
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

    --攻击
    local boneDic = armature._hitBoneList
    if boneDic ~= nil then 
        for key,bone in pairs(boneDic) do
            local DDList = bone:getDisplayManager():getDecorativeDisplayList()
            if #DDList==0 then
                print(" DDLIST IS ZERO")
            end
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

function GFPlayEffect(effect,effectId)
    if effect==nil then
        print("in GFPlayEffect: effect is nil!")
        return false
    end

    --初始化前清空所有事件
    --    bio:getAnimation():setFrameEventCallFunc()
    --    bio:getAnimation():setMovementEventCallFunc()
    
    --如果技能是与人物绑定的，则无需独立播放
    if g_tEffectTypeMatch[effectId] == g_tEffectType.binding then
        return
    end

    --根据effectId加载json资源
    local armatureName = GFLoadArmatureJson(effectId,g_tJsonType.effect)
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
    GFSetEditerColliderVisible(effect,false)

end
