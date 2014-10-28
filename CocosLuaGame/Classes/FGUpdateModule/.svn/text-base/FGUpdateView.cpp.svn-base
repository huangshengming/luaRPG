//
//  FGUpdateView.cpp
//  FGClient
//
//  Created by 神利 on 13-4-23.
//
//

#include "FGUpdateView.h"

//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#include "VisibleRect.h"
#include "network/HttpClient.h"
#include "AppDelegate.h"
#include "FGUpdateModule.h"
#include "FGgameSet.h"
#include "WholeDefine.h"
#include "FGgameinit.h"
#include "CCXMLFile.h"
#include "MarketAPI.h"
#include "FGgamePlatformAPI.h"


using namespace std;
using namespace network;

FGUpdateView::FGUpdateView()
:isEnterLoginScene(false)
,current_done_size(0)
,total_done_size(0)
,isDecompressioning(false)
,m_DeltaResVersion(-1)
{
    m_errorString.clear();
    FGUpdateModule::SharedIntance()->setCCGameResourcesVersion(this);

    
}

FGUpdateView::~FGUpdateView()
{
//    ShowGameVersion();

}

bool FGUpdateView::init()
{
    
    if ( !Node::init() )
    {
        return false;
    }
    
    initView();
    return true;
    
}
void  FGUpdateView::initView()
{
    Vec2 centerPos = VisibleRect::center();

    _ProgressBarlabel = Label::createWithSystemFont("", "Helvetica", 20);
    _ProgressBarlabel->setColor(Color3B::WHITE);
    _ProgressBarlabel->setPosition(Vec2(centerPos.x, centerPos.y-40));
    _ProgressBarlabel->setVisible(false);
    this->addChild(_ProgressBarlabel);
    

    
    LabelTitle = Label::createWithSystemFont(NSLocalizedString("更新检测中....","初始化界面"), "Helvetica", 40);
    LabelTitle->setColor(Color3B::WHITE);
    this->addChild(LabelTitle);
    
    LabelTitle->setPosition(Vec2(centerPos.x, 100));
    
    //开始检查更新
    log("initview.....2");
    FGUpdateModule::SharedIntance()->checkForUpdates();
    this->schedule(schedule_selector(FGUpdateView::nosFunc), 0.4);
    this->schedule(schedule_selector(FGUpdateView::speedTimeFunc), 0.05);
}

void FGUpdateView::requestResourcesSuccess(string resUrlString,string fullResUrl,int versionNum,float gamecodeversion,map<int, map<int, string> > versionMd5,map<int, map<int, string> > allpacketMd5,map<int, map<int, string> > fullResMd5,int trueUpdateVersion)
{
    
    string stringVersion =  FGUpdateModule::SharedIntance()->requestGameVersion();
    float gameVersion = atof(stringVersion.c_str());
    
    if (gameVersion < gamecodeversion ) {
        
//        FGUIMsgBox*temp= FGUIMsgBox::createWithString(NSLocalizedString("游戏版本过低,请下载新版本再进行游戏","版本过低提示"));
//        temp->setSelector(this, MsgBoxCallBack(FGUpdateView::OpenLinks));
        //版本过低
        
        //TODO(chenbin)
        log("游戏版本过低,请下载新版本再进行游戏");
        return;
    }
    
    
    //string newres = "最新资源版本:" + intToString(versionNum);
    
    //wwfa1->setString(newres.c_str());
    
    m_versionMd5 = versionMd5;
    
    m_allpacketMd5 = allpacketMd5;
    
    m_hightUpdateVersion = versionNum;  //当前服务器资源版本号
    
    m_urlString = resUrlString;
    
    m_fullResUrl = fullResUrl;
    
    m_fullResMd5 = fullResMd5;
    
    int currentVersion= FGgameSet::getInstance()->getIntegerForKey("gameResourcesVersion");
    //当前外网环境下的版本号 trueUpdateVersion
    if(m_hightUpdateVersion > trueUpdateVersion && m_hightUpdateVersion != currentVersion){
//        FGUIMsgBox* msgBox = FGUIMsgBox::createWithString("是否要更新内网测试包？\n(体验外服请选择取消)",MsgBoxOKCancel);
//        msgBox->setSelector(this, MsgBoxCallBack(FGUpdateView::confirmUpdateHandler));
        confirmUpdateHandler(NULL,1);
    }
    else{
        confirmUpdateHandler(NULL,1);
    }
}

