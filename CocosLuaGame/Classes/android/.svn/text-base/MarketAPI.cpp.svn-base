//
//  MarketAPI.cpp
//  FGClient
//
//  Created by 神利 on 13-5-20.
//
//

#include "MarketAPI.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <iostream>
#include "MyJni.h"
#include "WholeDefine.h"

using namespace std;

using namespace cocos2d;
static  bool isFitstStartGame =true;

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
    initMarket_JNI();
    

}


kMarketType MarketAPI::getMarketType()
{
    return marketType;
}

//获取平台id

int MarketAPI::getMarketCid()
{
    return    getMarketCid_JNI();
}



void MarketAPI::openLoginInterface()
{
    openLoginInterface_JNI();

}
void MarketAPI::logout()
{
    marketLogout_JNI();
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
    openMarketInterface_JIN();
    
}

void MarketAPI::openFeedback()
{
    
    openFeedback_JNI();
    
}

unsigned int g_nRechargeIndex = 0;

//任意充值
void MarketAPI::rechargeMoney(string OrderID)
{
    randomBuy_JNI(OrderID.c_str());
}
void MarketAPI::rechargeMoney(int index)
{
    //TODO(chenbin)
    /*
    if(index>FGRechargeModule::getInstance()->GetItems().size()||index<1)return;
	g_nRechargeIndex = index - 1;
	
	const RechargeItem* pItem = FGRechargeModule::getInstance()->GetItem(g_nRechargeIndex);
	if ( pItem == NULL )
	{
		return;
	}
	
	FGResourcesManage::SharedIntance()->StartRunning();
	
	// 请求订单号
	lua_State* L = FGLua_L();
    
	lua_getglobal(L,"login_register");
	lua_getfield(L, -1, "servername");
	const char* szServerName = lua_tostring(L, -1);
	lua_pop(L, 1);
	
	lua_getglobal(L,"globalCharId");
	double nCharId = lua_tonumber(L, -1);
	
	lua_getglobal(L,"globalCharName");
	const char* szCharName = lua_tostring(L, -1);
	
	std::string strAppID = getAppId_JNI();
	
    char szUrl[512] = {0};
    string neddEncryption;
    neddEncryption= intToString( getMarketCid())+ szServerName+ doubleToString(nCharId)+szCharName+strAppID+ intToString( pItem->nID);
    string key = FGgameEncryption(neddEncryption);
	
    
    string encodeCharName=UrlEncode(szCharName);
    string encodeServerName=UrlEncode(szServerName);
	
	if (getMarketCid() == kMarketJinli) {
		snprintf(szUrl,512, PlatformGetOrderSerialURL3,CFGgetPayUrlByCid().c_str(), getMarketCid(), encodeServerName.c_str(), nCharId, encodeCharName.c_str(), strAppID.c_str(), pItem->nID,key.c_str(), mUserID.c_str());
	} else {
		snprintf(szUrl,512, PlatformGetOrderSerialURL,CFGgetPayUrlByCid().c_str(), getMarketCid(), encodeServerName.c_str(), nCharId, encodeCharName.c_str(), strAppID.c_str(), pItem->nID,key.c_str());
	}
	
	
	CCHttpRequest* request = new CCHttpRequest();
    request->setUrl(szUrl);
    request->setRequestType(CCHttpRequest::kHttpGet);
    request->setResponseCallback(this, callfuncND_selector(MarketAPI::getdata));
    request->setTag("OrderSerial");
    CCHttpClient::getInstance()->send(request);
    request->release();
     */
}

