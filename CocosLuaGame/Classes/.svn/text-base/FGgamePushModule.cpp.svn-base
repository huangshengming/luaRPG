//
//  FGgamePushModule.cpp
//  FGClient
//
//  Created by 神利 on 13-6-10.
//
//

#include "FGgamePushModule.h"
#include "WholeDefine.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "MyJni.h"
#endif

#define TWO_DAY (2*24*60*60)
#define Five_DAY (5*24*60*60)
#define A_WEEK (7*24*60*60)
#define A_MONTH (30*24*60*60)

int getPustTimeforTag(FGgamePushTag tag)
{
//    VPfullPushTag=1,//体力满
//    twoDayPushTag=2,//离线2填
//    ThreeDayPushTag=3,//离线3天
//    eightoclockPushTag=4,//每天8点
//    activityPushTag=5,//每日活动
    
    if(!g_luaisLoad)
    {
        return -1;
    }
    int time=-1;
    
    switch (tag) {
            //体力满了
        case VPfullPushTag:
        {
        }
            break;
            
       
            //5天没有登入
        case fiveDayPushTag:
            time=Five_DAY;
            break;
        case twoDayPushTag:
            time=TWO_DAY;
            break;
            //每日8点
        case eightoclockPushTag:
        {
        }
            break;
            //每日活动
        case activityPushTag:
        {
        }
             break;
       
        case eatBun1:
        {
        }
            break;
        case eatBun2:
        {
        }
            break;
        case bossTag:
        {
        }
            break;
        default:
            break;
    }
    
    if(time<=0)
    {
        time=-1;
    };
    
    float p = (float)time/3600;
    CCLOG("离线推送时间：%f显示",p);
    return time;

}

std::string getPustStringforTag(FGgamePushTag tag)
{
    std::string tempString="";
//    lua_State *L = FGLua_L();
//    lua_getglobal(L,"FGGetUnlinePushString");
//    lua_pushinteger(L,tag);
//    lua_pcall(L,1,1,0);
//    tempString =lua_tostring(L, -1);
//    CCLOG("<<<<<<<离线文字%s",tempString.c_str());
    return tempString;
}

void setAndroidPush()
{
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    for (int i=VPfullPushTag; i<=activityPushTag; i++)
    {
        int time = getPustTimeforTag((FGgamePushTag)i);
        if(time!=-1)
        {
            string tempString = getPustStringforTag((FGgamePushTag)i);
            FGsetOneAlarm_JNI(i,time,tempString);
            
            log("%d,%s",time,tempString.c_str());
        }
    }
    
#endif
    
}
void cancelAndroidPush()
{
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    
    for (int i=VPfullPushTag; i<=activityPushTag; i++)
    {
        FGcancelOneAlarm_JNI(i);
    }
    FGcancelAllNotification_JNI();
    
#endif
}