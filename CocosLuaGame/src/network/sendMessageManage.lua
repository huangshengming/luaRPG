

local _tSendMsgvectorList={}


local _tSendMsgDeque={}


local function _sendAddOneMsg(prot)

    local tempProt = FGDeepCopy(prot)
    table.insert(_tSendMsgDeque,tempProt)
end
--登录服发送消息
function GFLonginSendOneMsg(prot,isNeedLoading)
    shortLinkSendProt(CONF_LONGINSERVER_URL,prot.protId,prot)
end
--非登录的发送消息
function GFSendOneMsg(prot,isNeedLoading)
    if isNeedLoading==nil then
        isNeedLoading= false
    end
    --内部消息 
    if prot.protId < g_protType.internal and prot.protId>g_protType.longConnection then
        _sendAddOneMsg(prot)
    end
    --短连接
    if prot.protId < g_protType.shortConnection and prot.protId>0 then
        shortLinkSendProt(g_logicServerUrl,prot.protId,prot)
    end
end

function GFSendClearAllMsg()
    _tSendMsgDeque={}
end
function GFSendAddListioner(Object)

    local bIsOriginallyHave=false
    for k,v in pairs(_tSendMsgvectorList or {}) do
        if v == Object then
            bIsOriginallyHave =true
        end
    end 
    if bIsOriginallyHave==false then
        table.insert(_tSendMsgvectorList,Object)
    end

end

function GFSendRemoveListioner(Object)
    for k,v in pairs(_tSendMsgvectorList or {}) do
        if v == Object then
            table.remove(_tSendMsgvectorList,k)
            break
        end
    end
end


function GFSendClearAllListioner()
    _tSendMsgvectorList={}
end
local function _sendMessageToData(prot)
    local tempSendMsgvectorList=_tSendMsgvectorList
    for k,v in pairs(tempSendMsgvectorList or {}) do
        if v then
            if v.sendMessageProc then
                v:sendMessageProc(prot)
            else
                print("你注册的监听类没有实现 sendMessageProc")
            end

        end
    end 

end

function GFSendMessageManageLoop()
    local tempMsgDeque=_tSendMsgDeque
    GFSendClearAllMsg()
    for kk,vv  in pairs(tempMsgDeque or {}) do
        if vv then
            _sendMessageToData(vv)
        end  
    end
   
end
