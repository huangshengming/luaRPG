//
//  CCFileCompressOperation.cpp
//  FGClient
//
//  Created by 神利 on 13-4-19.
//
//

#include "CCFileCompressOperation.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>
#include "unzip/unzip.h"

#include "unistd.h"           //所需头文件定义
#include "string.h"
#include "dirent.h"
#include "utime.h"
#include "stdio.h"
#include "sys/types.h"
#include "sys/stat.h"
#include "fcntl.h"
#include "WholeDefine.h"
#include "CCXMLFile.h"
#include "FGgameSet.h"
#include "FGUpdateModule.h"
#include "FGbspatch.h"
#include "FGMD5.h"


#define MAX_PATH 1024 // 定义最大路径长度

using namespace std;

bool isFileNameEndWithStr(string fileName,string endStr)
{
    return (int)fileName.find(endStr.c_str()) == MAX(0,(int)(fileName.length()-string(endStr.c_str()).length()));
}

CCFileCompressOperation::CCFileCompressOperation()
: m_delegate(NULL)
, pszZipFilePathString("")
, pszPasswordString("")
{
}

CCFileCompressOperation::~CCFileCompressOperation()
{
}

bool CCFileCompressOperation::isFileExistInWriteablePath(const char * mFileName)
{
    string aString(mFileName);
    vector<string> pKey = SplitString(aString,'/');
    string fileName = pKey[pKey.size()-1];
    
    std::string writablePath =  FileUtils::getInstance()->getWritablePath();
    writablePath = writablePath + fileName;
    const char*xmlFullPath = writablePath.c_str();
    
    FILE *fp = fopen(xmlFullPath, "r");
    bool bRet = false;
    
    if (fp)
    {
        bRet = true;
        fclose(fp);
    }
    return bRet;
}

long long CCFileCompressOperation::getLocalFileLenth(const char * mFileName)
{
    int fileLength = 0;
    //#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    struct stat buf;
    int statcode = stat(mFileName, &buf);
    if (statcode == 0)
    {
        fileLength = buf.st_size;
    }else
    {
        log( "%s,get file lenth error: %s\n", mFileName,strerror( errno ) );
    }
    //#endif
    return fileLength;
}

bool CCFileCompressOperation::isFileExistInWriteablePathFinal(const char * mFileName)
{
    bool retBool = false;
    //#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    struct stat buf;
    int statcode = stat(mFileName, &buf);
    if (statcode == 0)
    {
        retBool = true;
    }
    //#endif
    return retBool;
}
void* startUncompressThread(void* constCompress)
{
    reinterpret_cast<CCFileCompressOperation*>(constCompress)->decompressZipFileToWriteablePath();
    pthread_exit(NULL);
    return NULL;
}

