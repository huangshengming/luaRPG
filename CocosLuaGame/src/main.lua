
require "Cocos2d"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

function include(param)
    print(" ")
    print("include param=",param)
    package.path = package.path..";"..__app_path.."/"..param.."/?.lua"
    print("package.path=",package.path)
    require(param)
end

local function main()

    local mainPath = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
    local luapaht= string.find(mainPath,"/main.lua")
    luapaht= string.sub(mainPath,0,luapaht-1)
    __app_path= luapaht
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960, 640, 1)
    
    
--    local scene = require("GameScene")
--    local gameScene = scene.create()
--    gameScene:playBgMusic()
--    if cc.Director:getInstance():getRunningScene() then
--        cc.Director:getInstance():replaceScene(gameScene)
--    else
--        cc.Director:getInstance():runWithScene(gameScene)
--    end
    
    
    --create scene 
   
    require ("include")
    require("gameloop"):getInstance()
    shortLinkInit()
    require("sceneManagement.sceneManagement"):getInstance()
--    require("dataServer.FGDSManage"):getInstance()
    require("gestureManagement.actionTransform"):getInstance()
    require("armatureRender.armatureDraw")
    GFPreloadJson({1,2,3})


    --临时模拟 进入副本关卡返回
    --add by zw 
    --[[]]
    local inData = {}
    inData.pointsDrop = {}
    inData.pointsDrop = {{roomId = 1, bioStaticId = 20001, boxId = 1, }, } 
    inData.roomList = {1, 2, 3 ,}
    inData.miniMap = 1
    require("instanceZones.instanceZones"):getInstance(inData,true)
    
    --end

end




local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end




