require "Cocos2d"
require("armatureRender.armatureDraw")

c_standForceCoe = 0.05 
c_flyForceCoe = 1

local skill = require("skill.skill")
local skillData = require("skill.skillDataConf"):getInstance()

local bio = class("bio",function()
         return ccs.Armature:create()
end)

function bio:create(dyId,staticId,name,faction)
    local bioTag = bio.new(dyId,staticId,name,faction)
 
    return bioTag
end

function bio:ctor(dyId,staticId,name,faction)
    print("dyId=",dyId,"name=",name,"self=",type(self))
    --****************属性***********************
    --数据相关
    self.dyId = dyId                              --人物动态id
    self.staticId = 1                             --人物静态id
    --self.orgPos = cc.p(0,200)                   --人物初始坐标Point
    self.sceneLandHeight = 200                    --场景陆地高，即人物站在地面时的高度
    self.name = name                              --人物名称
    self.skillBar = {[1]={1,2,3,},[2]={5,},[3]={4,}}       --人物技能栏,[技能栏id]={连击1，连击2，...}
    self.skillBatterCount = 1                     --当前技能连击数
    self.skillIndexUse = nil                      --当前使用技能的技能栏索引
    self.faction = faction                        --生物派别阵营
    self.armatureName = nil                       --资源名字

    self.state = g_bioStateType.standing          --人物状态
    self.direction = g_bioDirectionType.right     --面朝方向，1-左边，2-右边
    self.xMoveState = g_bioStateType.standing     --x轴移动状态，包括走，跑，站立
    self.presetDirection = nil                    --预设的人物朝向，攻击动作结束后要根据该值调整朝向,nil时表示没有
    self.attackOrderQue = {}                      --攻击指令队列
    self.speedWalkVx = 350                        --人物行走x速度，像素每秒
    self.speedRunVx = 620                         --人物跑步x速度，像素每秒
    self.speedJumpVy = 400                        --人物跳跃y速度
    self.speedJumpAy = -1100                        --跳跃加速度
    --self.speedBeStrikeFlyVy = 400                 --人物被击飞时的x速度
    self.speedBeStrikeFlyAy = -1360                --击飞状态下的加速度
    self.speedBeHitVx = 80                        --人物受击时的x速度  
    self.jumpHeight = 260                         --惹怒跳起的高度
    self.lyingFlyHeight = 50                     --躺飞的高度
    self.lyingFlyLength = 220                    --躺飞的长度
    self.speedLyingFlyAy = -1400                  --躺飞的加速度
    self.vx = 0
    self.vy = 0
    self.ay = 0                                     --y轴加速度
    self.passiveMoveTime = 0                      --人物被动移动的时间
    --self.moveDisx = 0                             --人物需要移动的x距离
    --self.moveDisy = 0                             --人物需要移动的y距离
    self.bAttackAnimOver = false                  --攻击动画是否播放完毕
    self.schedulerId = nil                        --loopUpdate的定时器id
    self.onceSchedulerIds = {}                    --一次性的定时器数组
    self.skillObj = nil                           --释放技能时候的技能对象，最多只有一个
    self.sceneManagement=nil                      --场景管理类
    self.bChangStateByServer = false              --是否由服务器改变状态


    --********************************************

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
            
            if  self.sceneManagement then
                self.sceneManagement:removeOneBio(self)
            end

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
    local correctionX,correctionY= self.sceneManagement:PointInNearBg(mainX,mainY)
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
    self.state = g_bioStateType.beHit

    return success
end

function bio:standing_to_beStrikeFly()
    local success = true
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
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

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
    self.vx = 0
    self.vy = 0
    self.ay = 0
    self.state = g_bioStateType.beHit

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
--
--当前为jumpUp状态时
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

function bio:jumpUp_to_jumpDown()
    local success = false

    local x, y = self:getPosition()
    local tempMiny = self.sceneLandHeight --人物最低的y
    if y==tempMiny+self.jumpHeight then
        success = true
        self.state = g_bioStateType.jumpDown
    end

    return success
end

function bio:jumpUp_to_jumpAttackReady()
    local success = true
    --取消程序的位移,由编辑器预先编辑好的进行改变
    self.vx = 0
    self.vy = 0
    self.bAttackAnimOver = false
    
    return success
end
--
--当前为jumpDown状态时
function bio:jumpDown_to_standing()
    local success = false

    local x, y = self:getPosition()
    if y==self.sceneLandHeight then
        success = true
        self.vx = 0
        self.vy = 0
        self:clearOrderQue()
        self.state = g_bioStateType.standing 
    end
    return success
end

