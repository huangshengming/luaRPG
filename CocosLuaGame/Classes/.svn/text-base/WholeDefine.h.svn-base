//
//  WholeDefine.h
//  FGClient
//
//  Created by 神利 on 13-4-23.
//
//

#ifndef __FGClient__WholeDefine__
#define __FGClient__WholeDefine__



/**********宏*************/
//需要增量更新(正式版本)  ios开启更新时候请先运行Resources 下的 lua_to_luac.sh

//#define GameNeedUpdate
//开启就是高清版本  关闭 低清模式
#define GameHDVersion
//版本更新检测地址

//1.18版本
//#ifdef GameHDVersion
//
//#define VersionVerificationURL "http://opx097.my9yu.com:12007/upgrade?p=%d&sy=%s&sr=%d&res=1"
//
//#else
//#define VersionVerificationURL "http://opx097.my9yu.com:12007/upgrade?p=%d&sy=%s&sr=%d&res=2"
//
//#endif

//#define GetIsShowADUrl  "http://opx097.my9yu.com:12007/getadvstatus?cid=%d&ver=%s"
//2.0版本
#ifdef GameHDVersion

    #define VersionVerificationURL "http://opx097.my9yu.com:12006/upgrade?p=%d&sy=%s&sr=%d&res=1"

#else
    #define VersionVerificationURL "http://opx097.my9yu.com:12006/upgrade?p=%d&sy=%s&sr=%d&res=2"

#endif
#define GetIsShowADUrl  "http://opx097.my9yu.com:12006/getadvstatus?cid=%d&ver=%s"

//订单号
//普通充值
#define PlatformGetOrderSerialURL "%sGetOrderNo?platformCode=%d&serverName=%s&charId=%0.0f&charName=%s&app_id=%s&amount=%d&sign=%s"
//随便充值 37玩特供
#define PlatformGetOrderSerialURL2 "%sGetOrderNo?platformCode=%d&serverName=%s&charId=%0.0f&charName=%s&app_id=%s&sign=%s"
//金立特供 增加playerId
#define PlatformGetOrderSerialURL3 "%sGetOrderNo?platformCode=%d&serverName=%s&charId=%0.0f&charName=%s&app_id=%s&amount=%d&sign=%s&playerId=%s"

//appstore消费成功
#define appStoreOrderPostURL "%sGetAPPDataFromClient"
//**********通用include*************/

#include "cocos2d.h"
//#include "cocos-ext.h"

#include <iostream>
#include "CCLuaEngine.h"
//**********命名空间*************/
//USING_NS_CC_EXT;
USING_NS_CC;
using namespace std;

/**********全剧变量*********/
extern bool g_flag_update;
extern bool g_flag_reconnect;
extern bool g_flag_switch;
extern std::string g_flag_serverRealName ;
extern string g_flag_serverName;
extern string g_flag_ip;
extern string g_flag_port;
extern string g_flag_name;
extern string g_flag_psw;
extern int g_flag_userId;
extern int g_flag_sceneType;
extern int g_flag_networkStatus;
extern bool g_isEditboxShow;
extern bool g_luaisLoad;
extern string g_download_url;
extern bool g_flag_sdkSwitch;

// global var
extern Scene* globalScene;

extern map<int, std::string>g_cidkeyMap;
#define BYGPromptObjTag (-59939230)
/**********通用函数*************/

//分割字符串
vector<std::string> SplitString(std::string aString,char aSplitChar);
vector<std::string> SplitString(std::string aString,const char* aSplitChar);
//数据加密 生成校验码
string FGgameEncryption(string buff);
inline std::string intToString(int value)
{
    char buff[33] = {0};
    snprintf(buff, 33,"%d", value);
    
    std::string str;
    str.insert(0, buff);
    return str;
}
inline std::string doubleToString(double value)
{
    
    char buff[65] = {0};
    snprintf(buff, 65,"%0.0f", value);
    
    std::string str;
    str.insert(0, buff);
    return str;

}
inline Color3B intColorToccc(int color)
{
    Color3B col;
    col.r = (0x00FF0000&color)>>16;
    col.g = (0x0000FF00&color)>>8;
    col.b = (0x000000FF&color);
    return col;

}

inline lua_State * getGlobalLuaStack()
{
    auto engine = LuaEngine::getInstance();
    LuaStack* stack = engine->getLuaStack();
    lua_State* L = stack->getLuaState();
    return L;
}
inline void FGLuaRegistInterface(const char* interfaceName,lua_CFunction func){
    lua_register(getGlobalLuaStack(), interfaceName, func);
}
#define LRT(x) FGLuaRegistInterface(#x,x);

std::string UrlEncode(const std::string &szToEncode);
std::string UrlDecode(const std::string &szToDecode);


const char * FGLocalizedString(const char * mKey,const char * mComment);

#undef NSLocalizedString
#define NSLocalizedString(key, comment) FGLocalizedString(key,comment)


#endif /* defined(__FGClient__WholeDefine__) */
