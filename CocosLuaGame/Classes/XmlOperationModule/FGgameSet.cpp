/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2013-2014 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "FGgameSet.h"
#include "platform/CCCommon.h"
#include "platform/CCFileUtils.h"
#include "tinyxml2/tinyxml2.h"
#include "base/base64.h"
#include "base/ccUtils.h"
#include "CCFileCompressOperation.h"

//#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS && CC_TARGET_PLATFORM != CC_PLATFORM_MAC && CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)

// root name of xml
#define GAMESET_USERDEFAULT_ROOT_NAME    "GameSetRoot"

#define GAMESET_XML_FILE_NAME "GameDataSetting.xml"

using namespace std;


/**
 * define the functions here because we don't want to
 * export xmlNodePtr and other types in "CCUserDefault.h"
 */

static tinyxml2::XMLElement* getXMLNodeForKey(const char* pKey, tinyxml2::XMLElement** rootNode, tinyxml2::XMLDocument **doc)
{
    tinyxml2::XMLElement* curNode = nullptr;

    // check the key value
    if (! pKey)
    {
        return nullptr;
    }

    do 
    {
 		tinyxml2::XMLDocument* xmlDoc = new tinyxml2::XMLDocument();
		*doc = xmlDoc;

        std::string xmlBuffer = FileUtils::getInstance()->getStringFromFile(FGgameSet::getInstance()->getXMLFilePath());

		if (xmlBuffer.empty())
		{
			CCLOG("can not read xml file");
			break;
		}
		xmlDoc->Parse(xmlBuffer.c_str(), xmlBuffer.size());

		// get root node
		*rootNode = xmlDoc->RootElement();
		if (nullptr == *rootNode)
		{
			CCLOG("read root node error");
			break;
		}
		// find the node
		curNode = (*rootNode)->FirstChildElement();
		while (nullptr != curNode)
		{
			const char* nodeName = curNode->Value();
			if (!strcmp(nodeName, pKey))
			{
				break;
			}

			curNode = curNode->NextSiblingElement();
		}
	} while (0);

	return curNode;
}

static void setValueForKey(const char* pKey, const char* pValue)
{
 	tinyxml2::XMLElement* rootNode;
	tinyxml2::XMLDocument* doc;
	tinyxml2::XMLElement* node;
	// check the params
	if (! pKey || ! pValue)
	{
		return;
	}
	// find the node
	node = getXMLNodeForKey(pKey, &rootNode, &doc);
	// if node exist, change the content
	if (node)
	{
        if (node->FirstChild())
        {
            node->FirstChild()->SetValue(pValue);
        }
        else
        {
            tinyxml2::XMLText* content = doc->NewText(pValue);
            node->LinkEndChild(content);
        }
	}
	else
	{
		if (rootNode)
		{
			tinyxml2::XMLElement* tmpNode = doc->NewElement(pKey);//new tinyxml2::XMLElement(pKey);
			rootNode->LinkEndChild(tmpNode);
			tinyxml2::XMLText* content = doc->NewText(pValue);//new tinyxml2::XMLText(pValue);
			tmpNode->LinkEndChild(content);
		}	
	}

    // save file and free doc
	if (doc)
	{
		doc->SaveFile(FGgameSet::getInstance()->getXMLFilePath().c_str());
		delete doc;
	}
}

/**
 * implements of FGgameSet
 */

FGgameSet* FGgameSet::_userDefault = nullptr;
string FGgameSet::_filePath = string("");
bool FGgameSet::_isFilePathInitialized = false;

FGgameSet::~FGgameSet()
{
}

FGgameSet::FGgameSet()
{
}

bool FGgameSet::getBoolForKey(const char* pKey)
{
 return getBoolForKey(pKey, false);
}

bool FGgameSet::getBoolForKey(const char* pKey, bool defaultValue)
{
    const char* value = nullptr;
	tinyxml2::XMLElement* rootNode;
	tinyxml2::XMLDocument* doc;
	tinyxml2::XMLElement* node;
	node =  getXMLNodeForKey(pKey, &rootNode, &doc);
	// find the node
	if (node && node->FirstChild())
	{
        value = (const char*)(node->FirstChild()->Value());
	}

	bool ret = defaultValue;

	if (value)
	{
		ret = (! strcmp(value, "true"));
	}

    if (doc) delete doc;

	return ret;
}

