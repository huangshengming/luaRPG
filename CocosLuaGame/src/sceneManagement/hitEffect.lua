
require("Cocos2d")
require("armatureRender.armatureDraw")
-- 受伤特效
--@param _obj 添加到的对象
--@param _id hiteffId
--@param _x -- X 位置
--@param _y -- Y 位置
function hitEffect(_obj, _direction, _id, _x, _y)
	local _hit = ccs.Armature:create()
	_hit:setPosition(_x, _y)   
	_obj:addChild(_hit,10000)
    require("staticData.configuration")
    local id = g_tSkillData[_id].hiteffId
    local angle = g_tSkillData[_id].angle
    _hit:setRotation( (-1) ^ _direction * -1 * angle )
	GFPlayEffect(_hit,id)
	local function onMovementEvent(armatureBack,movementType, movementId)
		if(movementType==1)then
			_hit:removeFromParent()
		end
	end
	_hit:getAnimation():setMovementEventCallFunc(onMovementEvent)
end
