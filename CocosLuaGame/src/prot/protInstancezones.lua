---
-- 副本模块 CS通信协议 
-- ID段:1000~1099
-- @module protInstancezones
-- @author 张微
-- @copyright usugame


-- 请求关卡列表
protInstancezonesRequestList_C2S  = 1001
protInstancezonesRequestList_S2C  = 1002

--请求进入关卡
protInstancezonesRequestEnter_C2S = 1003
protInstancezonesRequestEnter_S2C = 1004

--关卡结算
protInstancezonesRequestStatistics_C2S = 1005
protInstancezonesRequestStatistics_S2C = 1006

--复活
protReborn_C2S_ID = 1007
protReborn_S2C_ID = 1008

--退出关卡
ProtInstanceZonesRequestQuit_C2S = 1009
ProtInstanceZonesRequestQuit_S2C = 1010



--请求关卡列表
protDict[protInstancezonesRequestList_C2S] = { 
    chapterId = -1,              --章节ID
}

local pointsStatus = {			--关卡状态结构
    pointsId = -1,				--关卡ID
    status = -1.          		-- 1 可进 2 已通关 3 不可进
}

protDict[protInstancezonesRequestList_S2C] = { 
    pointsStatus = pointsStatus,
}


--请求进入关卡
protDict[protInstancezonesRequestEnter_C2S] = { 
    pointsId = -1,              --关卡ID
}

local pointsDrop = {		--关卡掉落单元
    roomId = -1,     		--房间ID           
    bioStaticId = -1,		--怪物静态ID
    boxId = -1,				--箱子ID
}

local roomList = {
    
}

protDict[protInstancezonesRequestEnter_S2C] = {
    pointsDrop =  pointsDrop,	--关卡掉落单元
	roomList = roomList,        --房间ID表
    miniMap = -1,               --小地图ID
}


local boxList = { 		--箱子ID列表
    boxId = -1,
}

local dropList = {	--掉落箱子开启 
   type = -1,		--类型
   staticId = -1,	--静态ID
   count = -1,		--数量
}

local settleAccounts = {}  

--关卡结算
protDict[protInstancezonesRequestStatistics_C2S] = {
    result = -1,                -- 1,胜利 2,失败
    hp = -1,                    --剩余血量
    rebornTimes = -1,           --复活次数
    boxList = boxList,          --掉落箱子ID列表
}


protDict[protInstancezonesRequestStatistics_S2C] = {
    settleAccounts = settleAccounts,        --关卡结算
    dropList = dropList,                    --掉落箱子开启 
    score = -1,                             --评分 评星
}

--复活请求
protDict[protReborn_C2S_ID] = {
    
}

--复活返回
protDict[protReborn_S2C_ID] = {
    
}

--退出关卡
protDict[ProtInstanceZonesRequestQuit_C2S] = {
    
}

protDict[ProtInstanceZonesRequestQuit_S2C] = {
    
}
