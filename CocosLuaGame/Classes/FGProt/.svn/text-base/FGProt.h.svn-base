#ifndef __FGPROT_H__
#define __FGPROT_H__

const int MAX_PROT_LEN = 4096;

extern "C"{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

//ADD BY SUNG
#include <vector>
#include <map>
#include <string>

typedef struct _stField stField;
typedef std::map< int,std::vector<stField>* > MAPPROT;

struct _stField
{
	char szName[32];
	union
	{
		int nValue;
		char szValue[32];
	} uDefault;

	// 嵌套的子table
	std::vector<stField>* _next;

	int nType;
};

extern int CFGSerializeProt(lua_State* L);//(prot,bufferaddr,lengthlimit,setid,protId)
extern int CFGUnserializeProt(lua_State* L);//(bufferaddr,bufferlength,prot)
extern int CFGPickBufferInfo(lua_State* L);//(bufferaddr,bufferlength)
extern int FGDumpBuffer(const char* pszBuff,int nLen);
extern int CFGLoadProt(lua_State *L);
extern int FGUnserializeIntValue(long long &value, char* buffer, int bufferlen);
extern int FGSerializeStringValue(const char* value,char *buffer,int bufferlen);
extern int FGSerializeIntValue(long long value,char *buffer,int bufferlen);
extern int serialprot(lua_State* L,const std::vector<stField>* pvec,char* pszbuff,size_t limitlen);

//ADD BY SUNG
extern const std::vector<stField>* FGFindProt(int nProtID);

extern int CFGSocketSendEx(lua_State* L);

#endif//__FGPROT_H__
