//
//  MyJin.cpp
//  FGClient
//
//  Created by 神利 on 13-6-17.
//
//
#include "MyJni.h"
#include "AppDelegate.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "MarketAPI.h"
#include "WholeDefine.h"
#include "FGgamePushModule.h"
//#include "FGCheckNetwork.h"

#define  LOG_TAG    "MyJni"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;

extern "C" {
    
    static jclass classOfCocos2dxActivity = 0;
    JNIEnv *env = 0;
    //市场接口类
    static jclass classOfMarketMethodInterface = 0;
    
    static jmethodID getMethodID(const char *methodName, const char *paramCode,
                                 bool staticMethod) {
        jmethodID ret = 0;
        
        // get jni environment and java class for Cocos2dxActivity
        if (JniHelper::getJavaVM()->GetEnv((void**) (&env), JNI_VERSION_1_4) != JNI_OK) {
            LOGD("Failed to get the environment using GetEnv()");
            return 0;
        }
        
        if (JniHelper::getJavaVM()->AttachCurrentThread(&env, 0) < 0) {
            LOGD("Failed to get the environment using AttachCurrentThread()");
            return 0;
        }
        
        classOfCocos2dxActivity = env->FindClass("org/cocos2dx/lua/AppActivity");
        if (!classOfCocos2dxActivity) {
            LOGD("Failed to find class of org/cocos2dx/lua/AppActivity");
            
            return 0;
        }
        
        if (env != 0 && classOfCocos2dxActivity != 0) {
            if (true == staticMethod) //judgy to get static or normal method
                ret = env->GetStaticMethodID(classOfCocos2dxActivity, methodName,
                                             paramCode);
            else
                ret = env->GetMethodID(classOfCocos2dxActivity, methodName,
                                       paramCode);
            
            env->DeleteLocalRef(classOfCocos2dxActivity);
        }
        
        if (!ret) {
            LOGD("get method id of %s error", methodName);
        }
        
        return ret;
    }
    
    static jmethodID getMarketMethodID(const char *methodName, const char *paramCode,
                                       bool staticMethod) {
        jmethodID ret = 0;
        // get jni environment and java class for Cocos2dxActivity
        if (JniHelper::getJavaVM()->GetEnv((void**) (&env), JNI_VERSION_1_4) != JNI_OK) {
            LOGD("Failed to get the environment using GetEnv()");
            return 0;
        }
        
        if (JniHelper::getJavaVM()->AttachCurrentThread(&env, 0) < 0) {
            LOGD("Failed to get the environment using AttachCurrentThread()");
            return 0;
        }
        
        classOfMarketMethodInterface = env->FindClass("org/cocos2dx/lua/MarketHandler");
        if (!classOfMarketMethodInterface) {
            LOGD("Failed to find class of org/cocos2dx/lua/MarketHandler");
            
            return 0;
        }
        
        if (env != 0 && classOfMarketMethodInterface != 0) {
            if (true == staticMethod) //judgy to get static or normal method
                ret = env->GetStaticMethodID(classOfMarketMethodInterface, methodName,
                                             paramCode);
            else
                ret = env->GetMethodID(classOfMarketMethodInterface, methodName,
                                       paramCode);
            
            env->DeleteLocalRef(classOfMarketMethodInterface);
        }
        
        if (!ret) {
            LOGD("get method id of %s error", methodName);
        }
        
        return ret;
    }
    
    
  
    
    class CLoginSchedule : public Ref
	{
	public:
		CREATE_FUNC(CLoginSchedule);
		bool init()
		{
			CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(CLoginSchedule::ScheduleFunc), this, 0.1, false);
			return true;
		}
		
	private:
		void ScheduleFunc(float dt)
		{
			string strUserID;
			string strUSerName;
			MarketAPI::GetSharedInstance()->getUserInfo(strUserID, strUSerName);
			
            //TODO(chenbin)
            /*
			//通知登入模块
			lua_State *l = FGLua_L();
			lua_getglobal(l, "FGPrettyLogin");
			//用户id  主意字符串
			lua_pushstring(l, strUserID.c_str());
			//密码空
			lua_pushstring(l, "");
			//cid
			lua_pushinteger(l, MarketAPI::GetSharedInstance()->getMarketCid());
			lua_pcall(l, 3, 0, 0);
             */
			
			CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(CLoginSchedule::ScheduleFunc), this);
			this->release();
		}
        
	};
    ////
    class CSwitchSchedule : public Ref
	{
	public:
		CREATE_FUNC(CSwitchSchedule);
		bool init()
		{
			CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(CSwitchSchedule::ScheduleFunc), this, 0.1, false);
			return true;
		}
		
	private:
		void ScheduleFunc(float dt)
		{
            MarketAPI::GetSharedInstance()->switchAccount();
			
			CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(CSwitchSchedule::ScheduleFunc), this);
			this->release();
		}
        
	};
    /////
    class CLogOutSchedule : public Ref
	{
	public:
		CREATE_FUNC(CLogOutSchedule);
		bool init()
		{
			CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(CLogOutSchedule::ScheduleFunc), this, 0.00000000001, false);
			return true;
		}
		
	private:
		void ScheduleFunc(float dt)
		{
            //TODO(chenbin)
            /*
            FGLogoutCall();
             */
            CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(CLogOutSchedule::ScheduleFunc), this);
			this->release();
		}
        
	};
    


       //登录回调接口
    void Java_org_cocos2dx_lua_MarketInterface_LoginCallBack(JNIEnv*  env, jobject thiz, jstring userID, jstring userName){
    	
    	LOGD("******************ND login form Java to C++********************");        
        int len = env->GetStringLength(userID);
        char *NDUserID = NULL;
        int buf_size = 256;
        if (len * 3 > (sizeof(char) * 256)) {
            NDUserID = (char*) malloc(len * 3 + 8);
            buf_size = len * 3 + 8;
        } else {
            NDUserID = (char*) malloc(256);
        }
        env->GetStringUTFRegion(userID, 0, len, NDUserID);
        
        int len1 = env->GetStringLength(userName);
        char *NDUserName = NULL;
        int buffer = 256;
        if(len1 * 3 > (sizeof(char)* 256)) {
        	NDUserName = (char*) malloc(len1 * 3 +8);
        	buffer = len1 * 3 +8;
        }else{
        	NDUserName = (char *) malloc(256);
        }
        env->GetStringUTFRegion(userName, 0, len1, NDUserName);
        
        string tempName = string(NDUserName);
		string tempUserID = string(NDUserID);
        
        //保存用户信息
        MarketAPI::GetSharedInstance()->setUserInfo(tempUserID, tempName);
//        //通知登入模块
//        lua_State *l = FGLua_L();
//        lua_getglobal(l, "FGPrettyLogin");
//        //用户id  主意字符串
//        lua_pushstring(l,tempUserID.c_str());
//        //密码空
//        lua_pushstring(l,"");
//        //cid
//        lua_pushinteger(l, MarketAPI::GetSharedInstance()->getMarketCid());
//        lua_pcall(l, 3, 0, 0);
		
		CLoginSchedule* pLoginSchedule = CLoginSchedule::create();
		pLoginSchedule->retain();
        
        free(NDUserID);
        free(NDUserName);
    	
    }
    
    //sdk切换到新账号回调
    void Java_org_cocos2dx_lua_MarketInterface_onSwitchAccount(JNIEnv*  env, jobject thiz, jstring userID, jstring userName)
    {
        int len = env->GetStringLength(userID);
        char *NDUserID = NULL;
        int buf_size = 256;
        if (len * 3 > (sizeof(char) * 256)) {
            NDUserID = (char*) malloc(len * 3 + 8);
            buf_size = len * 3 + 8;
        } else {
            NDUserID = (char*) malloc(256);
        }
        env->GetStringUTFRegion(userID, 0, len, NDUserID);
        
        int len1 = env->GetStringLength(userName);
        char *NDUserName = NULL;
        int buffer = 256;
        if(len1 * 3 > (sizeof(char)* 256)) {
        	NDUserName = (char*) malloc(len1 * 3 +8);
        	buffer = len1 * 3 +8;
        }else{
        	NDUserName = (char *) malloc(256);
        }
        env->GetStringUTFRegion(userName, 0, len1, NDUserName);
        
        string tempName = string(NDUserName);
		string tempUserID = string(NDUserID);
        
        ///TODO,sdk切换账号后的处理
        
        MarketAPI::GetSharedInstance()->setUserInfo(tempUserID, tempName);
        CSwitchSchedule* pSwitchSchedule = CSwitchSchedule::create();
		pSwitchSchedule->retain();
        
        free(NDUserID);
        free(NDUserName);
    }
    
    //保存sid
    void Java_org_cocos2dx_lua_MarketInterface_setSessionId(JNIEnv*  env, jobject thiz, jstring sessionID)
    {
        int len = env->GetStringLength(sessionID);
        char *NDsessionID = NULL;
        int buf_size = 256;
        if (len * 3 > (sizeof(char) * 256)) {
            NDsessionID = (char*) malloc(len * 3 + 8);
            buf_size = len * 3 + 8;
        } else {
            NDsessionID = (char*) malloc(256);
        }
        env->GetStringUTFRegion(sessionID, 0, len, NDsessionID);
        
        string tempsessionID = string(NDsessionID);
        
        MarketAPI::GetSharedInstance()->setSessionId(tempsessionID);
        
        free(NDsessionID);
    }
    
    //获取sid
    jstring Java_org_cocos2dx_lua_MarketInterface_getSessionId(JNIEnv*  env, jobject thiz, jstring sessionID)
    {
        const char* szSID = MarketAPI::GetSharedInstance()->getSessionId().c_str();
        jstring jIp = env->NewStringUTF(szSID);
        return jIp;
    }
    
    //支付成功回调接口
    void Java_org_cocos2dx_lua_MarketInterface_RechargeSucessBack(JNIEnv*  env, jobject thiz, jint rechargeTag)
    {
        
    }
    
    //支付失败回调接口
    void Java_org_cocos2dx_lua_MarketInterface_RechargeCancelBack(JNIEnv*  env, jobject thiz)
    {
        
    }
    void Java_org_cocos2dx_lua_MarketInterface_ShareMessageOKBack(JNIEnv*  env, jobject thiz)
    {
        //TODO(chenbin)
//        CFGgameShareOKBack();
        
    }
    void Java_org_cocos2dx_lua_MarketInterface_ShareMessageCancelBack(JNIEnv*  env, jobject thiz)
    {
        //分享失败的回调
//        CFGReopenShare();
    }
    void Java_org_cocos2dx_lua_MarketInterface_outGame(JNIEnv*  env, jobject thiz)
    {
        setAndroidPush();
    }
    jstring Java_org_cocos2dx_lua_MarketInterface_getServerName(JNIEnv*  env, jobject thiz)
    {
        const char* szServerName = g_flag_serverRealName.c_str();
        jstring jIp = env->NewStringUTF(szServerName);
        return jIp;
    }
    jstring Java_org_cocos2dx_lua_MarketInterface_getCharName(JNIEnv*  env, jobject thiz)
    {
        //TODO(chenbin)
        /*
        lua_State* L = FGLua_L();
     	lua_getglobal(L,"globalCharName");
        const char* szCharName = lua_tostring(L, -1);
        jstring jname = env->NewStringUTF(szCharName);
        return jname;
         */
        return env->NewStringUTF("");
    }
    void Java_org_cocos2dx_lua_MarketInterface_colseAnnouncementView(JNIEnv*  env, jobject thiz)
    {
        //TODO(chenbin)
        /*
        lua_State* L = FGLua_L();
        lua_getglobal(L,"FGSetglobalScenePopWinBeExist");
        lua_pushboolean(L, false);
        lua_pcall(L,1, 0, 0);
         */
    }
    //sdk注销的回调
    void Java_org_cocos2dx_lua_MarketInterface_LogOutCallBack(JNIEnv*  env, jobject thiz)
    {
        CLogOutSchedule* pLoginSchedule = CLogOutSchedule::create();
		pLoginSchedule->retain();
    }
    