void CCFileCompressOperation::decompressZipFileToWriteablePath()
{
    log("现在开始解压");
    bool finalReturn = false;
    do
    {
        unzFile pFile = NULL;
        //        *pSize = 0;
        if("" == pszZipFilePathString)
        {
            return;
        }
        
        string writerPath =  FileUtils::getInstance()->getWritablePath();
        writerPath += pszZipFilePathString;
        pFile = unzOpen(writerPath.c_str());
        if (!pFile)
        {
            return;
        }
        
        unz_global_info _zFileInfo;
        int nRet =  unzGetGlobalInfo(pFile, &_zFileInfo);
        
        if (UNZ_OK != nRet)
        {
            return;
        }
        
        int totalfile = _zFileInfo.number_entry;
        int currentfile = 1;
        nRet = unzGoToFirstFile(pFile);
        if (UNZ_OK != nRet)
        {
            return;
        }
        
        char firstFileName[260] = {0};
        unz_file_info firstFileInfo;
        nRet = unzGetCurrentFileInfo(pFile, &firstFileInfo, firstFileName, sizeof(firstFileName), NULL, 0, NULL, 0);
        string firstFileNameString(firstFileName);
        do
        {
            if (m_delegate)
            {
                m_delegate->ccfileUncompressProgress(pszZipFilePathString.c_str(), currentfile, totalfile);
            }
            
            ++currentfile;
            char szFilePathA[260] = {0};
            unz_file_info FileInfo;
            nRet = unzGetCurrentFileInfo(pFile, &FileInfo, szFilePathA, sizeof(szFilePathA), NULL, 0, NULL, 0);
            CC_BREAK_IF(UNZ_OK != nRet);
            
            log("Current file Name : %s",szFilePathA);
            
            string szFilePathString(szFilePathA);
            
            if (szFilePathString.find("__MACOSX/") != string::npos
                || isFileNameEndWithStr(szFilePathString,".__MACOSX")
                || isFileNameEndWithStr(szFilePathString,".DS_Store")
                || isFileNameEndWithStr(szFilePathString,".svn")
                || szFilePathString == firstFileNameString)
            {
                unzCloseCurrentFile(pFile);
                nRet = unzGoToNextFile(pFile);
                continue;
            }
            
            szFilePathString = szFilePathString.substr(firstFileNameString.length(),
                                                       szFilePathString.length()-firstFileNameString.length());
            char endChar = szFilePathString[szFilePathString.length()-1];
            if (endChar == '/')
            {
                szFilePathString.erase(szFilePathString.end()-1);
                string headPath =  FileUtils::getInstance()->getWritablePath();
                string mkdirPath = headPath+szFilePathString;
                log("mkdir file full path : %s",mkdirPath.c_str());
                int dirExist = access(mkdirPath.c_str(), F_OK);
                if (dirExist==-1)
                {
                    int mkdircode = mkdir(mkdirPath.c_str(), S_IRWXU);
                    log("mkdir -- %s - code %d",mkdirPath.c_str(),mkdircode);
                    if (mkdircode == -1)
                    {
                        log( "mkdir error: %s\n", strerror( errno ) );
                    }
                }
                unzCloseCurrentFile(pFile);
                nRet = unzGoToNextFile(pFile);
                continue;
            }
            
            
            if (pszPasswordString == "")
            {
                
                nRet = unzOpenCurrentFile(pFile);
                CC_BREAK_IF(UNZ_OK != nRet);
            }
            else
            {
                
                nRet = unzOpenCurrentFilePassword(pFile, pszPasswordString.c_str());
                CC_BREAK_IF(UNZ_OK != nRet);
            }
            
            unsigned char * pBuffer = new unsigned char[FileInfo.uncompressed_size];
            int nSize = 0;
            nSize = unzReadCurrentFile(pFile, pBuffer, FileInfo.uncompressed_size);
            
            CCAssert(nSize == 0 || nSize == (int)FileInfo.uncompressed_size, "the file size is wrong");
            string writeablePath =  FileUtils::getInstance()->getWritablePath();
            writeablePath = writeablePath + szFilePathString;
            //        if(isFileExistInWriteablePath(writeablePath.c_str()))
            //        {
            //            remove(writeablePath.c_str());
            //        }
            
            FILE *desFile = fopen(writeablePath.c_str(), "w+");
//            if (!desFile)
//            {
                //这里不continue，让程序闪退.
//                continue;
//            }
            
            fwrite(pBuffer, FileInfo.uncompressed_size, 1, desFile);
            fclose(desFile);
            CC_SAFE_DELETE_ARRAY(pBuffer);
            unzCloseCurrentFile(pFile);
            
            //如果是diffdata 就去执行合并
            if(isFileNameEndWithStr(szFilePathString,".diffdata"))
            {
                string realFile(szFilePathString,0,(szFilePathString.length()-string(".diffdata").length()));
                std::string partA = realFile.substr(0, realFile.find_last_of("."));
                std::string mergerFileMd5 = realFile.substr(realFile.find_last_of(".")+1);
                string oldfileName=  FileUtils::getInstance()->fullPathForFilename(partA.c_str());
                ssize_t size;
                unsigned char * pBytes= FileUtils::getInstance()->getFileData(oldfileName.c_str(),"rb",&size);
                char  logbuff[1024];
                if (pBytes)
                {
                    string tempFile=  FileUtils::getInstance()->getWritablePath()+partA+".temp";
                    //合并文件
                    FGbsPatch(pBytes,size,tempFile.c_str(),writeablePath.c_str());
                   
                    ssize_t tempFileSize;
                    unsigned char * tempFileBytes= FileUtils::getInstance()->getFileData(tempFile.c_str(),"rb",&tempFileSize);
                    
                    if(tempFileBytes)
                    {
                        
                        string tempFileMd5 =  CFGMD5Digest((const char * )tempFileBytes,tempFileSize);
                        if (tempFileMd5== mergerFileMd5)
                        {
                            string mergerFile=  FileUtils::getInstance()->getWritablePath()+partA;
                            rename(tempFile.c_str(), mergerFile.c_str());
                    
                        }else
                        {
                            string olfileMd5 =CFGMD5Digest((const char * )pBytes,size);
                            if(olfileMd5!=mergerFileMd5)
                            {
                                if(m_delegate)
                                {
                                    memset(logbuff, 1024, 0);
                                    snprintf(logbuff,1024,"合成文件错%s出错",partA.c_str());
                                    m_delegate->ccfileUncompressErrorResult(logbuff, 0);
                                }
                            }else
                            {
                                log("之前解压有被中断过 %s",partA.c_str());
                            }
                        
                        }
                        CC_SAFE_DELETE_ARRAY(tempFileBytes);
                        remove(tempFile.c_str());
                    }
                     CC_SAFE_DELETE_ARRAY(pBytes);
                }else
                {
                    if(m_delegate)
                    {
                        memset(logbuff, 1024, 0);
                        snprintf(logbuff,1024,"合并文件出错,之前并不存在这个文件 %s",partA.c_str());
                        m_delegate->ccfileUncompressErrorResult(logbuff, 0);
                    }
                }
                //删除diffdate文件
                remove(writeablePath.c_str());
            }
            
            nRet = unzGoToNextFile(pFile);
        } while (UNZ_OK == nRet);
        
        if (pFile)
        {
            unzClose(pFile);
        }
        finalReturn = true;
    } while (0);
    if (finalReturn)
    {
        if(m_delegate)
        {
            m_delegate->ccfileUncompressProgressResult(pszZipFilePathString.c_str(), 1);
        }
    }
    else
    {
        if (m_delegate)
        {
            m_delegate->ccfileUncompressProgressResult(pszZipFilePathString.c_str(),0);
        }
    }
    return;
}

