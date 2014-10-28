
---
-- 传送门基类

require("Cocos2d")


PortalsBase = class("PortalsBase")

function PortalsBase:create(obj,fileName,type,id,x,y)
	local portal = PortalsBase.new(obj,fileName,type,id,x,y)
	return portal
end

function PortalsBase:ctor(obj,fileName,type,id,x,y)
	if NULL ~= obj and  NULL ~= fileName and  NULL ~= type then  
		self.sprite = cc.Sprite:create(fileName)
		self.type = type         --传送门类型
		self.toSceneID = id       --传送门连接的场景ID
		self.sprite:setPosition(x,y)
		obj:addChild(self.sprite)
	end
end

