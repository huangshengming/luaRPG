--场景类型
g_sceneType = 
{
    publicCity = 1, --公共主城
    singleFB   = 2, --单人副本
    onlineFB   = 3, --多人联机副本
}

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
    normalAttack = 1,   --普通攻击，单击click = 1,
    cutDown = 2,        --下斩，陆地下滑
    onrush = 3,         --前冲，左右滑动
    swoopDown = 5,      --俯冲，在空中下滑,
    airAttack = 6,      --跳起攻击，空中单击
    runAttack = 7,      --跑步攻击，冲刺单击
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
  jumpAttackEnd     =   8,              --空中攻击缓冲
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
    "standing"          ,             --站立
    "walking"           ,             --行走
    "running"           ,             --跑
    "jumpUp"            ,             --跳起
    "jumpDown"          ,             --落下
    "jumpAttackReady"   ,             --空中攻击准备
    "jumpAttacking"     ,             --空中攻击
    "jumpAttackEnd"     ,             --空中攻击缓冲,属于地面硬直！！
    "attackReady"       ,             --地面攻击准备、攻击前摇
    "attacking"         ,             --地面攻击
    "attackEnd"         ,             --地面攻击结束、连击缓冲
    "beHit"             ,             --受击
    "beStrikeFly"       ,             --击飞
    "beRebound"         ,             --反弹，击飞过高会产生反弹状态
    "lyingFloor"        ,             --躺地板
    "death"             ,             --死亡
    "lyingFly"          ,             --躺地板被击飞
}


--生物派别 (不是相对概念,只是分类)
g_bioFactionType=
{
  friend    = 1,        --友方  包括自己 
  enemy     = 2,        --敌方
  neutral   = 3,        --中立  比如NPC
}

--生物朝向
g_bioDirectionType=
{
  left= 1, --向左
  right=2, --向右
}
--为了避免歧义 都不用到想等的判断
--0--9999 为短连接
--10001-19999 为长连接
--20001- 29999 为内部
g_protType=
{
  shortConnection=10000, --短连接协议
  longConnection=20000, --长连接协议
  internal=30000, --客户端内部协议
}

g_aiStateType = {
    default = 0,
    idle = 1,
    activate = 2,
}

g_aiAction = {
  close_to_player = 1,
  away_from_player = 2
}

g_aiMessage = {
  afterStanding = 1,
  atkEnd = 2,
  afterBeingHit = 3
}

--当前玩家
g_playerObj=nil
--多人联机时，是否是主机
g_bMainMachine = true 


