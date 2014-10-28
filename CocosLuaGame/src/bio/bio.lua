require "Cocos2d"
require("armatureRender.armatureDraw")
require("sceneManagement.hitEffect")
require("sceneManagement.hurtNumber")
c_standForceCoe = 0.2 
c_flyForceCoe = 1

local skillClass = require("skill.skill")
local skillData = require("skill.skillDataConf"):getInstance()

local bio = class("bio",function()
         return ccs.Armature:create()
end)

function bio:create(dyId,staticId,name,faction,x,y,armatureResId)
    local bioTag = bio.new(dyId,staticId,name,faction,x,y,armatureResId)
 
    return bioTag
end

function bio:ctor(dyId,staticId,name,faction,x,y,armatureResId)
    print("bio:ctor_dyId=",dyId,"name=",name,"self=",type(self),"x,y=",x,y)
    --****************属性***********************
    --数据相关
    self.dyId = dyId                                --人物动态id
    self.bLeader = false                            --是否为主角
    self.staticId = staticId                        --人物静态id
    self.armatureResId =armatureResId               --人物动画资源id
    self.orgPos = cc.p(x,y)                         --人物初始坐标Point
    self.sceneLandHeight = 200                      --场景陆地高，即人物站在地面时的高度
    self.name = name                                --人物名称
    self.skillBar = {[1]={1,2,3,},[2]={7,},[3]={4,},[5]={8,},[6]={6,},[7]={5,},}       --人物技能栏,[技能栏id]={连击1，连击2，...}
    self.skillBatterCount = 0                       --当前技能连击数
    self.skillIndexUse = nil                        --当前使用技能的技能栏索引
    self.faction = faction                          --生物派别阵营
    self.armatureName = nil                         --资源名字

    self.state = g_bioStateType.standing            --人物状态
    self.direction = g_bioDirectionType.right       --面朝方向，1-左边，2-右边
    self.xMoveState = g_bioStateType.standing       --x轴移动状态，包括走，跑，站立
    self.presetDirection = nil                      --预设的人物朝向，攻击动作结束后要根据该值调整朝向,nil时表示没有
    self.attackOrderQue = {}                        --攻击指令队列,格式{order,dir}
    self.speedWalkVx = 350                          --人物行走x速度，像素每秒
    self.speedRunVx = 620                           --人物跑步x速度，像素每秒
    self.speedJumpVy = 400                          --人物跳跃y速度
    self.speedJumpAy = -1300                        --跳跃加速度
    --self.speedBeStrikeFlyVy = 400                 --人物被击飞时的x速度
    self.speedBeStrikeFlyAy = -1500                 --击飞状态下的加速度
    self.speedBeHitVx = 80                          --人物受击时的x速度  
    self.jumpHeight = 230                           --惹怒跳起的高度
    self.lyingFlyHeight = 50                        --躺飞的高度
    self.lyingFlyLength = 220                       --躺飞的长度
    self.speedLyingFlyAy = -1600                    --躺飞的加速度
    self.deathHeight = 90                           --死亡的抛物线高度
    self.deathLength = 130                          --死亡的抛物线长度
    self.speedDeathAy = -1800                       --死亡时从空中掉下的加速度
    self.bDeathFinish = false                       --是否完成死亡动画，即完成死亡抛物线落地
    self.vx = 0
    self.vy = 0
    self.ay = 0                                     --y轴加速度
    self.passiveMoveTime = 0                        --人物被动移动的时间
    --self.moveDisx = 0                             --人物需要移动的x距离
    --self.moveDisy = 0                             --人物需要移动的y距离
    self.bAttackAnimOver = false                    --攻击动画是否播放完毕
    self.schedulerId = nil                          --loopUpdate的定时器id
    self.onceSchedulerIds = {}                      --一次性的定时器数组
    self.shadowObj = nil                            --阴影
    self.skillObj = nil                             --释放技能时候的技能对象，最多只有一个
    self.sceneManagement=nil                        --场景管理类
    self.bChangStateByServer = false                --是否由服务器改变状态


    --********************************************
    self:setPosition(x,y)

    --注册接收协议
    GFRecAddViewListioner(self)

    --注册循环定时器
    local function tempLoop(dt)
        self:loopUpdate(dt)
    end
    self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tempLoop, 0, false)

    --注册事件回调
    local function onNodeEvent(event)
        if "cleanup" == event then --销毁回调
        
            if self.schedulerId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
            end
            for k,v in pairs(self.onceSchedulerIds) do
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
                self.onceSchedulerIds[k] = nil
            end
            
            --从场景注销
            if  self.sceneManagement then
                self.sceneManagement:removeOneBio(self)
            end

            --删除技能对象(貌似这里不需要)
            self:interruptSkill()
            --删除协议监听
            GFRecRemoveListioner(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)

    --播放站立状态动画
    self:playNewAnimation()
    
end

function bio:getDynamicId()
    return self.dyId
end

function bio:getDirection()
    return self.direction
end

function bio:getFaction()
    return self.faction
end

function bio:getOrgPos()
    return { x = self.orgPos.x, y = self.orgPos.y}
end

function bio:setSceneManagement(sceneManagement)
    if  self.sceneManagement then
        self.sceneManagement:removeOneBio(self)
    end
    
    self.sceneManagement = sceneManagement
    if  self.sceneManagement then
        --场景路面高
        self.sceneLandHeight = self.sceneManagement:StandingY()     
        --加入场景
        self.sceneManagement:addOneBio(self)
    end

    self.sceneLandHeight = self.sceneManagement:StandingY()     