unsigned long CCFileCompressOperation::getZipFileNumber(const char * fullPathString)
{
    unzFile pFile = NULL;
    
    if(!fullPathString)
    {
        return -1;
    }
    
    pFile = unzOpen(fullPathString);
    if (!pFile)
    {
        
        return -1;
    }
    
    unz_global_info _zFileInfo;
    int nRet =  unzGetGlobalInfo(pFile, &_zFileInfo);
    if (UNZ_OK != nRet)
    {
        return -1;
    }
    return _zFileInfo.number_entry;
}

void CCFileCompressOperation::uncompressZipFileThread(const char* pszZipFilePath,
                                                      CCFileCompressOperationDelegate* _delegateIntance,
                                                      string pszPassword)
{
    pszZipFilePathString = pszZipFilePath;
    pszPasswordString    = pszPassword;
    m_delegate           = _delegateIntance;
    pthread_create(&s_Thread, NULL, &startUncompressThread, this);
    pthread_detach(s_Thread);
}

void CCFileCompressOperation::listDirEachFileCopy(const char * fileName)
{
    
    vector<string> _vectorString;
    
    DIR              *pDir=NULL ;
    struct dirent    *ent  ;
    char              childpath[512]={0};
    
    pDir=opendir(fileName);
    
    memset(childpath,0,sizeof(childpath));
    if (pDir)
    {
        while((ent=readdir(pDir))!=NULL)
        {
            
            if(ent->d_type & DT_DIR)
            {
                if(strcmp(ent->d_name,".")==0 || strcmp(ent->d_name,"..")==0 || strcmp(ent->d_name,".svn")==0)
                {
                    continue;
                }
                sprintf(childpath,"%s/%s",fileName,ent->d_name);
                
                FILE* desFile = fopen("/Users/mac/Documents/filelist.txt", "+a");
                fwrite(childpath, sizeof(childpath), 1, desFile);
                fclose(desFile);
                printf("path:%s \n",childpath);
                listDirEachFileCopy(childpath);
            }
        }
    }
    
    for (int i = 0; i < _vectorString.size() ;++i)
    {
        // TODO: 这里是干什么的呢？
        
    }
}


