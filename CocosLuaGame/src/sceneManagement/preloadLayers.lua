--- 各种层
-- 2014-09-24 16:28:57 by zx

require("Cocos2d")

preLoadLayer = class("preLoadLayer")

function preLoadLayer:PreLoadLayer(_obj,_size)

	--人物响应事件
	local _char = require("sceneManagement/selectLayers/character"):create(100,_size)
	_char:SetLayerVisible(false)
	_obj:addChild(_char.layer)
end

return preLoadLayer