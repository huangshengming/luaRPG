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
    self.bioList={}
    self.skillList={}
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
            local tempBio= require("bio.bio")
            local temphero=tempBio:create("tttttttt")
            self.gameScene:GetNearBg():addChild(temphero)
            temphero:setSceneManagement(self)
            temphero:setPosition(v.positon.x,v.positon.y)
            if v.lead==1 then
                g_playerObj = temphero
                self.gameScene:SetHero(g_playerObj)
            end
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

    local bIsOriginallyHave=false
    for k,v in pairs(self.bioList or {}) do
        if v == bio then
            bIsOriginallyHave =true
        end
    end 
    if bIsOriginallyHave==false then
        table.insert(self.bioList ,bio)
    end

end

function sceneManagement:removeOneBio(bio)

    for k,v in pairs(self.bioList or {}) do
        if v == bio then
            table.remove(self.bioList,k)
            break
        end
    end
    
end

function sceneManagement:addOneSkill(skill)

    local bIsOriginallyHave=false
    for k,v in pairs(self.skillList or {}) do
        if v == skill then
            bIsOriginallyHave =true
        end
    end 
    if bIsOriginallyHave==false then
        table.insert(self.skillList ,bio)
    end


end
function sceneManagement:removeOneSkill(skill)

    for k,v in pairs(self.skillList or {}) do
        if v == skill then
            table.remove(self.skillList,k)
            break
        end
    end
end
return  sceneManagement 


