
---传送门层

require("Cocos2d")
require("sceneManagement/Portals/Portals_Normal")
require("sceneManagement/Portals/Portals_FB")
require("sceneManagement/Portals/Portals_Exp")
require("sceneManagement/Portals/PassButton")
PortalsLayer = class("PortalsLayer", function()
	return cc.Layer:create()
end)

---
-- 创建层
function PortalsLayer:createPortalsLayer(_x_left, _y_left, _x_right, _y_right, _x_fb, _y_fb, _x_exp, _y_exp)
	local layer = PortalsLayer.new(_x_left, _y_left,  _x_right, _y_right, _x_fb, _y_fb, _x_exp, _y_exp)

    return layer
end

function PortalsLayer:ctor(_x_left, _y_left, _x_right, _y_right, _x_fb, _y_fb, _x_exp, _y_exp)

    self.left = Portals_Normal:create(self,"door.png","left",1,_x_left,_y_left)
    self.right = Portals_Normal:create(self,"door.png","right",1,_x_right,_y_right)
    self.fb = Portals_FB:create(self,"door.png","fb",1,_x_fb,_y_fb)
    self.exp = Portals_Exp:create(self,"door.png","exp",1,_x_exp,_y_exp)
    self.pass = PassButton:create("menu1.png")
    self.pass:setShow(false)
    self.pass:setGlobalZOrder(10000)
    self.menu = cc.Menu:create(self.pass)
    self:addChild(self.menu)


    -----测试
    self.left.sprite:setVisible(false)
    self.right.sprite:setVisible(false)
    self.fb.sprite:setVisible(false)
end


function PortalsLayer:HeroInLayerRect(hero)
    local _p = self:convertToNodeSpace({x = hero:getPositionX(), y = hero:getPositionY() })
    return cc.rect( _p.x - hero:getContentSize().width/2,
                    _p.x - hero:getContentSize().height/2,
                    hero:getContentSize().width/2,
                    hero:getContentSize().height/2)
end

function PortalsLayer:IsCollide(hero)
    if cc.rectIntersectsRect(self:HeroInLayerRect(hero),self:HeroInLayerRect(self.left.sprite)) then
        --左门碰撞，传送
        --print(self.left.type)
        --cc.Director:getInstance():replaceScene(scene[self.left.toSceneID])
    elseif cc.rectIntersectsRect(self:HeroInLayerRect(hero),self:HeroInLayerRect(self.right.sprite)) then
        --右门碰撞，传送
        --print(self.right.type)
        --cc.Director:getInstance():replaceScene(scene[self.right.toSceneID])
    elseif cc.rectIntersectsRect(self:HeroInLayerRect(hero),self:HeroInLayerRect(self.fb.sprite)) then
        --副本们碰撞，显示passButton
        --self.menu:setPosition(self.fb.sprite:getPositionX(),self.fb.sprite:getPositionY() + self.fb.sprite:getContentSize().height/2 + 100 ) 
        --self.pass:setShow(true)
        --self.pass:setType(1)
        --print(self.pass.type)
       
    elseif cc.rectIntersectsRect(self:HeroInLayerRect(hero),self:HeroInLayerRect(self.exp.sprite)) then
        --经验门碰撞，显示passButton
        self.menu:setPosition(self.exp.sprite:getPositionX(),self.exp.sprite:getPositionY() + self.exp.sprite:getContentSize().height/2 + 100 )
        self.pass:setShow(true)
        self.pass:setType(2)
        --print(self.pass.type)
    else
        self.pass:setShow(false)
    end
end

function PortalsLayer:GetLeftPor()
    return self.left
end

function PortalsLayer:GetRightPor()
    return self.right
end

function PortalsLayer:GetFBPor()
    return self.fb
end

function PortalsLayer:GetExpPor()
    return self.exp
end
--[[
---
-- 获得传送门 4个 对象
function PortalsLayer:GetPortalsObj()
    if PortalsLayer.left and PortalsLayer.right and PortalsLayer.fb and PortalsLayer.exp then
	   return self:GetLeftPor(), PortalsLayer:GetRightPor(), PortalsLayer:GetFBPor(), PortalsLayer:GetExpPor()
    else
        print("have someone door is nil")
    end
end]]
--[[
function PortalsLayer:GetLayer()
    return self
end]]

return PortalsLayer