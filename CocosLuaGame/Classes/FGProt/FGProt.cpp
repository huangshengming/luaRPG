#include <assert.h>
#include <cstring>
#include <algorithm>
#include "FGProt.h"

using std::sort;

static const char T1 = 0x01; // 正,32位
static const char t1 = 0xF1; // 负,32位
static const char T2 = 0x02; // 正,16位
static const char t2 = 0xF2; // 负,16位
static const char T3 = 0x04; // 正,8位
static const char t3 = 0xF4; // 负,8位
static const char T4 = 0x08; // 正, 64位  //633
static const char t4 = 0xF8; // 夫, 64位  //633



class FieldCmp:std::greater<stField>
{
public:
    bool operator()(const stField& f1,const stField& f2) const
    {
        std::string strA = std::string(f1.szName);
        std::string strB = std::string(f2.szName);
        return strA > strB;
    }
};

MAPPROT gMapProt;

// 查找prot
const std::vector<stField>* FGFindProt(int nProtID)
{
    MAPPROT::iterator it = gMapProt.find(nProtID);

    if(it != gMapProt.end())
    {
        return it->second;
    }

    return NULL;
}

// 协议先加载,双层table
// 协议先加载,双层table
void loadtable(lua_State* L,std::vector<stField>* pvec)
{
	int it_idx = lua_gettop(L);
	lua_pushnil(L);
	while(lua_next(L, it_idx))
	{
		stField field;
		memset(&field,0,sizeof(stField));
		field.nType = lua_type(L,-1);
		
		strncpy(field.szName,lua_tostring(L,-2),sizeof(field.szName) - 1);
		
		if(field.nType == LUA_TSTRING)
		{
			strncpy(field.uDefault.szValue,lua_tostring(L,-1),sizeof(field.uDefault.szValue) - 1);
		}
		else if(field.nType == LUA_TNUMBER)
		{
			field.uDefault.nValue = lua_tointeger(L,-1);				
		}
		else
		{
			// table
			field._next = new std::vector<stField>;
			loadtable(L,field._next);
		}
		
		pvec->push_back(field);
		
		lua_pop(L, 1);
	}

	sort(pvec->begin(),pvec->end(),FieldCmp());
}

void clear_field(std::vector<stField>* pvec)
{
	std::vector<stField>::iterator it = pvec->begin();

	for(;it != pvec->end();++it)
	{
		if(it->nType == LUA_TTABLE)
		{
			clear_field(it->_next);
		}
	}

	delete pvec;
}

void clear_mapprot(MAPPROT* pmapprot)
{
	std::map< int,std::vector<stField>* >::iterator it = pmapprot->begin();

	for(;it != pmapprot->end();++it)
	{
		clear_field(it->second);
	}

	pmapprot->clear();
}

int CFGLoadProt(lua_State *L)
{
	clear_mapprot(&gMapProt);

    int it = lua_gettop(L);
    if(it < 1)
    {
        return 0;
    }

    lua_pushnil(L);

    while(lua_next(L, it))
    {
        int nprotid = (int)lua_tointeger(L,-2);

	std::vector<stField>* pvec = new std::vector<stField>;

	loadtable(L,pvec);

        gMapProt.insert(MAPPROT::value_type(nprotid,pvec));

        lua_pop(L, 1);
    }

    lua_pop(L, 1);

    return 0;
}

// 打印一段2进制buffer
int FGDumpBuffer(const char* pszBuff,int nLen)
{
    int column = nLen / 4+1;
    for(int icol = 0;icol < column;icol++)
    {
        for(int jrow = 0;jrow < 4;jrow++)
        {
            int iidx = icol * 4 + jrow;
            if( iidx >= nLen )
            {
                break;
            }

            printf("%02X ",(unsigned char)pszBuff[iidx]);
        }
    }

    printf("\n");

    return 0;
}

