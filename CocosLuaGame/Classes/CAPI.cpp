//
//  CAPI.cpp
//  usuClient
//
//  Created by 花如锦 on 14-9-11.
//
//

#include "CAPI.h"
#include <sys/time.h>


void capi_lua_register(lua_State *L) {
    lua_register(L, "capi_gettickcount", capi_gettickcount);
}

int capi_gettickcount(lua_State *L) {
    struct timeval now;
    gettimeofday(&now, nullptr);
    long time_stamp = now.tv_sec * 1000 + now.tv_usec / 1000;
    lua_pushnumber(L, time_stamp);
    return 1;
}