end

function bio:correctionPosition()
    local mainX,mainY = self:getMainPosition()
    local selfX,selfY = self:getPosition()
    local correctionX,correctionY= self.sceneManagement:PointInNearBg(self)
    selfX=selfX-(mainX-correctionX)
    selfY=selfY-(mainY-correctionY)
    self:setPosition(selfX,selfY)
end

function bio:getMainPosition()
    local x,y=0,0
    local tempBone =self:getBone("main")
    if tempBone then
        local tempBoundingBox =tempBone:getDisplayManager():getBoundingBox()
        local tempAnchorPoint =tempBone:getDisplayManager():getAnchorPoint()
        x= tempBoundingBox.width*tempAnchorPoint.x+tempBoundingBox.x
        y= tempBoundingBox.height*tempAnchorPoint.y+tempBoundingBox.y
    end
    local tempPoint=cc.p(0,0)
    tempPoint.x,tempPoint.y= self:getPosition()
    local retx = tempPoint.x+self:getScaleX()*x
    local rety = tempPoint.y+self:getScaleY()*y
    --print("MBB_=",tw,th,tx,ty,tax,tay,tempPoint.x,retx,tempPoint.y,rety)
    return retx,rety
end

--创建影子
function bio:createShadow()
    self.shadowObj = cc.Sprite:create("shadow.png")
    self.shadowObj:setPosition(0,0)
    self.shadowObj:setAnchorPoint(0.5,0.5) 
    self:addChild(self.shadowObj,0)
end

--创建skill对象
function bio:createSkill(skillId)
    self:interruptSkill()
    self.skillObj = skillClass:create(self,skillId,self.sceneManagement)
end

--通知skill对象完成
function bio:finishSkill()
    if self.skillObj~=nil then
        self.skillObj:finish()
        self.skillObj = nil
    end
end

--通知skill对象打断
function bio:interruptSkill()
    if self.skillObj~=nil then
        self.skillObj:interrupt()
        self.skillObj = nil
    end
end

--*************************************************************
--**以下为bio个状态之间的转换函数，当前状态和下一个状态一一对应
--
--当前为standing状态时
function bio:standing_to_standing()
    return false
end

function bio:standing_to_walking()
    local success = true
    self.vx = self.speedWalkVx
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.walking
    return success
end

function bio:standing_to_running()
    local success = true
    self.vx = self.speedRunVx
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.running
    return success
end

function bio:standing_to_jumpUp()
    local success = true
    self.ay = self.speedJumpAy
    local time = math.sqrt(math.abs(2*self.jumpHeight/self.ay))
    self.vx = 0
    self.vy = math.abs(self.ay*time)
    self.state = g_bioStateType.jumpUp
    return success
end

function bio:standing_to_attackReady()
    local success = true
    --
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.attackReady
    self.bAttackAnimOver = false

    return success
end

function bio:standing_to_beHit()
    local success = true
    --self:setPositionY(self.orgPos.y)
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

    return success
end

function bio:standing_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    --self:setPositionY(self.orgPos.y)
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:standing_to_beStrikeFly()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end
--
--当前为walking状态时
function bio:walking_to_standing()
    local success = true
    self.vx = 0
    self.vy = 0
    self:clearOrderQue()
    self.state = g_bioStateType.standing
    return success
end

function bio:walking_to_jumpUp()
    local success = true
    self.ay = self.speedJumpAy
    local time = math.sqrt(math.abs(2*self.jumpHeight/self.ay))
    self.vx = self.speedWalkVx
    self.vy = math.abs(self.ay*time)
    self.state = g_bioStateType.jumpUp
    return success
end

function bio:walking_to_attackReady()
    local success = true
    
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.attackReady
    self.bAttackAnimOver = false

    return success
end

function bio:walking_to_beHit()
    local success = true
    self:setPositionY(self.orgPos.y)
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

    return success
end

function bio:walking_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:walking_to_beStrikeFly()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end
--
--当前为running状态时
function bio:running_to_standing()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.standing
    return success
end

function bio:running_to_jumpUp()
    local success = true

    self.ay = self.speedJumpAy
    local time = math.sqrt(math.abs(2*self.jumpHeight/self.ay))
    self.vx = self.speedRunVx
    self.vy = math.abs(self.ay*time)
    self.state = g_bioStateType.jumpUp

    return success
end

function bio:running_to_beHit()
    local success = true
    self:setPositionY(self.orgPos.y)
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

    return success
end

function bio:running_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    --self:setPositionY(self.orgPos.y)
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:running_to_beStrikeFly()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:running_to_attackReady()
    local success = true
    --
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.attackReady
    self.bAttackAnimOver = false

    return success
end
--
--当前为jumpUp状态时
function bio:jumpUp_to_standing()
    local success = false
    self.vx = 0
    return success
end

function bio:jumpUp_to_walking()
    local success = false
    self.vx = self.speedWalkVx
    return success
end

function bio:jumpUp_to_runnig()
    local success = false
    --若在空中时，当前x速度不为跑步速度，则取用walk的x速度
    if self.vx~=self.speedRunVx then
        self.vx = self.speedWalkVx
    end
    return success
end

