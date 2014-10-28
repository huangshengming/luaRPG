--暂时 模拟配置各种相关表



--暂时模拟副本生物配置表
--副本不同关卡
g_bioConfiguration = {
    [1] = { 1,100,101,102,103,},
    [2] = { },
    [3] = { },
}


--暂时怪物属性 静态ID对应
--key为静态ID
--hardStraigh 硬直 
--armatureId = 2 ：monster1， 3= monster2
g_bioProperty = {
    [1] = {staticId = 1, hp = 50000000000, mp = 1000, positionX = 200, positionY = 150, 
            lead = 1, faction = 1,status = 1,hardStraight = {1,2,3,4,},armatureId = 1,},
    [100] = {staticId = 100, hp = 32000, mp = 100, positionX = 1200, positionY = 155,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},armatureId = 3,},
    [101] = {staticId = 101, hp = 32000, mp = 100, positionX = 800, positionY = 165,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},armatureId = 3,},
    [102] = {staticId = 102, hp = 40000, mp = 100, positionX = 600, positionY = 160,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},armatureId = 2,},        
    [103] = {staticId = 102, hp = 40000, mp = 100, positionX = 900, positionY = 168,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},armatureId = 2,},
}


--暂时模拟 硬直度相关
--1 站立 2 空中除击飞 3击飞 4倒地 5无敌状态
g_tHardStraight = {
    [1] = { max = 80, a = -0.05, defense = 0,},    --100
    [2] = { max = 1, a = -0.05 , defense = 0,},
    [3] = { max = 150, a = -0.025 , defense = 0,},  --200
    [4] = { max = 70, a = -0.04 , defense = 0,},   --100
    [5] = { max = 100000, a = 10 , defense = 0,},
}


--暂时模拟 技能伤害及硬直度增加值 key为技能ID
--1=123，2=7，3=4，5=8，6=6，7=5
--g_attackOrderType = {
--    normalAttack = 1,   --普通攻击，单击click = 1,
--    cutDown = 2,        --下斩，陆地下滑
--    onrush = 3,         --前冲，左右滑动
--    swoopDown = 5,      --俯冲，在空中下滑,
--    airAttack = 6,      --跳起攻击，空中单击
--    runAttack = 7,      --跑步攻击，冲刺单击
g_tSkillData = {
    [1] = { damage = 3003, hardStraightness = 20, bioArmId = 1, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={80,120,},  hiteffId = 3, angle = 68, atkDis = 100},
    [2] = { damage = 3505, hardStraightness = 30, bioArmId = 2, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={80,120,}, hiteffId = 3, angle = 172, atkDis = 100},
    [3] = { damage = 5006, hardStraightness = 75, bioArmId = 3, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={250,140,}, hiteffId = 3, angle = 103, atkDis = 100},
    [4] = { damage = 7009, hardStraightness = 85, bioArmId = 4, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={330,240,}, hiteffId = 3, angle = 17, atkDis = 100},
    [5] = { damage = 5505, hardStraightness = 85, bioArmId = 5, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={40,255,},  hiteffId = 3, angle = 249, atkDis = 100},
    [6] = { damage = 4006, hardStraightness = 85, bioArmId = 6, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={5,50,}, hiteffId = 5, angle = 90, atkDis = 100},
    [7] = { damage = 4504, hardStraightness = 85, bioArmId = 7, effId = -1, maxHurtTimes = 2, hurtDeltaTime = 300, forceDis={250,80,}, hiteffId = 5, angle = 10, atkDis = 100},
    [8] = { damage = 8002, hardStraightness = 85, bioArmId = 8, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={25,80,}, hiteffId = 3, angle = 50, atkDis = 100},
}

--不同状态对应不同的硬直 1-4对应怪物属性表里硬直度 而非直接对应g_tHardStraight
g_tStatusHardStraight = {
	[1] = { g_bioStateType.standing, g_bioStateType.walking, g_bioStateType.running,g_bioStateType.beHit,
        g_bioStateType.attackReady, g_bioStateType.attacking, g_bioStateType.attackEnd,},
	[2] = { g_bioStateType.jumpUp, g_bioStateType.jumpDown, g_bioStateType.jumpAttackReady,
         g_bioStateType.jumpAttacking,g_bioStateType.jumpAttackEnd,},
	[3] = { g_bioStateType.beStrikeFly,},
	[4] = { g_bioStateType.lyingFloor,g_bioStateType.lyingFly,g_bioStateType.beRebound,},
} 

g_tMonsterAI = {
    [1] = {
            safeDistance = 500, --警戒距离
            preActivateTime = 3, --进入激活状态前置时间
            patrolDeltaTime = 3, --巡逻标时间间隔
            atkDeltaTime = 5,  --尝试攻击时间间隔
            preAtkTime = 6,  --进入激活状态后前置时间
            patrolRadius = {20, 200},  --巡逻半径 20-最短距离 200-最远距离
            crossChance = 0.5,  --可穿过目标的概率
            responseTime = 0.5, --攻击反映时间
            gestureData = {{"normalAttack", 100, 0.8}}, --技能数据 "技能id, 随机权重, 发动成功的概率(0-1)"
            caromChance = {{0.0, 0.0}} --连击概率 0.8(第一招后接第二招的概率) 0.6(第二招后接第三招的概率), 0.5(第三招后接第四招的概率)
    }
}