inline int FGUnserializeIntValue(long long &value, char* buffer, int bufferlen)
{
	if(bufferlen <= 1)
	{
		return 0;
	}

        char T = *buffer;

        int totellen = 1;

        bool positive = ((T & 0xF0) == 0);

	bool isInt64 = T & 0x08;  //633
        bool isInt32 = T & 0x01;
        bool isInt16 = T & 0x02;
        bool isInt8 = T & 0x04;

        if(isInt32)
	{
		assert(sizeof(int) == 4);
		if((bufferlen - totellen) < sizeof(int))
		{
			return -1;
		}

		unsigned int v32 = *((int*)(buffer + totellen));
		value = positive ? (unsigned int)v32 : (signed int)-v32;
		totellen += sizeof(int);

		if(isInt16 || isInt8)
		{
			return 0;
		}

		return totellen;
	}
	else if(isInt16)
	{
		assert(sizeof(short) == 2);
		if((bufferlen - totellen) < sizeof(short))
		{
			return -1;
		}
        unsigned short v16 = *((short*)(buffer + totellen));
		value = positive ? (unsigned short)v16 : (signed short)-v16;
		totellen += sizeof(short);

		if(isInt32 || isInt8)
		{
			return 0;
		}

		return totellen;
	}
        else if(isInt8)
	{
		assert(sizeof(char) == 1);
		if((bufferlen - totellen) < sizeof(char))
		{
			return -1;
		}
        unsigned char v8 = *(buffer + totellen);
		value = positive ? (unsigned char)v8 : (signed char)-v8;
		totellen += sizeof(char);

		if(isInt32 || isInt16)
		{
			return 0;
		}

		return totellen;
	}
	else if(isInt64)	//633
	{
		assert(sizeof(long long)==8);
		if((bufferlen - totellen) < sizeof(long long))
		{
			return -1;
		}
        unsigned	long long v64 = *((long long *)(buffer + totellen));
		value = positive ? (unsigned long long )v64 : (signed long long)-v64;
		totellen += sizeof(long long);

		if( isInt32 || isInt16 || isInt8)
		{
			return 0;
		}

		return totellen;
	}

	return 0;
}

inline int FGSerializeIntValue( long long value,char *buffer,int bufferlen)
{
	bool positive = true;
	if(value < 0)
	{
		positive = false;
		value = -value;
	}


	if((value & 0xFFFFFFFF00000000) > 0)
	{
		assert(8 == sizeof(long long)); // 保证int是64位的
		if(bufferlen < 9)
		{
			return 0;
		}

		*buffer = positive ? T4 : t4;
		*((long long *)(buffer + 1)) = value;

		return 9;
	}
	else if((value & 0xFFFF0000) > 0)
	{
		assert(4 == sizeof(int)); // 保证int是32位的
		if(bufferlen < 5)
		{
			return 0;
		}

		*buffer = positive ? T1 : t1;
		*((int*)(buffer + 1)) = value;

		return 5;
	}
	else if((value & 0xFFFFFF00) > 0)
	{
		assert(2 == sizeof(short)); // 同理
		if(bufferlen < 3)
		{
			return 0;
		}

		*buffer = positive ? T2 : t2;
		*((short*)(buffer + 1)) = *((short*)&value);

		return 3;
	}
	else
	{
		// 1个字节足够了
		assert(1 == sizeof(char));
		if(bufferlen < 2)
		{
			return 0;
		}

		*buffer = positive ? T3 : t3;
		*(buffer + 1) = *((char*)&value); 

		return 2;
	}

	return 0;
}

inline int FGSerializeStringValue(const char* value,char *buffer,int bufferlen)
{
	int length = (int)strlen(value);
	int totellen = 0;
	int ret = FGSerializeIntValue(length,buffer,bufferlen);

	totellen += ret;
	if(totellen > 0)
	{
		if((bufferlen - totellen) < length)
		{
			return 0;
		}

		memcpy(buffer + totellen,value,length);
		totellen += length;

		return totellen;
	}

	return 0;
}