function bio:jumpUp_to_beStrikeFly()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:jumpUp_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:jumpUp_to_jumpDown()
    local success = false

    local x, y = self:getPosition()
    local tempMiny = self.orgPos.y --人物最低的y
    if y==tempMiny+self.jumpHeight then
        success = true
        self.ay = self.speedJumpAy
        self.state = g_bioStateType.jumpDown
    end

    return success
end

function bio:jumpUp_to_jumpAttackReady()
    local success = true
    --取消程序的位移,由编辑器预先编辑好的进行改变
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.bAttackAnimOver = false
    self.state = g_bioStateType.jumpAttackReady
    
    return success
end
--
--当前为jumpDown状态时
function bio:jumpDown_to_standing()
    local success = false

    local x, y = self:getPosition()
    if y==self.orgPos.y then
        success = true
        self.vx = 0
        self.vy = 0
        self:clearOrderQue()
        self.state = g_bioStateType.standing 
    else
        self.vx = 0
    end
    return success
end

function bio:jumpDown_to_walking()
    local success = false
    local x, y = self:getPosition()

    if y==self.orgPos.y then
        success = true
        self.vx = self.speedWalkVx
        self.vy = 0
        self:clearOrderQue()
        self.state = g_bioStateType.walking
    else
        self.vx = self.speedWalkVx
    end
    return success
end

function bio:jumpDown_to_running()
    local success = false
    local x, y = self:getPosition()

    if y==self.orgPos.y then
        success = true
        --落地后跑步状态强制转换为走路状态
        self.vx = self.speedWalkVx
        self.vy = 0
        self:clearOrderQue()
        self.state = g_bioStateType.walking
    else
        --若在空中时，当前x速度不为跑步速度，则取用walk的x速度
        if self.vx~=self.speedRunVx then
            self.vx = self.speedWalkVx
        end
    end

    return success
end

function bio:jumpDown_to_beStrikeFly()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:jumpDown_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:jumpDown_to_jumpAttackReady()
    local success = true
    --取消程序的位移,由编辑器预先编辑好的进行改变
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.bAttackAnimOver = false
    self.state = g_bioStateType.jumpAttackReady
    
    return success
end
--
--当前为JumpAttackReady状态
function bio:jumpAttackReady_to_jumpAttacking()
    local success = true
    self.state = g_bioStateType.jumpAttacking
    return success
end

function bio:jumpAttackReady_to_attacking()
    local success = true
    self.state = g_bioStateType.attacking
    return success
end

function bio:jumpAttackReady_to_beStrikeFly()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:jumpAttackReady_to_death()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    
    return success
end
--
--当前为JumpAttacking状态
function bio:jumpAttacking_to_jumpAttackEnd()
    local success = true
    self.state = g_bioStateType.jumpAttackEnd
    return success
end

function bio:jumpAttacking_to_attackEnd()
    local success = true
    self.state = g_bioStateType.attackEnd
    return success
end

function bio:jumpAttacking_to_beStrikeFly()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:jumpAttacking_to_death()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    
    return success
end
--
--当前为jumpAttackEnd状态
function bio:jumpAttackEnd_to_jumpDown()
    local success = false
    local x, y = self:getPosition()
    local disy = y - self.orgPos.y

    if self.bAttackAnimOver and disy>0 then
        success = true 
        self.ay = self.speedJumpAy
        --local time = math.sqrt(math.abs(2*disy/self.ay))
        self.vx = 0
        self.vy = -200 
        self.state = g_bioStateType.jumpDown
    end

    return success
end

function bio:jumpAttackEnd_to_standing()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self:setPosition(self.orgPos)
        self.vx = 0
        self.vy = 0
        self.state = g_bioStateType.standing 
    end
    return success
end

function bio:jumpAttackEnd_to_beStrikeFly()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:jumpAttackEnd_to_death()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    
    return success
end

--
--当前为attackReady状态
function bio:attackReady_to_attacking()
    local success = true
    self.state = g_bioStateType.attacking
    return success
end

function bio:attackReady_to_jumpAttacking()
    local success = true
    self.state = g_bioStateType.jumpAttacking
    return success
end

function bio:attackReady_to_beHit()
    local success = true
    self:interruptSkill()
    --self:setPositionY(self.orgPos.y)
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

    return success
end

function bio:attackReady_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:attackReady_to_beStrikeFly()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

--
--当前为attacking状态
function bio:attacking_to_attackEnd()
    local success = true
    self.state = g_bioStateType.attackEnd
    return success
end

function bio:attacking_to_jumpAttackEnd()
    local success = true
    self.state = g_bioStateType.jumpAttackEnd
    return success
end

function bio:attacking_to_beHit()
    local success = true
    self:interruptSkill()
    --self:setPositionY(self.orgPos.y)
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

    return success
end

function bio:attacking_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    --self:setPositionY(self.orgPos.y)
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:attacking_to_beStrikeFly()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

--
--当前为attackEnd状态
function bio:attackEnd_to_attackReady()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.state = g_bioStateType.attackReady
    self.bAttackAnimOver = false
    return success
end

function bio:attackEnd_to_standing()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self.vx = 0
        self.vy = 0
        self.state = g_bioStateType.standing 
    end
    return success
end

function bio:attackEnd_to_walking()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self.vx = self.speedWalkVx
        self.vy = 0
        self.ay = 0
        self.state = g_bioStateType.walking
    end
    return success
end

function bio:attackEnd_to_running()
    local success = false
    --攻击结束时的跑步状态转化为行走
    success = self:attackEnd_to_walking()
    return success
