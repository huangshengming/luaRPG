//
//  FGUpdateView.h
//  FGClient
//
//  Created by 神利 on 13-4-23.
//
//

#ifndef __FGClient__FGUpdateView__
#define __FGClient__FGUpdateView__

#include <iostream>
#include "cocos2d.h"
#include "libjson.h"
#include "FGUpdateModule.h"
#include "CCFileCompressOperation.h"
using namespace network;

class FGProgressBar;

//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
class FGUpdateView :public Node,public CCGameResourcesVersion ,public HttpRequestLoadingDelegate ,public CCFileCompressOperationDelegate
{
    
public:
    FGUpdateView();
    ~FGUpdateView();
    bool init();
    void initView();
    void update(float dt);
    
    //http 返回服务器版本信息
    virtual void requestResourcesSuccess(string resUrlString,string fullResUrl,int versionNum,float gamecodeversion,map<int, map<int, string> > versionMd5,map<int, map<int, string> > allpacketMd5,map<int, map<int, string> > fullResMd5,int trueUpdateVersion);
    //http 返回错误
    virtual void requestResourcesFail(string errorCode);
 
    //当前http 在下载的进度
    virtual void httpRequestLoadingProgress(const char* FileName,double download_total_size, double download_total_size_done);
    //http当前文件下载完成
    virtual void downloadfileresources(Node* sender,HttpResponse *response);
    
    //解压文件 进度
    virtual void ccfileUncompressProgress(const char * filename ,int currentFile,int totalFile);
    //解压文件
    virtual void ccfileUncompressProgressResult(const char * filename ,int resultCode);
    virtual void ccfileUncompressErrorResult(const char * errorString ,int resultCode);
    //开始更新 return false无需更新直接进入游戏
    bool sureUpdateResources();
    //小安装包更新大资源包的更新
    bool updateFullResources();
    //通知服务器大小包下载的状态,0开始下载，1完成所有下载
    void sendFullResourcesStatus(int resIndex);
    //在内网环境下，选择是否要更新测试包（如果有测试包）
    void confirmUpdateHandler(Ref* obj,int result);
    
    //退出游戏
 
//    void Callback(Ref* obj,int i);
    void focusExit(Ref* obj,int i);
    void Reconnect(Ref* obj,int i);
    void OpenLinks(Ref* obj,int i);
    void speedTimeFunc(float timesub);
    //
    void nosFunc(float timesub);
    void fullResCallBack(float dt);
    void updateResCallBack(float dt);
    CREATE_FUNC(FGUpdateView);
    

private:
    Label*  LabelTitle;
    Label* _ProgressBarlabel;
    bool isEnterLoginScene;
    map<int, map<int, string> > m_versionMd5;
    map<int, map<int, string> > m_allpacketMd5;
    map<int, map<int, string> > m_fullResMd5;
    std::list<string>m_errorString;
    int m_hightUpdateVersion;
    int m_hightAllPacket;
    string m_urlString;
    string m_fullResUrl;
    double current_done_size;
    double total_done_size;
    bool   isDecompressioning;
    //进度条应该被分成几份
    float m_DeltaResVersion;
    float m_CompletedRes;
    double m_ResLenght;
};

//#endif





#endif /* defined(__FGClient__FGUpdateView__) */