void CCFileCompressOperation::copy_data(char* spath,char* dpath)     //复制一个文件
{
    
    int nbyte ;                         //读出n个字节
    int pDir_s,pDir_d ;                //源文件句柄pDir_s, 目标文件句柄pDir_d
    char buf[BUFSIZ] ;                 //文件内容缓冲区
    struct stat file_stat ;           //文件属性 file_stat
    struct utimbuf mod_time;         //文件时间属性
    stat(spath,&file_stat) ;         //读取源文件属性
    if((pDir_s=open(spath,0)) == -1)     //打开源文件
    {
        printf("无法打开文件 %s，权限不足!/n",spath) ; //源文件不可读
        exit(0);
    }
    pDir_d=creat(dpath,S_IRWXU);                    //创建一个目标文件，可读可写，可执行
    log("拷贝文件:%s",dpath);
    while((nbyte = read(pDir_s,buf,BUFSIZ)) > 0)        //从源文件读取内容，写入目标文件
    {
        if(write(pDir_d,buf,nbyte) != nbyte)
        {
            printf("写数据出现异常错误!/n") ;     //写数据出错,退出
            exit(0);
        }
    }
    mod_time.actime = file_stat.st_atime ;            //修改目标文件时间属性，保持和源文件一致
    mod_time.modtime = file_stat.st_mtime ;
    utime(dpath,&mod_time) ;
    chmod(dpath,file_stat.st_mode);                   //修改目标文件权限，保持和源文件一致
    close(pDir_s) ;                                   //关闭文件句柄
    close(pDir_d) ;
}
void CCFileCompressOperation::mycp(char* source,char* des)              //拷贝一个目录，以及目录下子目录和相应的文件
{
    struct dirent* ent = NULL;         //定义目录属性dirent
    struct utimbuf mod_time;                //定义目录时间属性变量
    char spath[MAX_PATH] = "", dpath[MAX_PATH] = "" ;    //源文件路径spath，目标文件路径dpath
    DIR *pDir=NULL;                              //句柄
    struct stat file_stat ;                 //文件或者目录属性变量file_stat
    strcpy(spath,source) ;
    strcpy(dpath,des) ;
    pDir=opendir(source);                  //打开当前目录
    if (pDir)
    {
        while (NULL != (ent=readdir(pDir)))    //循环读取文件或目录属性，遍历文件夹
        {
            if(strcmp(ent->d_name,"..")==0||strcmp(ent->d_name,".")==0) //遇到子目录'.'或父母录标记'..'，继续
                continue ;
            if (ent->d_type == 4)    //d_type = 4,表示当前为子目录
            {
                strcat(dpath,"/");
                strcat(dpath,ent->d_name) ;        //构建目标文件子目录路径
                strcat(spath,"/");
                strcat(spath,ent->d_name) ;        //构建源文件子目录路径
                stat(spath,&file_stat);            //读取源文件子目录属性
                mkdir(dpath,S_IRWXU);            //创建目标文件子目录，可读可写，可执行
                mod_time.actime = file_stat.st_atime ;
                //修改目标子目录时间属性和源子目录时间属性保持一致
                mod_time.modtime = file_stat.st_mtime ;
                mycp(spath,dpath);                 //递归拷贝子目录
                chmod(dpath,file_stat.st_mode);    //修改目标子目录权限，保持和原子目录权限一致
                utime(dpath, &mod_time) ;          //设置目标子目录时间属性，保持和原子目录一致
                strcpy(dpath,des);                 //还原路径
                strcpy(spath,source) ;
            }
            else {                 //d_type != 4,是文件，调用copy_data直接拷贝
                strcat(dpath,"/");                  //构建目标文件路径
                strcat(dpath,ent->d_name) ;
                strcat(spath,"/");                 //构建源文件路径
                strcat(spath,ent->d_name) ;
                copy_data(spath,dpath);            //拷贝一个文件
                strcpy(dpath,des);                 //还原路径
                strcpy(spath,source);
            }
        }
    }
}

