//
//  CAPI.h
//  usuClient
//
//  Created by 花如锦 on 14-9-11.
//
//

#ifndef usuClient_CAPI_h
#define usuClient_CAPI_h

#include "CCLuaEngine.h"

void capi_lua_register();

int capi_gettickcount(lua_State *L);

int capi_random_0_1(lua_State *L);

int capi_random(lua_State *L);

int capi_random_minus1_1(lua_State *L);

#endif
