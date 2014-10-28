require "Cocos2d"
require("armatureRender.armatureDraw")

local bioClass = require("bio.bio")

local role = class("role",bioClass)

function role:create(dyId,staticId,name,faction,x,y,armatureResId)
    local roleTag = role.new(dyId,staticId,name,faction,x,y,armatureResId)
 
    return roleTag
end

function role:ctor(dyId,staticId,name,faction,x,y,armatureResId)
    self.super.ctor(self,dyId,staticId,name,faction,x,y,armatureResId)
end

--设置屏幕左部控制区域命令
function role:setLeftControlOrder(xState,dir)
    --print("setLeftControlOrder,xState=",xState)
    if self.state==g_bioStateType.beHit or self.state==g_bioStateType.lyingFloor or self.state==g_bioStateType.beStrikeFly or self.state==g_bioStateType.lyingFly or self.state==g_bioStateType.beRebound or self.state==g_bioStateType.death then
    --当为如上状态时，不允许外部改变
        return
    end

    local success = false
    if self.state~=g_bioStateType.attackEnd and self.state~=g_bioStateType.jumpAttackEnd then
        success = self:enterNextState(xState)
    end

    if dir~=nil then
        if self.state==g_bioStateType.standing or self.state==g_bioStateType.walking or self.state==g_bioStateType.running or self.state==g_bioStateType.jumpUp or self.state==g_bioStateType.jumpDown then
            self:setDirection(dir)
        else
            self.presetDirection = dir
        end
    end

    if not success and self.state~=g_bioStateType.standing and self.state~=g_bioStateType.walking and self.state~=g_bioStateType.running then
        self.xMoveState = xState
    end
end

--设置屏幕右部控制区域攻击命令
function role:setRightControlAttackOrder(order,dir)
    print("MM__skillIndex==",order)
    
    self:inputAttackOrder(order,dir)
end


return role