void MarketAPI::loginViewIsFinish()
{
    if(isFitstStartGame)
    {
        loginViewIsFinish_JNI();
    }
    isFitstStartGame=false;
    
    //TODO(chenbin)
    /*
    if (g_flag_sdkSwitch) {
        string strUserID;
        string strUSerName;
        MarketAPI::GetSharedInstance()->getUserInfo(strUserID, strUSerName);
        //通知登入模块
        lua_State *l = FGLua_L();
        lua_getglobal(l, "FGPrettyLogin");
        //用户id  主意字符串
        lua_pushstring(l,strUserID.c_str());
        //密码空
        lua_pushstring(l,"");
        //cid
        lua_pushinteger(l, MarketAPI::GetSharedInstance()->getMarketCid());
        lua_pcall(l, 3, 0, 0);
        
        g_flag_sdkSwitch = false;
    }
     */
}

void MarketAPI::getdata(CCNode* sender,void *responeData)
{
    //TODO(chenbin)
    /*
	FGResourcesManage::SharedIntance()->StopRunning();
	
    CCHttpResponse *response = (CCHttpResponse*)responeData;
    if (!response)
    {
        FGUIMsgBox::createWithString(NSLocalizedString("无法连接充值服务器",""));
        CCLog("response null");
        return;
    }
    
    if (!response->isSucceed()) {
        FGUIMsgBox::createWithString(NSLocalizedString("无法连接充值服务器",""));
        CCLog("response failed");
        return;
    }
    
    const char* szTag = response->getHttpRequest()->getTag();
	if ( strlen(szTag) == 0 ){
		return;
	}
	
	if ( strcmp(szTag, "OrderSerial") == 0 )
	{
		std::vector<char> *buffer = response->getResponseData();
		string tempbuffer(buffer->begin(), buffer->end());
		if(tempbuffer=="False")
        {
            FGUIMsgBox::createWithString(NSLocalizedString("数据校验出错","充值出错"));
            
        }
        else if(tempbuffer=="close")
        {
            FGUIMsgBox::createWithString(NSLocalizedString("充值服务暂未开放","充值关闭"));
        }
        else
        {
            const RechargeItem* pItem = FGRechargeModule::getInstance()->GetItem(g_nRechargeIndex);
            if ( pItem != NULL )
            {
                //获取内购名称
                lua_State *l = FGLua_L();
                lua_getglobal(l, "FGGetRechargeCellName");
                //商品ID
                lua_pushinteger(l,pItem->nID);
                
                lua_pcall(l, 1, 1, 0);
                
                string pname = lua_tostring(l, -1);
                if (getMarketCid() == 128) {
                    //酷派，商品ID是配在酷派后台的
                    buy_JNI(tempbuffer.c_str(),pname.c_str(), atoi(pItem->appStoreKey.c_str()), pItem->nDiamond, pItem->nPlatformPrice);
                }
                else if(getMarketCid() == 159)
                {
                    //柴米，商品ID是配在柴米后台的,并且是字符串
                    buy_JNI(tempbuffer.c_str(),pItem->appStoreKey.c_str(), pItem->nID, pItem->nDiamond, pItem->nPlatformPrice);
                }
                else{
                    buy_JNI(tempbuffer.c_str(),pname.c_str(), pItem->nID, pItem->nDiamond, pItem->nPlatformPrice);
                }
            }
        }
	}
    */
}
string MarketAPI::getMakretCurrencyType()
{
    return getCurrencyType_JNI();
}
void MarketAPI::sendServerSelected(const char* serverName)
{
    sendServerSelected_JNI(serverName);
}
void MarketAPI::sendEnterGame(const char* serverId,const char* serverName,const char* charId,const char* charName)
{
    sendEnterGame_JNI(serverId,serverName,charId,charName);
}
void MarketAPI::sendCharCreate(const char* serverId,const char* serverName,const char* charId,const char* charName)
{
        sendCharCreate_JNI(serverId,serverName,charId,charName);
}

//网络类型
void MarketAPI::checkNetworkStatus(){
    FGcheckNetworkStatus_JNI();
}
void MarketAPI::switchAccount()
{
}

void MarketAPI::pause(){
    
}

//点击游戏系统设置切换账号按钮时调用
void MarketAPI::switchAccountInGame()
{
    
}



#endif


