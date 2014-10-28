//
//  FGUpdateModule.cpp
//  FGClient
//
//  Created by 神利 on 13-4-24.
//
//

#include "FGUpdateModule.h"
#include "WholeDefine.h"
#include "MarketAPI.h"
#include "FGgameSet.h"
#include "FGgameinit.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "MyJni.h"
#endif

using namespace network;

static FGUpdateModule *Instance = NULL;

void FGUpdateModule::DestroyInstance()
{
    CC_SAFE_DELETE(Instance);
}
FGUpdateModule *FGUpdateModule::SharedIntance(){
    if(Instance == NULL){
        Instance = new FGUpdateModule();
    }
    return Instance;
}


FGUpdateModule::FGUpdateModule()
:_CCGameResourcesVersion(NULL)
{

}
FGUpdateModule::~FGUpdateModule()
{

}
void FGUpdateModule::ReconnectionCheckForUpdates()
{
    
#ifdef GameNeedUpdate

    char urlChar[512] = {0};
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    string   SystemType="ios";
#endif
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    string   SystemType="android";
#endif
    int cid =SHARED_MARKET_API->getMarketCid();
    snprintf(urlChar,512,VersionVerificationURL,cid,SystemType.c_str(),1);
    HttpRequest* request = new HttpRequest();
    request->setUrl(urlChar);
    log("%s",urlChar);
    request->setRequestType(HttpRequest::Type::GET);
    request->setResponseCallback(this, httpresponse_selector(FGUpdateModule::ReconnectionRequestGameResourcesVersionFunc));
    request->setTag("ReconnectionGameversion");
    HttpClient::getInstance()->send(request);
    request->release();
#endif

}

void FGUpdateModule::ReconnectionRequestGameResourcesVersionFunc(Node* sender,HttpResponse *response)
{
    if (!response || !response->isSucceed())
    {
        log("response null");
        
//        ReconnectionCheckForUpdates();
        return;
    }
    
    
    if (0 != strlen(response->getHttpRequest()->getTag()))
    {
        log("%s response completed , response code is %ld \n", response->getHttpRequest()->getTag(),response->getResponseCode());
    }
    
    std::vector<char> *buffer = response->getResponseData();
    
    string serverTime(buffer->begin(), buffer->end());
    
    log("%s",serverTime.c_str());
    
    JSONNODE *nr  = json_parse(serverTime.c_str());
    
    if (nr == NULL) {
        
        log("request version is null");
//        ReconnectionCheckForUpdates();
        return;
        
    }
    
    json_char *refChar = json_as_string(json_get(nr, "ref"));
    
    if (atoi(refChar) == 0) {
        
        json_char *referror = json_as_string(json_get(nr, "error"));
        
        
//        ReconnectionCheckForUpdates();
        
        json_free(referror);
        
    }else
    {
        
    
        
        json_char* resourcesversion = json_as_string(json_get(nr, "var_res_out"));
        float tempresourcesversion= atoi(resourcesversion);
        
        int currentVersion= FGgameSet::getInstance()->getIntegerForKey("gameResourcesVersion");
        if(currentVersion<tempresourcesversion)
        {
            //跳转到更新界面
//            ReconnectionUpdate();
//            FGUIMsgText::createWithString(NSLocalizedString("检测到有资源更新","更新"),1);
            //游戏初始化
            FGgameinit::SharedIntance()->initStartGameview();
//            FGgameinit::SharedIntance()->gotoUpdateView();
        }
        json_free(resourcesversion);
        
 
    }
    
    
    json_free(refChar);
    
    json_delete(nr);

    
    

}

