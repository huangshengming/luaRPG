//
//  httpExpansion.cpp
//  usuClient
//
//  Created by 神利 on 14/10/21.
//
//

#include "httpExpansion.h"
#include "CCLuaEngine.h"
#include "WholeDefine.h"
#include "FGProt.h"
#define HttpExpansionSessionLength (36)
#define HttpExpansionSerialNumberLength (4)
//短链接一次发送的buff的最大长度
#define shortLinkBuffMaxSize (16*1024)
static httpExpansion *Instance = NULL;


httpExpansion* httpExpansion::SharedIntance()
{
    if(Instance == NULL){
        Instance = new httpExpansion();
    }
    return Instance;
}
void httpExpansion::DestroyInstance()
{
    CC_SAFE_DELETE(Instance);
}


httpExpansion::httpExpansion()
:_isHaveMessageSending(false),
_isDisconnect(false),
_currentSerialNumber(0),
_session(""),
_successLuaCallBack(""),
_failureLuaCallBack("")
{
    _sendMessageList.clear();
    network::HttpClient::getInstance()->setTimeoutForRead(10);
    _httpRequest  = new network::HttpRequest();
    Director *pDirector = Director::getInstance();

    Scheduler *pCcscheduler = pDirector->getScheduler();
    pCcscheduler->schedule(schedule_selector(httpExpansion::myUpdate), this, 0, false);
}
httpExpansion::~httpExpansion()
{
    CC_SAFE_RELEASE(_httpRequest);
    while (_sendMessageList.size()>0)
    {
        if(_sendMessageList[_sendMessageList.size()-1])
        {
            if(_sendMessageList[_sendMessageList.size()-1]->buff)
            {
                free(_sendMessageList[_sendMessageList.size()-1]->buff);
            }
            delete  _sendMessageList[_sendMessageList.size()-1];
        }
        _sendMessageList.pop_back();
    }
    
    Director *pDirector = Director::getInstance();
    
    Scheduler *pCcscheduler = pDirector->getScheduler();
    pCcscheduler->unschedule(schedule_selector(httpExpansion::myUpdate), this);
    
}



void httpExpansion::sendOneMessage(char *buff,unsigned int buffLength,std::string url)
{
    if( (buff)&&(buffLength>0) )
    {
        _currentSerialNumber++;
        httpMessage * tempHttpMessage = new httpMessage();
        tempHttpMessage->buff= (char*)malloc(buffLength);
        tempHttpMessage->bufflength=buffLength;
        tempHttpMessage->url=url;
        memcpy(tempHttpMessage->buff, buff, buffLength);
        tempHttpMessage->serialNumber=_currentSerialNumber;
        _sendMessageList.push_back(tempHttpMessage);
        _RealSendOneMessage();
    }
}
void httpExpansion::_RealSendOneMessage()
{

    if( !_isHaveMessageSending && !_isDisconnect)
    {
        if( _sendMessageList.size()>0)
        {
            httpMessage* tempMessage= _sendMessageList[0];
            if (tempMessage)
            {
                _httpRequest->setUrl(tempMessage->url.c_str());
                _httpRequest->setRequestType(network::HttpRequest::Type::POST);
                char tempBuff[33];
                snprintf(tempBuff, 33,"%d", tempMessage->serialNumber);
                _httpRequest->setTag(tempBuff);
                _httpRequest->setResponseCallback(CC_CALLBACK_2(httpExpansion::handshakeResponse,this));
                char *realSendBuff= (char*)malloc(tempMessage->bufflength+HttpExpansionSessionLength+HttpExpansionSerialNumberLength);
                memset(realSendBuff, 0, tempMessage->bufflength+HttpExpansionSessionLength+HttpExpansionSerialNumberLength);
                if(strlen(_session.c_str())== HttpExpansionSessionLength)
                {
                    //写入 session
                    memcpy(realSendBuff, _session.c_str(), HttpExpansionSessionLength);
                }
                //写入 serialNumber
                memcpy(realSendBuff+HttpExpansionSessionLength, &(tempMessage->serialNumber),HttpExpansionSerialNumberLength );
                //写入真实数据
                memcpy(realSendBuff+HttpExpansionSessionLength+HttpExpansionSerialNumberLength,  tempMessage->buff, tempMessage->bufflength);
                _httpRequest->setRequestData(realSendBuff, tempMessage->bufflength+HttpExpansionSessionLength+HttpExpansionSerialNumberLength);
                network::HttpClient::getInstance()->send(_httpRequest);
                free(realSendBuff);
                
                _isHaveMessageSending= true;
            }
        }

    }

}

