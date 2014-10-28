//
//  httpExpansion.h
//  usuClient
//
//  Created by 神利 on 14/10/21.
//
//

#ifndef __usuClient__httpExpansion__
#define __usuClient__httpExpansion__

#include <stdio.h>
#include "cocos2d.h"
#include "network/HttpClient.h"

USING_NS_CC;

typedef struct _httpMessage httpMessage;

struct _httpMessage
{
    _httpMessage()
    {
        buff=nullptr;
    }
    char * buff;
    unsigned int bufflength;
    unsigned int serialNumber;
    std::string url;
};


class httpExpansion: public cocos2d::Ref
{
public:
    httpExpansion();
    ~httpExpansion();
    static httpExpansion* SharedIntance();
    static void DestroyInstance();
    void sendOneMessage(char *buff,unsigned int buffLength,std::string url);
    void _RealSendOneMessage();
    void handshakeResponse(network::HttpClient *sender, network::HttpResponse *response);
    void setSession(std::string session );
    void setSuccessLuaCallBack(std::string callBack);
    void setFailureLuaCallBack(std::string callBack);
    std::string getSession();
    void reconnection();
    void myUpdate(float time);
    bool isDisconnect();
private:
    std::deque<httpMessage*>_sendMessageList;
    bool _isHaveMessageSending;
    bool _isDisconnect;
    unsigned int _currentSerialNumber;
    std::string _session;
    network::HttpRequest * _httpRequest;
    std::string _successLuaCallBack;
    std::string _failureLuaCallBack;
    
};
void LRTHttpExpansion();
#endif /* defined(__usuClient__httpExpansion__) */
