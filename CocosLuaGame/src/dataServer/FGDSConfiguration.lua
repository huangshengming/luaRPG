


--[[
--生物状态 用于状态机处理
g_bioStateType=
{
    standing      =   1,              --站立
    walking       =   2,              --行走
    running       =   3,              --跑
    jumpUp        =   4,              --跳起
    jumpDown      =   5,              --落下
    jumpAttack    =   6,              --跳起攻击
    attackReady   =   7,              --攻击准备、攻击前摇
    attacking     =   8,              --攻击
    attackEnd     =   9,              --攻击结束、连击缓冲
    beHit         =   10,              --受击
    beStrikeFly   =   11,             --击飞
    beRebound     =   12,             --反弹，击飞过高会产生反弹状态
    lyingFloor    =   13,             --躺地板
    Death         =   14,             --死亡
    --****debuff相关状态,后续补充
    dizzy         =   21,             --晕,
}
]]

--状态转换 人物--客户端后台
--C2S
--1  -> 2,3,4
--2  -> 1,3,4
--3  -> 1,2,4
--4  -> 5,6
--5  -> 12,13
--12 -> 13

--S2C 
--1,2,3,4,5,6   -> 10,11
--10            -> 11
--

--skill -> S
--    -> 7->8->9





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
            lead = 1,status = 1,hardStraight = {1,2,3,4,},},
    [100] = {staticId = 100, hp = 500, mp = 100, positionX = 600, positionY = 200,
            lead = 0, status = 1,hardStraight = {1,2,3,4,},},
    [101] = {staticId = 101, hp = 500, mp = 100, positionX = 800, positionY = 200,
            lead = 0, status = 1,hardStraight = {1,2,3,4,},},
    [102] = {staticId = 102, hp = 500, mp = 100, positionX = 900, positionY = 250,
            lead = 0, status = 1,hardStraight = {1,2,3,4,},},        
}


--暂时模拟 硬直度相关
--1 站立 2 空中除击飞 3击飞 4倒地 5无敌状态
g_tHardStraight = {
    [1] = { max = 100, a = -0.05 , defense = 0,},
    [2] = { max = 1, a = -0.05 , defense = 0,},
    [3] = { max = 200, a = -0.05 , defense = 0,},
    [4] = { max = 50, a = -0.05 , defense = 0,},
    [5] = { max = 100000, a = 10 , defense = 0,},
}


--暂时模拟 技能伤害及硬直度增加值 key为技能ID
g_tSkillData = {
    [1] = { damage = 20, hardStraightness = 40, bioArmId = 1, effId = 1, maxHurtTimes = 3,},
    [2] = { damage = 30, hardStraightness = 40, bioArmId = 2, effId = 2, maxHurtTimes = 1,},
    [3] = { damage = 100, hardStraightness = 60, bioArmId = 3, effId = 3, maxHurtTimes = 5,},
}

--不同状态对应不同的硬直 1-4对应怪物属性表里硬直度 而非直接对应g_tHardStraight
g_tStatusHardStraight = {
	[1] = { g_bioStateType.standing, g_bioStateType.walking, g_bioStateType.running,g_bioStateType.beHit, g_bioStateType.jumpAttackEnd,},
	[2] = { g_bioStateType.jumpUp, g_bioStateType.jumpDown, g_bioStateType.jumpAttackReady, g_bioStateType.jumpAttacking,},
	[3] = { g_bioStateType.beStrikeFly,},
	[4] = { g_bioStateType.lyingFloor,g_bioStateType.lyingFly,g_bioStateType.beRebound,},
} 

