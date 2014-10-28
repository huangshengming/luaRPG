require "Cocos2d"
local _equipData = nil

local equipData = class("equipData",function()
    return cc.Node:create()
end)

function equipData:getInstance()
    if _equipData==nil then
        _equipData = equipData.new()
        _equipData:retain()
    end
    return _equipData
end

function equipData:ctor()
    self._tWearDatas = {} --玩家身上装备
    self._tAttributeDatas = {}--所有装备属性详情
    GFRecAddDataListioner(self)
    local function onNodeEvent(event)
        if "cleanup" == event then
            GFRecRemoveListioner(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end
--获取装备信息请求协议c2s
function equipData:sendGetData()
    -- 获取装备信息 请求协议
    local prot = GFProtGet(protEquipInfo_C2S_ID)
    GFSendOneMsg(prot)
end
--请求穿戴装备c2s
function equipData:sendWearEquip(dynamicId,bagIndex)
    require "bag/bagData"
    local dx = bagIndex or bagData:getInstance():getEquipBagIndex(dynamicId)
    if not dx then return end
    local prot = GFProtGet(protEquipWear_C2S_ID)
    prot.dynamicId = dynamicId
    prot.bagIndex = dx
    GFSendOneMsg(prot)
end
--请求卸下装备c2s
function equipData:sendUnwieldEquip(dynamicId)
    local prot = GFProtGet(protEquipUnwield_C2S_ID)
    prot.dynamicId = dynamicId
    GFSendOneMsg(prot)
end


--装备对比(评分更高请求穿戴)
function equipData:contrastWearEquip(tbl)
    for k,v in pairs(tbl) do
        local _eId = self._tAttributeDatas[k].id 
        local _eType =  self:getEquipType(_eId) 
        local _eScore = self._tAttributeDatas[k].score
        
        local _wScore = 0
        for m,n in pairs(self._tWearDatas) do
            if self._tAttributeDatas[n.dynamicId] then
                local _wId = self._tAttributeDatas[n.dynamicId].id 
                local _wType = self:getEquipType(_wId) 
                if wType == _eType then
                    _wScore = self._tAttributeDatas[n.dynamicId].score
                end
            end
        end
        if _eScore > _wScore then--评分更高请求穿戴
            self:sendWearEquip(k)
        end

    end
end

--装备协议返回数据处理
function equipData:recMessageProc(prot)
    --获取装备信息返回
    if prot.protId == protEquipInfo_S2C_ID then
        self._tWearDatas = FGDeepCopy(prot.wearData)

        for k,v in pairs(prot.equipData) do
            self._tAttributeDatas[v.dynamicId] = FGDeepCopy(v)
        end

    --装备属性变更返回
    elseif prot.protId == protEquipPropertyChanges_S2C_ID then
        local ps = {}
        for k,v in pairs(prot.equipData) do
            ps[v.dynamicId] = true
            self._tAttributeDatas[v.dynamicId] = FGDeepCopy(v)
        end

        self:contrastWearEquip(ps)

    --删除装备数据
    elseif prot.protId == protEquipPropertyClearS2C_ID then
        for k,v in pairs(prot.clearEquipData) do
            self._tAttributeDatas[v.dynamicId] = nil
        end
    --穿戴装备
    --卸下装备
    elseif prot.protId == protEquipWear_S2C_ID or prot.protId == protEquipUnwield_S2C_ID then
        for k,v in pairs(prot.wearData) do
            for m,n in pairs(self._tWearDatas) do
                if v.dynamicId == n.dynamicId then
                    self._tWearDatas[m] = FGDeepCopy(v)
                    break
                end
            end
        end
    end
    
end


--装备是否穿戴
function equipData:isWear(dynamicId)
    for k,v in pairs(self._tWearDatas) do
        if dynamicId == v.dynamicId then
            return true
        end
    end
    return false
end
--返回装备类型
function equipData:getEquipType(id)
    return 1
end



