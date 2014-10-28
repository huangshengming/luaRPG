require "Cocos2d"
local _bagData = nil
 
local bagData = class("bagData",function()
    return cc.Node:create()
end)

function bagData:getInstance()
    if _bagData==nil then
        _bagData = bagData.new()
        _bagData:retain()
    end
    return _bagData
end

function bagData:ctor()
    self._tDatas = {} --背包格子数据表
    self._tAllDatas = {}
    GFRecAddDataListioner(self)
    local function onNodeEvent(event)
        if "cleanup" == event then
            GFRecRemoveListioner(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end





--请求背包数据c2s
function bagData:sendGetData()
    local prot = GFProtGet(protBagQueryInfo_C2S_ID)
    GFSendOneMsg(prot)
end
--请求使用物品c2s
function bagData:sendUseItem(index,count)
    local prot = GFProtGet(protBagUse_C2S_ID)
    prot.index=index
    prot.count = count
    GFSendOneMsg(prot)
end
--请求出售物品c2s
function bagData:sendSellItem(index,count)
    local prot = GFProtGet(protBagSell_C2S_ID)
    prot.index=index
    prot.count = count
    GFSendOneMsg(prot)
end
--请求拖动物品c2s
function bagData:sendSwapPlace(sIndex,eIndex)
    local prot = GFProtGet(protBagSwapPlaces_C2S_ID)
    prot.startIndex=sIndex
    prot.endIndex = eIndex
    GFSendOneMsg(prot)
end

function bagData:setAllBagData(protData,setType)
    local cfun = function(pDta)
        local _ps = {}
        for k,v in pairs(pDta) do
            local isExist = false
            for m,n in pairs(_ps) do
                if v.id == n.id and v.type == n.type then
                    isExist = true
                    n.count = n.count + v.count 
                    break
                end
            end
            if not isExist then
                if v.id > 0 then
                    local temp = FGDeepCopy(v)
                    table.insert(_ps,temp)
                end
            end
        end
        return _ps
    end
    if setType == 1 then
        self._tAllDatas = cfun(self._tDatas)
    elseif setType == 2 then
        local oldData = self._tAllDatas
        self._tAllDatas = cfun(self._tDatas)
        
        local _tbl = cfun(protData)
        local _addTbl = {}--增加的物品

        local _fGetCount = function(parameterTbl,conTbl)
            local count = 0
            for k,v in pairs(parameterTbl) do
                if conTbl.id == v.id and conTbl.type == v.type then
                    count = v.count
                    break
                end
            end
            return count
        end

        for k,v in pairs(_tbl) do
            local nowCount =_fGetCount(self._tAllDatas,v)
            local oldCount =_fGetCount(oldData,v)
            local disCount = nowCount - oldCount
            if disCount > 0 then
                local temp = {}
                temp.id = v.id
                temp.count = disCount
                temp.type = v.type
                table.insert(_addTbl,temp)
            end
        end

    end
end


function bagData:recMessageProc(prot)
    printByCsp(prot,"接收到背包模块协议")
    
    --查询背包数据协议
    if prot.protId == protBagQueryInfo_S2C_ID then
        self._tDatas = FGDeepCopy(prot.bagData)
        self:setAllBagData(prot.bagData,1)
    end

    --格子信息变更协议
    if prot.protId == protBagModify_S2C_ID then
        for k,v in pairs(prot.bagData) do
            local isfind = false
            for m,n in pairs(self._tDatas) do
                if n.index == v.index then
                    isfind = true
                    self._tDatas[n] = FGDeepCopy(v)
                    break
                end
            end
            if not isfind then--新开格子
                table.insert(self._tDatas,FGDeepCopy(v))
            end
        end
        self:setAllBagData(prot.bagData,2)
	end

    if prot.protId == protBagUse_S2C_ID then
    end

    if prot.protId == protBagSell_S2C_ID then
    end

    if prot.protId == protBagBuyGrid_S2C_ID then
    end

    if prot.protId == protBagSwapPlaces_S2C_ID then
    end
end

--获取物品数量
function bagData:getItemCount(id)
	local _nCount = 0
    for k,v in pairs(self._tAllDatas) do
	   if id == v.id then
	       _nCount = v.count
	       break
	   end
	end
	return _nCount
end


--获取装备所在背包位置
function bagData:getEquipBagIndex(dynamicId)
    local index = nil
    for k,v in pairs(self._tDatas) do
        if dynamicId == v.dynamicId and v.type == 2 then
            index = v.index 
            break
        end
    end
    return index
end




return bagData