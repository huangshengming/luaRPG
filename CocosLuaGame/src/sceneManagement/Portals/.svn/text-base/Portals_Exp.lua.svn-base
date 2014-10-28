
require("Cocos2d")
require("sceneManagement/Portals/PortalsBase")


Portals_Exp = class("Portals_Exp",PortalsBase)

function Portals_Exp:create(obj,fileName,type,id,x,y)
    local portal = Portals_Exp.new(obj,fileName,type,id,x,y)
    return portal
end

function Portals_Exp:ctor(obj,fileName,type,id,x,y)
    self.super.ctor(self,obj,fileName,type,id,x,y)
    --self.type = type
end


return Portals_Exp
