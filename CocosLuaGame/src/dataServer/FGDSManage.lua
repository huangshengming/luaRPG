---
-- 客户端战斗 内部逻辑 生物管理类
-- @module dataServer
-- @author 张微
-- @copyright usugame

require "Cocos2d"

local _FGDSManage = nil

--无尽
local wave = 1


---
-- 生物管理类 
-- @type FGDSManage Node
local FGDSManage = class("FGDSManage",function()
    return cc.Node:create()
end)

---
-- 生物管理类 获取单例
-- @return userdata 生物管理类单例
function FGDSManage:getInstance()
    if _FGDSManage == nil then
        _FGDSManage = FGDSManage.new()
        _FGDSManage:retain()
    end

    return _FGDSManage
end


function FGDSManage:ctor()

    self._tBio = {}
    self.dy = 0
    self._tList = {}
    --当前增加的生物组属性列表
    self._tAdd = {}
    
    local function onNodeEvent(event)
        if "cleanup" == event then
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
	--注册 生物相关通信 接收协议
    GFSendAddListioner(self)

    --[[
    self._tList = {}
    if wave == 1 then
        table.insert(self._tList,1)
    end
   self:endlessMode()
   self:dataInit(self._tList)
   self:sendListPort(self._tAdd)
   ]]
end



-- 生物管理类 C2S 接收协议的处理
-- @param prot 协议
-- @treturn bool bool 是否处理此协议
function FGDSManage:sendMessageProc(prot)
	print("got send prot ",prot.protId)
	
    if prot.protId == ProtBioInstanceList_C2S_ID then
        -- 场景 怪物 初始化
        --[[
	   print("got scene request     ",prot.protId)
        self._tList = {}
        if wave == 1 then
            table.insert(self._tList,1)
        end
	   self:endlessMode()
       self:dataInit(self._tList)
       self:sendListPort(self._tAdd)
       ]]
	   return true 
    elseif prot.protId == ProtBioPosition_C2S_ID then
	   -- 主角坐标 更新
	    print("fy-- C2S role position update")
        self:rolePositionUpdate(prot.Coordinates)
    	
	   return true 
    elseif prot.protId == ProBioStatusChange_C2S_ID then 
	   --C2S 状态变更
        print("fy-- C2S status change  ",prot.protId,prot.dynamicId,prot.status)
        self:setStatus(prot.dynamicId,prot.status)
	   
	   return true
    elseif prot.protId == ProtBioCollision_C2S_ID then
	   -- 碰撞检测
        print("fy-- C2S Collision ",prot.attackerDynamicId,prot.goalDynamicId,prot.skillId)
        self:collision(prot.attackerDynamicId,prot.goalDynamicId,prot.skillId,prot.faceDirection,prot.moveDirection)
         
	   return true 
    end
    
    return false
end

--场景 怪物 初始化 协议相关 
--获取当前生物列表
function FGDSManage:getBioList(  )
    return self._tBio
end


--场景 生物列表 返回协议
function FGDSManage:sendListPort(list,ifAdd)
 --  list = self._tBio
    local bioList = {}
    for i,v in ipairs(list or {}) do 
        local instanceList = {}
        local Coordinates = {}
        Coordinates.x = v.positionX
        Coordinates.y = v.positionY
        instanceList.positon = Coordinates
        instanceList.hp = v.hp                      
        instanceList.mp = v.mp             
        instanceList.lead = v.lead         
        instanceList.dynamicId = v.dynamicId       
        instanceList.staticId = v.staticId
        instanceList.status = v.status
        instanceList.faction = v.faction
        
        --临时代码 无尽模式 怪物坐标随机变动
        local _rNum = FGRandom(9)
        Coordinates.x = _rNum * 100
        
        print("fy-- 发送怪物信息 " ,i,v.dynamicId,v.staticId)
        table.insert(bioList,instanceList)
	end
	local prot
    if ifAdd then
         print("fy-- add ")
        prot = GFProtGet(ProtBioInstanceList_S2C_ID)
        prot.instanceList = bioList
    else
        print("fy-- clean add ")
        prot = GFProtGet(protSceneInit_S2C_ID)
        prot.bioList = bioList
    end
    
    GFRecOneMsg(prot)
    self._tAdd = {}
