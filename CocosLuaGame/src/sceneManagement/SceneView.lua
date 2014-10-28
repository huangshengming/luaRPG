
---
-- 场景

require "Cocos2d"
require "math"
require("gameWinSize")

sceneView = class("sceneView", function ()
    return cc.Scene:create()
end)
---2014-09-19 15:22:20 by zx
local SceneView = sceneView
---
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
    self.standingY      =   150
    self._x             =   0
    self._y             =   0

    ---屏幕偏移 
    --add 9.16 zx
    gameWinSize:getInstance():setSceneScale(self)
    self._x,self._y = gameWinSize:getInstance():GetSceneOriginPos()
    local function onNodeEvent(event)
        if "enter" == event then
            
        elseif "cleanup" == event then
            print("----退出----  ( Log Position: SceneView.lua --- 56 by zx )")
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
        print("近景创建失败  ( Log Position: SceneView.lua --- 70 by zx )")
    else
        --add 9.12 添加传送门层
        --self.bg_near:addChild(self:createPorsLayer(),0)
    end

    self.bg_far = self:AddFarBg()
    if not self.bg_far then
        print("远景创建失败( Log Position: SceneView.lua --- 78 by zx )")
    end
        
    ---
    -- 添加背景层
    self.layer:addChild(self.bg_far)
    self.layer:addChild(self.bg_near)
    
    
    ---
    -- 设置背景偏移量
    self.bg_far:setPosition(-self._x,210)
    self.bg_near:setPosition(-self._x,-self._y)
    self.bg_near:addChild(self:createPorsLayer(),0)   
    local centerPos     =   cc.p(self.winSize.width/2,self.winSize.height/2)                                    -- 屏幕中心点
    local originPoint   =   cc.p( -1 * self._x, -1 * self._y )                                                  -- 像素点，(偏移了)
    local heroPos       =   cc.p( 0, 0 )                                                                        -- 帅哥，美眉初始点     
    local scenePos      =   cc.p( 0, 0 )                                                                        -- 屏幕位置
    local LBCenterPos   =   centerPos                                                                           --  ↙  中心点
    local LTCenterPos   =   { x = centerPos.x, y = self.bg_near:getContentSize().height + 210 - centerPos.y }   --  ↖  中心点
    local RBCenterPos   =   { x = self.bg_near:getContentSize().width - centerPos.x, y = centerPos.y }          --  ↘  中心点
    local RTCenterPos   =   { x = self.bg_near:getContentSize().width - centerPos.x, 
                              y = self.bg_near:getContentSize().height + 210 - centerPos.y }                    --  ↗  中心点
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
            self.portalsLayer:IsCollide(self.hero)
        else
            print("update() ---> Hero对象为空 ( Log Position: SceneView.lua --- 160 by zx )")
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId)
        end
        
    end
    self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false) 

    




    --- 区域显示
    -- 2014-09-19 23:06:50 by zx
    --[[local showRect = cc.MenuItemImage:create("menu1.png","menu1.png")
    showRect:setRotation( -1 * 45)
    showRect:setVisible(false)
    showRect:setPosition(0,0)
    local function p()
        local sm = require("sceneManagement.sceneManagement"):getInstance()
        local _boilist = sm:getBoiList()
        if true == g_bIsShowEditerCollider then
            g_bIsShowEditerCollider=false
        else
            g_bIsShowEditerCollider=true
        end
        for k,v in pairs(_boilist) do
            GFSetEditerColliderVisible(v,g_bIsShowEditerCollider)
        end
    end
    showRect:registerScriptTapHandler(p)
    showRect:setGlobalZOrder(10)]]

    --UI 显示
    --[[local showUI = cc.MenuItemImage:create("menu1.png","menu1.png")
    showUI:setPosition(200,0)
    showUI:setVisible(false)
    local function pp()
        
        if true == g_bIsShowUI then
            UILayer:setVisible(false)
            g_bIsShowUI=false
        else
            UILayer:setVisible(true)
            g_bIsShowUI=true
        end
    end
    showUI:registerScriptTapHandler(pp)
    showUI:setGlobalZOrder(10)

     local menu = cc.Menu:create(showRect,showUI)
     menu:setPosition(480,600)
    self.layer:addChild(menu)]]
    ---
    
    return self.layer
end

-- 坐标点判断
function SceneView:PointInNearBg(object)
    local _x, _y = object:getMainPosition()
    if _x < 50 then 
        _x = 50
    end
    if  _x > ( self.bg_near:getContentSize().width - 50 ) then
        _x = ( self.bg_near:getContentSize().width - 50)  
    end

    if  _y < object.orgPos.y then
        _y = object.orgPos.y --self.standingY
    end

    if  _y > self.bg_far:getContentSize().height+self.bg_far:getPositionY() then
        _y = self.bg_far:getContentSize().height+self.bg_far:getPositionY()
    end
    return _x, _y
end

function SceneView:getStandingY()
    return self.standingY or 200
end

---add 9.12
function SceneView:createPorsLayer()
    local _layer = require("sceneManagement.Portals.PortalsLayer")
    self.portalsLayer  = _layer:createPortalsLayer(0,self.visibleSize.height/2,2275,self.visibleSize.height/2,500,self.visibleSize.height/2,1000,self.visibleSize.height/2)
    if self.portalsLayer then
        self.portalsLayer:setAnchorPoint(0,0)
        self.portalsLayer:setPosition(-self._x,-self._y)
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
    local _bgfar = cc.Sprite:create("far4.jpg")
    _bgfar:setAnchorPoint(0,0)
    return _bgfar
end

---
-- @return _bgnear 近景对象
function SceneView:AddNearBg()
    local _bgnear = cc.Sprite:create("near4.png")
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

function SceneView:GetNearBgXLeft()
    if self.bg_near then
        return self.bg_near:getPositionX() 
    end
end

function SceneView:GetNearBgXRight()
    if self.bg_near then
        return self.bg_near:getContentSize().width
    end
end

function SceneView:GetFarBgXLeft()
    if self.bg_far then
        return self.bg_far:getPositionX()
    end
end

function SceneView:GetFarBgXRight()
    if self.bg_far then
        return self.bg_far:getContentSize().width
    end
end


return SceneView
