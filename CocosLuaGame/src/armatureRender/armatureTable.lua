--人物资源id
g_tBioId = {
        [1]   =     {name = "hero",path = "Hero/Hero.ExportJson"}
}

--动画类型
g_tAnimationType = {
        [1]   =     "stand",        --待机
        [2]   =     "walk",         --跑步和冲刺
        [3]   =     "fly",          --浮空
        [4]   =     "attack",       --普攻
        [5]   =     "beHit",        --受击
        [6]   =     "jump",         --跳跃
        [7]   =     "die",          --死亡
        [8]   =     "skill"         --技能攻击
}

--人物状态匹配的是哪种类型的动画
g_tBioStateMatch = {
        --[[ g_bioStateType.standing          = ]]   1              ,             --站立
        --[[ g_bioStateType.walking           = ]]   2              ,             --行走
        --[[ g_bioStateType.running           = ]]   2              ,             --跑
        --[[ g_bioStateType.jumpUp            = ]]   6              ,             --跳起
        --[[ g_bioStateType.jumpDown          = ]]   6              ,             --落下
        --[[ g_bioStateType.jumpAttackReady   = ]]   6              ,             --空中攻击准备
        --[[ g_bioStateType.jumpAttacking     = ]]   6              ,             --空中攻击
        --[[ g_bioStateType.jumpAttackEnd     = ]]   6              ,             --空中攻击缓冲,属于地面硬直！！
        --[[ g_bioStateType.attackReady       = ]]   4              ,             --地面攻击准备、攻击前摇
        --[[ g_bioStateType.attacking         = ]]   4              ,             --地面攻击
        --[[ g_bioStateType.attackEnd         = ]]   4              ,             --地面攻击结束、连击缓冲
        --[[ g_bioStateType.beHit             = ]]   5              ,             --受击
        --[[ g_bioStateType.beStrikeFly       = ]]   3              ,             --击飞
        --[[ g_bioStateType.beRebound         = ]]   7              ,             --反弹，击飞过高会产生反弹状态
        --[[ g_bioStateType.lyingFloor        = ]]   7              ,             --躺地板
        --[[ g_bioStateType.death             = ]]   7              ,             --死亡
        --[[ g_bioStateType.lyingFly          = ]]   7              ,             --躺地板被击飞
}

--匹配类型后的动画名
g_tBioDatas = {
        [1] = {
            [1] = "hero_stand",
            [2] = "hero_walk",
            [3] = "hero_fly",
            [4] = {
                "hero_attack1",
                "hero_attack2",
                "hero_attack3",
                "hero_attack4"
            },
            [5] = "hero_beHit",
            [6] = "hero_jump",
            [7] = "hero_die",
            [8] = "hero_skill"
        }
}

--effect静态id
g_tEffectId ={
        [1] = {name = "effect1",path = "effect/effect1/effect1.ExportJson"},
        [2] = {name = "effect2",path = "effect/effect2/effect2.ExportJson"}
}

--json资源类型
g_tJsonType = {
        bio = 1,
        effect = 2
}
    
 