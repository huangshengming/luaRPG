
//
//  MarketAPIDefine.h
//  FGClient
//
//  Created by 神利 on 13-5-20.
//
//

#ifndef __FGClient__MarketAPI__
#define __FGClient__MarketAPI__

#include "MarketAPIDefine.h"
#include "cocos2d.h"
#include "WholeDefine.h"




#define SHARED_MARKET_API MarketAPI::GetSharedInstance()


struct CommodityInfo  //普通物品
{
    int  CommodityID; //商品id
    int  CommodityNub; //商品数量 (多少灵钻)
    int  CommodityPrice;//商品价格 (比如 多少91豆 ,多少$ 多少RMB)
    string  PriceName;  //比如 91豆  $ RMB等等
};



class MarketAPI : public Ref
{
public:
    static MarketAPI *m_sInstance;
    static MarketAPI *GetSharedInstance()
    {
        if (m_sInstance == NULL)
        {
            m_sInstance = new MarketAPI();
            m_sInstance->init();
        }
        return m_sInstance;
    }

    MarketAPI();
    ~MarketAPI();

    void init();
    /**
     * @brief 市场平台初始化
     */
    void initMarket();
    /**
     * @brief 获取当前市场类型
     */
    kMarketType getMarketType();
    /**
     * @brief 打开登录界面
     */
    void openLoginInterface();
    /**
     * @brief 注销
     */
    void logout();
    /**
     * @brief 切换账号
     */
    void switchAccount();
    /**
     * @brief 充值
     * @param index充值索引
     **/
    //定额充值
    void rechargeMoney(int index);
    //任意充值
    void rechargeMoney(string OrderID);
    
    // 获取平台cid
    int getMarketCid();
    // 获取平台Key
//    string getMarketPrivateKey();
    
    /**
     * @brief 设置登录数据
     * @param UserID用户ID, NickName 昵称
     */
    void setUserInfo(string UserID, string NickName);
    /**
     * @brief 获取登录数据
     * @param return UserID用户ID, NickName 昵称
     */
    void getUserInfo(string &UserID, string &NickName);
    /**
     * @brief 打开平台界面
     */
    void openMarketInterface();
    /**
     * @brief 打开用户反馈界面
     */
    void openFeedback();

    /**
     * @brief 登陆界面初始化完成
     */
    void loginViewIsFinish();
    
    /**
     * @brief 选服统计
     */
    void sendServerSelected(const char* serverName);
    
    /**
     * @brief 进入游戏统计
     */
    void sendEnterGame(const char* serverId,const char* serverName,const char* charId,const char* charName);
    
    /**
     * @brief 创建角色统计
     */
    void sendCharCreate(const char* serverId,const char* serverName,const char* charId,const char* charName);
   
    //http回调
    void getdata(Node* sender,void *responeData);
    
    string  getMakretCurrencyType();
    
    //网络类型
    void checkNetworkStatus();
    
    //暂停
    void pause();
    
    /**
     * @brief 切换账号 点击游戏系统设置切换账号按钮时调用
     */
    void switchAccountInGame();
    
    inline void setSessionId(string id){sessionId = id;}
    inline string getSessionId(){return sessionId;}
    
private:
    //市场类型
    kMarketType marketType;
    //用户ID
    string  mUserID;
    //昵称
    string mNickName;
    //sessionId
    string sessionId;
};

#endif