void CCFileCompressOperation::versionDetection()
{
//    log("WTF__WritablePath__%s",FileUtils::getInstance()->getWritablePath().c_str());
    
    //不用关闭
    CCXMLFileforLibs *tempLibsxml =new CCXMLFileforLibs();
    tempLibsxml->openXMLFile("GameDataSetting.xml");
    int nowPacketsVersion = tempLibsxml->getIntegerForKey("gamePacketsVersion");
    delete  tempLibsxml;
    
    int nowcachePacketsVersion= FGgameSet::getInstance()->getIntegerForKey("gamePacketsVersion");
    log("目前版本 %d  cache版本 %d",nowPacketsVersion,nowcachePacketsVersion);
    
    string cacheGameVersion = FGgameSet::getInstance()->getStringForKey("gameVersion","0");
    string nowGameVersion = FGUpdateModule::SharedIntance()->requestGameVersion();
    
    log("目前游戏显示版本 %s  cache版本 %s",nowGameVersion.c_str(),cacheGameVersion.c_str());
    
    if(nowPacketsVersion>nowcachePacketsVersion || nowGameVersion > cacheGameVersion)
    {
        //清除cache数据
        string  WriteablePath = FileUtils::getInstance()->getWritablePath().c_str();
        std::string partA = WriteablePath.substr(0, WriteablePath.find_last_of("/"));
        dirRecursive(partA.c_str());
        FGgameSet::destroyInstance();
    }
    
    
    
    
}

void CCFileCompressOperation::dirNotRecursive(const char* source)
{
    struct dirent* ent = NULL;      //定义目录属性dirent
    char spath[MAX_PATH] = "";      //源文件路径spath，目标文件路径dpath
    DIR *pDir=NULL;                 //句柄
    strcpy(spath,source);
    pDir=opendir(source);           //打开当前目录
    if(pDir)
    {
        while (NULL != (ent=readdir(pDir)))    //循环读取文件或目录属性，遍历文件夹
        {
            if(strcmp(ent->d_name,"..")==0||strcmp(ent->d_name,".")==0) //遇到子目录'.'或父母录标记'..'，继续
                continue ;
            
            if (ent->d_type != 4) {             //d_type != 4,是文件，调用copy_data直接拷贝
                strcat(spath,ent->d_name) ;
                deleteZipFile(spath);           //删除文件
                strcpy(spath,source);           //还原路径
            }
        }
    }
}
void CCFileCompressOperation::deleteZipFile(char* source)
{
    string tempbuff =source;
    size_t _Pos=0;
    _Pos = tempbuff.find(".zip");
    if (_Pos != std::string::npos && _Pos == tempbuff.size()-4)
    {
        log("删除zip文件 %s",tempbuff.c_str());
        remove(source);
    }
}

