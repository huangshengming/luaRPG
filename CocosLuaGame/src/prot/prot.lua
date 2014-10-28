require("FGProtocolEx")


--所有协议必须在这个文件 require
--战斗内部
require("protBioInstance") 
require("protMultiplayer")

--副本
require("protInstancezones") --11000~11099

--场景
require("protScene")		--29101~29200	



require("protChar")--ID段:200~249


require("protSceneCS")		--9800~9849


require("protBag")-- ID段:9900~9949
require("protEquip")-- ID段:9950~9999

--请保持这个函数在这个文件的最末尾
GFLoadProtToC()