end

function bio:attackEnd_to_beHit()
    local success = true
    self:interruptSkill()
    --self:setPositionY(self.orgPos.y)
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

    return success
end

function bio:attackEnd_to_death()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end

function bio:attackEnd_to_beStrikeFly()
    local success = true
    self:interruptSkill()
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

--
--当前为beHit状态
function bio:beHit_to_standing()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:setPositionY(self.orgPos.y)
    self:clearOrderQue()
    self.xMoveState = g_bioStateType.standing
    self.state = g_bioStateType.standing
    return success
end

function bio:beHit_to_beStrikeFly()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

function bio:beHit_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    --self:setPositionY(self.orgPos.y)
    self:clearOrderQue()
    self.state = g_bioStateType.death
    return success
end
--
--当前为beStrikeFly状态
function bio:beStrikeFly_to_lyingFloor()
    local success = false
    local x, y = self:getPosition()
    if y==self.orgPos.y then
        success = true
        self.vx = 0
        self.vy = 0
        self.ay = 0
        self.state = g_bioStateType.lyingFloor
    end
    
    return success
end

function bio:beStrikeFly_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    
    return success
end
--
--当前为lyingFloor状态
function bio:lyingFloor_to_standing()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.xMoveState = g_bioStateType.standing
    self.state = g_bioStateType.standing
    return success
end

function bio:lyingFloor_to_death()
    local success = true
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self:clearOrderQue()
    self.state = g_bioStateType.death
    
    return success
end

function bio:lyingFloor_to_lyingFly()
    local success = true
    --[[
    self.ay = self.speedLyingFlyAy
    local time = math.sqrt(math.abs(2*self.lyingFlyHeight/self.ay))
    self.vx = self.lyingFlyLength/time
    self.vy = math.abs(self.ay*time)
    ]]
    self.state = g_bioStateType.lyingFly

    return success
end

--
--当前为lyingFly状态
function bio:lyingFly_to_lyingFloor()
    local success = false
    local x, y = self:getPosition()
    if y==self.orgPos.y then
        success = true
        self.vx = 0
        self.vy = 0
        self.ay = 0
        self.state = g_bioStateType.lyingFloor
    end
    
    return success
end


--********end**********

--输入攻击指令
--@order 攻击指令
--@dir 方向，保持原有方向则为nil
function bio:inputAttackOrder(order,dir)
    local skillIndex = order  
    local success = self:attack(skillIndex)
    if success then
        if dir then
            self:setDirection(dir)
        end
    else
        table.insert(self.attackOrderQue,{order,dir})
    end
end

--运行攻击指令队列的下一个指令
function bio:runNextAttackOrder()
    if #self.attackOrderQue>0 then
        local success = self:attack(self.attackOrderQue[1][1])
        if success then
            local dir = self.attackOrderQue[1][2]
            if dir then 
                self:setDirection(dir) 
            end
            table.remove(self.attackOrderQue,1)
        end
    end
end

--清楚指令队列
function bio:clearOrderQue()
    self.attackOrderQue = {}
    self.skillIndexUse = nil
    self.skillBatterCount = 0
end

--人物攻击释放技能
function bio:attack(skillIndex)
    local success = false
    
    local skillTree = self.skillBar[skillIndex]
    print("skillIndexUse=",self.skillIndexUse,"skillIndex=",skillIndex,"skillTree=",skillTree)
    --该装备位是否有技能连击树
    if type(skillTree)=="table" and #skillTree>0 then
        if self.state==g_bioStateType.attackEnd then
            --在attackEnd只有连击能继续
            if self.skillIndexUse==skillIndex then
                local skillId = skillTree[self.skillBatterCount+1]
                print("MMM_Batter skillId=",skillId)
                if skillId~=nil then
                --若该技能树仍有连击技能
                    local nextState = g_bioStateType.attackReady
                    if self.state==g_bioStateType.jumpUp or self.state==g_bioStateType.jumpDown then
                        nextState = g_bioStateType.jumpAttackReady
                        if skillIndex==g_attackOrderType.swoopDown or skillIndex==g_attackOrderType.airAttack then
                            success = self:enterNextState(nextState,skillId)
                        end
                    else
                        success = self:enterNextState(nextState,skillId)
                    end
                end
            end
        elseif self.state==g_bioStateType.standing or self.state==g_bioStateType.walking or self.state==g_bioStateType.running or self.state==g_bioStateType.jumpUp or self.state==g_bioStateType.jumpDown then
            self.skillBatterCount = 0
            local skillId = skillTree[self.skillBatterCount+1]
            print("MMM_skillId=",skillId)
            local nextState = g_bioStateType.attackReady
            if self.state==g_bioStateType.jumpUp or self.state==g_bioStateType.jumpDown then
                nextState = g_bioStateType.jumpAttackReady
                if skillIndex==g_attackOrderType.swoopDown or skillIndex==g_attackOrderType.airAttack then
                    success = self:enterNextState(nextState,skillId)
                end
            else
                success = self:enterNextState(nextState,skillId)
            end
        end
    end
    if success then
        self.skillIndexUse = skillIndex
        self.skillBatterCount = self.skillBatterCount+1
    end

    return success
end

--攻击、跳落等动作结束后还原为预设的x轴状态
function bio:restoreXMoveState()
    local success = self:enterNextState(self.xMoveState)
    if success then
        self.xMoveState = g_bioStateType.standing
    end
