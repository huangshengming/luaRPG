require("FGProtocolEx")
--require("FGLuaToolFunc")
--FGProtWrite = FGProtWrite   -- @param (buffer,bufferlen,fd,protId,prot)
							-- @return the length written
FGProtRead = FGProtRead     -- @param (buffer,bufferlen,prot)
							-- @return the length read
FGProtPick = FGProtPick     -- @param (buffer,bufferlen)
							-- @return fd,protId,pkgLength so can match the prot format
FGProtGet = FGProtGet       -- @param (protId)
							-- @return the protocol witch ID is protId
FGProtRegHandler = FGProtRegHandler
FGProtGetHandler = FGProtGetHandler

-- 注意FGProtInclude的协议文件只能放在prot目录下

--战斗内部
require("protBioInstance") -- 10001-10100





