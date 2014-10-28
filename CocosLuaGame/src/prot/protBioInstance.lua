---
-- 战斗模块 客户端内部通信协议 
-- ID段:29001~29100
-- @module ProtBioInstance
-- @author 张微
-- @copyright usugame





-- PVE战斗 生物类列表
ProtBioInstanceList_C2S_ID  = 29001
ProtBioInstanceList_S2C_ID  = 29002

--表现通知逻辑 坐标更新 目前限主角
ProtBioPosition_C2S_ID = 29003

--状态变化
ProBioStatusChange_C2S_ID = 29005
ProBioStatusChange_S2C_ID = 29006

--碰撞检测 
ProtBioCollision_C2S_ID = 29007

--请求施放技能
ProtBioCastSkill_C2S_ID = 29009
ProtBioCastSkill_S2C_ID = 29010

--伤害 表现相关
ProtBioDamage_S2C_ID = 29012







--坐标
local Coordinates = {
    x = -1,
    y = -1,
}



--请求生物类列表 可用于中途加怪物
protDict[ProtBioInstanceList_C2S_ID] = {
}

local instanceList = {
    positon = Coordinates,	--初始坐标
	hp = -1,	            --血量			
	mp = -1,		     	--魔量	
	lead = -1,		        --0 非英雄 1英雄 目前demo 以后英雄属性有主角类管理
    faction = -1,           --阵营 1己方 2敌方 3中立
	dynamicId = -1,         --动态ID
	staticId = -1,          --静态ID 
    status = -1,            --初始状态 对应g_bioStateType
}

--请求生物类列表返回
protDict[ProtBioInstanceList_S2C_ID] = {
	instanceList =  instanceList,	--生物列表
}




--坐标更新
protDict[ProtBioPosition_C2S_ID] = {
    dynamicId = -1,                     --动态ID  
    position = Coordinates,            
}




--状态变化
protDict[ProBioStatusChange_C2S_ID] = {
    dynamicId = -1,                     --动态ID
    status = -1,                        --状态 对应g_bioStateType
}

protDict[ProBioStatusChange_S2C_ID] = {
    dynamicId = -1,                     --动态ID
    currentStatus = -1,                 --上一个状态
    nextStatus = -1,                    --下一个状态 对应g_bioStateType
}



--碰撞检测
protDict[ProtBioCollision_C2S_ID] = {
    attackerDynamicId = -1,             --攻击者动态ID
    goalDynamicId = -1,                 --被攻击者动态ID
    skillId = -1,                       --技能ID
    faceDirection = -1,                 --受击后朝向  1 left 2 right
    moveDirection = -1,                 --移动方向    1 left 2 right
}

--请求是否可以施放技能
protDict[ProtBioCastSkill_C2S_ID] = {
    dynamicId = -1,                     --攻击者动态ID
    skillId = -1,                       --技能ID
}

protDict[ProtBioCastSkill_S2C_ID] = {
    dynamicId = -1,                     --攻击者动态ID
    skillId = -1,                       --技能ID
    cast = -1,                          --0可施放 1CD 2魔不够 3状态不可施放
}

--扣血 
protDict[ProtBioDamage_S2C_ID] = {
    dynamicId = -1,                     --被攻击者动态ID
    attackDynamicId = -1,               --攻击者动态ID
    damage = -1,                        --扣血量
    skillId = -1,                       --被攻击的技能ID
    dType = -1,                         --扣血类型 0常规(技能) 1暴击 2BUFF 
    faceDirection = -1,                 --受击后朝向  1 left 2 right
    moveDirection = -1,                 --移动方向    1 left 2 right
}
