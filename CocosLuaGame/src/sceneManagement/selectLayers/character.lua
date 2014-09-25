---character
-- 2014-09-24 16:36:13 by zx

require("Cocos2d")
require("sceneManagement/selectLayers/layerBase")
character = class("character")

setmetatable(character, layerBase)
character.__index = character

function character:create(_alpha,_size)

	local _t_char = layerBase:createLayer(_alpha,_size)
	setmetatable(_t_char, character)
	self.listener = _t_char.listener
	self.layer = _t_char.layer
	local ttf = cc.LabelTTF:create("This is character layer","Airal", 40)
	ttf:setColor(cc.c4b(255,0,0,255))
	ttf:setPosition(500,500)
	_t_char.layer:addChild(ttf)
	return _t_char
end

function character:GetListener()
	return self.listener
end

function character:SetLayerVisible(_bool)
	self.layer:setVisible(_bool)
end

return character
