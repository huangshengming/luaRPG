
---
-- 场景

require "Cocos2d"
require "math"
require("gameWinSize")

local SceneView = class("SceneView", function ()
    return cc.Scene:create()
end)

function SceneView:createScene(id)
    local scene = SceneView.new()
    if not scene then
        print("create scene failed")
        return nil
    end

    scene:addChild(scene:createLayer(id))
    return scene
end
---
--初始化
function SceneView:ctor()
    self.visibleSize    =   cc.Director:getInstance():getVisibleSize()
    self.visibleOrigin  =   cc.Director:getInstance():getVisibleOrigin()
    self.winSize        =   cc.Director:getInstance():getWinSize()
    self.bg_near        =   nil
    self.bg_far         =   nil
    self.layer          =   nil
    self.scheduleId     =   nil
    self.hero           =   nil
    ---add 9.12
    self.portalsLayer   =   nil
    ---add by liushenli 
    self.standingY      =   200
    self._x             =   0
    self._y             =   0

    ---屏幕偏移 
    --add 9.16 zx
    gameWinSize:getInstance():setSceneScale(self)
    self._x,self._y = gameWinSize:getInstance():GetSceneOriginPos()

    local function onNodeEvent(event)
        if "enter" == event then
            --- 2014年09月17日19:38:09 zx
            -- loading层
            --scene:addChild( require("sceneManagement/loadLayer"):CreateLoadingLayer(1))
            --print("加载资源")
        elseif "cleanup" == event then
            print("----退出----")
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

---
-- 创建层
function SceneView:createLayer(id)
    self.layer = cc.Layer:create()

    self.bg_near = self:AddNearBg()
    if not self.bg_near then
        print("近景创建失败")
    else
        --add 9.12 添加传送门层
        --self.bg_near:addChild(self:createPorsLayer(),0)
    end

    self.bg_far = self:AddFarBg()
    if not self.bg_far then
        print("远景创建失败")
    end
    
    ---
    -- 添加背景层
    self.layer:addChild(self.bg_far)
    self.layer:addChild(self.bg_near)
    ---
    -- 设置背景偏移量
    self.bg_far:setPosition(-self._x,220)
    self.bg_near:setPosition(-self._x,-self._y)
        
    local centerPos     =   cc.p(self.winSize.width/2,self.winSize.height/2)                                    -- 屏幕中心点
    local originPoint   =   cc.p( -1 * self._x, -1 * self._y )                                                  -- 像素点，(偏移了)
    local heroPos       =   cc.p( 0, 0 )                                                                        -- 帅哥，美眉初始点     
    local scenePos      =   cc.p( 0, 0 )                                                                        -- 屏幕位置
    local LBCenterPos   =   centerPos                                                                           --  ↙  中心点
    local LTCenterPos   =   { x = centerPos.x, y = self.bg_near:getContentSize().height + 220 - centerPos.y }   --  ↖  中心点
    local RBCenterPos   =   { x = self.bg_near:getContentSize().width - centerPos.x, y = centerPos.y }          --  ↘  中心点
    local RTCenterPos   =   { x = self.bg_near:getContentSize().width - centerPos.x, 
                              y = self.bg_near:getContentSize().height + 220 - centerPos.y }                    --  ↗  中心点
    local persentX      =   ( self.bg_far:getContentSize().width  - self.winSize.width - self._x * 2 ) / 
                            ( self.bg_near:getContentSize().width - self.winSize.width - self._x * 2 )          -- 速度比例
    local persentY      =   0.3                                                                                 -- 非固定值
    local newPos        =   cc.p( 0, 0 )                                                                        -- 远景位置

    local function update()

        if self.hero then
            local perNearPos = cc.p( self.bg_near:getPositionX(), self.bg_near:getPositionY() )
            local heroXMove  = false         --
            local heroYMove  = false    

            heroPos.x , heroPos.y   =   self.hero:getMainPosition()
            scenePos.x  =   self.bg_near:getPositionX()
            scenePos.y  =   self.bg_near:getPositionY()

            if heroPos.x < LBCenterPos.x - originPoint.x then
                scenePos.x = originPoint.x;
            elseif heroPos.x > RBCenterPos.x + originPoint.x then
                scenePos.x = LBCenterPos.x - RBCenterPos.x - originPoint.x                
            else
                heroXMove = true
            end
       
            if heroPos.y < LBCenterPos.y - originPoint.y then
                scenePos.y = originPoint.y
            elseif heroPos.y > LTCenterPos.y + originPoint.y then
                scenePos.y = ( LBCenterPos.y - LTCenterPos.y ) - originPoint.y
            else
                heroYMove = true
            end

            self.bg_near:setPosition( scenePos.x, scenePos.y )

            if heroXMove or heroYMove then

                local moveToPos = scenePos

                if heroXMove then
                    moveToPos.x = ( LBCenterPos.x - heroPos.x ) 
                end
        
                if heroYMove then
                    moveToPos.y = ( LBCenterPos.y - heroPos.y ) 
                end

                self.bg_near:setPosition( moveToPos.x, moveToPos.y )
            end

            local currNearPos = cc.p( self.bg_near:getPositionX(), self.bg_near:getPositionY() )
            local changeX = currNearPos.x - perNearPos.x 
            local changeY = currNearPos.y - perNearPos.y
            newPos.x = self.bg_far:getPositionX() + changeX * persentX 
            newPos.y = self.bg_far:getPositionY() + changeY * persentY
            self.bg_far:setPosition( newPos )
            
            ---
            -- 9.17 传送门碰撞
            --self.portalsLayer:IsCollide(self.hero)
        else
            print("update() ---> Hero对象为空")
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId)
        end
    end
    self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)

    return self.layer
end

-- 坐标点判断
function SceneView:PointInNearBg(x,y)
    local _x, _y = x, y
    if _x < 0 then 
        _x = 0
    end
    if  _x > ( self.bg_near:getContentSize().width ) then
        _x = ( self.bg_near:getContentSize().width )  
    end

    if  _y < self.standingY then
        _y = self.standingY
    end
    if  _y > self.bg_near:getContentSize().height then
        _y = self.bg_near:getContentSize().height
    end
    return _x, _y
end

function SceneView:getStandingY()
    return self.standingY or 200
end

---add 9.12
function SceneView:createPorsLayer()
    local _layer = require("sceneManagement/Portals/PortalsLayer")
    self.portalsLayer  = _layer:createPortalsLayer()
    if self.portalsLayer then
        self.portalsLayer:setAnchorPoint(0,0)
        self.portalsLayer:setPosition(0,0)
        return self.portalsLayer 
    else
        print("create PortalsLayer failed")
        return nil
    end 
end

function SceneView:SetHero(hero)
    self.hero = hero
end

function SceneView:GetHero()
    return self.hero
end

function SceneView:AddFarBg()
    local _bgfar = cc.Sprite:create("far.jpg")
    _bgfar:setAnchorPoint(0,0)
    return _bgfar
end

---
-- @return _bgnear 近景对象
function SceneView:AddNearBg()
    local _bgnear = cc.Sprite:create("near.png")
    _bgnear:setAnchorPoint(0,0) 
    return _bgnear
end

function SceneView:GetLayer()
    if self.layer then 
        return self.layer
    else
        print("self.layer is nil")
    end
end

function SceneView:GetFarBg()
    if self.bg_far then
        return self.bg_far
    else
        print("self.bg_far is nil")
    end
end
---
-- 返回近景层
function SceneView:GetNearBg()
    if self.bg_near then
        return self.bg_near
    else
        print("self.bg_near is nil")
    end
end

return SceneView