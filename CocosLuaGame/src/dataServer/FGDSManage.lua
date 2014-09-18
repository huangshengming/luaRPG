---
-- 客户端战斗 内部逻辑 生物管理类
-- @moudle dataServer
-- @author 张微
-- @copyright usugame

require "Cocos2d"

local _FGDSManage = nil

---
-- 生物管理类 
-- @type BioManage Node
local FGDSManage = class("FGDSManage",function()
    return cc.Node:create()
end)


function FGDSManage:getInstance()
    if _FGDSManage == nil then
        _FGDSManage = FGDSManage.new()
        _FGDSManage:retain()
    end
 
    return _FGDSManage
end


function FGDSManage:ctor()

    self._tBio = {}
    
    local function onNodeEvent(event)
        if "cleanup" == event then
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
	--注册 生物相关通信 接收协议
    GFSendAddListioner(self)
end


---
-- 生物管理类 C2S 接收协议的处理
-- @param prot 协议
-- @treturn bool bool 是否处理此协议
function FGDSManage:sendMessageProc(prot)
	print("got send prot ",prot.protId)
	
    if prot.protId == 9001 then
        -- 场景 怪物 初始化
	   print("got scene request     ",prot.protId)
	   self.dataInit(self)
       self.sendListPort(self)
       
	   return true 
	elseif prot.protId == 9003 then
	   -- 主角坐标 更新
	    print("fy-- C2S role position update")
        self:rolePositionUpdate(prot.Coordinates)
    	
	   return true 
	elseif prot.protId == 9005 then 
	   --C2S 状态变更
	   print("fy-- C2S status change  ",prot.protId)
        self:setStatus(prot.dynamicId,prot.status)
	   
	   return true
	elseif prot.protId == 9007 then
	   -- 碰撞检测
        print("fy-- C2S Collision ")
        self:collision(prot.attackerDynamicId,prot.goalDynamicId,prot.skillId)
         
	   return true 
    end
    
    return false
end

--场景 怪物 初始化 协议相关 
--场景 生物列表 返回协议
function FGDSManage:sendListPort()
    local bioList = {}
	for i,v in ipairs(self._tBio or {}) do 
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
        
        table.insert(bioList,instanceList)
	end
	local prot = GFProtGet(ProtBioInstanceList_S2C_ID)
    prot.instanceList = bioList
    GFRecOneMsg(prot)
end

--怪物相关数据数据初始化 
function FGDSManage:dataInit()

    local dy = 0
    for i,v in pairs(g_bioConfiguration[1] or {}) do 
        local dataList = {}
        if g_bioProperty[v] then 
            dataList = FGDeepCopy(g_bioProperty[v])
            print("fuck-- init1  ")
        end
        dataList.dynamicId = 1000 + dy 
        dy = dy + 1 
        local bio = require("FGDSProperty")
        local bioInstance = bio.create()
        dataList.obj = bioInstance
        bioInstance:init(dataList)               
        table.insert(self._tBio,dataList)
        print("fuck-- init11  ",dataList.staticId,dataList.dynamicId)
    end

end

--根据动态ID 获取当前对象 及 数据表
function FGDSManage:getInstanceByDynamicId(dynamicId)
	for i,v in pairs(self._tBio or {}) do 
	   if v.dynamicId == dynamicId then
	       return v.obj
	   end
	end
	
	return nil
end


--管理数据相关
function FGDSManage:addByStaticId(staticId)
    if not g_bioProperty[staticId] then print("fy-- 场景添加怪物ID错误") return end
    
    --
end

function FGDSManage:removeByDynamicId(dynamicId)
    for i,v in pairs(self._tBio or {}) do 
        if v.dynamicId == dynamicId then
            print("fy-- 生物管理类删除 ",dynamicId)
            table.remove(self._tBio,i)
        end
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
end




--技能检测 
function FGDSManage:collision(attacker,goal,skillId)
	local a = self:getInstanceByDynamicId(attacker)
	local g = self:getInstanceByDynamicId(goal)
	
	if a ~= nil then 
       a:attackHandle(skillId)
	end
	if g ~= nil then
	   g:goalHandle(skillId)
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



return FGDSManage
