---
-- 背包模块 通信协议 
-- ID段:9900~9949
-- @module protBag
-- @author csp
-- @copyright usugame





-- 查询背包所有物品
protBagQueryInfo_C2S_ID  = 9900
protBagQueryInfo_S2C_ID  = 9901

-- 背包物品交换位置
protBagSwapPlaces_C2S_ID  = 9902
protBagSwapPlaces_S2C_ID  = 9903

-- 背包物品使用
protBagUse_C2S_ID  = 9904
protBagUse_S2C_ID  = 9905

-- 背包物品出售
protBagSell_C2S_ID  = 9906
protBagSell_S2C_ID  = 9907


-- 背包物品格子信息变更
protBagModify_S2C_ID  = 9908


--购买格子
protBagBuyGrid_C2S_ID  = 9909
protBagBuyGrid_S2C_ID  = 9910


local bagTemp ={
	index = -1,--格子位置
	count = -1,--物品数量
	id = -1,--物品id
	dynamicId = -1,--动态id（如装备）
	type = -1,--1为物品，2为装备

}



-- 查询背包所有物品
protDict[protBagQueryInfo_C2S_ID] = {
}

protDict[protBagQueryInfo_S2C_ID] = {
    bagData =  bagTemp,
}


-- 背包物品交换位置
protDict[protBagSwapPlaces_C2S_ID] = {
    startIndex = -1,
    endIndex = -1,  
}

protDict[protBagSwapPlaces_S2C_ID] = {
}

protDict[protBagModify_S2C_ID] = {
    bagData =  bagTemp,
}

-- 使用物品
protDict[protBagUse_C2S_ID] = {
    index = -1,--格子号
    count = 1, --使用数量
}
protDict[protBagUse_S2C_ID] = { 
}

local sellTemp = {
    index = -1,
}
-- 出售物品
protDict[protBagSell_C2S_ID] = {
    index = -1,--格子号
    sellData=sellTemp
}
protDict[protBagSell_S2C_ID] = {
}

