

--动画类型
g_tAnimationType = {
        [1]   =     "stand",        --待机
        [2]   =     "walk",         --跑步和冲刺
        [3]   =     "fly",          --浮空
        [4]   =     "attack",       --普攻
        [5]   =     "beHit",        --受击
        [6]   =     "jump",         --跳跃
        [7]   =     "die",          --死亡
        [8]   =     "skill",        --技能攻击
        [9]   =     "run",          --冲刺
        [10]  =     "jDown",        --落地
        [11]  =     "lying"         --躺地板
}

--人物状态匹配的是哪种类型的动画
g_tBioStateMatch = {
        --[[ g_bioStateType.standing          = ]]   1              ,             --站立
        --[[ g_bioStateType.walking           = ]]   2              ,             --行走
        --[[ g_bioStateType.running           = ]]   9              ,             --跑
        --[[ g_bioStateType.jumpUp            = ]]   6              ,             --跳起
        --[[ g_bioStateType.jumpDown          = ]]   10              ,             --落下
        --[[ g_bioStateType.jumpAttackReady   = ]]   4              ,             --空中攻击准备
        --[[ g_bioStateType.jumpAttacking     = ]]   4              ,             --空中攻击
        --[[ g_bioStateType.jumpAttackEnd     = ]]   4              ,             --空中攻击缓冲
        --[[ g_bioStateType.attackReady       = ]]   4              ,             --地面攻击准备、攻击前摇
        --[[ g_bioStateType.attacking         = ]]   4              ,             --地面攻击
        --[[ g_bioStateType.attackEnd         = ]]   4              ,             --地面攻击结束、连击缓冲
        --[[ g_bioStateType.beHit             = ]]   5              ,             --受击
        --[[ g_bioStateType.beStrikeFly       = ]]   3              ,             --击飞
        --[[ g_bioStateType.beRebound         = ]]   7              ,             --反弹，击飞过高会产生反弹状态
        --[[ g_bioStateType.lyingFloor        = ]]   11              ,            --躺地板
        --[[ g_bioStateType.death             = ]]   7              ,             --死亡
        --[[ g_bioStateType.lyingFly          = ]]   11              ,            --躺地板被击飞
        
}

--匹配类型后的动画名
g_tBioDatas = {
        --role_1
        [1] = {
        [1] = "armatureRes/role_1_state_std",
        [2] = "armatureRes/role_1_state_walk",
        [3] = "armatureRes/role_1_state_loss",
            [4] = {
            "armatureRes/role_1_skill_1_1",
            "armatureRes/role_1_skill_1_2",
            "armatureRes/role_1_skill_1_3",
            "armatureRes/role_1_skill_4_1",
            "armatureRes/role_1_skill_2_1",
            "armatureRes/role_1_skill_3_1",
            "armatureRes/role_1_skill_5_1",
            "armatureRes/role_1_skill_6_1"
            },
        [5] = "armatureRes/role_1_state_hit",
        [6] = "armatureRes/role_1_state_jumpup",
        [7] = "armatureRes/role_1_state_fall",
        [8] = "armatureRes/role_1_state_fall",
        [9] = "armatureRes/role_1_state_run",
        [10] = "armatureRes/role_1_state_jumpdown",
        [11] = "armatureRes/role_1_state_fall"
        },
        --moster_1
        [2] = {
            [1] = "armatureRes/monster_1_state_std",
            [2] = "armatureRes/monster_1_state_run",
            [3] = "armatureRes/monster_1_state_loss",
            [4] = {
                "armatureRes/monster_1_skill_1_1",
                "armatureRes/monster_1_skill_2_1"
            },
            [5] = "armatureRes/monster_1_state_hit",
            [6] = "armatureRes/monster_1_state_std",
            [7] = "armatureRes/monster_1_state_fall",
            [8] = "armatureRes/monster_1_state_std",
            [9] = "armatureRes/monster_1_state_run",
            [10] = "armatureRes/monster_1_state_std",
            [11] = "armatureRes/monster_1_state_fall"
        },
        [3] = {
            [1] = "armatureRes/monster_2_state_std",
            [2] = "armatureRes/monster_2_state_run",
            [3] = "armatureRes/monster_2_state_loss",
            [4] = {
                "armatureRes/monster_2_skill_1_1",
                "armatureRes/monster_2_skill_2_1"
            },
            [5] = "armatureRes/monster_2_state_hit",
            [6] = "armatureRes/monster_2_state_std",
            [7] = "armatureRes/monster_2_state_fall",
            [8] = "armatureRes/monster_2_state_std",
            [9] = "armatureRes/monster_2_state_run",
            [10] = "armatureRes/monster_2_state_std",
            [11] = "armatureRes/monster_2_state_fall"
        }
}

--effect静态id
g_tEffectId ={
        [1] = {name = "effect1",path = "effect/effect1/effect1.ExportJson"},
        [2] = {name = "effect2",path = "effect/effect2/effect2.ExportJson"},
        [3] = {name = "sjEffect",path = "armatureRes/role_1_effect_hit_2.ExportJson"},
        [4] = {name = "effect4",path = "effect/effect4/effect4.ExportJson"},
        [5] = {name = "sjEffect",path = "armatureRes/role_1_effect_hit_2.ExportJson"},
        [6] = {name = "effect6",path = "effect/effect6/effect6.ExportJson"},
        [10021] ={name = "eeee",path = "armatureRes/role_1_effect_2_1.ExportJson"}
}

--json资源类型
g_tJsonType = {
        bio = 1,
        effect = 2
}


--人物换装类型
g_tPartType={
    weapon = 1,
    body = 2,
    head = 3
}

g_sArmatureResPath = "armatureRes/"
    
 
