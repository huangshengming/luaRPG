#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "Runtime.h"
#include "ConfigParser.h"
#include "CAPI.h"
#include "WholeDefine.h"
#include "FGUpdateView.h"
#include "FGgameinit.h"
#include "MarketAPIDefine.h"
#include "MarketAPI.h"

#include "CCFileCompressOperation.h"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    //初始化cidkey
    initCIDkey();
    
    
#if (COCOS2D_DEBUG>0)
    initRuntime();
#endif
    
    if (!ConfigParser::getInstance()->isInit()) {
            ConfigParser::getInstance()->readConfig();
        }
    
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();    
    if(!glview) {
        cocos2d::Size viewSize = ConfigParser::getInstance()->getInitViewSize();
        string title = ConfigParser::getInstance()->getInitViewName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        extern void createSimulator(const char* viewName, float width, float height,bool isLandscape = true, float frameZoomFactor = 1.0f);
        bool isLanscape = ConfigParser::getInstance()->isLanscape();
        createSimulator(title.c_str(),viewSize.width,viewSize.height,isLanscape);
#else
        glview = GLView::createWithRect(title.c_str(), cocos2d::Rect(0,0,viewSize.width,viewSize.height));
        director->setOpenGLView(glview);
#endif
    }

    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);

    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    
    
    //版本检测 如果第一次装 清除cache
    CCFileCompressOperation::ShareInstance()->versionDetection();
    
    //提前初始化sdk
    MarketAPI::GetSharedInstance();
    
    //创建一个初始scene
    globalScene = Scene::create();
    director->runWithScene(globalScene);
    
    //游戏初始化
    FGgameinit::SharedIntance()->initStartGameview();
    
    //------------------------------------------------------
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}


void AppDelegate::startLoadLua(bool isfirst/*=true*/)
{
    g_luaisLoad=false;
    
    auto engine = LuaEngine::getInstance();
    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));
    
    capi_lua_register();
    
    g_luaisLoad=true;
    
#if (COCOS2D_DEBUG>0)
    if (startRuntime())
        return;
#endif
    engine->executeScriptFile(ConfigParser::getInstance()->getEntryFile().c_str());
    
}