function bio:jumpDown_to_walking()
    local success = false

    local x, y = self:getPosition()
    if y==self.sceneLandHeight then
        success = true
        self.vx = self.speedWalkVx
        self.vy = 0
        self:clearOrderQue()
        self.state = g_bioStateType.walking
    end
    return success
end

function bio:jumpDown_to_running()
    local success = false
    --落地后跑步状态强制转换为走路状态
    success = self:jumpDown_to_walking()
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
--
--当前为attackReady状态
function bio:attackReady_to_attacking()
    local success = true
    self.state = g_bioStateType.attacking
    return success
end

--[[
function bio:attackReady_to_standing()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self.vx = 0
        self.vy = 0
        self.state = g_bioStateType.standing 
    end
    return success
end

function bio:attackReady_to_walking()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self.vx = self.speedWalkVx
        self.vy = 0
        self.state = g_bioStateType.walking
    end
    return success
end

function bio:attackReady_to_running()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self.vx = self.speedRunVx
        self.vy = 0
        self.state = g_bioStateType.running
    end
    return success
end
]]

function bio:attackReady_to_beHit()
    local success = true
    self:skillObjInterrupt()
    self.state = g_bioStateType.beHit

    return success
end

function bio:attackReady_to_beStrikeFly()
    local success = true
    self:skillObjInterrupt()
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

function bio:attacking_to_beHit()
    local success = true
    self:skillObjInterrupt()
    self.state = g_bioStateType.beHit

    return success
end

function bio:attacking_to_beStrikeFly()
    local success = true
    self:skillObjInterrupt()
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

--
--当前为attackEnd状态
function bio:attackEnd_to_attackReady()
    local success = true
    self:skillObjInterrupt()
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
        self.state = g_bioStateType.walking
    end
    return success
end

function bio:attackEnd_to_running()
    local success = false
    if self.bAttackAnimOver then
        success = true
        self.vx = self.speedRunVx
        self.vy = 0
        self.state = g_bioStateType.running
    end
    return success
end

function bio:attackEnd_to_beHit()
    local success = true
    self:skillObjInterrupt()
    self.state = g_bioStateType.beHit

    return success
end

function bio:attackEnd_to_beStrikeFly()
    local success = true
    self:skillObjInterrupt()
    self.state = g_bioStateType.beStrikeFly
    
    return success
end

--
--当前为beHit状态
function bio:beHit_to_standing()
    local success = true
    self.vx = 0
    self.vy = 0
    self:clearOrderQue()
    self.xMoveState = g_bioStateType.standing
    self.state = g_bioStateType.standing
    return success
end

function bio:beHit_to_beStrikeFly()
    local success = true
    self.state = g_bioStateType.beStrikeFly
    
    return success
end
--
--当前为beStrikeFly状态
function bio:beStrikeFly_to_lyingFloor()
    local success = false
    local x, y = self:getPosition()
    if y==self.sceneLandHeight then
        success = true
        self.vx = 0
        self.vy = 0
        self.ay = 0
        self.state = g_bioStateType.lyingFloor
    end
    
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
    if y==self.sceneLandHeight then
        success = true
        self.vx = 0
        self.vy = 0
        self.ay = 0
        self.state = g_bioStateType.lyingFloor
    end
    
    return success
end


--********end**********


--运行攻击指令队列的下一个指令
function bio:runNextAttackOrder()
    if #self.attackOrderQue>0 then
        local success = self:attack(self.attackOrderQue[1])
        if success then
            table.remove(self.attackOrderQue,1)
        end
    end
end

--清楚指令队列
function bio:clearOrderQue()
    self.attackOrderQue = {}
    self.skillIndexUse = nil
    self.skillBatterCount = 1
end