end

--还原成预设的朝向
function bio:restorePresetDirection()
    if self.presetDirection~=nil then
        self:setDirection(self.presetDirection)
        self.presetDirection = nil
    end
end

--通过技能设置运动轨迹
function bio:setMoveLocusBySkill(skillId,dirCoe)
    --受击者移动轨迹
    local tagSkill = skillData:getTagConfBySkillId(skillId)
    if tagSkill~=nil then
        local coe = c_standForceCoe
        local vx = self.speedBeHitVx
        local vy = 0
        local ay = 0 
        local moveDisx,moveDisy = 0,0
        local time = 0
        if self.state==g_bioStateType.beStrikeFly then
            coe = c_flyForceCoe
            moveDisy = tagSkill.forceDis[2]*coe
            moveDisx = tagSkill.forceDis[1]*coe
            ay = self.speedBeStrikeFlyAy
        elseif self.state==g_bioStateType.lyingFly then
            moveDisy = self.lyingFlyHeight
            moveDisx = self.lyingFlyLength
            ay = self.speedLyingFlyAy
        elseif self.state==g_bioStateType.death then
            moveDisy = self.deathHeight
            moveDisx = self.deathLength
            ay = self.speedDeathAy
        else
            moveDisx = tagSkill.forceDis[1]*coe
        end
        if moveDisy>0 and ay~=0 then 
            local upTime = math.sqrt(math.abs(2*moveDisy/ay))
            vy = math.abs(ay*upTime)
            local downTime = math.sqrt(math.abs(2*(moveDisy+self:getPositionY()-self.orgPos.y)/ay))
            time = upTime + downTime
            vx = moveDisx/(2*upTime)--time
        elseif moveDisx>0 then
            time = moveDisx/vx
        end
        self.vx = vx*dirCoe
        self.vy = vy
        self.ay = ay
        self.passiveMoveTime = time

    else
        print("[erro]skill配置未找到！")
    end

end

--通知服务器人物状态
function bio:sendSeverBioState()
    local prot =GFProtGet(ProBioStatusChange_C2S_ID)
    prot.dynamicId = self.dyId
    prot.status = self.state
    print("MMM_sendstate,dyId,state=",self.dyId,self.state)
    GFSendOneMsg(prot)
end

--发送协议多生物状态同步
function bio:sendProtMultibioSynchronize(lastState,skillId,dir)
    if self.sceneManagement:getSceneType()==g_sceneType.onlineFB and g_bMainMachine then 
        local prot = GFProtGet(ProtMultibioSynchronize_C2S_ID)
        prot.dynamicId = self.dyId              --动态ID  
        prot.curState  = -1
        prot.nextState = -1
        prot.direction = -1
        prot.posX = -1
        prot.posY = -1
        prot.skillId = -1                       --attackReady or jumpAttackReady释放技能时才有值，其余都为-1
        prot.skillIndex = -1                    --当前使用的技能栏索引，当skillId>0时才有用，其余为-1
        prot.skillBatterCount = -1              --当前技能系列的连击数
        prot.tick = -1
        if lastState~=nil then
            prot.curState = lastState
            prot.nextState = self.state
        end
        if skillId~=nil then
            prot.skillId = skillId
            prot.skillIndex = self.skillIndexUse
            prot.skillBatterCount = self.skillBatterCount
        end
        if dir~=nil then
            prot.direction = dir
        end

        GFSendOneMsg(prot)
    end
end

--发送协议多生物伤害同步
function bio:sendProtMultibioDamage(atkerDyId,dmg,skillId,dType,faceDir,moveDir)
    --当前为多人副本且为主机时，发送多人伤害同步协议至其他副机
    if self.sceneManagement:getSceneType()==g_sceneType.onlineFB and g_bMainMachine then 
        local prot = GFProtGet(ProtMultibioDamage_C2S_ID)
        prot.dynamicId = self.dyId                   --被攻击者动态ID
        prot.attackDynamicId = atkerDyId             --攻击者动态ID
        prot.damage = dmg                            --扣血量
        prot.skillId = skillId                       --被攻击的技能ID
        prot.dType = dType                           --扣血类型 0常规(技能) 1暴击 2BUFF 
        prot.faceDirection = faceDir                 --受击后朝向  1 left 2 right
        prot.moveDirection = moveDir                 --移动方向    1 left 2 right

        GFSendOneMsg(prot)
    end
end