void httpExpansion::handshakeResponse(network::HttpClient *sender, network::HttpResponse *response)
{
    
    _isHaveMessageSending=false;
    if (!response||!response->isSucceed())
    {
        CCLOG("response failed");
        CCLOG("error buffer: %s", response->getErrorBuffer());
        _isDisconnect=true;
        if (strlen( _failureLuaCallBack.c_str()))
        {
            
            auto engine = LuaEngine::getInstance();
            LuaStack* stack = engine->getLuaStack();
            lua_State* L = stack->getLuaState();
            lua_getglobal(L,_failureLuaCallBack.c_str());
            lua_pcall(L, 0, 0, 0);

        }
        
   
        return;
    }
    std::string tag="";
    if (0 != strlen(response->getHttpRequest()->getTag()))
    {
        tag=response->getHttpRequest()->getTag();
        CCLOG("%s completed", tag.c_str());
    }
    
    
    
    if (strlen( _failureLuaCallBack.c_str()))
    {
        
        auto engine = LuaEngine::getInstance();
        LuaStack* stack = engine->getLuaStack();
        lua_State* L = stack->getLuaState();
        lua_getglobal(L,_successLuaCallBack.c_str());
        lua_pcall(L, 0, 0, 0);
        
    }
    
    std::vector<char> *buffer = response->getResponseData();
    char* concatenated = (char*) malloc(buffer->size());
    std::string s2(buffer->begin(), buffer->end());
    memcpy(concatenated, s2.c_str(), buffer->size());
    
    //交给反序列化
    auto engine = LuaEngine::getInstance();
    LuaStack* stack = engine->getLuaStack();
    lua_State* L = stack->getLuaState();
    lua_getglobal(L,"shortLinkNetOnRecv");
    lua_pushlightuserdata(L, concatenated);
    lua_pushinteger(L,buffer->size());
    lua_pcall(L, 2, 1, 0);
    //返回的是不是Session的校验码
    bool isSessionCheck=lua_toboolean(L, -1);
    free(concatenated);
    if (!isSessionCheck)
    {
        if(_sendMessageList.size()>0)
        {
            if(_sendMessageList[0])
            {
                if(_sendMessageList[0]->serialNumber==atoi(tag.c_str()))
                {
                    if(_sendMessageList[0]->buff)
                    {
                        free(_sendMessageList[0]->buff);
                    }
                    delete  _sendMessageList[0];
                }
            }
            _sendMessageList.pop_front();
        }
    }

}

void httpExpansion::reconnection()
{
    _isDisconnect=false;
    _RealSendOneMessage();
}
void httpExpansion::myUpdate(float time)
{

    _RealSendOneMessage();

}

void httpExpansion::setSession(std::string session)
{
    _session=session;
}
void httpExpansion::setSuccessLuaCallBack(std::string callBack)
{
    _successLuaCallBack=callBack;

}
void httpExpansion::setFailureLuaCallBack(std::string callBack)
{
    _failureLuaCallBack=callBack;
}

std::string httpExpansion::getSession()
{
    return _session;
}
bool httpExpansion::isDisconnect()
{
    return _isDisconnect;

}



//设置Session
int capi_shortLinkSetSession(lua_State*L)
{
    if( lua_gettop(L) == 1 )
    {
        httpExpansion::SharedIntance()->setSession(lua_tostring(L,1));
    }
    return 0;
    
}

int capi_shortLinkSetSuccessCallBack(lua_State*L)
{
    if( lua_gettop(L) == 1 )
    {
        httpExpansion::SharedIntance()->setSuccessLuaCallBack(lua_tostring(L,1));
    }
    return 0;
    
}

int capi_shortLinkSetFailureCallBack(lua_State*L)
{
    if( lua_gettop(L) == 1 )
    {
        httpExpansion::SharedIntance()->setFailureLuaCallBack(lua_tostring(L,1));
    }
    return 0;
    
}

//获得Session
int capi_shortLinkGetSession(lua_State*L)
{
    lua_pushstring(L, httpExpansion::SharedIntance()->getSession().c_str());
    return 1;
    
}
//断线重连
int capi_shortLinkReconnection(lua_State*L)
{
    httpExpansion::SharedIntance()->reconnection();
    return 0;
}
//销毁单例
int capi_shortLinkDestroyInstance(lua_State*L )
{
    httpExpansion::DestroyInstance();
    return 0;
}
//判断是否已经断线
int capi_shortLinkIsDisconnect(lua_State*L)
{
    lua_pushboolean(L,httpExpansion::SharedIntance()->isDisconnect());
    return 1;
}


//发送协议 1 url 2 protid  3 prot(table)
int capi_shortLinkSendProt(lua_State*L)
{
    
    if( lua_gettop(L) == 3 )
    {
        int fd = 0;
        int charid = 0;
        int totellen = 0;
        int pos=0;
        std::string url=lua_tostring(L, 1);
        int protid = (int)lua_tointeger(L,2);
        static char shortLinkBuff[shortLinkBuffMaxSize];
        memset(shortLinkBuff, 0,shortLinkBuffMaxSize );
        
        //fd
        *((int*)(shortLinkBuff+pos)) = fd;
        totellen+=sizeof(int);
        pos+=sizeof(int);
        //protid
        *((int*)(shortLinkBuff+pos)) = protid;
        totellen+=sizeof(int);
        pos+=sizeof(int);
        //charid
        *((int*)(shortLinkBuff+pos)) = charid;
        totellen+=sizeof(int);
        pos+=sizeof(int);
        
        //总长度 pos
        totellen+=sizeof(int);
        pos+=sizeof(int);
        
        const std::vector<stField>* pVecProt = FGFindProt(protid);
        int len = serialprot(L,pVecProt,shortLinkBuff+pos,shortLinkBuffMaxSize);
        if(len < 0)
        {
            return 0;
        }
        totellen+=len;
        *((int*)(shortLinkBuff+pos-sizeof(int))) = totellen;
        
        httpExpansion::SharedIntance()->sendOneMessage(shortLinkBuff, totellen,url);
    }
    
    
    return 0;
}

void LRTHttpExpansion()
{
    
    //shortLink begin
    LRT(capi_shortLinkSetSession);
    LRT(capi_shortLinkGetSession);
    LRT(capi_shortLinkSetSuccessCallBack);
    LRT(capi_shortLinkSetFailureCallBack);
    LRT(capi_shortLinkDestroyInstance);
    LRT(capi_shortLinkIsDisconnect);
    LRT(capi_shortLinkReconnection);
    LRT(capi_shortLinkSendProt);
    //shortLink end

}

