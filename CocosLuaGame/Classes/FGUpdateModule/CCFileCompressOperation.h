//
//  CCFileCompressOperation.h
//  FGClient
//
//  Created by 神利 on 13-4-19.
//
//



#ifndef __FGClient__CCFileCompressOperation__
#define __FGClient__CCFileCompressOperation__

#include "cocos2d.h"
#include <iostream>


USING_NS_CC;
using namespace std;



class CCFileCompressOperationDelegate
{
public:
    virtual void ccfileUncompressProgress(const char * filename ,int currentFile,int totalFile)=0;
    virtual void ccfileUncompressProgressResult(const char * filename ,int resultCode)=0;
    virtual void ccfileUncompressErrorResult(const char * errorString ,int resultCode)=0;
};

class CCFileCompressOperation
{
public:
    static CCFileCompressOperation* ShareInstance()
    {
        static CCFileCompressOperation Instance;
        return &Instance;
    }
    
    CCFileCompressOperation();
    ~CCFileCompressOperation();
    
    bool isFileExistInWriteablePath(const char * mFileName);
    long long getLocalFileLenth(const char * mFileName);
    void decompressZipFileToWriteablePath();

    //static void* startUncompressThread(void* constCompress);
    void uncompressZipFileThread(const char* pszZipFilePath,CCFileCompressOperationDelegate* _delegateIntance = NULL, string pszPassword = "");
    unsigned long getZipFileNumber(const char * fullPathString);
    void listDirEachFileCopy(const char * fileName);
    bool isFileExistInWriteablePathFinal(const char * mFileName);

//    int copy_r( char *read_dir_path, char *write_dir_path);
    void  mycp(char* source,char* des) ;
    void copy_data(char* spath,char* dpath) ;
    void versionDetection();
    void dirRecursive(const char* source);
    void handleData(char* source);
    
    static void dirNotRecursive(const char* source);
    static void deleteZipFile(char* source);
    
    //从包中拷贝文件 到沙盒
    static  bool copyWriteablePathFile(const char * fileName);
    //解压已经存在沙盒中的文件  路径从沙盒开始不用全路径
    static bool decompressZipFile(const char * filname,const char * PasswordString="");
    static void removeWriteablePathfile(const char * fileName);
private:
    pthread_t  s_Thread;
    string pszZipFilePathString;
    string pszPasswordString;
    CCFileCompressOperationDelegate* m_delegate;
};

#endif
