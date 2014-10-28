/*
 *  CCXMLFile.cpp
 *  SkeletonX
 *
 *  Created by Vincent on 12/22/11.
 *  Copyright 2011 GeekStudio. All rights reserved.
 *
 */


#include "CCXMLFile.h"
#include "WholeDefine.h"
bool CCXMLFileforLibs::openXMLFile(const char *mFileName)
{
    string fadsfa =  FileUtils::getInstance()->fullPathForFilename(mFileName,false);
    ssize_t pFileSize = 0;
    unsigned char* fileIo = FileUtils::getInstance()->getFileData(fadsfa.c_str(), "r", &pFileSize);
    CC_SAFE_DELETE(_nowbuff);
    _nowbuff = (char*) malloc(pFileSize+1);
  
    memcpy(_nowbuff, fileIo, pFileSize);
    return true;
}

CCXMLFileforLibs::CCXMLFileforLibs()
:_nowbuff(NULL)
{
}
CCXMLFileforLibs::~CCXMLFileforLibs()
{
    CC_SAFE_DELETE(_nowbuff);
}
const char*CCXMLFileforLibs::getValueForKey(const char*pKey)
{
    if(_nowbuff==NULL)return NULL;
    string temp(_nowbuff);
    int firstPos = temp.find(pKey);
    
    string firstBuff(&temp[firstPos]);
    //去除第一个key
    firstBuff=  firstBuff.substr(strlen(pKey),firstBuff.size()-1);
    int secondPos = firstBuff.find(pKey);
    //去除第二个key 并且 去除> </
    string lastbuff=firstBuff.substr(1,secondPos-1-2);
    return lastbuff.c_str();

}
int		CCXMLFileforLibs::getIntegerForKey(const char*pKey, int defaultValue )
{
    string value = getValueForKey(pKey);
    int ret = defaultValue;
    if (!value.empty())
    {
        ret = atoi(value.c_str());
    }
    return ret;
}