--接收协议
function bio:recMessageProc(prot)
    --是否处于攻击
    local function inAttack(state)
        local ret = false
        if state==g_bioStateType.attackReady or state==g_bioStateType.attacking or state==g_bioStateType.attackEnd or state==g_bioStateType.jumpAttackReady or state==g_bioStateType.jumpAttacking or state==g_bioStateType.jumpAttackEnd then
            ret = true
        end
        return ret
    end

    --本地服务器状态改变
    if prot.protId==ProBioStatusChange_S2C_ID and self.dyId==prot.dynamicId then
        local curState = prot.currentStatus
        local nextState = prot.nextStatus
        print("MMM_ProBioStatusChange_S2C_ID,dyId=",prot.dynamicId,"curState=",curState,"nextState=",nextState,"selfState=",self.state)

        if inAttack(self.state) and inAttack(nextState)~=true then
            self.bAttackAnimOver = true
        end
        --处理因异步造成的异常，以服务器的当前状态为准
        if self.state~=curState then
            if inAttack(self.state) and inAttack(curState)~=true then
                self:interruptSkill()
            end
            self.state=curState
        end

        self.bChangStateByServer = true
        self:enterNextState(nextState)
        self.bChangStateByServer = false

    --本地服务器伤害信息
    elseif prot.protId==ProtBioDamage_S2C_ID and self.dyId==prot.dynamicId then
        local atkerDyId = prot.attackDynamicId
        local damage = prot.damage
        local skillId = prot.skillId
        local dType = prot.dType
        local faceDir = prot.faceDirection
        local moveDir = prot.moveDirection      --移动方向,1 left 2 right

        local atker = nil
        local dirCoe = -1 --方向正负系数
        if faceDir==moveDir then
            dirCoe = 1
        end
        local mainBoneX,mainBoneY = self:getMainPosition()

        if self.sceneManagement then
            atker = self.sceneManagement:getBioTag(atkerDyId)
        end

        print("MMM_ProtBioDamage_S2C_ID,dyId=",prot.dynamicId,"damage,x,y=",damage,mainBoneX,mainBoneY)
        --调整受击者朝向
        if self.state==g_bioStateType.beHit or self.state==g_bioStateType.beStrikeFly or self.state==g_bioStateType.lyingFloor or self.state==g_bioStateType.death or self.state==g_bioStateType.lyingFly then
            self:setDirection(faceDir)
        end

        --跳血 
        local offsetY1 = 150
        local offsetY2 = 100
        if self.state==g_bioStateType.lyingFloor or self.state==g_bioStateType.lyingFly then
            offsetY1 = 20
            offsetY2 = 0
        end
        local bCirit = false
        if prot.dType == 1 then 
            bCirit = true
        end
        hurtNumberShow(self:getParent(),faceDir,damage,mainBoneX,mainBoneY+offsetY1,bCirit)
        hitEffect(self:getParent(),faceDir,skillId, mainBoneX,mainBoneY+offsetY2)

        --通过受击技能改变运动轨迹
        self:setMoveLocusBySkill(skillId,dirCoe)

        --当前为多人副本且为主机时，发送多人伤害同步协议至其他副机
        self:sendProtMultibioDamage(atkerDyId,damage,skillId,dType,faceDir,moveDir)
                
    --多生物状态同步
    elseif prot.protId==ProtMultibioSynchronize_S2C_ID and self.dyId==prot.dynamicId then
        local curState = prot.curState
        local nextState = prot.nextState
        local dir = prot.direction
        local posX = prot.posX 
        local posY = prot.posY 
        local skillId = nil
        if prot.skillId>0 then skillId = prot.skillId end  --attackReady or jumpAttackReady释放技能时才有值，其余都为-1
        local skillIndex = prot.skillIndex                 --当前使用的技能栏索引，当skillId>0时才有用，其余为-1
        local skillBatterCount = prot.skillBatterCount     --当前技能系列的连击数
        local tick = prot.tick  
        print("MMM_dyId=",prot.dynamicId,"curState=",curState,"nextState=",nextState,"skillId=",skillId)
        --若不是主机,则接受状态同步
        if not g_bMainMachine then
            if curState>0 and nextState>0 then
                if inAttack(self.state) and inAttack(nextState)~=true then
                    self.bAttackAnimOver = true
                end
                if self.state~=curState then
                    if inAttack(self.state) and inAttack(curState)~=true then
                        self:interruptSkill()
                    end
                    self.state=curState
                end
                
                self:enterNextState(nextState,skillId,false)

                if skillId~=nil then
                    skillIndex = self.skillIndexUse
                    skillBatterCount = self.skillBatterCount
                end
            end
            
            if dir>0 then
                self:setDirection(dir)
            end

            self:setPosition(posX,posY)
        end

    --多生物伤害同步
    elseif prot.protId==ProtMultibioDamage_S2C_ID and self.dyId==prot.dynamicId then
        local skillId = prot.skillId
        local damage = prot.damage
        local faceDir = prot.faceDirection
        local moveDir = prot.moveDirection      --移动方向,1 left 2 right
        local atker = nil
        local dirCoe = -1 --方向正负系数
        if faceDir==moveDir then
            dirCoe = 1
        end
        local mainBoneX,mainBoneY = self:getMainPosition()

        if self.sceneManagement then
            atker = self.sceneManagement:getBioTag(prot.attackDynamicId)
        end

        print("MMM_ProtBioDamage_S2C_ID,dyId=",prot.dynamicId,"damage,x,y=",damage,mainBoneX,mainBoneY)
        --若不是主机,则接受伤害同步
        if not g_bMainMachine then
            --调整受击者朝向
            if self.state==g_bioStateType.beHit or self.state==g_bioStateType.beStrikeFly or self.state==g_bioStateType.lyingFloor or self.state==g_bioStateType.death or self.state==g_bioStateType.lyingFly then
                self:setDirection(faceDir)
            end

            --跳血 
            local offsetY1 = 150
            local offsetY2 = 100
            if self.state==g_bioStateType.lyingFloor or self.state==g_bioStateType.lyingFly then
                offsetY1 = 20
                offsetY2 = 0
            end
            local bCirit = false
            if prot.dType == 1 then 
                bCirit = true
            end
            hurtNumberShow(self:getParent(),faceDir,damage,mainBoneX,mainBoneY+offsetY1,bCirit)
            hitEffect(self:getParent(),faceDir,skillId, mainBoneX,mainBoneY+offsetY2)

            --通过受击技能改变运动轨迹
            self:setMoveLocusBySkill(skillId,dirCoe)
        end
	end