void FGUpdateView::confirmUpdateHandler(Ref* obj,int result)
{
    //result == 0为取消，能够选择取消则表示一定是在内网，并且测试版本大于正式版本
    if (result == 0) {
        m_hightUpdateVersion -= 1;
    }
    
    int currentVersion= FGgameSet::getInstance()->getIntegerForKey("gameResourcesVersion");
    
    if (currentVersion)
    {
        if (currentVersion < m_hightUpdateVersion)
        {
            log("有更新");
            if (m_DeltaResVersion == -1) {
                m_DeltaResVersion = (m_hightUpdateVersion - currentVersion)*2;
                m_CompletedRes = 0;
                m_ResLenght = 0;
                int resIndex = currentVersion;
                
                while (1) {
                    if (resIndex >= m_hightUpdateVersion) {
                        break;
                    }
                    map<int, map<int, string> >::iterator fileIter = m_versionMd5.find(++resIndex);
                    if(fileIter != m_versionMd5.end())
                    {
                        map<int, string> md5String = fileIter->second;
                        map<int, string>::iterator iter = md5String.begin();
                        int lenght = iter->first;
                        m_ResLenght += lenght;
                    }else{
                        break;
                    }
                }
                double resSize = m_ResLenght/(1024*1024);
                if (resSize > 1.0f) {
                    LabelTitle->setString(CCString::createWithFormat(NSLocalizedString("更新包大小%0.1fM，建议在Wi-Fi环境下载","更新系统"),resSize)->getCString());
                    LabelTitle->setSystemFontSize(26);
                    LabelTitle->setPosition(Vec2(VisibleRect::center().x, VisibleRect::center().y-100));
                }
                else{
                    LabelTitle->setString("");
                }
//                _ProgressBarbg->setVisible(true);
            }
        }
    }
    
    schedule(schedule_selector(FGUpdateView::update),0.1);
    if(g_flag_update==false)
    {
        int currentVersion= FGgameSet::getInstance()->getIntegerForKey("gameResourcesVersion");
        
        if (currentVersion)
        {
            
            if (currentVersion < m_hightUpdateVersion)
            {
                log("有更新");
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
                //                [[ViewController alloc]SetAlertUrl:"http://www.my9yu.com/connect.php"];
#endif
                g_flag_update=true;
            }
            else
            {
                g_flag_update=true;
            }
            
        }
    }
}

void FGUpdateView::speedTimeFunc(float timesub)
{
//    if(isDecompressioning)return;
    if (!current_done_size && !total_done_size) {
        _ProgressBarlabel->setVisible(false);
    }else
    {
        double tempscale;
        if (total_done_size==0.0f) {
            tempscale = 0.0f;
        }
        else{
            tempscale=current_done_size/total_done_size;
            if(tempscale>1.0000)tempscale=1;
        }

        float nowPer = m_CompletedRes/m_DeltaResVersion;
        float per = nowPer + tempscale/m_DeltaResVersion;
        if(per>0.95f)per=0.95f;
//        _ProgressBar->SetPercent(per);
        ShowGameVersion();
        
        char speedchar[256] = {0};
        sprintf(speedchar, NSLocalizedString("当前%0.1fm/总%0.1fm","下载进度"),current_done_size/(1024*1024),(total_done_size/(1024*1024)));
        _ProgressBarlabel->setString(speedchar);
        _ProgressBarlabel->setVisible(true);
    }
    
    
}
void FGUpdateView::requestResourcesFail(string errorCode)
{
    
    
//    FGUIMsgBox*temp= FGUIMsgBox::createWithString(errorCode.c_str());
//    temp->setSelector(this, MsgBoxCallBack(FGUpdateView::Reconnect));
    Reconnect(nullptr,1);
}

