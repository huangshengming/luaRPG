--- 伤害数字显示
-- 2014-09-20 13:44:44 by zx 

--- 测试用例
	-- local t = require("sceneManagement.hurtNumber"):createNumber("受伤对象",受伤数值,是否是暴击( true or false ))
 	-- t:runCustomAction()
---


require("Cocos2d")

HurtNumber = class("HurtNumber", function(_ttfConfig, _num)
	return cc.Label:createWithTTF(_ttfConfig, _num)
end)

HurtNumber.hurt 	= nil			--伤害对象
HurtNumber.isCrit 	= nil			--暴击判断
--HurtNumber.__index = HurtNumber

function HurtNumber:createNumber(_body,_num,_bool)
	--local _scale = require("gameWinSize"):getInstance():GetSceneScale()
	--local _x, _y = require("gameWinSize"):getInstance():GetSceneOriginPos()
	local num = string.format("-%d", _num)
	--- fuck 
	local ttfConfig = {}
    ttfConfig.fontFilePath = "fonts/arial.ttf"
    ttfConfig.fontSize = 32
	HurtNumber.hurt = HurtNumber.new(ttfConfig, num)
	HurtNumber.hurt:retain()
	HurtNumber.hurt:setPosition( 0, 100)
	if _bool then 
		HurtNumber.hurt:setTextColor(cc.c4b(255,0,0,255)) 
	else
		HurtNumber.hurt:setTextColor(cc.c4b(255,255,0,255)) 
	end
	_body:addChild(HurtNumber.hurt,1)
	HurtNumber.isCrit = _bool
	return HurtNumber.hurt
end

--- 伤害数字运动
-- 2014-09-20 15:59:10
function HurtNumber:runCustomAction()

	if HurtNumber.hurt then
		--- Bezier 曲线
		local _bezierConfig = { cc.p( 0  , 30 ),
								cc.p( 60 , 30 ),
								cc.p( 60 , 0  ),
							  } 
		local bezierBy = cc.BezierBy:create(0.5, _bezierConfig)

		--- Move
		local moveBy = cc.MoveBy:create(0.5, { x = 0, y = 10})
		--- Fade
		local fadeIn  = cc.FadeIn:create(0.5)
		local fadeOut = cc.FadeOut:create(0.5)

		---Scale
		local scale = ( HurtNumber.isCrit ) and ( cc.ScaleTo:create(0.5,3) ) or ( cc.ScaleTo:create(0.5, 1.5) )

	    local function hurtCallBack()
	    	if HurtNumber.hurt then
	    		print("移除了伤害。 ( Log Position: hurtNumber.lua -- 64 by zx)")
	        	HurtNumber.hurt:removeFromParent()
	    	end
	    end

		HurtNumber.hurt:runAction(cc.Sequence:create( cc.Spawn:create(bezierBy, fadeIn, scale ) , 
													  fadeOut, 
													  cc.CallFunc:create(hurtCallBack)
													)
								 )
		end
end


return HurtNumber