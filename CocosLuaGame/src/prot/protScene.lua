---
-- 客户端内部 场景相关
-- ID段:29101~29200
-- @module ProtBioInstance
-- @author 张微
-- @copyright usugame








--场景初始化
protSceneInit_C2S_ID = 29101
protSceneInit_S2C_ID = 29102







--场景初始化
local bioList = {
    positon = Coordinates,	--初始坐标
	hp = -1,	            --血量			
	mp = -1,		     	--魔量	
	lead = -1,		        --0 非英雄 1英雄 目前demo 以后英雄属性有主角类管理
    faction = -1,           --阵营 1己方 2敌方 3中立
	dynamicId = -1,         --动态ID
	staticId = -1,          --静态ID 
    status = -1,            --初始状态 对应g_bioStateType
    armatureId = -1,        --生物形象
}

local portal = {}


protDict[protSceneInit_S2C_ID] = {
    sceneId = -1,                 --场景ID
    bioList = bioList,            --生物信息 包括人物
    portal = portal,              --时空门相关 预留

}

