//
//  FGgamePushModule.h
//  FGClient
//
//  Created by 神利 on 13-6-10.
//
//

#ifndef __FGClient__FGgamePushModule__
#define __FGClient__FGgamePushModule__

#include <iostream>


typedef enum
{
    VPfullPushTag=1,//体力满
    twoDayPushTag=2,//离线2填
    fiveDayPushTag=3,//离线3天
    eightoclockPushTag=4,//每天8点
    activityPushTag=5,//每日活动
    eatBun1 = 6,//吃包子
    eatBun2 = 7,
    bossTag =8,//荒兽入侵
   
} FGgamePushTag;

int getPustTimeforTag(FGgamePushTag tag);
std::string getPustStringforTag(FGgamePushTag tag);

void setAndroidPush();
void cancelAndroidPush();
#endif /* defined(__FGClient__FGgamePushModule__) */
