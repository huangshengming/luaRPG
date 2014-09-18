require "Cocos2d"

local _gameloop_Instance=nil

local gameloop = class("gameloop",function()
         return cc.Node:create()
end)


function gameloop:loop()
    --接收消息队列管理    
    GFRecMessageManageLoop()
    --发送消息队列管理
    GFSendMessageManageLoop()
end
function gameloop:getInstance()
    
    if _gameloop_Instance==nil then
        _gameloop_Instance = gameloop.new()
        _gameloop_Instance:retain()
    end
    return _gameloop_Instance
end

function gameloop:ctor()
   
    function mytempLoop()
    	self:loop()
    end
    self.tttempid=  cc.Director:getInstance():getScheduler():scheduleScriptFunc(mytempLoop,0,false)

    
    
    local function onNodeEvent(event)
        if "cleanup" == event then
        end
    end
    self:registerScriptHandler(onNodeEvent)
end




return gameloop

