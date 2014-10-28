
---
-- 左传送门

require("Cocos2d")
require("sceneManagement/Portals/PortalsBase")


Portals_Normal = class("Portals_Normal",PortalsBase)

function Portals_Normal:create(obj,fileName,type,id,x,y)
	local portal = Portals_Normal.new(obj,fileName,type,id,x,y)
	return portal
end

function Portals_Normal:ctor(obj,fileName,type,id,x,y)
	self.super.ctor(self,obj,fileName,type,id,x,y)
	--self.type = type
end

function Portals_Normal:GetToSceneID()
	return self.toSceneID
end

return Portals_Normal


