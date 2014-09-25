--暂时 模拟配置各种相关表



--暂时模拟副本生物配置表
--副本不同关卡
g_bioConfiguration = {
    [1] = { 1,100,101,},
    [2] = { },
    [3] = { },
}


--暂时怪物属性 静态ID对应
--key为静态ID
--hardStraigh 硬直 
g_bioProperty = {
    [1] = {staticId = 1, hp = 5000, mp = 1000, positionX = 200, positionY = 200, 
            lead = 1, faction = 1,status = 1,hardStraight = {1,2,3,4,},},
    [100] = {staticId = 100, hp = 50000000, mp = 100, positionX = 1200, positionY = 200,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},},
    [101] = {staticId = 101, hp = 50000000, mp = 100, positionX = 800, positionY = 200,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},},
    [102] = {staticId = 102, hp = 500, mp = 100, positionX = 900, positionY = 250,
            lead = 0, faction = 2, status = 1,hardStraight = {1,2,3,4,},},        
}


--暂时模拟 硬直度相关
--1 站立 2 空中除击飞 3击飞 4倒地 5无敌状态
g_tHardStraight = {
    [1] = { max = 100, a = -0.05, defense = 0,},
    [2] = { max = 1, a = -0.05 , defense = 0,},
    [3] = { max = 50, a = -0.025 , defense = 0,},
    [4] = { max = 50, a = -0.04 , defense = 0,},
    [5] = { max = 100000, a = 10 , defense = 0,},
}


--暂时模拟 技能伤害及硬直度增加值 key为技能ID
g_tSkillData = {
    [1] = { damage = 20, hardStraightness = 20, bioArmId = 1, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={180,100,},},
    [2] = { damage = 20, hardStraightness = 30, bioArmId = 2, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={150,180,},},
    [3] = { damage = 30, hardStraightness = 90, bioArmId = 3, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={330,130,},},
    [4] = { damage = 80, hardStraightness = 120, bioArmId = 4, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={280,200,},},
    [5] = { damage = 30, hardStraightness = 120, bioArmId = 5, effId = -1, maxHurtTimes = 1, hurtDeltaTime = 50, forceDis={30,300,},},
}

--不同状态对应不同的硬直 1-4对应怪物属性表里硬直度 而非直接对应g_tHardStraight
g_tStatusHardStraight = {
	[1] = { g_bioStateType.standing, g_bioStateType.walking, g_bioStateType.running,g_bioStateType.beHit,
         g_bioStateType.attackReady, g_bioStateType.attacking, g_bioStateType.attacking,},
	[2] = { g_bioStateType.jumpUp, g_bioStateType.jumpDown, g_bioStateType.jumpAttackReady,
         g_bioStateType.jumpAttacking,g_bioStateType.jumpAttackEnd,},
	[3] = { g_bioStateType.beStrikeFly,},
	[4] = { g_bioStateType.lyingFloor,g_bioStateType.lyingFly,g_bioStateType.beRebound,},
} 

