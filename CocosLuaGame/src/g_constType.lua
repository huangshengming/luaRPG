
--方向控制类型
g_walkingType=
{
  walkLeft= 1,
  walkRight=2,
  runLeft=3,--向左边奔跑
  runRight=4,--向右边奔跑
  standing=5, --停止
}
 --手势类型
g_gestureType=
{
  up= 1,--向上滑动
  down=2,
  left=3,
  right=4,
  click=5,--点击
}

--攻击指令
g_attackOrderType = {
    click = 1,
    down = 2,
    left = 3,
    right = 4,
    runClick = 5,
    jumpClick = 6,
    jumpDown = 7,

}
--生物状态 用于状态机处理
g_bioStateType=
{
  standing          =   1,              --站立
  walking           =   2,              --行走
  running           =   3,              --跑
  jumpUp            =   4,              --跳起
  jumpDown          =   5,              --落下
  jumpAttackReady   =   6,              --空中攻击准备
  jumpAttacking     =   7,              --空中攻击
  jumpAttackEnd     =   8,              --空中攻击缓冲,属于地面硬直！！
  attackReady       =   9,              --地面攻击准备、攻击前摇
  attacking         =   10,             --地面攻击
  attackEnd         =   11,             --地面攻击结束、连击缓冲
  beHit             =   12,             --受击
  beStrikeFly       =   13,             --击飞
  beRebound         =   14,             --反弹，击飞过高会产生反弹状态
  lyingFloor        =   15,             --躺地板
  death             =   16,             --死亡
  lyingFly          =   17,             --躺地板被击飞
                                --****debuff相关状态,后续补充
  dizzy             =   21,             --晕,
}

--生物状态对应的str
g_bioStateStr = 
{
   --[[ g_bioStateType.standing          = ]]   "standing"          ,             --站立
   --[[ g_bioStateType.walking           = ]]   "walking"           ,             --行走
   --[[ g_bioStateType.running           = ]]   "running"           ,             --跑
   --[[ g_bioStateType.jumpUp            = ]]   "jumpUp"            ,             --跳起
   --[[ g_bioStateType.jumpDown          = ]]   "jumpDown"          ,             --落下
   --[[ g_bioStateType.jumpAttackReady   = ]]   "jumpAttackReady"   ,             --空中攻击准备
   --[[ g_bioStateType.jumpAttacking     = ]]   "jumpAttacking"     ,             --空中攻击
   --[[ g_bioStateType.jumpAttackEnd     = ]]   "jumpAttackEnd"     ,             --空中攻击缓冲,属于地面硬直！！
   --[[ g_bioStateType.attackReady       = ]]   "attackReady"       ,             --地面攻击准备、攻击前摇
   --[[ g_bioStateType.attacking         = ]]   "attacking"         ,             --地面攻击
   --[[ g_bioStateType.attackEnd         = ]]   "attackEnd"         ,             --地面攻击结束、连击缓冲
   --[[ g_bioStateType.beHit             = ]]   "beHit"             ,             --受击
   --[[ g_bioStateType.beStrikeFly       = ]]   "beStrikeFly"       ,             --击飞
   --[[ g_bioStateType.beRebound         = ]]   "beRebound"         ,             --反弹，击飞过高会产生反弹状态
   --[[ g_bioStateType.lyingFloor        = ]]   "lyingFloor"        ,             --躺地板
   --[[ g_bioStateType.death             = ]]   "death"             ,             --死亡
   --[[ g_bioStateType.lyingFly          = ]]   "lyingFly"          ,             --躺地板被击飞
}


--生物派别 (不是相对概念,只是分类)
g_bioFactionType=
{
  friend= 1,-- 友方  包括自己 
  enemies=2, -- 敌方
  neutral=3,-- 中立  比如NPC
}

--生物朝向
g_bioDirectionType=
{
  left= 1, --向左
  right=2, --向右
}
--为了避免歧义 都不用到想等的判断
--0--9999 为内部
--10001-19999 为短连接
--20001- 29999 为长连接
g_protType=
{
  internal=10000, --客户端内部协议
  shortConnection=20000, --短连接协议
  longConnection=30000, --长连接协议
}


g_playerObj=nil