void FGUpdateView::update(float dt)
{
    if(g_flag_update)
    {
        //test

        if (updateFullResources()) {
            if ( ! sureUpdateResources() ) {
                //无更新直接进入游戏
                return;
            }
        }
        unschedule(schedule_selector(FGUpdateView::update));
    }
}

bool FGUpdateView::updateFullResources()
{
    //现在无需检测大小包
    return true;
    
    
    
#ifndef GameNeedUpdate
    return  true;
#endif
#ifdef GameFullVersion
    return  true;
#endif
    int isFullVersion = FGgameSet::getInstance()->getIntegerForKey("gameIsFullVersion");
    if (isFullVersion == 1) {
        return  true;
    }
    if (m_fullResUrl == "") {
        return  true;
    }
    //获得当前客户端的游戏版本信息
    string currentResVersion =  FGUpdateModule::SharedIntance()->requestGameVersion();
    float currentGameVersion = atof(currentResVersion.c_str()) * 100;
    currentResVersion = CCString::createWithFormat("%d",(int)currentGameVersion)->getCString();
    
    
    //获得缓存的游戏版本信息
    int gameFullResIndex = FGgameSet::getInstance()->getIntegerForKey("gameFullResIndex");
    float savedGameVersion = FGgameSet::getInstance()->getFloatForKey("gameVersion") * 100;
    string savedGameVersionStr = CCString::createWithFormat("%d",(int)savedGameVersion)->getCString();
    
    string fileWriterPath = FileUtils::getInstance()->getWritablePath();
    
    if (currentResVersion != savedGameVersionStr) {
        FGgameSet::getInstance()->setIntegerForKey("gameFullResIndex",0);
        FGgameSet::getInstance()->flush();
        FGgameSet::getInstance()->setFloatForKey("gameVersion",currentGameVersion/100);
        FGgameSet::getInstance()->flush();
    }
    
    gameFullResIndex = FGgameSet::getInstance()->getIntegerForKey("gameFullResIndex") + 1;
    stringstream indexSS;
    indexSS << gameFullResIndex;
    currentResVersion += indexSS.str();
    
    int resIndex;
    stringstream(currentResVersion) >> resIndex;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    string fileName = "floragameRes_ios_"+ currentResVersion + ".zip";
#endif
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    string fileName = "floragameRes_android_"+ currentResVersion + ".zip";
#endif

    map<int, map<int, string> >::iterator fileIter = m_fullResMd5.find(resIndex);
    if (fileIter == m_fullResMd5.end()) {
        //完成了所有数据包的下载
        FGgameSet::getInstance()->setIntegerForKey("gameIsFullVersion",1);
        FGgameSet::getInstance()->flush();
        
        CCXMLFileforLibs *tempLibsxml =new CCXMLFileforLibs();
        tempLibsxml->openXMLFile("GameDataSetting.xml");
        int nowResVersion = tempLibsxml->getIntegerForKey("gameResourcesVersion");
        delete  tempLibsxml;
        
        FGgameSet::getInstance()->setIntegerForKey("gameResourcesVersion",nowResVersion);
        FGgameSet::getInstance()->flush();
        
        sureUpdateResources();
        return false;
    }
    
    map<int, string> md5String = fileIter->second;
    map<int, string>::iterator iter = md5String.begin();
    string nativeFileName = "floragameRes." + currentResVersion +"."+ intToString(iter->first) + ".zip";
    fileWriterPath += nativeFileName;
    
    long long fileLenght = CCFileCompressOperation::ShareInstance()->getLocalFileLenth(fileWriterPath.c_str());
    
    if (fileLenght == iter->first) {
//        LabelTitle->setString(NSLocalizedString("正在解压数据包,请勿关闭...","解压提示"));
        CCFileCompressOperation::ShareInstance()->uncompressZipFileThread(nativeFileName.c_str(),this);
        return false;        
    }
    
    
    //下载数据包
    //通知服务器纪录
    if (gameFullResIndex == 1) {
        sendFullResourcesStatus(0);
    }
    HttpRequest* downrequest = new HttpRequest();
    downrequest->setUrl((m_fullResUrl + fileName).c_str());
    
    log("download fullRes url is : %s",(m_fullResUrl + fileName).c_str());
    log("set native download save file name : %s",nativeFileName.c_str());
    
    downrequest->setTag(nativeFileName.c_str());
    downrequest->setRequestType(HttpRequest::Type::DOWN);
    downrequest->setploadingDelegate(this);
    downrequest->setResponseCallback(this, httpresponse_selector(FGUpdateView::downloadfileresources));
    HttpClient::getInstance()->send(downrequest);
    
    downrequest->release();
    log("安装包正在下载资源包....");
//    LabelTitle->setString(NSLocalizedString("正在下载数据包,请勿关闭..","下载提示"));
    return false;
}

