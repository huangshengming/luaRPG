---按钮周边粒子效果

require("Cocos2d")


menuParticle = {}

menuParticle._index = menuParticle


function menuParticle:createParticle(_obj)

	local par = cc.ParticleSystemQuad:create("Hero/heropaticle.plist")
	par:setPosition( cc.p( _obj:getContentSize().width/2, _obj:getContentSize().height) )
	_obj:addChild(par)

	local bezierConfig_one = { cc.p( _obj:getContentSize().width, _obj:getContentSize().height ),
							   cc.p( _obj:getContentSize().width, 0),
							   cc.p( _obj:getContentSize().width/2, 0)
							 }

	local bezierConfig_two = { cc.p( 0, 0 ),
							   cc.p( 0, _obj:getContentSize().height ),
							   cc.p( _obj:getContentSize().width/2, _obj:getContentSize().height)
							 }

	local bezier_One = cc.BezierTo:create(0.8, bezierConfig_one)
	local bezier_Two = cc.BezierTo:create(0.8, bezierConfig_two)

	par:runAction( cc.RepeatForever:create( cc.Sequence:create( bezier_One, bezier_Two )))

end











return menuParticle