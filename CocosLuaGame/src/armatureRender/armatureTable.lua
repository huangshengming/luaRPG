--人物资源id
g_tBioId = 
    {
        hero = 1
    }

--人物json资源路径
g_tBioPath = 
    {
        --[[g_tBioId.hero]] "Hero/Hero.ExportJson"
    }

--动画类型
g_tAnimationType = 
    {
        stand   = 1,
        walk    = 2,
        fly     = 3,
        skill   = 4,
        attack  = 5,
        beHit   = 6,
        jump    = 7,
        die     = 8
    }

--人物状态匹配的是哪种类型的动画
g_tBioStateMatch = 
    {
        --[[ g_bioStateType.standing          = ]]   "stand"            ,             --站立
        --[[ g_bioStateType.walking           = ]]   "walk"             ,             --行走
        --[[ g_bioStateType.running           = ]]   "walk"             ,             --跑
        --[[ g_bioStateType.jumpUp            = ]]   "jump"             ,             --跳起
        --[[ g_bioStateType.jumpDown          = ]]   "jump"             ,             --落下
        --[[ g_bioStateType.jumpAttackReady   = ]]   "jump"             ,             --空中攻击准备
        --[[ g_bioStateType.jumpAttacking     = ]]   "jump"             ,             --空中攻击
        --[[ g_bioStateType.jumpAttackEnd     = ]]   "jump"             ,             --空中攻击缓冲,属于地面硬直！！
        --[[ g_bioStateType.attackReady       = ]]   "attack"           ,             --地面攻击准备、攻击前摇
        --[[ g_bioStateType.attacking         = ]]   "attack"           ,             --地面攻击
        --[[ g_bioStateType.attackEnd         = ]]   "attack"           ,             --地面攻击结束、连击缓冲
        --[[ g_bioStateType.beHit             = ]]   "beHit"            ,             --受击
        --[[ g_bioStateType.beStrikeFly       = ]]   "fly"              ,             --击飞
        --[[ g_bioStateType.beRebound         = ]]   "die"              ,             --反弹，击飞过高会产生反弹状态
        --[[ g_bioStateType.lyingFloor        = ]]   "die"              ,             --躺地板
        --[[ g_bioStateType.death             = ]]   "die"              ,             --死亡
        --[[ g_bioStateType.lyingFly          = ]]   "die"              ,             --躺地板被击飞
    }

--匹配后的动画名
g_tBioDatas = 
    {
        [g_tBioId.hero] =  {
            [g_tAnimationType.stand]  = "hero_stand",
            [g_tAnimationType.walk]   = "hero_walk",
            [g_tAnimationType.fly]    = "hero_fly",
            [g_tAnimationType.skill]  = "hero_skill",
            [g_tAnimationType.attack] = {
                "hero_attack1",
                "hero_attack2",
                "hero_attack3",
                "hero_attack4"
            },
            [g_tAnimationType.beHit]  = "hero_beHit",
            [g_tAnimationType.jump]   = "hero_jump",
            [g_tAnimationType.die]    = "hero_die"
        }
    }

--效果类型
g_tEffectType = 
    {
        binding = 1,        --与人物绑定在同一个资源的
        independent = 2     --独立一个资源的
    }

--效果资源id
g_tEffectId =
    {
        effect1 = 1,
        effect2 = 2
    }

--效果类型匹配
g_tEffectTypeMatch = 
    {
        [g_tEffectId.effect1]  = g_tEffectType.binding,
        [g_tEffectId.effect2]  = g_tEffectType.independent
    }

--效果资源路径
g_tEffectPath = 
    {
        --[[g_tEffectId.effect1 ]] "Hero/Hero.ExportJson",
        --[[g_tEffectId.effect1 ]] "effect/effect2/effect2.ExportJson" 
    }

--json资源类型
g_tJsonType = 
    {
        bio = 1,
        effect = 2
    }
 