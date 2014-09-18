

local _tRecMsgvectorViewList={}
local _tRecMsgvectorDataList={}

local _tRecMsgDeque={}

local function _recAddOneMsg(prot)
    
    local tempProt = FGDeepCopy(prot)
    table.insert(_tRecMsgDeque,tempProt)

end

function GFRecOneMsg(prot)
    _recAddOneMsg(prot)
end

function GFRecClearAllMsg()
    _tRecMsgDeque={}
end
function GFRecAddViewListioner(Object)

    local bIsOriginallyHave=false
    for k,v in pairs(_tRecMsgvectorViewList or {}) do
        if v == Object then
            bIsOriginallyHave =true
        end
    end 
    if bIsOriginallyHave==false then
        table.insert(_tRecMsgvectorViewList,Object)
    end

end

function GFRecAddDataListioner(Object)

    local bIsOriginallyHave=false
    for k,v in pairs(_tRecMsgvectorDataList or {}) do
        if v == Object then
            bIsOriginallyHave =true
        end
    end 
    if bIsOriginallyHave==false then
        table.insert(_tRecMsgvectorDataList,Object)
    end

end
function GFRecRemoveListioner(Object)
    for k,v in pairs(_tRecMsgvectorDataList or {}) do
        if v == Object then
            table.remove(_tRecMsgvectorDataList,k)
            break
        end
    end
    
    for k,v in pairs(_tRecMsgvectorViewList or {}) do
        if v == Object then
            table.remove(_tRecMsgvectorViewList,k)
            break
        end
    end
end

function GFRecClearAllListioner()
    _tRecMsgvectorViewList={}
    _tRecMsgvectorDataList={}
end
local function _sendMessageToClinet(prot)

    local tempRecMsgvectorDataList=_tRecMsgvectorDataList
    for k,v in pairs(tempRecMsgvectorDataList or {}) do
        if v then
            print("ddddddfasfasf====")
            if v.recMessageProc then
                v:recMessageProc(prot)
            else
                print("你注册的监听类没有实现 recMessageProc")
            end
          
        end
    end 
    local temptempRecMsgvectorDataList=_tRecMsgvectorViewList
    for k,v in pairs(temptempRecMsgvectorDataList or {}) do
        if v then
            if v.recMessageProc then
                v:recMessageProc(prot)
            else
                print("你注册的监听类没有实现 recMessageProc")
            end

        end
    end 
    
end

function GFRecMessageManageLoop()
    local tempMsgDeque=_tRecMsgDeque
    GFRecClearAllMsg()
    for kk,vv  in pairs(tempMsgDeque or {}) do
        if vv then
            _sendMessageToClinet(vv)
        end  
    end
  
end