void FGUpdateView::sendFullResourcesStatus(int resIndex)
{
    int cid =MarketAPI::GetSharedInstance()->getMarketCid();
    string DeviceIdentification = getDeviceIdentification();
    string statusStr = CCString::createWithFormat("%d%s%d",cid,DeviceIdentification.c_str(),resIndex)->getCString();
    string sign = FGgameEncryption(statusStr);
    //FullResStatusURL未定义
    //statusStr = CCString::createWithFormat(FullResStatusURL,cid,DeviceIdentification.c_str(),resIndex,sign.c_str())->getCString();
    
    
    HttpRequest* downrequest = new HttpRequest();
    downrequest->setUrl(statusStr.c_str());
    downrequest->setTag(statusStr.c_str());
    downrequest->setRequestType(HttpRequest::Type::GET);
    HttpClient::getInstance()->send(downrequest);
    downrequest->release();
}

bool FGUpdateView::sureUpdateResources()
{
    
    
    
    
    
    int currentVersion= FGgameSet::getInstance()->getIntegerForKey("gameResourcesVersion");
    
    
    if (!currentVersion)
    {
        map<int, map<int, string> >::iterator iter = m_allpacketMd5.end();
        ++iter;
        map<int, string>::iterator itercell = iter->second.begin();
        string fileName       = "full" + intToString(iter->first) + ".zip";
        string nativeFileName = "full." + intToString(iter->first) +  "." + intToString(itercell->first) + ".zip";
        string fileWriterPath = FileUtils::getInstance()->getWritablePath();
        
        fileWriterPath       += nativeFileName;
        
        long long fileLenght  = CCFileCompressOperation::ShareInstance()->getLocalFileLenth(fileWriterPath.c_str());
        
        if (fileLenght == iter->first)
        {
//            CustomIndicator::sharedInstance()->StartRunningWithText("正在解压数据包,请勿关闭..........",false);
            
            CCFileCompressOperation::ShareInstance()->uncompressZipFileThread(nativeFileName.c_str(),this);
            
            return true;
            
        }
        
        string versionType = "640_768";
        
        log("%s",(m_urlString + "n/" + versionType + "/" + fileName).c_str());
        
        
        HttpRequest* downrequest = new HttpRequest();
        
        downrequest->setUrl((m_urlString + "n/" + versionType + "/" + fileName).c_str());
        
        
        log("set native download save file name : %s",nativeFileName.c_str());
        
        downrequest->setTag(nativeFileName.c_str());
        
        downrequest->setRequestType(HttpRequest::Type::DOWN);
        
        downrequest->setploadingDelegate(this);
        
        downrequest->setResponseCallback(this, httpresponse_selector(FGUpdateView::downloadfileresources));
        
        HttpClient::getInstance()->send(downrequest);
        
        downrequest->release();
        
        
//        CustomIndicator::sharedInstance()->StartRunningWithText("正在下载数据包,请勿关闭..........",false);
        
        
    }else
    {
        if (currentVersion >= m_hightUpdateVersion)
        {
//            FGLayerManager::getGlobalLayerManager()->resetUILayer();
            this->removeFromParentAndCleanup(true);
            AppDelegate::startLoadLua();
            return false;
            
        }
        else if (currentVersion < m_hightUpdateVersion)
        {
            
//            if (m_hightUpdateVersion - currentVersion >=100)
//            {
//                
//                map<int, map<int, string> >::iterator iter = m_allpacketMd5.end();
//                
//                ++iter;
//                
//                map<int, string>::iterator itercell = iter->second.begin();
//                
//                
//                string fileName = "full" + intToString(iter->first) + ".zip";
//                
//                string versionType = "640_768";
//                
//                log("%s",(m_urlString + "n/" + versionType + "/" + fileName).c_str());
//                
//                
//                string nativeFileName = "full." + intToString(iter->first) +  "." + intToString(itercell->first) + ".zip";
//                
//                
//                string fileWriterPath = FileUtils::getInstance()->getWritablePath();
//                
//                fileWriterPath += nativeFileName;
//                
//                long long fileLenght = CCFileCompressOperation::ShareInstance()->getLocalFileLenth(fileWriterPath.c_str());
//                
//                if (fileLenght == iter->first)
//                {
//                    
//                    
//                    LabelTitle->setString(NSLocalizedString("正在解压数据包,请勿关闭...","解压提示"));
////                    CustomIndicator::sharedInstance()->StartRunningWithText("正在解压数据包,请勿关闭..........",false);
//                    
//                    CCFileCompressOperation::ShareInstance()->uncompressZipFileThread(nativeFileName.c_str(),this);
//                    
//                    return;
//                    
//                }
//                
//                HttpRequest* downrequest = new HttpRequest();
//                
//                downrequest->setUrl((m_urlString + "n/" + versionType + "/" + fileName).c_str());
//                
//                
//                log("set native download save file name : %s",nativeFileName.c_str());
//                
//                downrequest->setTag(nativeFileName.c_str());
//                
//                downrequest->setploadingDelegate(this);
//                
//                downrequest->setRequestType(HttpRequest::Type::DOWN);
//                
//                downrequest->setResponseCallback(this, httpresponse_selector(FGUpdateView::downloadfileresources));
//                
//                HttpClient::getInstance()->send(downrequest);
//                
//                downrequest->release();
//                
//                
//                LabelTitle->setString(NSLocalizedString("正在下载数据包,请勿关闭..","下载提示"));
//
//            }else
            
            {
                
                //for (int i = currentVersion+1; i <= m_hightUpdateVersion; ++i) {
                
                //m_hightUpdateVersion
                
                map<int, string> md5String = m_versionMd5[currentVersion+1];
                
                map<int, string>::iterator iter = md5String.begin();
                
                string nativeFileName = "floragame." + intToString(currentVersion+1) +  "." + intToString(iter->first) + ".zip";
                
                
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
                string fileName = "floragame_ios_"+ intToString(currentVersion+1) + ".zip";
#endif
#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
                string fileName = "floragame_android_"+ intToString(currentVersion+1) + ".zip";
#endif
                
//                string versionType = "640_768";
                
//                log("%s",(m_urlString + "n/" + versionType + "/" + fileName).c_str());
                
                string fileWriterPath = FileUtils::getInstance()->getWritablePath();
                
                fileWriterPath += nativeFileName;
                
                long long fileLenght = CCFileCompressOperation::ShareInstance()->getLocalFileLenth(fileWriterPath.c_str());
                
                if (fileLenght == iter->first) {
                    
                    
//                    LabelTitle->setString(NSLocalizedString("正在解压数据包,请勿关闭...","解压提示"));
                    
                    CCFileCompressOperation::ShareInstance()->uncompressZipFileThread(nativeFileName.c_str(),this);
                    
                    return true;
                    
                }
                
                HttpRequest* downrequest = new HttpRequest();
                
                downrequest->setUrl((m_urlString + fileName).c_str());
                
                log("%s",(m_urlString + fileName).c_str());
                log("set native download save file name : %s",nativeFileName.c_str());
                
                downrequest->setTag(nativeFileName.c_str());
                
                downrequest->setRequestType(HttpRequest::Type::DOWN);
                
                downrequest->setploadingDelegate(this);
                
                downrequest->setResponseCallback(this, httpresponse_selector(FGUpdateView::downloadfileresources));

                HttpClient::getInstance()->send(downrequest);
                
                downrequest->release();
                log("正在下载....");
//                LabelTitle->setString(NSLocalizedString("正在下载数据包,请勿关闭..","下载提示"));
                
                // }
                
                
            }
            
            
        }
        
    }
    return true;
}



