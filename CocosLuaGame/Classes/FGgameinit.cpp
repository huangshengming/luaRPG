//
//  FGgameinit.cpp
//  FGClient
//
//  Created by 神利 on 13-6-8.
//
//

#include "FGgameinit.h"
#include "VisibleRect.h"
#include "FGgameSet.h"
#include "WholeDefine.h"
#include <sys/stat.h>
#include "CCFileCompressOperation.h"
#include "FGUpdateView.h"
#include "FGgamePlatformAPI.h"
#define GameVersionTag  (-599959)

void collectUserInformation()
{
    /*
#ifdef NDEBUG
    
    string url = "";
    if (SHARED_MARKET_API->getMarketCid()==100)
    {
        url=  NSLocalizedString("http://opx098.my9yu.com:12000", "收集用户信息地址app");
    }
    else if (SHARED_MARKET_API->getMarketCid()==102)
    {
        url=  NSLocalizedString("http://urs.xxmx.floragame.com:12910", "收集用户信息地址pp");
    }
    else
    {
         url=  NSLocalizedString("http://urs.xxmx.floragame.com:12900", "收集用户信息地址安卓和越狱");
    }
    url+="/clientstartlog?mac=%s&idfa=%s&osversion=%s&dtype=%s&dname=%s&cid=%d&ptype=%s";
    class clientGetUserInfo: public CCObject
    {
    public:
        CREATE_FUNC(clientGetUserInfo);
        bool init()
        {
            
            return true;
        }
        void getdata(CCNode* sender,void *responeData)
        {
            
            
            
            cocos2d::extension::CCHttpResponse *response = (cocos2d::extension::CCHttpResponse*)responeData;
            if (!response)
            {
                
                log("response null");
                this->release();
                return;
            }
            
            if (!response->isSucceed()) {
                
                log("response failed");
                this->release();
                return;
            }
            this->release();
            
        }
    private:
        
    };
    
    
    clientGetUserInfo* tempObj = clientGetUserInfo::create();
    tempObj->retain();
    cocos2d::extension::CCHttpRequest* request = new cocos2d::extension::CCHttpRequest();
    char szUrl[2048] = {0};
    string mac = getMacAddress();
    string idfa = getIdfa();
    string osversion = UrlEncode(getDeviceSysVerSion());
    string dtype = UrlEncode(getDeviceType());
    string dname = UrlEncode(getDeviceName());
    string ptype ="";
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    ptype="ios";
#else
    ptype="android";
#endif
    string reason =FGMarketGetMarketName(SHARED_MARKET_API->getMarketCid());
    snprintf(szUrl,2048, url.c_str(), mac.c_str(),idfa.c_str(),osversion.c_str(),dtype.c_str(),dname.c_str(),SHARED_MARKET_API->getMarketCid(),ptype.c_str());
    request->setUrl(szUrl);
    request->setRequestType(HttpRequest::Type::GET);
    request->setResponseCallback(tempObj, callfuncND_selector(clientGetUserInfo::getdata));
    request->setTag("collectUserInformation");
    CCHttpClient::getInstance()->send(request);
    request->release();
    
#endif
    
    */
}



static FGgameinit *Instance = NULL;

void FGgameinit::DestroyInstance()
{
    CC_SAFE_DELETE(Instance);
}
FGgameinit *FGgameinit::SharedIntance(){
    if(Instance == NULL){
        Instance = new FGgameinit();
    }
    return Instance;
}

FGgameinit::FGgameinit()
{
    
    //collectUserInformation();

}
FGgameinit::~FGgameinit()
{
    
}

bool FGgameinit::copyfileAndUnzip(const char* fileName)
{


    if(CCFileCompressOperation::copyWriteablePathFile(fileName))
    {

        if(CCFileCompressOperation::decompressZipFile(fileName))
        {

            return true;
        }
    }

    log("拷贝并且解压资源出错啦4");
    return false;
}

void FGgameinit::initStartGameviewGeneral()
{
    //TDGameAnalytics
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    //TDCCTalkingDataGA::onStart("FAF47ACC72DD5FCC7D076347A1CEACE9", FGMarketGetMarketName(SHARED_MARKET_API->getMarketCid()));
//    if(SHARED_MARKET_API->getMarketCid()==100)
//    {
//        FGappcpaInit();
//        
//    }
#endif
    
    LabelTitle = Label::createWithSystemFont(NSLocalizedString("游戏初始化中...","游戏启动"), "Helvetica", 40);
    LabelTitle->setColor(Color3B::WHITE);
    LabelTitle->setPosition(Vec2 ( VisibleRect::center().x,100));
    
    
    CreateBgInit();
    
    globalScene->addChild(LabelTitle);
    
//    ShowGameVersion();
    
    //TODO 暂不拷贝lua
    /*
    int luaisCopy= FGgameSet::getInstance()->getIntegerForKey("luaIsCopy");
    copyfileName.clear();
    if(luaisCopy!=1)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        //        copyfileName.push_back("allLua.zip");
        copyfileName.push_back("floragameRes_android_1.zip");
#else
        
#ifdef GameNeedUpdate
        copyfileName.push_back("allLua.zip");
#endif
        
#endif
    }
     */
    
    Director *pDirector = Director::getInstance();
    Scheduler *pCcscheduler = pDirector->getScheduler();
    pCcscheduler->schedule(schedule_selector(FGgameinit::copyFileUpdate), this, 0.001, false);
}
void FGgameinit::startPageCallBack(Ref* obj)
{
//    FGSprite* startPage = (FGSprite*)obj;
//    startPage->removeFromParentAndCleanup(true);
    initStartGameviewGeneral();
}
void FGgameinit::initStartGameviewStartPage()
{
//    FGSprite* startPage = FGSprite::create();
//    startPage->loadFrame("startPage.png");
//    startPage->setAnchorPoint(ccp(0.5,0.5));
//    startPage->setPosition(VisibleRect::center());
//    startPage->pauseAt(0);
//    FGLayerManager::getGlobalLayerManager()->insertMsgTextObject(startPage->objectId);
//    
//    CCFiniteTimeAction* pAction = CCCallFuncN::create(this,callfuncN_selector(FGgameinit::startPageCallBack));
//    CCFiniteTimeAction* delay = CCDelayTime::create(1.0f);
//    CCAction* act = CCSequence::create(delay,pAction,NULL);
//    startPage->runAction(act);
    
    startPageCallBack(nullptr);
}
//打开游戏刚启动界面
void FGgameinit::initStartGameview()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    initStartGameviewStartPage();
//    if (SHARED_MARKET_API->getMarketCid() == 111) {
//        initStartGameviewStartPage();
//    }
//    else{
//        initStartGameviewGeneral();
//    }
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    initStartGameviewGeneral();
#endif
}