void FGUpdateModule::checkForUpdates()
{
   
    //test
    char urlChar[512] = {0};
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    string   SystemType="ios";
#endif
    
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    string   SystemType="android";
#endif
    int cid =SHARED_MARKET_API->getMarketCid();
    snprintf(urlChar,512,VersionVerificationURL,cid,SystemType.c_str(),1);
    HttpRequest* request = new HttpRequest();
    request->setUrl(urlChar);
    log("%s",urlChar);
    request->setRequestType(HttpRequest::Type::GET);
    request->setResponseCallback(this, httpresponse_selector(FGUpdateModule::requestGameResourcesVersionFunc));
    request->setTag("gameversion");
    HttpClient::getInstance()->send(request);
    request->release();
}
void FGUpdateModule::requestGameResourcesVersionFunc(Node* sender,HttpResponse *response)
{
    if (!response || !response->isSucceed())
    {
        log("response null");
        
       if (_CCGameResourcesVersion) {

           _CCGameResourcesVersion->requestResourcesFail(NSLocalizedString("请求资源版本失败,请检查网络后重试.","更新出错"));

       }
        
        return;
    }
    
    
    // You can get original request type from: response->request->reqType
    if (0 != strlen(response->getHttpRequest()->getTag()))
    {
        log("%s response completed , response code is %d \n", response->getHttpRequest()->getTag(),response->getResponseCode());
    }
    
    std::vector<char> *buffer = response->getResponseData();
    
    string serverTime(buffer->begin(), buffer->end());
    
    log("%s",serverTime.c_str());
    
    JSONNODE *nr  = json_parse(serverTime.c_str());
    
    if (nr == NULL) {
        
        log("request version is null");
   
        if (_CCGameResourcesVersion) {
            
            _CCGameResourcesVersion->requestResourcesFail(NSLocalizedString("请求资源版本失败,请检查网络后重试.","更新出错"));
        }
        
        return;
        
    }
    
    json_char *refChar = json_as_string(json_get(nr, "ref"));
    
    if (atoi(refChar) == 0) {
        
        json_char *referror = json_as_string(json_get(nr, "error"));
        
//        string errorString = SHARED_LOCALLATAMANAGE.getPlistFirstStringFromKey("explain",refChar, ERRORCODEPLIST);
        
        if (_CCGameResourcesVersion)
        {
            _CCGameResourcesVersion->requestResourcesFail(NSLocalizedString("请求资源版本失败,请检查网络后重试.","更新出错"));
        }
        
        
        json_free(referror);
        
    }else
    {
        
        JSONNODE *allpacketMd5 = json_as_array(json_get(nr, "full"));
        
        JSONNODE *upgradeMd5 = json_as_array(json_get(nr, "upgrade"));
        
        json_char* urlString = json_as_string(json_get(nr, "res"));
        
        json_char* gamecodeversion = json_as_string(json_get(nr, "var_must"));
        
        json_char* resourcesversion = json_as_string(json_get(nr, "var_res"));
        json_char* true_resversion = json_as_string(json_get(nr, "var_res_out"));//外网真实资源版本
        if (true_resversion == NULL || strcmp(true_resversion, "") == 0) {
            true_resversion = resourcesversion;
        }
        json_char* download_url=json_as_string(json_get(nr, "download_url"));
        
        //资源包更新地址
        json_char* download_res_url=json_as_string(json_get(nr, "download_res_url"));
        
        JSONNODE *fullResMd5 = json_as_array(json_get(nr, "big"));
        
        //
        if (_CCGameResourcesVersion) {
            
            _CCGameResourcesVersion->requestResourcesSuccess(urlString,download_res_url, atoi(resourcesversion), atof(gamecodeversion), formatVersionJsonToArray(upgradeMd5), formatVersionJsonToArray(allpacketMd5),formatVersionJsonToArray(fullResMd5),atoi(true_resversion));
            
        }
        //TODO_update ?referer=%s  在下载地址后面加上渠道号
        g_download_url=download_url;
        json_free(download_url);
        json_free(urlString);
        
        json_free(gamecodeversion);
        
        json_free(resourcesversion);
        
        json_free(true_resversion);
        
        json_delete(allpacketMd5);
        
        json_delete(upgradeMd5);
    }
    
    
    json_free(refChar);
    
    json_delete(nr);
    
    
}

map<int, map<int, string> > FGUpdateModule::formatVersionJsonToArray(JSONNODE *jsonNode)
{
    map<int, map<int, string> > maparray;
    
    JSONNODE_ITERATOR iter = json_begin(jsonNode);
    
    while (iter != json_end(jsonNode)) {
        
        map<int, string> mapcellarray;
        
        json_char* jsonid = json_as_string(json_get(*iter, "v"));
        
        json_char* jsonmd5 = json_as_string(json_get(*iter, "m"));
        
        json_char* filesize = json_as_string(json_get(*iter, "s"));
        
        mapcellarray.insert(make_pair(atoi(filesize), jsonmd5));
        
        maparray.insert(make_pair(atoi(jsonid), mapcellarray));
        
        log("jsonid === %d,jsonmd5 === %s,filesize ==== %d",atoi(jsonid),jsonmd5,atoi(filesize));
        
        json_free(jsonid);
        
        json_free(jsonmd5);
        
        json_free(filesize);
        
        ++iter;
    }
    
    return maparray;
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#	include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

#pragma mark 获取游戏版本号
string FGUpdateModule::requestGameVersion()
{
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    const char* ver = [version UTF8String];
    return string(ver);
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    return getPackageVersion_JNI();
#endif
    
}

