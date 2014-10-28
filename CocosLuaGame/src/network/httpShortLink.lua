
shortLinkNetOnRecv = function(buffer,bufferlen)
    local fd,protId,pkgLength = CFGPickBufferInfo(buffer,bufferlen)
    print("shortLinkNetOnRecv",fd,"protId=",protId,"pkgL=",pkgLength)

    if not protId then
        return false
    end
    local prot = GFProtGet(protId)
    if not prot then
        print("有未注册的协议,protId是:"..protId)
        return false
    end
    local nread = CFGUnserializeProt(buffer,bufferlen,prot)
    if nread > 0 then
        print("接收到短连接发回的数据")
        pprint(prot)
        GFRecOneMsg(prot)
    end
    return false
end
shortLinkSuccessCallBack = function ()
end
shortLinkFailureCallBack = function ()
    --TODO 弹出提示框 是否要重连  点击确认后调用 capi_shortLinkReconnection
end
shortLinkInit = function()
    capi_shortLinkDestroyInstance()
    capi_shortLinkSetSuccessCallBack("shortLinkSuccessCallBack")
    capi_shortLinkSetFailureCallBack("shortLinkFailureCallBack")
end

shortLinkSetSession = function(session)
    capi_shortLinkSetSession(session)
end

shortLinkGetSession = function ()
    return capi_shortLinkGetSession()
end

shortLinkSendProt= function (url,protId,prot)
    capi_shortLinkSendProt(url,protId,prot)
end