end

--怪物相关数据数据初始化 
function FGDSManage:dataInit(list,pX)
    self._tAdd = {}
    for i,v in pairs(list or {}) do 
        local dataList = {}
        
        if v < 100 then 
            if data_player.player[v] then
                dataList = FGDeepCopy(data_player.player[v])
            end
        else 
            if data_monster.Monster[v] then
                dataList = FGDeepCopy(data_monster.Monster[v])
            end
        end
        dataList.pX = pX
        dataList.staticId = v

        dataList.dynamicId = 1000 + self.dy 
        self.dy = self.dy + 1 
        local bio = require("FGDSProperty")
        local bioInstance = bio.create()
        dataList.obj = bioInstance
        bioInstance:init(dataList)               
        table.insert(self._tBio,dataList)
        table.insert(self._tAdd,dataList)
        print("fuck-- init11  ",dataList.staticId,dataList.dynamicId)
    end
    pprint(self._tBio)
end

--根据动态ID 获取当前对象 及 数据表
function FGDSManage:getInstanceByDynamicId(dynamicId)
	for i,v in pairs(self._tBio or {}) do
    --    print("fy-- get instance by dynamicId",v.dynamicId,dynamicId) 
	   if v.dynamicId == dynamicId then
	       return v.obj
	   end
	end
	
	return nil
end


--管理数据相关
function FGDSManage:addByStaticId(staticIdList,ifAdd)
  --  if not g_bioProperty[staticId] then print("fy-- 场景添加怪物ID错误") return end
    self:dataInit(staticIdList)
    self:sendListPort(self._tAdd,ifAdd)  
end

function FGDSManage:removeByDynamicId(dynamicId)
    for i,v in pairs(self._tBio or {}) do 
        if v.dynamicId == dynamicId then
            print("fy-- 生物管理类删除 ",dynamicId)
            table.remove(self._tBio,i)
        end
    end
 --   self:addBio()
end

--无尽模式 临时代码
--检测 如果场景中只剩英雄 怪物都死亡 则重新加入下一组怪物
function FGDSManage:addBio()
    print("fy-- 无尽 剩余怪物 ",#(self._tBio),self._tBio[1].staticId)
	if #(self._tBio) == 1 and self._tBio[1].staticId == 1 then
        self._tList = {}
	   self:endlessMode()
	   self:addByStaticId(self._tList,true)
	end
end

--主角坐标更新
--C2S
function FGDSManage:rolePositionUpdate(Coordinates)
    local obj = self:getInstanceByDynamicId(dId)
    if obj == nil then return end 
    obj:setPosition(Coordinates.x,Coordinates.y)
end

--状态变更 相关协议处理
--C2S
function FGDSManage:setStatus(dId,status)
    local obj = self:getInstanceByDynamicId(dId)
	if obj == nil then return end 
	obj:setStatus(status,false)
    print("fy-- C2S 状态变化 状态 / 动态ID ",status,dId)
end




--技能检测 
function FGDSManage:collision(attacker,goal,skillId,faceDirection,moveDirection)
	local a = self:getInstanceByDynamicId(attacker)
	local g = self:getInstanceByDynamicId(goal)
	print("fy-- 管理碰撞 分发",a,g)
	if a ~= nil then 
       a:attackHandle(skillId)
	end
	if g ~= nil then
        g:goalHandle(skillId,attacker,faceDirection,moveDirection)
    end
end


--删除
function FGDSManage:remove()
	if _FGDSManage then 
	    self._tBio = {}
        self.release()
        _FGDSManage = nil
	end
end

--临时代码 
--无尽模式
--怪物组初始化
function FGDSManage:endlessMode()
	local group = (wave-1)%6 + 1
	local list = {101,102,103,}
    local addhero = false
--    self._tList = {}
    print("fy-- 无尽 添加怪物组 wave / group ",wave,group)
	for i=1,group do
	   for k,v in pairs(list) do
	       table.insert(self._tList,v)
	   end
	end
	for i,v in pairs(self._tList or {}) do
	   print("fy-- 无尽 添加怪物组 静态ID ",v)
	end
    wave = wave + 1
    print("fy-- 无尽 添加怪物组  ",wave)
end



return FGDSManage