int CFGPickBufferInfo(lua_State* L)
{
	if(lua_gettop(L) >= 2)
	{
		char* buffer = (char*)lua_touserdata(L, 1);
		int bufferlen = (int)lua_tointeger(L, 2);
		if(bufferlen > 16)
		{
			int fd = *((int*)buffer);
			int protId = *((int*)(buffer + sizeof(int)));
			int totellen = *((int*)(buffer + sizeof(int) + sizeof(int) + sizeof(int)));
			if(totellen <= bufferlen)
			{
				lua_pushinteger(L,fd);
				lua_pushinteger(L,protId);
				lua_pushinteger(L,totellen);
				return 3;
			}//end totellen<=bufferlen
		}//end bufferlen>12
	}//end gettop>=2

	lua_pushnil(L);
	lua_pushnil(L);
	lua_pushnil(L);

	return 3;
}

int unserialize(lua_State* L,const std::vector<stField>* pvec,char* pszbuff,int limitlen)
{
	int nRet = 0;
	int nTotal = 0;
	for(std::vector<stField>::const_iterator it = pvec->begin();it != pvec->end();++it)
	{
		if(it->nType == LUA_TSTRING)
		{
			long long nValue = 0;
			nRet = FGUnserializeIntValue(nValue,pszbuff + nTotal,limitlen - nTotal);
			if((nRet > limitlen - nTotal) || (nValue > limitlen - nTotal) || nRet < 0 || nValue < 0)
			{
				return -1;
			}

			const char* pszValue = pszbuff + nTotal + nRet;
			nTotal += nValue;

			if(limitlen < nTotal)
			{
				return -1;
			}

			lua_pushstring(L, it->szName);
			lua_pushlstring(L, pszValue, nValue);

			lua_settable(L, -3);
		}
		else if(it->nType == LUA_TNUMBER)
		{
			long long nValue = -1;
			nRet = FGUnserializeIntValue(nValue,pszbuff + nTotal,limitlen - nTotal);
			lua_pushstring(L, it->szName);
			lua_pushnumber(L, nValue);
			lua_settable(L, -3);
		}
		else
		{
			// table
			long long tablesize = 0;
			nRet = FGUnserializeIntValue(tablesize,pszbuff + nTotal,limitlen - nTotal);
			if((nRet > limitlen - nTotal) || (tablesize > limitlen - nTotal) || nRet < 0 || tablesize < 0)
			{
				return -1;
			}	

			lua_pushstring(L, it->szName);
			lua_newtable(L);
			for(int i = 0;i < tablesize;++i)
			{
				lua_pushnumber(L,i + 1);
				lua_newtable(L);
				int n = unserialize(L,it->_next,pszbuff + nRet + nTotal,limitlen - nRet - nTotal);

				if(n < 0)
				{
					return -1;
				}

				nRet += n;
				lua_settable(L, -3);
			}
			lua_settable(L, -3);
		}

		nTotal += nRet;
		
		if(limitlen < nTotal)
		{
			return -1;
		}
	}

	return nTotal;
}

int CFGUnserializeProt(lua_State* L)
{
	if(lua_gettop(L) < 3)
	{
		lua_pushinteger(L,-1);
		return 1;
	}

	char* pszBuff = (char*)lua_touserdata(L, 1);
	int nLenLimit = (int)lua_tointeger(L, 2);

	printf("CFGUnserializeProt\n");
	//FGDumpBuffer(pszBuff,nLenLimit);
	printf("CFGUnserializeProt\n");

	int nTotal = sizeof(int) + sizeof(int) + sizeof(int) + sizeof(int);

	if(nLenLimit < nTotal)
	{
		lua_pushinteger(L,-1);
		return 1;
	}
	int nProtID = *((int*)(pszBuff + sizeof(int)));
	const std::vector<stField>* pVecProt = FGFindProt(nProtID);
	if(!pVecProt)
	{
		lua_pushinteger(L,-1);
		return 1;
	}

	// 循环
	int n = unserialize(L,pVecProt,pszBuff + nTotal,nLenLimit - nTotal);
	if(n < 0)
	{
		lua_pushinteger(L,-1);
		return 1;
	}
	nTotal += n;
	if(nLenLimit != nTotal)
	{
		lua_pushinteger(L,-1);
		return 1;
	}

	lua_pushinteger(L,nTotal);
	return 1;
}

