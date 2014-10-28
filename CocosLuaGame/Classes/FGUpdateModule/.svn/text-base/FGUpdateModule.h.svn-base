//
//  FGUpdateModule.h
//  FGClient
//
//  Created by 神利 on 13-4-24.
//
//

#ifndef __FGClient__FGUpdateModule__
#define __FGClient__FGUpdateModule__

//#include <iostream>
//#if USE_STD_UNORDERED_MAP
//#include <unordered_map>
//#else
//#include <map>
//#endif
#include "cocos2d.h"
#include "network/HttpClient.h"
#include "AppDelegate.h"
#include "libjson.h"

USING_NS_CC;
using namespace std;
using namespace network;

class CCGameResourcesVersion
{
public:
    virtual void requestResourcesSuccess(string resUrlString,string fullResUrl,int versionNum,float gamecodeversion,map<int, map<int, string> > versionMd5,map<int, map<int, string> > allpacketMd5,map<int, map<int, string> > fullResMd5,int trueUpdateVersion)=0;
    virtual void requestResourcesFail(string errorCode) = 0;
};

class FGUpdateModule :public Ref
{
public:
    FGUpdateModule();
    ~FGUpdateModule();
    static FGUpdateModule* SharedIntance();
    static void DestroyInstance();
    void checkForUpdates();
    void requestGameResourcesVersionFunc(Node* sender,HttpResponse *response);
    
    void ReconnectionCheckForUpdates();
    void ReconnectionRequestGameResourcesVersionFunc(Node* sender,HttpResponse *response);
    
    map<int, map<int, string> >formatVersionJsonToArray(JSONNODE *jsonNode);
    CC_SYNTHESIZE(CCGameResourcesVersion*, _CCGameResourcesVersion, CCGameResourcesVersion);
    
    
#pragma mark 获取游戏版本号
    
    string requestGameVersion();
};
#endif /* defined(__FGClient__FGUpdateModule__) */
