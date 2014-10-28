require("staticData.data_equip")

---
-- 读取装备静态表数据
-- @module dataUse
-- @author csp
-- @copyright usugame



---
-- 读取装备静态表数据函数表
-- @equipDataUse
-- @tparam function getQuality 获取装备品质
-- @tparam function getPrice 获取装备售价
-- @tparam function getPart 获取装备位置
-- @tparam function getUseLevel 获取装备穿戴等级
-- @tparam function getMaxStreng 获取装备最高强化等级
-- @tparam function getSuit 获取装备套装id
equipDataUse = {
	getQuality= nil,
	getPrice= nil,
	getPart= nil,
	getUseLevel= nil,
	getMaxStreng= nil,
	getSuit= nil,
}

local _equip = data_equip.Equip


--- 
-- 获取装备品质
-- @tparam number id 装备id
-- @treturn number quality
equipDataUse.getQuality = function(id)
	if _equip[id] then
		return _equip[id].quality
	else
		print("error: data_equip getQuality: id = ",id)
		return nil
	end
end

--- 
-- 获取装备售价
-- @tparam number id 装备id
-- @treturn number price
equipDataUse.getPrice = function(id)
	if _equip[id] then
		return _equip[id].sell
	else
		print("error: data_equip getPrice: id = ",id)
		return nil
	end
end
--- 
-- 获取装备位置
-- @tparam number id 装备id
-- @treturn number part
equipDataUse.getPart = function(id)
	if _equip[id] then
		return _equip[id].part
	else
		print("error: data_equip getPart: id = ",id)
		return nil
	end
end
--- 
-- 获取装备穿戴等级
-- @tparam number id 装备id
-- @treturn number level
equipDataUse.getUseLevel = function(id)
	if _equip[id] then
		return _equip[id].level
	else
		print("error: data_equip getUseLevel: id = ",id)
		return nil
	end
end
--- 
-- 获取装备最高强化等级
-- @tparam number id 装备id
-- @treturn number level
equipDataUse.getMaxStreng = function(id)
	if _equip[id] then
		return _equip[id].maxStreng
	else
		print("error: data_equip getMaxStreng: id = ",id)
		return nil
	end
end

--- 
-- 获取装备套装id
-- @tparam number id 装备id
-- @treturn number suitId
equipDataUse.getSuit = function(id)
	if _equip[id] then
		return _equip[id].suit
	else
		print("error: data_equip getSuit: id = ",id)
		return nil
	end
end