void FGUpdateView::httpRequestLoadingProgress(const char* FileName,double download_total_size, double download_total_size_done)
{
    isDecompressioning=false;
    current_done_size =download_total_size_done;
    total_done_size=download_total_size;
    
//    log("下载回应....%f,%f",current_done_size,total_done_size);

    

    
}
void FGUpdateView::downloadfileresources(Node* sender,HttpResponse *response)
{
    if (!response || !response->isSucceed())
    {
        log("response failed");
        
//        FGUIMsgBox*temp= FGUIMsgBox::createWithString(NSLocalizedString("下载更新包超时,请检查网络","超时提示"));
//        temp->setSelector(this, MsgBoxCallBack(FGUpdateView::Reconnect));
        Reconnect(nullptr,1);
        return;
        
    }
    
    // You can get original request type from: response->request->reqType
    if (0 != strlen(response->getHttpRequest()->getTag()))
    {
        log("%s response completed", response->getHttpRequest()->getTag());
    }
    
    int statusCode = response->getResponseCode();
    
    log("response code: %d", statusCode);
    
    std::vector<char> *buffer = response->getResponseData();
    
    string bufferStr(buffer->begin(),buffer->end());
    
    vector<string> splitString = SplitString(bufferStr, '.');
    
    string filePaht = FileUtils::getInstance()->getWritablePath();
    
    filePaht += bufferStr;
    
    log("md5 compare file is : %s ,md5 string is :%s",filePaht.c_str(),splitString[splitString.size()-2].c_str());
    
    //CustomIndicator::sharedInstance()->StartRunningWithText("正在校验数据包,请勿关闭..........",false);
    
    //bool md5compare = CCCrypto::MD5WithFileCompare(filePaht.c_str(),splitString[splitString.size()-2].c_str());
    //4f105a6a9e06785884950e5df4b791f7   splitString[splitString.size()-2].c_str()
    long long downFileLenght =  CCFileCompressOperation::ShareInstance()->getLocalFileLenth(filePaht.c_str());
    
    //log("%d",downFileLenght);
    if (intToString(downFileLenght) == splitString[splitString.size()-2]) {
        
        m_CompletedRes ++;
        current_done_size=0;
        total_done_size=0;
//        LabelTitle->setString(NSLocalizedString("正在解压数据包,请勿关闭...","解压提示"));
        
//        CustomIndicator::sharedInstance()->StartRunningWithText("正在解压数据包,请勿关闭..........",false);
        
        CCFileCompressOperation::ShareInstance()->uncompressZipFileThread(bufferStr.c_str(),this);
        
    }else
    {
        
//        FGUIMsgBox*temp= FGUIMsgBox::createWithString(NSLocalizedString("数据包校验错误,请重新下载更新包","数据校验提示"));
//        temp->setSelector(this, MsgBoxCallBack(FGUpdateView::Reconnect));
        Reconnect(nullptr,1);
        remove(filePaht.c_str());
        
        
    }
    
    
}

