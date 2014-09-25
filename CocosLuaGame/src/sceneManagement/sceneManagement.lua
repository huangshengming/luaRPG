require "Cocos2d"

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
    self.gameScene = nil
    self.bioList={} --[bio.dyId] = bio
    GFRecAddDataListioner(self)
    local prot =GFProtGet(ProtBioInstanceList_C2S_ID)
    GFSendOneMsg(prot)
end
function sceneManagement:recMessageProc(prot)
    if prot.protId == ProtBioInstanceList_S2C_ID then
        pprint(prot)
        require("gestureManagement.actionTransform"):getInstance()
        local gestureMgr = require("gestureManagement.gestureManagement"):getInstance()
        local scene = require("sceneManagement/SceneView")
        self.gameScene = scene:createScene(1000)
     
     
        for k,v in pairs(prot.instanceList or {}) do
            local bioClass= require("bio.monster")
            local roleClass = require("bio.role")
            local bio=nil
            
            if v.lead==1 then
                bio = roleClass:create(v.dynamicId,v.staticId,"ttttttt",v.faction)
                g_playerObj = bio 
                self.gameScene:SetHero(g_playerObj)
            else
                bio = bioClass:create(v.dynamicId,v.staticId,"ttttttt",v.faction)  
            end
            self.gameScene:GetNearBg():addChild(bio)
            bio:setSceneManagement(self)
            bio:setPosition(v.positon.x,v.positon.y)
        end 
        
       
        self.gameScene:addChild(gestureMgr)
        if cc.Director:getInstance():getRunningScene() then
            cc.Director:getInstance():replaceScene(self.gameScene)
        else
            cc.Director:getInstance():runWithScene(self.gameScene)
        end
        
	end
end

function sceneManagement:PointInNearBg(x,y)
    if self.gameScene then
        return self.gameScene:PointInNearBg(x,y)
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

function sceneManagement:getlayer()
    local tempLayer=nil
    if self.gameScene then
        tempLayer=self.gameScene:GetNearBg()
    end
    return tempLayer
end

return  sceneManagement 


