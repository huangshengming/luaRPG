//
//  MyJin.h
//  FGClient
//
//  Created by 神利 on 13-6-17.
//
//
#ifndef __MYJNI__H__
#define __MYJNI__H__

#include <string>
using namespace std;
extern "C"
{


    
//    /***********************市场相关***********************/
    extern void initMarket_JNI();
    extern void openLoginInterface_JNI();
    extern void marketLogout_JNI();
    extern void openMarketInterface_JIN();
    extern void openFeedback_JNI();
    extern void loginViewIsFinish_JNI();
    extern void sendServerSelected_JNI(const char* serverName);
    extern void sendEnterGame_JNI(const char* serverId,const char* serverName,const char* charId,const char* charName);
    extern void sendCharCreate_JNI(const char* serverId,const char* serverName,const char* charId,const char* charName);
    extern void sendCharInfo_JNI(const char* serverId,const char* serverName,const char* charId,const char* charName,const char* charLevel,const char* vipLv,char* leftDiamond,const char* guildId);
    
	extern void buy_JNI(const char* szSerial,const char* bName, int nID, int nDiamond, int nPrice);
    extern void randomBuy_JNI(const char * szSerial);
	
    extern int getMarketCid_JNI();
	extern string getAppId_JNI();

	extern string getCurrencyType_JNI();
    
    extern string getDeviceMACAddress_JNI();
    extern string getDeviceType_JNI();
    extern string getDeviceSysVerSion_JNI();
    
    
    extern void FGgameShareAchieve_init_JNI();
    extern void FGgameShareAchieve_ShareMessage_JNI(string content,string defaultContent,string title, string image,string url);
    extern void FGGameOpenLinks_JNI(string url);
    extern void FGopenAnnouncementView_JNI(string url);
    
    extern void FGsetOneAlarm_JNI(int pushId ,int time , string  text);
    extern void FGcancelOneAlarm_JNI(int pushId);
    extern void FGcancelAllNotification_JNI();
    
    /***********************网络状况相关***********************/
    extern void FGcheckNetworkStatus_JNI();
    //获取android 游戏名称
    extern string FGGetGameName_JNI();
    //android exit game handle
    extern void FGAndroidExitGameHandle_JNI();
    
    extern string getPackageVersion_JNI();
}
#endif /* __MYJNI__H__ */

