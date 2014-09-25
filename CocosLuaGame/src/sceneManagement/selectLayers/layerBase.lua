--- 屏蔽层 基类
-- 2014-09-18 17:34:09 by zx


require("Cocos2d")

layerBase = class("layerBase")

layerBase.layer        =  nil
layerBase.listener     =  nil

layerBase.__index = layerBase

function layerBase:createLayer(_alpha,_size)
	--layerBase.layer = layerBase.new() 
	local _t = {}
	setmetatable(_t, layerBase)
	local _scale = require("gameWinSize"):getInstance():GetSceneScale()
	local _x, _y = require("gameWinSize"):getInstance():GetSceneOriginPos()
	_t.layer = cc.LayerColor:create(cc.c4b(100,100,100,_alpha), _size.width / _scale, _size.height / _scale)
	if not _t.layer then 
		print("layerBase create failed")
		return nil
	end
	_t.layer:setAnchorPoint(0,0)
	_t.layer:setPosition(-_x,-_y)

	--- 2014-09-19 16:55:09 关闭层按钮 + 事件
	local closeLayer = cc.MenuItemImage:create("l.png","l.png")
	closeLayer:setPosition(0,0)
	local function closeCallBack()
		_t.listener:setEnabled(false)
		_t.listener:setSwallowTouches(false)	
		_t.layer:setVisible(false)
	end
	closeLayer:registerScriptTapHandler(closeCallBack)
	local menu = cc.Menu:create(closeLayer)
	menu:setPosition(600,600)
	_t.layer:addChild(menu)

	
	local function onTouchBegan(touch, event)
		print("屏蔽了下层点击 ( Log Position: layerBase.lua --- 44 by zx )")		
		return true
	end

	local function onTouchMoved(touch, event)
		
	end

    local function onTouchCanceled(touch, event)
        
    end
    
	local function onTouchEnded(touch, event)
		
	end
	_t.listener = cc.EventListenerTouchOneByOne:create()
	_t.listener:setEnabled(false)
	_t.listener:setSwallowTouches(false)	
	_t.listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_t.listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_t.listener:registerScriptHandler(onTouchCanceled, cc.Handler.EVENT_TOUCH_CANCELLED)
	_t.listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = _t.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_t.listener, _t.layer)
	return _t
end
--[[
function layerBase:setLayerVisible(_bool)
	layerBase.layer:setVisible(_bool)
end

function layerBase:GetListener()
	return layerBase.listener
end]]

return layerBase