int FGgameSet::getIntegerForKey(const char* pKey)
{
    return getIntegerForKey(pKey, 0);
}

int FGgameSet::getIntegerForKey(const char* pKey, int defaultValue)
{
	const char* value = nullptr;
	tinyxml2::XMLElement* rootNode;
	tinyxml2::XMLDocument* doc;
	tinyxml2::XMLElement* node;
	node =  getXMLNodeForKey(pKey, &rootNode, &doc);
	// find the node
	if (node && node->FirstChild())
	{
        value = (const char*)(node->FirstChild()->Value());
	}

	int ret = defaultValue;

	if (value)
	{
		ret = atoi(value);
	}

	if(doc)
	{
		delete doc;
	}


	return ret;
}

float FGgameSet::getFloatForKey(const char* pKey)
{
    return getFloatForKey(pKey, 0.0f);
}

float FGgameSet::getFloatForKey(const char* pKey, float defaultValue)
{
    float ret = (float)getDoubleForKey(pKey, (double)defaultValue);
 
    return ret;
}

double  FGgameSet::getDoubleForKey(const char* pKey)
{
    return getDoubleForKey(pKey, 0.0);
}

double FGgameSet::getDoubleForKey(const char* pKey, double defaultValue)
{
	const char* value = nullptr;
	tinyxml2::XMLElement* rootNode;
	tinyxml2::XMLDocument* doc;
	tinyxml2::XMLElement* node;
	node =  getXMLNodeForKey(pKey, &rootNode, &doc);
	// find the node
	if (node && node->FirstChild())
	{
        value = (const char*)(node->FirstChild()->Value());
	}

	double ret = defaultValue;

	if (value)
	{
		ret = utils::atof(value);
	}

    if (doc) delete doc;

	return ret;
}

std::string FGgameSet::getStringForKey(const char* pKey)
{
    return getStringForKey(pKey, "");
}

string FGgameSet::getStringForKey(const char* pKey, const std::string & defaultValue)
{
    const char* value = nullptr;
	tinyxml2::XMLElement* rootNode;
	tinyxml2::XMLDocument* doc;
	tinyxml2::XMLElement* node;
	node =  getXMLNodeForKey(pKey, &rootNode, &doc);
	// find the node
	if (node && node->FirstChild())
	{
        value = (const char*)(node->FirstChild()->Value());
	}

	string ret = defaultValue;

	if (value)
	{
		ret = string(value);
	}

    if (doc) delete doc;

	return ret;
}

Data FGgameSet::getDataForKey(const char* pKey)
{
    return getDataForKey(pKey, Data::Null);
}

Data FGgameSet::getDataForKey(const char* pKey, const Data& defaultValue)
{
    const char* encodedData = nullptr;
	tinyxml2::XMLElement* rootNode;
	tinyxml2::XMLDocument* doc;
	tinyxml2::XMLElement* node;
	node =  getXMLNodeForKey(pKey, &rootNode, &doc);
	// find the node
	if (node && node->FirstChild())
	{
        encodedData = (const char*)(node->FirstChild()->Value());
	}
    
	Data ret = defaultValue;
    
	if (encodedData)
	{
        unsigned char * decodedData = nullptr;
        int decodedDataLen = base64Decode((unsigned char*)encodedData, (unsigned int)strlen(encodedData), &decodedData);
        
        if (decodedData) {
            ret.fastSet(decodedData, decodedDataLen);
        }
	}
    
    if (doc) delete doc;
    
	return ret;    
}


void FGgameSet::setBoolForKey(const char* pKey, bool value)
{
    // save bool value as string

    if (true == value)
    {
        setStringForKey(pKey, "true");
    }
    else
    {
        setStringForKey(pKey, "false");
    }
}