end

--播放动画
function bio:playNewAnimation(actionId)
    local x,y =self:getMainPosition()
    self:setPosition(x,y)
    --draw
    self:stopAllActions()
    if self.shadowObj~=nil then self.shadowObj:removeFromParent() end

    local state=self.state
    --若死亡且处于抛物线运动时,用击飞的动画,直到落地用回死亡动画
    if state==g_bioStateType.death and not self.bDeathFinish then
        state = g_bioStateType.beStrikeFly
    end
    GFArmaturePlayAction(self,self.armatureResId,state,actionId,nil,nil,nil)
    self:createShadow()
    self:restorePresetDirection()

 
    --停掉下帧回调(蛋疼的写法)
    for k,v in pairs(self.onceSchedulerIds) do
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v)
        self.onceSchedulerIds[k] = nil
    end
 
    --动画监听回调
    --整体动画回调
    --@param owner 所属者
    --@param movementType 1-非循环动画播放结束,2-循环动画每次动画播放结束
    --@param movementId 动画标识str
    local function onAnimationMovementEvent(owner,movementType,movementId)
        if movementType==1 then
            if self.dyId==1000 then
                print("movementEvent,movementType=",movementType,"movementId=",movementId,"dyId=",self.dyId,"bioState=",self.state)
            end
            if self.state==g_bioStateType.attackReady or self.state==g_bioStateType.attacking or self.state==g_bioStateType.attackEnd or self.state==g_bioStateType.jumpAttackReady or self.state==g_bioStateType.jumpAttacking or self.state==g_bioStateType.jumpAttackEnd then
                --下一帧切换动作，防止即时删除当前动作造成上层循环指针野掉
                local function timingEnter()
                    self.bAttackAnimOver = true
                    self:finishSkill() 
                    local y = self:getPositionY()
                    if y-self.orgPos.y>10 then
                        self:enterNextState(g_bioStateType.jumpDown)
                    else
                        self:restoreXMoveState()
                    end
                    self:clearOrderQue()
                    if self.onceSchedulerIds[1] then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[1])
                    end
                end

                if self.onceSchedulerIds[1] then 
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[1])
                end
                self.onceSchedulerIds[1] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timingEnter, 0, false)
            end
        end
    end
    self:getAnimation():setMovementEventCallFunc(onAnimationMovementEvent)

    --骨骼动画关键帧回调
    --@param bone 骨骼动画
    --@param eventName 事件tag
    --@param originFrameIndex 预定的触发事件的帧数
    --@param currentFrameIndex 实际触发时的帧数，特殊情况下由丢帧引起的实际触发帧数大于预定帧数
    local function onBoneFrameEvent(bone,eventName,originFrameIndex,currentFrameIndex)
        if self.dyId==1000 then
            print("frameEvent,eventName=",eventName,",dyId=",self.dyId,"bioState=",self.state)
        end
        if self.state==g_bioStateType.attackReady or self.state==g_bioStateType.attacking or self.state==g_bioStateType.jumpAttackReady or self.state==g_bioStateType.jumpAttacking then
            local names = FGUtilStringSplit(eventName,"+")

            for i,name in ipairs(names) do
                if name=="attacking" then
                    self:enterNextState(g_bioStateType.attacking)
                elseif name=="attackEnd" then
                    --下帧回调
                    local function nextFrameFunc()
                        print("nextFrameFunc,dyId=",self.dyId)
                        self:enterNextState(g_bioStateType.attackEnd)
                        self:runNextAttackOrder() 

                        if self.onceSchedulerIds[2] then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[2])
                        end
                    end

                    if self.onceSchedulerIds[2] then 
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[2])
                    end
                    self.onceSchedulerIds[2] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(nextFrameFunc, 0, false)
                elseif name=="jumpAttacking" then
                    self:enterNextState(g_bioStateType.jumpAttacking)
                elseif name=="jumpAttackEnd" then
                    --下帧回调
                    local function nextFrameFunc()
                        print("jumpAttackEndnextFrameFunc,dyId=",self.dyId)
                        self:enterNextState(g_bioStateType.jumpAttackEnd)
                        self:runNextAttackOrder() 

                        if self.onceSchedulerIds[2] then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[2])
                        end
                    end

                    if self.onceSchedulerIds[2] then 
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[2])
                    end
                    self.onceSchedulerIds[2] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(nextFrameFunc, 0, false)
                else
                --通知技能那边的事件
                    if self.skillObj~=nil then
                        self.skillObj:eventHandler(bone,name,originFrameIndex,currentFrameIndex)
                    end
                end
            end

        end
    end
    self:getAnimation():setFrameEventCallFunc(onBoneFrameEvent)

end

