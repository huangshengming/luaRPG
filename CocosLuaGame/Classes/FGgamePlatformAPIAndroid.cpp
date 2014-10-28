//
//  FGgamePlatformAPI.cpp
//  FGClient
//
//  Created by 神利 on 13-7-11.
//
//

#include "FGgamePlatformAPI.h"
#include "MyJni.h"


string getDeviceIdentification()
{
    
      
    return getDeviceMACAddress_JNI();
}


string getBundleIdentifier()
{
    return "";
}

string getGameName()
{
    return FGGetGameName_JNI();
}

void openWebView(string url ,CCRect nowRect,bool isNeedclose)
{
    
    
    
}
void closeWebView()
{
    
}

void openAnnouncementView(string url)
{
    
    FGopenAnnouncementView_JNI(url);
    
    
    
}

//android exit game handle
void androidExitGame(){
    FGAndroidExitGameHandle_JNI();
}

string getDeviceName()
{
    return "";
}
string getDeviceType()
{
    return getDeviceType_JNI();
}
string getDeviceSysVerSion()
{
    return "android " + getDeviceSysVerSion_JNI();
}
string getMacAddress()
{
    
    return getDeviceMACAddress_JNI();
}
string getIdfa()
{
    
    return "";
    
}