void FGgameSet::setIntegerForKey(const char* pKey, int value)
{
    // check key
    if (! pKey)
    {
        return;
    }

    // format the value
    char tmp[50];
    memset(tmp, 0, 50);
    sprintf(tmp, "%d", value);

    setValueForKey(pKey, tmp);
}

void FGgameSet::setFloatForKey(const char* pKey, float value)
{
    setDoubleForKey(pKey, value);
}

void FGgameSet::setDoubleForKey(const char* pKey, double value)
{
    // check key
    if (! pKey)
    {
        return;
    }

    // format the value
    char tmp[50];
    memset(tmp, 0, 50);
    sprintf(tmp, "%f", value);

    setValueForKey(pKey, tmp);
}

void FGgameSet::setStringForKey(const char* pKey, const std::string & value)
{
    // check key
    if (! pKey)
    {
        return;
    }

    setValueForKey(pKey, value.c_str());
}

void FGgameSet::setDataForKey(const char* pKey, const Data& value) {
    // check key
    if (! pKey)
    {
        return;
    }

    char *encodedData = 0;
    
    base64Encode(value.getBytes(), static_cast<unsigned int>(value.getSize()), &encodedData);
        
    setValueForKey(pKey, encodedData);
    
    if (encodedData)
        free(encodedData);
}

FGgameSet* FGgameSet::getInstance()
{
    initXMLFilePath();

    // only create xml file one time
    // the file exists after the program exit
//    if ((! isXMLFileExist()) && (! createXMLFile()))
//    {
//        return nullptr;
//    }
    
    //1.先判断是否存在  如果不在 拷贝  如果拷贝不成功创建
    if (! isXMLFileExist())
    {
        if( !CCFileCompressOperation::copyWriteablePathFile(GAMESET_XML_FILE_NAME))
        {
            if(! createXMLFile())
            {
                return nullptr;
            }
        }
    }
    if (! _userDefault)
    {
        _userDefault = new FGgameSet();
    }

    return _userDefault;
}

void FGgameSet::destroyInstance()
{
    CC_SAFE_DELETE(_userDefault);
}

// XXX: deprecated
FGgameSet* FGgameSet::sharedUserDefault()
{
    return FGgameSet::getInstance();
}

// XXX: deprecated
void FGgameSet::purgeSharedUserDefault()
{
    return FGgameSet::destroyInstance();
}

bool FGgameSet::isXMLFileExist()
{
    FILE *fp = fopen(_filePath.c_str(), "r");
	bool bRet = false;

	if (fp)
	{
		bRet = true;
		fclose(fp);
	}

	return bRet;
}

void FGgameSet::initXMLFilePath()
{
    if (! _isFilePathInitialized)
    {
        _filePath += FileUtils::getInstance()->getWritablePath() + GAMESET_XML_FILE_NAME;
        _isFilePathInitialized = true;
    }    
}

// create new xml file
bool FGgameSet::createXMLFile()
{
	bool bRet = false;  
    tinyxml2::XMLDocument *pDoc = new tinyxml2::XMLDocument(); 
    if (nullptr==pDoc)  
    {  
        return false;  
    }  
	tinyxml2::XMLDeclaration *pDeclaration = pDoc->NewDeclaration(nullptr);  
	if (nullptr==pDeclaration)  
	{  
		return false;  
	}  
	pDoc->LinkEndChild(pDeclaration); 
	tinyxml2::XMLElement *pRootEle = pDoc->NewElement(GAMESET_USERDEFAULT_ROOT_NAME);  
	if (nullptr==pRootEle)  
	{  
		return false;  
	}  
	pDoc->LinkEndChild(pRootEle);  
	bRet = tinyxml2::XML_SUCCESS == pDoc->SaveFile(_filePath.c_str());

	if(pDoc)
	{
		delete pDoc;
	}

	return bRet;
}

const string& FGgameSet::getXMLFilePath()
{
    return _filePath;
}

void FGgameSet::flush()
{
}


//#endif // (CC_TARGET_PLATFORM != CC_PLATFORM_IOS && CC_PLATFORM != CC_PLATFORM_ANDROID)