void CCFileCompressOperation::dirRecursive(const char* source)
{
    
    
    const char* des ="";
    
    struct dirent* ent = NULL;         //定义目录属性dirent
    struct utimbuf mod_time;                //定义目录时间属性变量
    char spath[MAX_PATH] = "", dpath[MAX_PATH] = "" ;    //源文件路径spath，目标文件路径dpath
    DIR *pDir=NULL;                              //句柄
    struct stat file_stat ;                 //文件或者目录属性变量file_stat
    strcpy(spath,source) ;
    strcpy(dpath,des) ;
    pDir=opendir(source);                  //打开当前目录
    if (pDir)
    {
        while (NULL != (ent=readdir(pDir)))    //循环读取文件或目录属性，遍历文件夹
        {
            if(strcmp(ent->d_name,"..")==0||strcmp(ent->d_name,".")==0) //遇到子目录'.'或父母录标记'..'，继续
                continue ;
            if (ent->d_type == 4)    //d_type = 4,表示当前为子目录
            {
                strcat(dpath,"/");
                strcat(dpath,ent->d_name) ;        //构建目标文件子目录路径
                strcat(spath,"/");
                strcat(spath,ent->d_name) ;        //构建源文件子目录路径
                stat(spath,&file_stat);            //读取源文件子目录属性
                mkdir(dpath,S_IRWXU);            //创建目标文件子目录，可读可写，可执行
                mod_time.actime = file_stat.st_atime ;
                //修改目标子目录时间属性和源子目录时间属性保持一致
                mod_time.modtime = file_stat.st_mtime ;
                dirRecursive(spath);                 //递归拷贝子目录
                chmod(dpath,file_stat.st_mode);    //修改目标子目录权限，保持和原子目录权限一致
                utime(dpath, &mod_time) ;          //设置目标子目录时间属性，保持和原子目录一致
                strcpy(dpath,des);                 //还原路径
                strcpy(spath,source) ;
            }
            else {                 //d_type != 4,是文件，调用copy_data直接拷贝
                strcat(dpath,"/");                  //构建目标文件路径
                strcat(dpath,ent->d_name) ;
                strcat(spath,"/");                 //构建源文件路径
                strcat(spath,ent->d_name) ;
                handleData(spath);//拷贝一个文件
                strcpy(dpath,des);                 //还原路径
                strcpy(spath,source);
            }
        }
    }
    
    
    
}

void CCFileCompressOperation::handleData(char* source)
{
    string tempbuff =source;
    size_t _Pos=0;
    _Pos = tempbuff.find("UserDefault.xml");
    log("%lu %zu %s",std::string::npos,_Pos,tempbuff.c_str());
    if (_Pos == std::string::npos )
    {
        remove(source);
        log("正在删除cache中的文件 %s",source);
        
    }
}

bool CCFileCompressOperation::copyWriteablePathFile(const char * fileName)
{
    
	bool mRet=false;
    string filePath = cocos2d:: FileUtils::getInstance()->fullPathForFilename(fileName,false).c_str();
    string writablePath  = cocos2d:: FileUtils::getInstance()->getWritablePath();
    writablePath         = writablePath + fileName;
    string xmlFullPath = writablePath.c_str();
    ssize_t psize = 0;
    unsigned char * fileChar = cocos2d:: FileUtils::getInstance()->getFileData(filePath.c_str(), "rb", &psize);
    if (psize)
    {
        FILE *desFile = fopen(xmlFullPath.c_str(), "w+");
        fwrite(fileChar,psize,1,desFile);
        fclose(desFile);
        mRet = true;
    }
    CC_SAFE_DELETE_ARRAY(fileChar);
    return mRet;
}

