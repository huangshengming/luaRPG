
require("Cocos2d")
require("sceneManagement/Portals/PortalsBase")


Portals_FB = class("Portals_FB",PortalsBase)

function Portals_FB:create(obj,fileName,type,id,x,y)
    local portal = Portals_FB.new(obj,fileName,type,id,x,y)
    return portal
end

function Portals_FB:ctor(obj,fileName,type,id,x,y)
    self.super.ctor(self,obj,fileName,type,id,x,y)
    --self.type = type
end


return Portals_FB


