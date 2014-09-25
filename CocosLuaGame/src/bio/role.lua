require "Cocos2d"
require("armatureRender.armatureDraw")

local bioClass = require("bio.bio")

local role = class("role",bioClass)

function role:create(dyId,staticId,name,faction)
    local roleTag = role.new(dyId,staticId,name,faction)
 
    return roleTag
end

function role:ctor(dyId,staticId,name,faction)
    print("dyId=",dyId,"name=",name,"self=",type(self))
    self.super.ctor(self,dyId,staticId,name,faction)
end

--设置屏幕左部控制区域命令
function role:setLeftControlOrder(xState,dir)
    print("setLeftControlOrder,xState=",xState)
    local success = self:enterNextState(xState)

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
    local skillIndex = order
    
    local success = self:attack(skillIndex)
    if success then
        self:setDirection(dir)
    else    
        table.insert(self.attackOrderQue,order)
    end
end


return role
