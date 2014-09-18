require "Cocos2d"
require("armatureRender.armatureDraw")


local bio = class("bio",function()
         return ccs.Armature:create()
end)

function bio:create(dyId,name)
    local bioTag = bio.new(dyId,name)
 
    return bioTag
end

function bio:ctor(dyId,name)
    print("dyId=",dyId,"name=",name,"self=",type(self))
    --****************属性***********************
    self.dyId = dyId                              --人物动态id
    self.staticId = 1                        --人物静态id
    --self.orgPos = cc.p(0,200)                   --人物初始坐标Point
    self.sceneLandHeight = 200                    --场景陆地高，即人物站在地面时的高度
    self.name = name                              --人物名称
    self.state = g_bioStateType.standing          --人物状态
    self.direction = g_bioDirectionType.right      --面朝方向，1-左边，2-右边
    self.xMoveState = g_bioStateType.standing     --x轴移动状态，包括走，跑，站立
    self.preSetDirection = nil                    --预设的人物朝向，攻击动作结束后要根据该值调整朝向,nil时表示没有
    self.attackOrderQue = {}                      --攻击指令队列
    self.speedWalkVx = 350                        --人物行走x速度，像素每秒
    self.speedRunVx = 620                         --人物跑步x速度，像素每秒
    self.speedJumpVy = 400                        --人物跳跃y速度
    self.jumpHeight = 260
    self.vx = 0
    self.vy = 0
    self.bAttackAnimOver = false                  --攻击动画是否播放完毕
    self.schedulerId = nil                        --loopUpdate的定时器id
    self.onceSchedulerId = nil                    --一次性的定时器
    self.sceneManagement=nil                      --场景管理类


    --********************************************
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
        end
    end
    self:registerScriptHandler(onNodeEvent)

    --进入站立状态
    GFArmaturePlayAction(self,self.staticId,self.state,nil,nil,nil,nil)

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
    local tempPoint=self:convertToWorldSpaceAR(cc.p(x,y))
    if self:getParent() then
        tempPoint = self:getParent():convertToNodeSpaceAR(tempPoint)
    end
    return tempPoint.x,tempPoint.y
end

--************************************************************
--动画监听回调
--
--整体动画回调
--@param bio 所属者
--@param movementType 1-非循环动画播放结束,2-循环动画每次动画播放结束
--@param movementId 动画标识str
function bio.onAnimationMovementEvent(bio,movementType,movementId)
    if movementType==1 then
        print("movementEvent,movementType=",movementType,"movementId=",movementId,"bioState=",bio.state)
        if bio.state==g_bioStateType.attackReady or bio.state==g_bioStateType.attacking or bio.state==g_bioStateType.attackEnd then
            bio.bAttackAnimOver = true

            --下一帧切换动作，防止即时删除当前动作造成上层循环指针野掉
            local function timingEnter()
                bio:enterNextState(bio.xMoveState)
                if bio.preSetDirection~=nil then
                    bio:setDirection(bio.preSetDirection)
                    bio.preSetDirection = nil
                end
                if bio.onceSchedulerId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(bio.onceSchedulerId)
                end
            end

            bio.onceSchedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timingEnter, 0, false)
        end
    end
end

--骨骼动画关键帧回调
--@param bone 骨骼动画
--@param eventName 事件tag
--@param originFrameIndex 预定的触发事件的帧数
--@param currentFrameIndex 实际触发时的帧数，特殊情况下由丢帧引起的实际触发帧数大于预定帧数
function bio.onBoneFrameEvent(bone,eventName,originFrameIndex,currentFrameIndex)
    local bio = bone:getArmature()
    print("frameEvent,eventName=",eventName,"bioState=",bio.state)
    if bio.state==g_bioStateType.attackReady then
        if eventName=="attacking" then
        end
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
    self.xMoveState = g_bioStateType.walking
    self.vx = self.speedWalkVx
    self.vy = 0
    self.state = g_bioStateType.walking
    return success
end

function bio:standing_to_running()
    local success = true
    self.xMoveState = g_bioStateType.running
    self.vx = self.speedRunVx
    self.vy = 0
    self.state = g_bioStateType.running
    return success
end

function bio:standing_to_jumpUp()
    local success = true
    self.vx = 0
    self.vy = self.speedJumpVy
    self.state = g_bioStateType.jumpUp
    return success
end

function bio:standing_to_attackReady()
    local success = true
    self.vx = 0
    self.vy = 0
    self.state = g_bioStateType.attackReady
    self.bAttackAnimOver = false

    return success
end
--
--当前为walking状态时
function bio:walking_to_standing()
    local success = true
    self.xMoveState = g_bioStateType.standing
    self.vx = 0
    self.vy = 0
    self.state = g_bioStateType.standing
    return success
end

function bio:walking_to_jumpUp()
    local success = true
    self.vx = self.speedWalkVx
    self.vy = self.speedJumpVy
    self.state = g_bioStateType.jumpUp
    return success
