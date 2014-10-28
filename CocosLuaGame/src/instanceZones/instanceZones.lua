
---
-- 副本
-- @module instanceZones
-- @author 张微
-- @copyright usugame


require "Cocos2d"
require("staticData.data_instance")
require("staticData.data_monster")
require("staticData.data_player")

require("staticData.data_templetScene")

local _Instance = nil

---
-- 副本类
-- @type Instance Node
local Instance = class("Instance",function()
    return cc.Node:create()
end) 


---
-- 副本类 获取单例
-- @param IZEnterProt 进入副本关卡协议返回prot
-- @return userdata 副本类单例
function Instance:getInstance(enterProt,ifSingle)
    if _Instance == nil then
        _Instance = Instance.new(enterProt,ifSingle)
        _Instance:retain()
    end

    return _Instance
end


function Instance:ctor(enterProt,ifSingle)
    --初始化相关
    self._bIfSingle = ifSingle                  --是否是单人副本
    self._bIfaddhero = false                    --是否添加过主角
    self._bIfclean = false                      --当前房间是否通关 怪物消灭
    self._iRoomId = -1                          --当前房间ID

    self._tDrop = {}                            --掉落信息
    self._tRoom = {}                            --房间信息
    self._tDrop = enterProt.pointsDrop          
    self._tRoom = enterProt.roomList
    self._nMap = enterProt.miniMap              --小地图ID

    self._nReborn = 0                           --主角重生次数
    self._nHp = -1                              --主角剩余血量
    self._box = {}                              --箱子掉落
    self._nResult = -1                          --战斗结果 1胜利 2失败
    

    local function onNodeEvent(event)
        if "cleanup" == event then
        end
    end
    self:registerScriptHandler(onNodeEvent)

    --注册 生物相关通信 接收协议
    GFSendAddListioner(self)

    --判断房间配置信息 通知生物管理类
    self:createBio(1)
end

--
--副本类 remove
function Instance:remove(parameters)
    if _Instance then 
        self.release()
        _Instance = nil
    end
end

--收发协议相关
function Instance:sendMessageProc(prot)
    if prot.protId == 9000000 then
	   
	   return true 
	end
	
	return false
end


----------
--********
----------

--根据小地图ID 获取起点房间ID
function Instance:getStartingRoom(  )
    

    return self._tRoom[1]
end
 
 --通知生物管理类 创建生物
 function Instance:createBio( roomId  )
     local roomId = roomId

     self._iRoomId = roomId
     --self:getStartingRoom()

    local dsManage = require("dataServer.FGDSManage"):getInstance()
    print("fy-- 生物初始化 怪物    " ,roomId)

    if not self._bIfaddhero then
        dsManage:dataInit({1,},0.5)
        self._bIfaddhero = true 
    end

    for i,v in pairs(data_instance.Room[roomId].monsterGroup or {}) do
        print("fy-- 生物初始化 怪物    ",data_instance.Room[roomId].monsterGroup[1][1],v[2])
        dsManage:dataInit(data_monster.MonsterGroup[v[1]].monster,v[2])
    end
    
    local bList = dsManage:getBioList()

    local bioList = {}
    for i,v in ipairs(bList or {}) do 
        local instanceList = {}
        local Coordinates = {}
        local sm = require("sceneManagement.sceneManagement"):getInstance()

        instanceList.hp = v.hp                      
        instanceList.mp = v.mp             
        instanceList.lead = v.mold         
        instanceList.dynamicId = v.dynamicId       
        instanceList.staticId = v.staticId
        instanceList.status = v.status
        instanceList.faction = v.faction
        require("dataUse.monsterDataUse")
        local tb = monsterDataUse.getResConf(v.staticId)
        instanceList.armatureId = tb.armatureId
        if v.staticId > 100 then
            Coordinates.x = v.pX
        else
            Coordinates.x = 200
        end
        Coordinates.y = 150 + tb.positionY
        instanceList.positon = {}
        instanceList.positon = Coordinates
        
        --怪物坐标随机小范围变动
        if v.staticId > 100 then
            local _rNum = FGRandom(9)
            Coordinates.x = Coordinates.x + 20 * _rNum
        end
        
        print("fy-- 发送怪物信息 " ,i,v.dynamicId,v.staticId,instanceList.positon.x,instanceList.positon.y,instanceList.lead)
        table.insert(bioList,instanceList)
    end
     
    local prot
    prot = GFProtGet(protSceneInit_S2C_ID)
    prot.bioList = bioList
    prot.sceneId = data_instance.Room[roomId].templetScene
    
    GFRecOneMsg(prot)

 end


--时空门回调 切换房间处理
function Instance:changeRoom( roomId )
    
end




return Instance