void FGUpdateView::ccfileUncompressProgress(const char * filename ,int currentFile,int totalFile)
{
    isDecompressioning=true;
    _ProgressBarlabel->setVisible(false);
    current_done_size = currentFile;
    total_done_size = totalFile;
}
void FGUpdateView::ccfileUncompressProgressResult(const char * filename ,int resultCode)
{
    
//    CustomIndicator::sharedInstance()->StopRunning();
    
    if (resultCode) {
        string filepath = FileUtils::getInstance()->getWritablePath();
        
        //filepath += filename;
        //remove(filepath.c_str());
        //现在直接remove filepath下的所有zip文件(不递归子文件夹)
        CCFileCompressOperation::dirNotRecursive(filepath.c_str());
        
        
        vector<string> m_stringSplit = SplitString(filename, '.');
        
        if (m_stringSplit[0] == "floragameRes") {
            //下载了一个数据包
            int gameFullResIndex = FGgameSet::getInstance()->getIntegerForKey("gameFullResIndex");
            FGgameSet::getInstance()->setIntegerForKey("gameFullResIndex",gameFullResIndex+1);
            FGgameSet::getInstance()->flush();
            
            //继续下载后续数据包
            this->schedule(schedule_selector(FGUpdateView::fullResCallBack), 0.1);
        }
        else if (m_stringSplit[0] == "floragame") {
            
            int updatepackVersion = atoi(m_stringSplit[1].c_str());
            
            FGgameSet::getInstance()->setIntegerForKey("gameResourcesVersion",updatepackVersion);
            FGgameSet::getInstance()->flush();
            
            
            m_CompletedRes ++;
            current_done_size=0;
            total_done_size=0;
            
            if (updatepackVersion == m_hightUpdateVersion) {
                log("可以进游戏了");
                isEnterLoginScene = true;
                
            }else if(updatepackVersion < m_hightUpdateVersion)
            {
                //继续下载后续热更包
                this->schedule(schedule_selector(FGUpdateView::updateResCallBack), 0.1);
            }
            
            
        }else if (m_stringSplit[0] == "full")
        {
            
            int fullversion = atoi(m_stringSplit[1].c_str());
            
            
            FGgameSet::getInstance()->setIntegerForKey("gameResourcesVersion",fullversion);
            FGgameSet::getInstance()->flush();
            FGUpdateModule::SharedIntance()->checkForUpdates();
//            LoginServerListModule::shareInstance()->requestGameResourcesVersion();
        }
        
    }else
    {
        
        string filepath = FileUtils::getInstance()->getWritablePath();
        
        //filepath += filename;
        //remove(filepath.c_str());
        //现在直接remove filepath下的所有zip文件(不递归子文件夹)
        CCFileCompressOperation::dirNotRecursive(filepath.c_str());
        
        
//        FGUIMsgBox*temp= FGUIMsgBox::createWithString(NSLocalizedString("解压数据包失败,请重新开启游戏","解压出错提示"));
//        temp->setSelector(this, MsgBoxCallBack(FGUpdateView::focusExit));
        focusExit(nullptr,1);
    }
}
void FGUpdateView::ccfileUncompressErrorResult(const char * errorString ,int resultCode)
{
    m_errorString.push_back(errorString);
}
void FGUpdateView::fullResCallBack(float dt)
{
    //通知服务器纪录
    int gameFullResIndex = FGgameSet::getInstance()->getIntegerForKey("gameFullResIndex");
    sendFullResourcesStatus(gameFullResIndex);
    
    
    updateFullResources();
    this->unschedule(schedule_selector(FGUpdateView::fullResCallBack));
}
void FGUpdateView::updateResCallBack(float dt)
{
    sureUpdateResources();
    this->unschedule(schedule_selector(FGUpdateView::updateResCallBack));
}
void FGUpdateView::nosFunc(float timesub)
{
    if (isEnterLoginScene)
    {
        
        std::list<string>::iterator iter = m_errorString.begin();
        while (iter!=m_errorString.end())
        {
//            FGUIMsgBox::createWithString(iter->c_str(),MsgBoxOKCancel);
            iter++;
        }

        
        //开始游戏
        //        FGLayerManager::getGlobalLayerManager()->resetUILayer();
        this->unschedule(schedule_selector(FGUpdateView::nosFunc));
        this->removeFromParentAndCleanup(true);
        AppDelegate::startLoadLua();
    }
}

//void FGUpdateView::Callback(Ref* obj,int i)
//{
//
//    if(i == 1)//确定
//    {
//        
//    }
//    
//    
//}
void FGUpdateView::focusExit(Ref* obj,int i)
{
//    if(i == 1)//确定
//    {
        exit(EXIT_SUCCESS);
//    }
}

void FGUpdateView::OpenLinks(Ref* obj,int i)
{
//    FGGameOpenLinks(g_download_url);
    exit(EXIT_SUCCESS);
}

void FGUpdateView::Reconnect(Ref* obj,int i)
{
    if(i == 1)//确定
    {
        FGUpdateModule::SharedIntance()->checkForUpdates();
    }

}
//void FGUpdateView::focusExit()
//{
//    exit(EXIT_SUCCESS);
//    
//}
//#endif
