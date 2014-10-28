---
-- 装备模块 通信协议 
-- ID段:9950~9999
-- @module protEquip
-- @author csp
-- @copyright usugame


-- 查询装备
protEquipInfo_C2S_ID  = 9951
protEquipInfo_S2C_ID  = 9952

--穿戴装备
protEquipWear_C2S_ID  = 9953
protEquipWear_S2C_ID  = 9954
--卸下装备
protEquipUnwield_C2S_ID  = 9955
protEquipUnwield_S2C_ID  = 9956


--装备属性变更
protEquipPropertyChanges_S2C_ID  = 9957

--装备属性清除
protEquipPropertyClearS2C_ID  = 9958

local wearTemp = {
	dynamicId = -1,--动态id
	pos = -1,--穿戴位置
}

local equipTemp = {
	dynamicId = -1,--动态id
	id = -1 ,
	level = -1,--等级
	score  = -1,--评分
	--其他以后再加
}


-- 查询装备
protDict[protEquipInfo_C2S_ID] = {}

protDict[protEquipInfo_S2C_ID] = {
    wearData =  wearTemp,--穿戴中的装备
    equipData = equipTemp,--所有装备的详细信息
}
--装备属性变更
protDict[protEquipPropertyChanges_S2C_ID] = {
    equipData = equipTemp,--属性发生变更的装备的详细信息
}
--装备属性清除（如装备出售后，分解等）
local clearTemp = {
	dynamicId = -1,
}
protDict[protEquipPropertyClearS2C_ID] = {
    clearEquipData = clearTemp,
}
-- 穿戴装备
protDict[protEquipWear_C2S_ID] = {
    bagIndex = -1,--背包位置
    dynamicId  = -1,--动态id  
}

protDict[protEquipWear_S2C_ID] = {
    wearData =  wearTemp,
}
-- 卸下装备
protDict[protEquipUnwield_C2S_ID] = {
    dynamicId  = -1,--动态id  
}

protDict[protEquipUnwield_S2C_ID] = { 
    wearData =  wearTemp, 
}