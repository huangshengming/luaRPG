//
//  WholeDefine.cpp
//  FGClient
//
//  Created by 神利 on 13-4-23.
//
//

#include "WholeDefine.h"
#include "FGMD5.h"
#include "MarketAPI.h"
#include "MarketAPIDefine.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
//#import <Foundation/NSObject.h>
#endif
bool g_flag_update=false;
bool g_flag_reconnect = false;
bool g_flag_switch = false;
string g_flag_serverRealName = "";
string g_flag_serverName = "";
string g_flag_ip = "";
string g_flag_port = "";
string g_flag_name = "";
string g_flag_psw = "";
string g_download_url="";
int g_flag_userId = 0;
int g_flag_sceneType = 0;
int g_flag_networkStatus = 0;
bool g_isEditboxShow = true;
bool g_luaisLoad=false;
bool g_flag_sdkSwitch = false;
map<int, std::string>g_cidkeyMap;

// global var
Scene* globalScene = NULL;


string FGgameEncryption(string buff)
{
    int cid =MarketAPI::GetSharedInstance()->getMarketCid();
    string cidkey= FGgameGetCIDKEY(cid);
    string needMD5buff=buff+cidkey;
    CCLog("%s",needMD5buff.c_str());
    return CFGMD5Digest(needMD5buff);
}

vector<std::string> SplitString(std::string aString,char aSplitChar)
{
	std::vector<std::string> list;
    
	int pos;
    
	while((pos=aString.find(aSplitChar)) != -1)
	{
		list.push_back(aString.substr(0,pos));
        
		if(pos <= (int)(aString.length()-1))
		{
			aString=aString.substr(pos+1);
		}
        else
        {
            break;
        }
	}
	if(aString.length() > 0)
	{
		list.push_back(aString);
	}
	return list;
}

vector<std::string> SplitString(std::string aString,const char* aSplitChar)
{
    std::vector<std::string> list;
    
	int pos;
    
	while((pos=aString.find(aSplitChar)) != -1)
	{
		list.push_back(aString.substr(0,pos));
        
		if(pos <= (int)(aString.length()-1))
		{
			aString=aString.substr(pos+strlen(aSplitChar));
		}
        else
        {
            break;
        }
	}
	if(aString.length() > 0)
	{
		list.push_back(aString);
	}
	return list;
}



std::string UrlEncode(const std::string& szToEncode)
{
	std::string src = szToEncode;
	char hex[] = "0123456789ABCDEF";
	string dst;
    
	for (size_t i = 0; i < src.size(); ++i)
	{
		unsigned char cc = src[i];
		if (isascii(cc))
		{
			if (cc == ' ')
			{
				dst += "%20";
			}
			else
            {
                dst += cc;
            }
		}
		else
		{
			unsigned char c = static_cast<unsigned char>(src[i]);
			dst += '%';
			dst += hex[c / 16];
			dst += hex[c % 16];
		}
	}
	return dst;
}

std::string UrlDecode(const std::string& szToDecode)
{
	std::string result;
	int hex = 0;
	for (size_t i = 0; i < szToDecode.length(); ++i)
	{
		switch (szToDecode[i])
		{
            case '+':
                result += ' ';
                break;
            case '%':
                if (isxdigit(szToDecode[i + 1]) && isxdigit(szToDecode[i + 2]))
                {
                    std::string hexStr = szToDecode.substr(i + 1, 2);
                    hex = strtol(hexStr.c_str(), 0, 16);
                    //字母和数字[0-9a-zA-Z]、一些特殊符号[$-_.+!*'(),] 、以及某些保留字[$&+,/:;=?@]
                    //可以不经过编码直接用于URL
                    if (!((hex >= 48 && hex <= 57) ||	//0-9
                          (hex >=97 && hex <= 122) ||	//a-z
                          (hex >=65 && hex <= 90) ||	//A-Z
                          //一些特殊符号及保留字[$-_.+!*'(),]  [$&+,/:;=?@]
                          hex == 0x21 || hex == 0x24 || hex == 0x26 || hex == 0x27 || hex == 0x28 || hex == 0x29
                          || hex == 0x2a || hex == 0x2b|| hex == 0x2c || hex == 0x2d || hex == 0x2e || hex == 0x2f
                          || hex == 0x3A || hex == 0x3B|| hex == 0x3D || hex == 0x3f || hex == 0x40 || hex == 0x5f
                          ))
                    {
                        result += char(hex);
                        i += 2;
                    }
                    else result += '%';
                }else {
                    result += '%';
                }
                break;
            default:
                result += szToDecode[i];
                break;
		}
	}
	return result;
}



const char * FGLocalizedString(const char * mKey,const char * mComment)
{

    //return CCLocalizedString(mKey, mComment);
    return mKey;
}

