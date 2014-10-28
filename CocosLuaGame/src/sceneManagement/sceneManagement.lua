require "Cocos2d"
require("staticData.configuration")

local _sceneManagementInstance=nil

	
local sceneManagement = class("sceneManagement",function()
    return cc.Node:create()
end)

function sceneManagement:getInstance()

    if _sceneManagementInstance==nil then
        _sceneManagementInstance = sceneManagement.new()
        _sceneManagementInstance:retain()
    end
    return _sceneManagementInstance
end

function sceneManagement:ctor()
    self.sceneType = g_sceneType.publicCity
    self.gameScene = nil
    self.bioList={} --[bio.dyId] = bio
    self.schedulerId = nil

    GFRecAddDataListioner(self)
     --注册循环定时器
    local function tempLoop(dt)
        self:sortBioZorderOnY()
    end
    self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tempLoop, 0, false)
end

function sceneManagement:recMessageProc(prot)
        print("wtf=======")
        pprint(prot)
    if prot.protId == ProtBioInstanceList_S2C_ID then

        for k,v in pairs(prot.instanceList or {}) do
            local bioClass= require("bio.monster")
            local roleClass = require("bio.role")
            local armatureId = v.armatureId
            local bio=nil
            
            if v.lead==1 then
                bio = roleClass:create(v.dynamicId,v.staticId,"ttttttt",v.faction,v.positon.x,v.positon.y,armatureId)
                g_playerObj = bio 
                
                self.gameScene:SetHero(g_playerObj)
            else
                bio = bioClass:create(v.dynamicId,v.staticId,"ttttttt",v.faction,v.positon.x,v.positon.y,armatureId)  
            end          
            self.gameScene:GetNearBg():addChild(bio)
            bio:setSceneManagement(self)
        end 
	end
    if prot.protId == protSceneInit_S2C_ID then
        require("gestureManagement.actionTransform"):getInstance()
        local gestureMgr = require("gestureManagement.gestureManagement"):getInstance()
        local scene = require("sceneManagement/SceneView")
        self.gameScene = scene:createScene(1000)
        self.gameScene:addChild(gestureMgr)
        if cc.Director:getInstance():getRunningScene() then
            cc.Director:getInstance():replaceScene(self.gameScene)
        else
            cc.Director:getInstance():runWithScene(self.gameScene)
        end
     
        
        for k,v in pairs(prot.bioList or {}) do
            print("wtf======")
            local bioClass= require("bio.monster")
            local roleClass = require("bio.role")
            local armatureId = v.armatureId
            local bio=nil
            
            if v.lead==1 then
                bio = roleClass:create(v.dynamicId,v.staticId,"ttttttt",v.faction,v.positon.x,v.positon.y,armatureId)
                g_playerObj = bio 
                
                self.gameScene:SetHero(g_playerObj)
            else
                bio = bioClass:create(v.dynamicId,v.staticId,"ttttttt",v.faction,v.positon.x,v.positon.y,armatureId)  
            end          
            self.gameScene:GetNearBg():addChild(bio)
            bio:setSceneManagement(self)
        end 
    end
end

function sceneManagement:getSceneType()
    return self.sceneType
end

function sceneManagement:GetNearBgXLeft()
    if self.gameScene then
        --print("[[[[[[[[[[[[[[[[[[[[[[[---------", self.gameScene:GetNearBgXLeft())
        return self.gameScene:GetNearBgXLeft()
    else
        print("GetNearBgXLeft nil nil")
    end
end

function sceneManagement:GetNearBgXRight()
    if self.gameScene then
        --print("[[[[[[[[[[[[[[[[[[[[[[[---------", self.gameScene:GetNearBgXRight())
        return self.gameScene:GetNearBgXRight()
    else
        print("GetNearBgXRight nil nil")
    end
end

function sceneManagement:GetFarBgXLeft()
    if self.gameScene then
        --print("[[[[[[[[[[[[[[[[[[[[[[[---------", self.gameScene:GetFarBgXLeft())
        return self.gameScene:GetFarBgXLeft()
    else
        print("GetFarBgXLeft nil nil")
    end
end

function sceneManagement:GetFarBgXRight()

    if self.gameScene then
        --print("[[[[[[[[[[[[[[[[[[[[[[[---------", self.gameScene:GetFarBgXRight())
        return self.gameScene:GetFarBgXRight()
    else
        print("GetFarBgXRight nil nil")
    end
end

function sceneManagement:PointInNearBg(object)
    if self.gameScene then
        return self.gameScene:PointInNearBg(object)
    else
        return x,y
    end
end

function sceneManagement:StandingY()
    
    if self.gameScene then
        return self.gameScene:getStandingY()
    end
	
end

function sceneManagement:addOneBio(bio)
    if self.bioList[bio.dyId]==nil then

        self.bioList[bio.dyId] = bio
    end

    --[[
    local bIsOriginallyHave=false
    for k,v in pairs(self.bioList or {}) do
        if v == bio then
            bIsOriginallyHave =true
        end
    end 
    if bIsOriginallyHave==false then
        table.insert(self.bioList ,bio)
    end
    ]]

end

function sceneManagement:removeOneBio(bio)
    if self.bioList[bio.dyId]~=nil then
        self.bioList[bio.dyId] = nil
    end

    --[[
    for k,v in pairs(self.bioList or {}) do
        if v == bio then
            table.remove(self.bioList,k)
            break
        end
    end
    ]]
    
end

function sceneManagement:getBoiList()
    return self.bioList
end

function sceneManagement:getBioTag(dyId)
    return self.bioList[dyId]
end

function sceneManagement:getEnemyList(bio)
    local enemyList = {}
    local enemyFaction = nil
    if bio.faction==g_bioFactionType.friend then
        enmeyFaction = g_bioFactionType.enemy
    elseif bio.faction==g_bioFactionType.enemy then
        enmeyFaction = g_bioFactionType.friend
    end

    if enemyFaction~=nil then
        for k,v in pairs(self.bioList) do
            if v.faction==enemyFaction then
                table.insert(enemyList,v)
            end
        end
    end

    return enemyList
end

function sceneManagement:getlayer()
    local tempLayer=nil
    if self.gameScene then
        tempLayer=self.gameScene:GetNearBg()
    end
    return tempLayer
end

function sceneManagement:sortBioZorderOnY()
    if self.gameScene and self.gameScene:GetNearBg() then
        for k,v in pairs(self.bioList or {}) do
            local z = self.gameScene:GetNearBg():getContentSize().height - v:getPositionY()
            self.gameScene:GetNearBg():reorderChild(v,z)
        end
    end
end

return  sceneManagement 