end
--
--当前为running状态时
function bio:running_to_standing()
    local success = true
    self.xMoveState = g_bioStateType.standing
    self.vx = 0
    self.vy = 0
    self.state = g_bioStateType.standing
    return success
end

function bio:running_to_jumpUp()
    local success = true
    self.vx = self.speedRunVx
    self.vy = self.speedJumpVy
    self.state = g_bioStateType.jumpUp
    return success
end

--
--当前为jumpUp状态时
function bio:jumpUp_to_walking()
    local success = false
    self.xMoveState = g_bioStateType.walking
    self.vx = self.speedWalkVx
    return success
end

function bio:jumpUp_to_runnig()
    local success = false
    self.xMoveState = g_bioStateType.running
    --若在空中时，当前x速度不为跑步速度，则取用walk的x速度
    if self.vx~=self.speedRunVx then
        self.vx = self.speedWalkVx
    end
    return success
end

function bio:jumpUp_to_jumpDown()
    local success = false

    local x, y = self:getPosition()
    local tempMiny = self.sceneLandHeight --人物最低的y
    if y==tempMiny+self.jumpHeight then
        success = true
        self.vy = -1*self.speedJumpVy
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
    self.xMoveState = g_bioStateType.standing

    local x, y = self:getPosition()
    if y==self.sceneLandHeight then
        success = true
        self.vx = 0
        self.vy = 0
        self.state = g_bioStateType.standing 
    end
    return success
end

function bio:jumpDown_to_walking()
    local success = false
    self.xMoveState = g_bioStateType.walking

    local x, y = self:getPosition()
    if y==self.sceneLandHeight then
        success = true
        self.vx = self.speedWalkVx
        self.vy = 0
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
--
--当前为attackReady状态
function bio:attackReady_to_attackReady()
    return false
end

function bio:attackReady_to_attacking()
    local success = true
    self.state = g_bioStateType.attacking
    return success
end

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

--
--当前为attacking状态
function bio:attacking_to_attackEnd()
end

--
--当前为attackEnd状态
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

--********end**********


--设置屏幕左部控制区域命令
function bio:setLeftControlOrder(xState,dir)
    local success = self:enterNextState(xState)
    if dir~=nil then
        if success or self.state==g_bioStateType.standing or self.state==g_bioStateType.walking or self.state==g_bioStateType.running or self.state==g_bioStateType.jumpUp or self.state==g_bioStateType.jumpDown then
            self:setDirection(dir)
        else
            self.preSetDirection = dir
        end
    end
    if not success then
        self.xMoveState = xState
    end
end

--设置屏幕右部控制区域命令
function bio:setRightControlOrder(order)
    local success = self:enterNextState(g_bioStateType.attackReady)
    if not success then
        table.insert(self.attackOrderQue,order)
    end
end

--播放动画
function bio:playNewAnimation()
    --draw
    local x,y =self:getMainPosition()
    self:setPosition(x,y)
    self:stopAllActions()
    GFArmaturePlayAction(self,self.staticId,self.state,1,nil,nil,nil)
    self:getAnimation():setMovementEventCallFunc(self.onAnimationMovementEvent)
    self:getAnimation():setFrameEventCallFunc(self.onBoneFrameEvent)
end

--进入下一个指定状态
function bio:enterNextState(state)
    local bSuccess = false

    --通过当前状态和下一个状态组成调用的函数名
    local funcName = g_bioStateStr[self.state].."_to_"..g_bioStateStr[state]
    local changeFunc = self[funcName]
    
    if changeFunc~=nil then
        bSuccess = changeFunc(self)
    end
    print("funcName=",funcName,"changeFunc=",changeFunc,"bSuccess=",bSuccess)

    if bSuccess then
        self:playNewAnimation() 
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
            self:setScaleX(self:getScaleX()*-1)
        end
    else
        if self:getScaleX()<0 then
            self:setScaleX(self:getScaleX()*-1)
        end 
    end
end

--通过程序的位移，另外还有一种位移是通过编辑器
function bio:movingOnCode(dt)
    local vx = self.vx
    local vy = self.vy
    local x, y = self:getPosition()
    if self.direction==g_bioDirectionType.left then vx = -1*vx end

    x = x + vx*dt
    y = y + vy*dt
    
    local tempMiny = self.sceneLandHeight --人物最低的y


    if self.state==g_bioStateType.jumpUp then
        if y>=self.jumpHeight+tempMiny then
            y = self.jumpHeight+tempMiny
            self:setPosition(x,y)
            self:enterNextState(g_bioStateType.jumpDown)
            return
        end
    end
    if self.state==g_bioStateType.jumpDown then
        if y<=tempMiny then
            y = tempMiny
            self:setPosition(x,y)
            self:enterNextState(self.xMoveState)
            return
        end
    end
    
    self:setPosition(x,y) 
end

--循环更新状态
function bio:loopUpdate(dt)
    self:movingOnCode(dt)
    self:correctionPosition()
end


return bio

