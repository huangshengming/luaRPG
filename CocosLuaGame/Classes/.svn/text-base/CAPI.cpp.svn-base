//
//  CAPI.cpp
//  usuClient
//
//  Created by 花如锦 on 14-9-11.
//
//

#include "CAPI.h"
#include <sys/time.h>
#include "WholeDefine.h"
#include "httpExpansion.h"
#include "FGProt.h"

int capi_gettickcount(lua_State *L) {
    struct timeval now;
    gettimeofday(&now, nullptr);
    long time_stamp = now.tv_sec * 1000 + now.tv_usec / 1000;
    lua_pushnumber(L, time_stamp);
    return 1;
}

int capi_random_0_1(lua_State *L) {
    float rnd = CCRANDOM_0_1();
    lua_pushnumber(L, rnd);
    return 1;
}

int capi_random(lua_State *L) {
    int num = lua_tonumber(L, 1);
    int rnd = rand()%num;
    lua_pushnumber(L, rnd);
    return 1;
}

int capi_random_minus1_1(lua_State *L) {
    float rnd = CCRANDOM_MINUS1_1();
    lua_pushnumber(L, rnd);
    return 1;
}


void capi_lua_register() {
    LRT(capi_gettickcount);
    LRT(capi_random_0_1);
    LRT(capi_random);
    LRT(capi_random_minus1_1);
    LRTHttpExpansion();
    
    LRT(CFGSerializeProt);
    LRT(CFGUnserializeProt);
    LRT(CFGPickBufferInfo);
    LRT(CFGLoadProt);
}