int serialprot(lua_State* L,const std::vector<stField>* pvec,char* pszbuff,size_t limitlen)
{
	// 循环
	int nRet = 0;
	int totellen = 0;
	for(std::vector<stField>::const_iterator it = pvec->begin();it != pvec->end();++it)
	{
		if(limitlen < totellen)
		{
			return -1;
		}

		lua_getfield(L, -1, it->szName);

		if(it->nType == LUA_TSTRING)
		{
			const char* pszValue = lua_tostring(L,-1);
			if(pszValue)
			{
				nRet = FGSerializeStringValue(pszValue, pszbuff + totellen, limitlen - totellen);
			}
			else
			{
				// 按默认值
				nRet = FGSerializeStringValue(it->uDefault.szValue, pszbuff + totellen, limitlen - totellen);
			}
		}
		else if(it->nType == LUA_TNUMBER)
		{
			int nType = lua_type(L,-1);

			if(nType == LUA_TNUMBER || nType == LUA_TSTRING)
			{
				long long nValue = lua_tonumber(L,-1);
				nRet = FGSerializeIntValue(nValue, pszbuff + totellen, limitlen - totellen);
			}
			else
			{
				// 按默认值
				nRet = FGSerializeIntValue(it->uDefault.nValue, pszbuff + totellen, limitlen - totellen);
			}
		}
		else if(it->nType == LUA_TTABLE)
		{
			// 遍历该表
			int size = lua_objlen(L,-1);
			nRet = FGSerializeIntValue(size,pszbuff + totellen,limitlen - totellen);

			if(limitlen < totellen + nRet)
			{
				return -1;
			}

			if(size > 0)
			{
				int n = 0;
				lua_pushnil(L);
				while(lua_next(L,-2))
				{
					n = serialprot(L,it->_next,pszbuff + totellen + nRet ,limitlen - totellen - nRet);

					if(n < 0)
					{
						return -1;
					}

					nRet += n;

					if(limitlen < totellen + nRet)
					{
						return -1;
					}

					lua_pop(L, 1);
				}
			}
		}

		totellen += nRet;
		lua_pop(L,1);
	}

	return totellen;
}

int CFGSerializeProt(lua_State* L)
{
    if(lua_gettop(L) < 5)
    {
        return 0;
    }

    //prot,bufferaddr,lengthlimit,setid,protId
    char *bufferaddr = (char*)lua_tointeger(L,-4);
    int lengthlimit = (int)lua_tointeger(L,-3);
    int fd = (int)lua_tointeger(L,-2);
    int protid = (int)lua_tointeger(L,-1);
    lua_pop(L,4);

    int totellen = sizeof(int) + sizeof(int) + sizeof(int) + sizeof(int);
    /*7  table prot*/

    // 12 个字节的包头需要保证
    if(lengthlimit < totellen)
    {
        return 0;
    }

    const std::vector<stField>* pVecProt = FGFindProt(protid);

    if(!pVecProt)
    {
        return 0;
    }

    // 写入FD
    *((int*)bufferaddr) = fd;
    // 写入协议ID
    *((int*)(bufferaddr + sizeof(int))) = protid;

    // 写入总长度,这里还不知道
    int len = serialprot(L,pVecProt,bufferaddr + totellen,lengthlimit - totellen);
    if(len < 0)
    {
        return 0;
    }

    totellen += len;

    *((int*)(bufferaddr + sizeof(int) + sizeof(int) + sizeof(int))) = totellen;
    lua_pushinteger(L,totellen);

    return 1;
}