--进入下一个指定状态
--@bLocalMachine 是否通过本机改变，默认ture
function bio:enterNextState(state,skillId,bLocalMachine)
    local bSuccess = false
    if bLocalMachine==nil then bLocalMachine = true end

    --当前为多人副本且不为主机时，不允许通过内部改变
    if bLocalMachine and self.sceneManagement:getSceneType()==g_sceneType.onlineFB and g_bMainMachine~=true then
        return bSuccess
    end

    local lastState = self.state
    --通过当前状态和下一个状态组成调用的函数名
    local funcName = g_bioStateStr[self.state].."_to_"..g_bioStateStr[state]
    local changeFunc = self[funcName]
    
    if changeFunc~=nil then
        bSuccess = changeFunc(self)
    end
    if self.dyId==1000 then
        print("funcName=",funcName,"changeFunc=",changeFunc,"bSuccess=",bSuccess," actionId=",actionId)
    end

    if bSuccess then
        --告诉服务器
        if not self.bChangStateByServer then
            self:sendSeverBioState()
        end
        --替换动画
        if self.state~=g_bioStateType.attacking and self.state~=g_bioStateType.attackEnd and self.state~=g_bioStateType.jumpAttacking and self.state~=g_bioStateType.jumpAttackEnd then
            local actionId = nil
            if skillId~=nil then
                --调用skill接口
                self:createSkill(skillId)
                actionId = skillData:getBioArmatureIdBySkillId(skillId)
            end
            self:playNewAnimation(actionId) 
        end

        --当前为多人副本且为主机时，发送多人状态同步协议至其他副机
        self:sendProtMultibioSynchronize(lastState,skillId,nil)
    end

    return bSuccess 
end

--指定方向
--@param g_bioStateType
function bio:setDirection(dir)
    if dir~=self.direction then
        self.direction = dir
        if self.direction==g_bioDirectionType.left then
            self:setFlipX(true)
        else
            self:setFlipX(false)
        end

        --当前为多人副本且为主机时，发送多人状态同步协议至其他副机
        self:sendProtMultibioSynchronize(nil,nil,dir)
    end
end

function bio:setFlipX(bFlipX)
    if bFlipX then
        if self:getScaleX()>0 then
            self:setScaleX(-1*self:getScaleX())
        end
    else
        if self:getScaleX()<0 then
            self:setScaleX(-1*self:getScaleX())
        end 
    end
end

--播放死亡
function bio:playDeath()
    --落地后切换为死亡躺地板动画
    self.bDeathFinish = true
    self:playNewAnimation()

    --动作
    local blink = cc.Blink:create(0.35,2)
    local fadeOut = cc.FadeOut:create(0.45)

    local function removeCallBack()
        print("删除bio,dyId=",self.dyId)
        self:removeFromParent()
    end
        
    self:runAction( cc.Sequence:create( blink,
                                        fadeOut,
                                        cc.CallFunc:create(removeCallBack)
                                        )
                    )

end

--通过程序的位移，另外还有一种位移是通过编辑器
function bio:movingOnCode(dt)
    local vx = self.vx
    local vy = self.vy
    local ay = self.ay
    local vty = vy + ay*dt
    local x, y = self:getPosition()
    if self.direction==g_bioDirectionType.left then vx = -1*vx end

    if vy>0 and vty<=0 then 
        vty = 0
    end

    local disx = vx*dt
    local disy = (vy+vty)/2*dt
    x = x + disx
    y = y + disy

    self.vy = vty

    local tempMiny = self.orgPos.y --人物最低的y

    if self.passiveMoveTime>0 then
        self.passiveMoveTime = self.passiveMoveTime - dt
        if self.passiveMoveTime<=0 then
            self.passiveMoveTime = 0
            y = tempMiny
            self:setPosition(x,y) 
            self.vx = 0
            self.vy = 0
            self.ay = 0
            if self.state==g_bioStateType.beStrikeFly or self.state==g_bioStateType.lyingFly then
                self:enterNextState(g_bioStateType.lyingFloor)
            elseif self.state==g_bioStateType.death then
                self:playDeath()
            end
            return
        end
    else 
        if self.state==g_bioStateType.jumpUp then
            if self.vy==0 then
                y = self.jumpHeight+tempMiny
                self:setPosition(x,y)
                self:enterNextState(g_bioStateType.jumpDown)
                return
            end
        end
        if self.state==g_bioStateType.jumpDown then
            if y<=tempMiny then
                y = tempMiny
                self.ay = 0
                self:setPosition(x,y)
                self:restoreXMoveState()
                return
            end
        end
        
    end
    self:setPosition(x,y) 
end

function bio:aiExecute(dt)
    -- body
end

function bio:updateShadow()
    if self.shadowObj then
        --获取main骨骼坐标
        local x,y=0,0
        local tempBone =self:getBone("main")
        if tempBone then
            local tempBoundingBox =tempBone:getDisplayManager():getBoundingBox()
            local tempAnchorPoint =tempBone:getDisplayManager():getAnchorPoint()
            x= tempBoundingBox.width*tempAnchorPoint.x+tempBoundingBox.x
            y= tempBoundingBox.height*tempAnchorPoint.y+tempBoundingBox.y
        end
        
        --设置坐标
        local posx,posy = self:getPosition()
        self.shadowObj:setPosition(x,-(posy-self.orgPos.y)/self:getScaleY())
        
        --根据人物跳起高度改变scale
        local bonex,boney = self:getMainPosition()
        local offsety = boney  - self.orgPos.y
        local maxHeight = 450
        if offsety>maxHeight then offsety = maxHeight end
        local scale = 1-offsety/self.jumpHeight*0.2
        self.shadowObj:setScale(scale)

    end
end

--循环更新状态
function bio:loopUpdate(dt)
    self:movingOnCode(dt)
    self:correctionPosition()
    self:updateShadow()
    self:aiExecute(dt)
end


return bio