//初始化资源 包括不释放标记资源加载
void FGgameinit::initImageResources()
{
    
    //添加不释放plist

}

//音效加载
void FGgameinit::initSounResources()
{
    //加载音效
    //FGAudioLoadingAlwaysSounds();
}

//打开更新界面
void FGgameinit::gotoUpdateView()
{
    log("进入更新界面");
    FGUpdateView * temp =  FGUpdateView::create();
    globalScene->addChild(temp);
}

void FGgameinit::copyFileUpdate(float dt)
{
    
//#ifdef GameNeedUpdate
    if(copyfileName.size()>0)
    {

        string tempName = copyfileName[copyfileName.size()-1];
        if( copyfileAndUnzip(tempName.c_str()))
        {
            copyfileName.pop_back();
        }
    }else if (copyfileName.size()==0)
    {
        FGgameSet::getInstance()->setIntegerForKey("luaIsCopy",1);
        FGgameSet::getInstance()->flush();
        
    }
//#else
//    FGgameSet::getInstance()->setIntegerForKey("luaIsCopy",1);
//    FGgameSet::getInstance()->flush();
//#endif
    
    
    int nowluaisCopy= FGgameSet::getInstance()->getIntegerForKey("luaIsCopy");
    //拷贝完成 开始其他初始化
    if(nowluaisCopy==1)
    {
        string nowGameVersion = FGUpdateModule::SharedIntance()->requestGameVersion();
        FGgameSet::getInstance()->setStringForKey("gameVersion",nowGameVersion);
        FGgameSet::getInstance()->flush();
//        log("WTF__gameversion写入_%s",nowGameVersion.c_str());
        
        Director *pDirector = Director::getInstance();
        Scheduler *pCcscheduler = pDirector->getScheduler();
        pCcscheduler->unschedule(schedule_selector(FGgameinit::copyFileUpdate), this);
    
        Function.clear();
        Function.push_back(callfunc_selector(FGgameinit::initImageResources));
        //Function.push_back(callfunc_selector(FGgameinit::initSounResources));
        pCcscheduler->schedule(schedule_selector(FGgameinit::initResourcesUpdate), this,0.001,false);
        
        //渲染特效
        FGgameinit::SharedIntance()->showEffect();
    }
    
}
void FGgameinit::initResourcesUpdate(float dt)
{
    if(Function.size()>0)
    {
        (this->*(Function[Function.size()-1]))();
        Function.pop_back();
    }else if (Function.size()==0)
    {
        
        Director *pDirector = Director::getInstance();
        Scheduler *pCcscheduler = pDirector->getScheduler();
        pCcscheduler->unschedule(schedule_selector(FGgameinit::initResourcesUpdate), this);
        LabelTitle->removeFromParentAndCleanup(true);
#ifdef GameNeedUpdate
        gotoUpdateView();
#else
//        FGLayerManager::getGlobalLayerManager()->resetUILayer();
        AppDelegate::startLoadLua();
#endif
        
    }
    
}

void ShowGameVersion()
{
   Label* GameVersion = dynamic_cast<Label*>(globalScene->getChildByTag(GameVersionTag));
    char buff[512];
    snprintf(buff,512, NSLocalizedString("当前版本号:%s\n资源号:%d","版本号"),FGUpdateModule::SharedIntance()->requestGameVersion().c_str(),FGgameSet::getInstance()->getIntegerForKey("gameResourcesVersion"));
    if(GameVersion)
    {
        GameVersion->setString(buff);
        
    }
    else
    {

        GameVersion = Label::createWithSystemFont(buff, "Helvetica", 15,Size::ZERO, TextHAlignment::LEFT);
        GameVersion->setColor(Color3B::WHITE);
        globalScene->addChild(GameVersion);
        GameVersion->setPosition(VisibleRect::leftTop());
        GameVersion->setAnchorPoint(Vec2(0,1));
        GameVersion->setTag(GameVersionTag);
    }
    
}

int CFGdeleteGameVersion(lua_State* L)
{
    globalScene->removeChildByTag(GameVersionTag, true);
    return 0;
}

int CFGDrawInitBg(lua_State* L){
    FGgameinit::SharedIntance()->CreateBgInit();
    return 0;
}


void FGgameinit::CreateBgInit(){
    
   
}

void FGgameinit::showEffect(){

}



