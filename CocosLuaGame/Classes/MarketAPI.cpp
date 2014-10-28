//
//  MarketAPI.cpp
//  FGClient
//
//  Created by 神利 on 13-5-20.
//
//


#include "MarketAPI.h"
#include "network/HttpClient.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#include <iostream>
//#import "AppStorePay.h"


using namespace std;

using namespace cocos2d;
using namespace network;

MarketAPI* MarketAPI::m_sInstance = NULL;

MarketAPI::MarketAPI()
:mUserID("")
,mNickName("")
, marketType(kMarketGeneral)
{
    
}
MarketAPI::~MarketAPI()
{

}
void MarketAPI::init()
{
    
    initMarket();
}


void MarketAPI::initMarket()
{
    
//    AppStorePay* appPay = [AppStorePay GetShargInstance];
//    [appPay initAppStoreMarket];

}


kMarketType MarketAPI::getMarketType()
{
    return marketType;
}

//获取平台id

int MarketAPI::getMarketCid()
{
    return CID_w(800);
    
}

//string MarketAPI::getMarketPrivateKey()
//{
//    
//
//}


void MarketAPI::openLoginInterface()
{

}
void MarketAPI::logout(){
    
}

void MarketAPI::switchAccount(){
   
}

void MarketAPI::setUserInfo(std::string UserID, std::string NickName)
{
    mUserID   = UserID;
    mNickName = NickName;
    
}

void MarketAPI::getUserInfo(std::string &UserID, std::string &NickName)
{
    UserID   = mUserID;
    NickName = mNickName;
}

void MarketAPI::openMarketInterface()
{
    
    
}

void MarketAPI::openFeedback()
{
    
    
    
}

void MarketAPI::rechargeMoney(int index)
{
//    AppStorePay* appPay = [AppStorePay GetShargInstance];
//    [appPay buyProductWithIndex:index];

}
//任意充值
void MarketAPI::rechargeMoney(string OrderID)
{
}
void MarketAPI::loginViewIsFinish()
{

}

void MarketAPI::getdata(Node* sender,void *responeData)
{
    
    HttpResponse *response = (HttpResponse*)responeData;
    if (!response)
    {
        log("response null");
        return;
    }
    
    if (!response->isSucceed()) {
        log("response failed");
        return;
    }



}

string MarketAPI::getMakretCurrencyType()
{

    return "￥";
}

void MarketAPI::sendServerSelected(const char* serverName)
{
}
void MarketAPI::sendEnterGame(const char* serverId,const char* serverName,const char* charId,const char* charName)
{
}
void MarketAPI::sendCharCreate(const char* serverId,const char* serverName,const char* charId,const char* charName)
{
}

//网络类型
void MarketAPI::checkNetworkStatus(){
    
}

void MarketAPI::pause(){
    
}

//点击游戏系统设置切换账号按钮时调用
void MarketAPI::switchAccountInGame()
{
    
}

#endif //(CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
