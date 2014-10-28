---
-- 多人联机生物长连接通信协议 
-- ID段:31001~31100
--

--主机生物状态同步给副机
--

--多生物的状态同步
ProtMultibioSynchronize_C2S_ID = 13001
ProtMultibioSynchronize_S2C_ID = 13002

--多生物伤害信息同步
ProtMultibioDamage_C2S_ID = 13003
ProtMultibioDamage_S2C_ID = 13004

--副机玩家行动
ProtViceMachinePlayerAct_C2S_ID = 13005
--ProtViceMachinePlayerAct_S2C_ID = 31006

--坐标
local Coordinates = {
    x = -1,
    y = -1,
}

--多生物的状态同步
protDict[ProtMultibioSynchronize_C2S_ID] = {
    dynamicId = -1,                     --动态ID  
    curState  = -1,
    nextState = -1,
    direction = -1,
    posX = -1,
    posY = -1,
    skillId = -1,                       --attackReady or jumpAttackReady释放技能时才有值，其余都为-1
    skillIndex = -1,                    --当前使用的技能栏索引，当skillId>0时才有用，其余为-1
    skillBatterCount = -1,              --当前技能系列的连击数
    tick = -1,
}

protDict[ProtMultibioSynchronize_S2C_ID] = {
    dynamicId = -1,                     --动态ID  
    curState  = -1,
    nextState = -1,
    direction = -1,
    posX = -1,
    posY = -1,
    skillId = -1,                       --attackReady or jumpAttackReady释放技能时才有值，其余都为-1
    skillIndex = -1,                    --当前使用的技能栏索引，当skillId>0时才有用，其余为-1
    skillBatterCount = -1,              --当前技能系列的连击数
    tick = -1,
}

--多生物伤害信息同步
protDict[ProtMultibioDamage_C2S_ID] = {
    dynamicId = -1,                     --被攻击者动态ID
    attackDynamicId = -1,               --攻击者动态ID
    damage = -1,                        --扣血量
    skillId = -1,                       --被攻击的技能ID
    dType = -1,                         --扣血类型 0常规(技能) 1暴击 2BUFF 
    faceDirection = -1,                 --受击后朝向  1 left 2 right
    moveDirection = -1,                 --移动方向    1 left 2 right

}

protDict[ProtMultibioDamage_S2C_ID] = {
    dynamicId = -1,                     --被攻击者动态ID
    attackDynamicId = -1,               --攻击者动态ID
    damage = -1,                        --扣血量
    skillId = -1,                       --被攻击的技能ID
    dType = -1,                         --扣血类型 0常规(技能) 1暴击 2BUFF 
    faceDirection = -1,                 --受击后朝向  1 left 2 right
    moveDirection = -1,                 --移动方向    1 left 2 right

}


--副机玩家行动请求
protDict[ProtViceMachinePlayerAct_C2S_ID] = {
    protId = ProtViceMachinePlayerAct_C2S_ID,
    dynamicId = -1,
    nextState = -1,                     --没有改变时为-1
    direction = -1,                     --方向，没有改变时为-1
    skillId = -1,                       --attackReady or jumpAttackReady释放技能时才有值，其余都为-1
}



