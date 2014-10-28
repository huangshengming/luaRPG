/*
 *  CCXMLFile.h
 *  SkeletonX
 *
 *  Created by Vincent on 12/22/11.
 *  Copyright 2011 GeekStudio. All rights reserved.
 *
 */

#ifndef _CCXMLFile_H_
#define _CCXMLFile_H_


#include <string>
#include "cocos2d.h"

USING_NS_CC;
using namespace std;

class CCXMLFileforLibs
{
public:
    CCXMLFileforLibs();
    ~CCXMLFileforLibs();
    bool openXMLFile(const char *mFileName);
//    bool	getBoolForKey(const char*pKey, bool defaultValue = false);
	int		getIntegerForKey(const char*pKey, int defaultValue = 0);
//	float	getFloatForKey(const char*pKey, float defaultValue=0.0f);
//	double  getDoubleForKey(const char*pKey, double defaultValue=0.0);
//	string getStringForKey(const char*pKey, const string & defaultValue = "");
   const char* getValueForKey(const char*pKey);
    
private:
    char * _nowbuff;
};


#endif