--人物攻击释放技能
function bio:attack(skillIndex)
    local success = false
    
    local skillTree = self.skillBar[skillIndex]
    print("skillIndexUse=",self.skillIndexUse,"skillIndex=",skillIndex,"skillTree=",skillTree,"#skillTree=",#skillTree)
    --该装备位是否有技能连击树
    if type(skillTree)=="table" and #skillTree>0 then
        if self.state==g_bioStateType.attackEnd then
            --在attackEnd只有连击能继续
            if self.skillIndexUse==skillIndex then
                local skillId = skillTree[self.skillBatterCount]
                print("MMM_Batter skillId=",skillId)
                if skillId~=nil then
                --若该技能树仍有连击技能
                    success = self:enterNextState(g_bioStateType.attackReady,skillId)
                end
            end
        elseif self.state==g_bioStateType.standing or self.state==g_bioStateType.walking or self.state==g_bioStateType.running then
            self.skillBatterCount = 1
            local skillId = skillTree[self.skillBatterCount]
            print("MMM_skillId=",skillId)
            success = self:enterNextState(g_bioStateType.attackReady,skillId)
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

--通知skill对象完成
function bio:skillObjFinish()
    if self.skillObj~=nil then
        self.skillObj:finish()
        self.skillObj = nil
    end
end

--通知skill对象打断
function bio:skillObjInterrupt()
    if self.skillObj~=nil then
        self.skillObj:interrupt()
        self.skillObj = nil
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

--接收协议
function bio:recMessageProc(prot)
    if prot.protId==ProBioStatusChange_S2C_ID and self.dyId==prot.dynamicId then
    --状态改变
        local state = prot.status
        print("MMM_ProBioStatusChange_S2C_ID,dyId=",prot.dynamicId,"state=",state)

        self.bChangStateByServer = true
        self:enterNextState(state)
        self.bChangStateByServer = false
    elseif prot.protId==ProtBioDamage_S2C_ID and self.dyId==prot.dynamicId then
        local skillId = prot.skillId
        local faceDir = prot.faceDirection
        local moveDir = prot.moveDirection      --移动方向,1 left 2 right
        local atker = nil
        local dirCoe = -1 --方向正负系数
        if faceDir==moveDir then
            dirCoe = 1
        end
        local mianBoneX,mainBoneY = self:getMainPosition()

        if self.sceneManagement then
            atker = self.sceneManagement:getBioTag(prot.attackDynamicId)
        end
        --调整受击者朝向
        self:setDirection(faceDir)

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
            else
                moveDisx = tagSkill.forceDis[1]*coe
            end
            if moveDisy>0 and ay~=0 then 
                local upTime = math.sqrt(math.abs(2*moveDisy/ay))
                vy = math.abs(ay*upTime)
                local downTime = math.sqrt(math.abs(2*(moveDisy+self:getPositionY()-self.sceneLandHeight)/ay))
                time = upTime + downTime
                vx = moveDisx/time
            elseif moveDisx>0 then
                time = moveDisx/vx
            end
            self.vx = vx*dirCoe
            self.vy = vy
            self.ay = ay
            self.passiveMoveTime = time

        print("MMM_dyId=",prot.dynamicId,"skillId=",skillId,"vx,vy=",self.vx,self.vy,"moveTime=",time)

        else
            print("[erro]skill配置未找到！")
        end
	end
end

--播放动画
function bio:playNewAnimation(actionId)
    --draw
    local x,y =self:getMainPosition()
    self:setPosition(x,y)
    self:stopAllActions()
    GFArmaturePlayAction(self,self.staticId,self.state,actionId,nil,nil,nil)
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
            print("movementEvent,movementType=",movementType,"movementId=",movementId,"bioState=",self.state)
            if self.state==g_bioStateType.attackReady or self.state==g_bioStateType.attacking or self.state==g_bioStateType.attackEnd then
                --下一帧切换动作，防止即时删除当前动作造成上层循环指针野掉
                local function timingEnter()
                    self.bAttackAnimOver = true
                    self:skillObjFinish() 
                    self:restoreXMoveState()
                    self:clearOrderQue()
                    if self.onceSchedulerIds[1] then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[1])
                    end
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
        print("frameEvent,eventName=",eventName,"bioState=",self.state)
        if self.state==g_bioStateType.attackReady or self.state==g_bioStateType.attacking then
            if eventName=="attacking" then
                self:enterNextState(g_bioStateType.attacking)
            elseif eventName=="attackEnd" then
                --下帧回调
                local function nextFrameFunc()
                    --self:skillObjFinish() 
                    self:enterNextState(g_bioStateType.attackEnd)
                    self:runNextAttackOrder() 

                    if self.onceSchedulerIds[2] then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onceSchedulerIds[2])
                    end
                end
                self.onceSchedulerIds[2] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(nextFrameFunc, 0, false)
            else
            --通知技能那边的事件
                if self.skillObj~=nil then
                    self.skillObj:eventHandler(bone,eventName,originFrameIndex,currentFrameIndex)
                end
            end
        end
    end
    self:getAnimation():setFrameEventCallFunc(onBoneFrameEvent)

end

--进入下一个指定状态
function bio:enterNextState(state,skillId)
    local bSuccess = false

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
        if self.state~=g_bioStateType.attacking and self.state~=g_bioStateType.attackEnd then
            local actionId = nil
            if skillId~=nil then
                --调用skill接口
                self.skillObj = skill:create(self,skillId,self.sceneManagement)
                actionId = skillData:getBioArmatureIdBySkillId(skillId)
            end
            self:playNewAnimation(actionId) 
        end
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

    local tempMiny = self.sceneLandHeight --人物最低的y

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

--循环更新状态
function bio:loopUpdate(dt)
    self:movingOnCode(dt)
    self:correctionPosition()
    self:aiExecute(dt)
end


return bio