bool CCFileCompressOperation::decompressZipFile(const char * filname,const char * PasswordString)
{
    
    
    log("现在开始解压");
    do
    {
        unzFile pFile = NULL;
        //        *pSize = 0;
        string tempfilname =filname;
        if("" == tempfilname)
        {
            return false;
        }
        
        string writerPath =  FileUtils::getInstance()->getWritablePath();
        writerPath += filname;
        pFile = unzOpen(writerPath.c_str());
        if (!pFile)
        {
            return false ;
        }
        
        unz_global_info _zFileInfo;
        int nRet =  unzGetGlobalInfo(pFile, &_zFileInfo);
        
        if (UNZ_OK != nRet)
        {
            return false;
        }
        
        int currentfile = 1;
        nRet = unzGoToFirstFile(pFile);
        if (UNZ_OK != nRet)
        {
            return false;
        }
        
        char firstFileName[260] = {0};
        unz_file_info firstFileInfo;
        nRet = unzGetCurrentFileInfo(pFile, &firstFileInfo, firstFileName, sizeof(firstFileName), NULL, 0, NULL, 0);
        string firstFileNameString(firstFileName);
        log("%s",firstFileNameString.c_str());
        do
        {
            
            
            ++currentfile;
            char szFilePathA[260] = {0};
            unz_file_info FileInfo;
            nRet = unzGetCurrentFileInfo(pFile, &FileInfo, szFilePathA, sizeof(szFilePathA), NULL, 0, NULL, 0);
            CC_BREAK_IF(UNZ_OK != nRet);
            
            log("Current file Name : %s",szFilePathA);
            
            string szFilePathString(szFilePathA);
            if (szFilePathString.find("__MACOSX/") != string::npos
                || isFileNameEndWithStr(szFilePathString,".__MACOSX")
                || isFileNameEndWithStr(szFilePathString,".DS_Store")
                || isFileNameEndWithStr(szFilePathString,".svn")
                || szFilePathString == firstFileNameString)
            {
                unzCloseCurrentFile(pFile);
                nRet = unzGoToNextFile(pFile);
                continue;
            }
            
            szFilePathString = szFilePathString.substr(firstFileNameString.length(),
                                                       szFilePathString.length()-firstFileNameString.length());
            char endChar = szFilePathString[szFilePathString.length()-1];
            if (endChar == '/')
            {
                szFilePathString.erase(szFilePathString.end()-1);
                string headPath =  FileUtils::getInstance()->getWritablePath();
                string mkdirPath = headPath+szFilePathString;
                log("mkdir file full path : %s",mkdirPath.c_str());
                int dirExist = access(mkdirPath.c_str(), F_OK);
                if (dirExist==-1)
                {
                    int mkdircode = mkdir(mkdirPath.c_str(), S_IRWXU);
                    log("mkdir -- %s - code %d",mkdirPath.c_str(),mkdircode);
                    if (mkdircode == -1)
                    {
                        log( "mkdir error: %s\n", strerror( errno ) );
                    }
                }
                unzCloseCurrentFile(pFile);
                nRet = unzGoToNextFile(pFile);
                continue;
            }
            
            string tempPasswordString =PasswordString;
            if (tempPasswordString == "")
            {
                
                nRet = unzOpenCurrentFile(pFile);
                CC_BREAK_IF(UNZ_OK != nRet);
            }
            else
            {
                
                nRet = unzOpenCurrentFilePassword(pFile, PasswordString);
                CC_BREAK_IF(UNZ_OK != nRet);
            }
            
            unsigned char * pBuffer = new unsigned char[FileInfo.uncompressed_size];
            int nSize = 0;
            nSize = unzReadCurrentFile(pFile, pBuffer, FileInfo.uncompressed_size);
            
            CCAssert(nSize == 0 || nSize == (int)FileInfo.uncompressed_size, "the file size is wrong");
            string writeablePath =  FileUtils::getInstance()->getWritablePath();
            writeablePath = writeablePath + szFilePathString;
            //        if(isFileExistInWriteablePath(writeablePath.c_str()))
            //        {
            //            remove(writeablePath.c_str());
            //        }
            
            FILE *desFile = fopen(writeablePath.c_str(), "w+");
            
            fwrite(pBuffer, FileInfo.uncompressed_size, 1, desFile);
            fclose(desFile);
            CC_SAFE_DELETE_ARRAY(pBuffer);
            unzCloseCurrentFile(pFile);
  
           
            nRet = unzGoToNextFile(pFile);
        } while (UNZ_OK == nRet);
        
        if (pFile)
        {
            unzClose(pFile);
        }
    } while (0);
    
    removeWriteablePathfile(filname);
    return true;
    
}

void CCFileCompressOperation::removeWriteablePathfile(const char * fileName)
{
    
    string writablePath  = cocos2d:: FileUtils::getInstance()->getWritablePath();
    writablePath         = writablePath + fileName;
    if(CCFileCompressOperation::ShareInstance()-> isFileExistInWriteablePath(writablePath.c_str()))
    {
        remove(writablePath.c_str());
    }
    
}