//    //取消转圈圈
//    void Java_org_cocos2dx_lua_AppActivity_cancleLoading(JNIEnv*  env, jobject thiz)
//    {
//    	LOGD("***********cancleLoading!!*************");
//        CUSTOMINDICATOR->StopRunning();
//    }
    
    //android 网络状态回调
    void Java_org_cocos2dx_lua_MarketInterface_AndroidNetworkstatusBack(JNIEnv*  env, jobject thiz,jint status)
    {
        //TODO(chenbin)
        /*
        log("回调设置网络状态");
        FGSetNetworkStatusFlag(status);
         */
    }
    
    //android 获取当前游戏场景信息
    int Java_org_cocos2dx_lua_MarketInterface_AndroidGetSceneType(JNIEnv* env,jobject thiz)
    {
        //TODO(chenbin)
        /*
        int stype =  FGGetSceneTypeFlag();
        bool recon = FGIfReconnection();
        
        int state = 0;
        if (stype > 0 && recon == false)
        {
            state = 1;
        }
        else
        {
            state = 0;
        }
        
        return state;
         */
        return  0;
    }
    
    //android 返回按钮 - 退出游戏界面
    void Java_org_cocos2dx_lua_MarketInterface_ExitGameBox(JNIEnv* env,jobject thiz)
    {
        log("退出游戏 界面");
        class CFGGameOut : public Ref
        {
        public:
            CREATE_FUNC(CFGGameOut);
            bool init()
            {
                CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(CFGGameOut::ScheduleFunc), this, 0.00001, false);
                return true;
            }
            
        private:
            void ScheduleFunc(float dt)
            {
                //TODO(chenbin)
                /*
                FGAndroidExitGame();
                 */
                CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(CFGGameOut::ScheduleFunc), this);
                this->release();
            }
            
            
            
            
        };
        CFGGameOut* tempclass = CFGGameOut::create();
        tempclass->retain();
        
 
    }
	    
    //市场相关
    extern void initMarket_JNI(){
        jmethodID method = getMarketMethodID("initMarket", "()V",true);
        if (method != 0) 
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    //登陆
    extern void openLoginInterface_JNI() {
        jmethodID method = getMarketMethodID("openLoginInterface", "()V",true);
        if (method != 0) 
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    //注销
    extern void marketLogout_JNI(){
        jmethodID method = getMarketMethodID("marketLogout", "()V",true);
        if (method != 0)
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    //社区
    extern void openMarketInterface_JIN() {
        jmethodID method = getMarketMethodID("openMarketInterface", "()V",true);
        if (method != 0) 
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
  
    //取的cid
   extern int getMarketCid_JNI() {
        jmethodID method = getMarketMethodID("getMarketCID","()I", true);
        int _marketType;
        if(method!=0)
        {
            _marketType = env->CallStaticIntMethod(classOfMarketMethodInterface,method);
        }
        return _marketType;
    }
	
	extern string getAppId_JNI(){
		jmethodID method = getMarketMethodID("getAppID","()Ljava/lang/String;", true);
        string strRet = "";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
			strRet = JniHelper::jstring2string(str).c_str();
			env->DeleteLocalRef(str);
        }
        return strRet;
	}
	
	extern string getCurrencyType_JNI(){
		jmethodID method = getMarketMethodID("getCurrencyType","()Ljava/lang/String;", true);
        string strRet = "$";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
			strRet = JniHelper::jstring2string(str).c_str();
			env->DeleteLocalRef(str);
        }
        return strRet;
	}
    extern string getDeviceMACAddress_JNI(){
		jmethodID method = getMarketMethodID("getDeviceMACAddress","()Ljava/lang/String;", true);
        string strRet = "android";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
			strRet = JniHelper::jstring2string(str).c_str();
			env->DeleteLocalRef(str);
        }
        return strRet;
	}
    extern string getDeviceType_JNI()
    {
        jmethodID method = getMarketMethodID("getDeviceType","()Ljava/lang/String;", true);
        string strRet = "android";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
			strRet = JniHelper::jstring2string(str).c_str();
			env->DeleteLocalRef(str);
        }
        return strRet;
    }
    extern string getDeviceSysVerSion_JNI()
    {
        jmethodID method = getMarketMethodID("getDeviceSysVerSion","()Ljava/lang/String;", true);
        string strRet = "android";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
			strRet = JniHelper::jstring2string(str).c_str();
			env->DeleteLocalRef(str);
        }
        return strRet;
    }
    
    extern void sendServerSelected_JNI(const char* serverName)
    {
        jmethodID method = getMarketMethodID("sendServerSelected", "(Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg = env->NewStringUTF(serverName);
			
			
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg);
			
			env->DeleteLocalRef(stringArg);
        }
    }
    extern void sendEnterGame_JNI(const char* serverId,const char* serverName,const char* charId,const char* charName)
    {
        jmethodID method = getMarketMethodID("sendEnterGame", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg0 = env->NewStringUTF(serverId);
            jstring stringArg1 = env->NewStringUTF(serverName);
            jstring stringArg2 = env->NewStringUTF(charId);
            jstring stringArg3 = env->NewStringUTF(charName);
						
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg0,stringArg1,stringArg2,stringArg3);
			
			env->DeleteLocalRef(stringArg0);
            env->DeleteLocalRef(stringArg1);
            env->DeleteLocalRef(stringArg2);
            env->DeleteLocalRef(stringArg3);
        }
    }
    extern void sendCharCreate_JNI(const char* serverId,const char* serverName,const char* charId,const char* charName)
    {
        jmethodID method = getMarketMethodID("sendCharCreate", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg0 = env->NewStringUTF(serverId);
            jstring stringArg1 = env->NewStringUTF(serverName);
            jstring stringArg2 = env->NewStringUTF(charId);
            jstring stringArg3 = env->NewStringUTF(charName);
            
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg0,stringArg1,stringArg2,stringArg3);
			
			env->DeleteLocalRef(stringArg0);
            env->DeleteLocalRef(stringArg1);
            env->DeleteLocalRef(stringArg2);
            env->DeleteLocalRef(stringArg3);
        }
    }
    extern void sendCharInfo_JNI(const char* serverId,const char* serverName,const char* charId,const char* charName,const char* charLevel,const char* vipLv,char* leftDiamond,const char* guildId)
    {
        jmethodID method = getMarketMethodID("sendCharInfo", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg0 = env->NewStringUTF(serverId);
            jstring stringArg1 = env->NewStringUTF(serverName);
            jstring stringArg2 = env->NewStringUTF(charId);
            jstring stringArg3 = env->NewStringUTF(charName);
            jstring stringArg4 = env->NewStringUTF(charLevel);
            jstring stringArg5 = env->NewStringUTF(vipLv);
            jstring stringArg6 = env->NewStringUTF(leftDiamond);
            jstring stringArg7 = env->NewStringUTF(guildId);
            
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg0,stringArg1,stringArg2,stringArg3,stringArg4,stringArg5,stringArg6,stringArg7);
			
			env->DeleteLocalRef(stringArg0);
            env->DeleteLocalRef(stringArg1);
            env->DeleteLocalRef(stringArg2);
            env->DeleteLocalRef(stringArg3);
            env->DeleteLocalRef(stringArg4);
            env->DeleteLocalRef(stringArg5);
            env->DeleteLocalRef(stringArg6);
            env->DeleteLocalRef(stringArg7);
        }
    }
    
    //反馈
    extern void  openFeedback_JNI(){
    	jmethodID method = getMarketMethodID("openFeedback", "()V",true);
        if (method != 0) 
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    extern void loginViewIsFinish_JNI()
    {
        
        jmethodID method = getMarketMethodID("loginViewIsFinish", "()V",true);
        if (method != 0)
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    extern void randomBuy_JNI(const char * szSerial)
    {
        jmethodID method = getMarketMethodID("randomBuy", "(Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg = env->NewStringUTF(szSerial);
			
			
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg);
			
			env->DeleteLocalRef(stringArg);
        }
    }
	extern void buy_JNI(const char* szSerial,const char* bName, int nID, int nDiamond, int nPrice)
	{
		jmethodID method = getMarketMethodID("buy", "(Ljava/lang/String;Ljava/lang/String;III)V",true);
        if (method != 0)
        {
			jstring stringArg = env->NewStringUTF(szSerial);
			jstring stringName = env->NewStringUTF(bName);
			
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg,stringName, nID, nDiamond, nPrice);
			
			env->DeleteLocalRef(stringArg);
        }
	}
    
    
    
    
    //分享初始化
    extern void FGgameShareAchieve_init_JNI()
	{
//		jmethodID method = getMarketMethodID("buy", "(Ljava/lang/String;III)V",true);
//        if (method != 0)
//        {
//			jstring stringArg = env->NewStringUTF(szSerial);
//			
//			
//            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg, nID, nDiamond, nPrice);
//			
//			env->DeleteLocalRef(stringArg);
//        }
	}

    
    extern void FGgameShareAchieve_ShareMessage_JNI(string content,string defaultContent,string title, string image,string url)
    {
        
        
        
        
		jmethodID method = getMarketMethodID("ShareMessage", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring j_content = env->NewStringUTF(content.c_str());
            jstring j_defaultContent = env->NewStringUTF(defaultContent.c_str());
            jstring j_title = env->NewStringUTF(title.c_str());
            jstring j_image = env->NewStringUTF(image.c_str());
            jstring j_url = env->NewStringUTF(url.c_str());
            
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, j_content,j_defaultContent,j_title,j_image,j_url);
			env->DeleteLocalRef(j_content);
            env->DeleteLocalRef(j_defaultContent);
            env->DeleteLocalRef(j_title);
            env->DeleteLocalRef(j_image);
            env->DeleteLocalRef(j_url);
        }
        
        
        
        
    }
    extern void FGGameOpenLinks_JNI(string url)
    {
        
		jmethodID method = getMarketMethodID("openSystemUrl", "(Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg = env->NewStringUTF(url.c_str());
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg);
			env->DeleteLocalRef(stringArg);
        }
    
    }
    
    extern void FGopenAnnouncementView_JNI(string url)
    {
        
        jmethodID method = getMarketMethodID("openAnnouncementView", "(Ljava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg = env->NewStringUTF(url.c_str());
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method, stringArg);
			env->DeleteLocalRef(stringArg);
        }
    
    }
    
    extern void FGsetOneAlarm_JNI(int pushId ,int time , string  text)
    {
        
        jmethodID method = getMarketMethodID("FGsetOneAlarm", "(IILjava/lang/String;)V",true);
        if (method != 0)
        {
			jstring stringArg = env->NewStringUTF(text.c_str());
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method,pushId,time, stringArg);
			env->DeleteLocalRef(stringArg);
        }

    }
    extern void FGcancelOneAlarm_JNI(int pushId)
    {
        
        jmethodID method = getMarketMethodID("FGcancelOneAlarm", "(I)V",true);
        if (method != 0)
        {

            env->CallStaticVoidMethod(classOfMarketMethodInterface, method,pushId);
        }
    }
    extern void FGcancelAllNotification_JNI()
    {
        jmethodID method = getMarketMethodID("FGcancelAllNotification", "()V",true);
        if (method != 0)
        {
            
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    
    
    extern void FGcheckNetworkStatus_JNI(){
        jmethodID method = getMarketMethodID("FGcheckNetworkStatus", "()V",true);
        if (method != 0)
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    extern string FGGetGameName_JNI(){
        jmethodID method = getMarketMethodID("FGGetGameName","()Ljava/lang/String;",true);
        string strRet = "";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
			strRet = JniHelper::jstring2string(str).c_str();
			env->DeleteLocalRef(str);
        }
        return strRet;
    }
    
    string getPackageVersion_JNI(){
        
        jmethodID method = getMarketMethodID("getPackageVersion","()Ljava/lang/String;",true);
        string strRet = "";
        if(method!=0)
        {
            jstring str = (jstring)env->CallStaticObjectMethod(classOfMarketMethodInterface,method);
            strRet = JniHelper::jstring2string(str).c_str();
            env->DeleteLocalRef(str);
        }
        return strRet;
    }
    
    extern void FGAndroidExitGameHandle_JNI(){
        jmethodID method = getMarketMethodID("FGAndroidExitGameHandle", "()V",true);
        if (method != 0)
        {
            env->CallStaticVoidMethod(classOfMarketMethodInterface, method);
        }
    }
    
    
}
