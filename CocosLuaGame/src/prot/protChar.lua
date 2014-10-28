-- 角色
prot_create_char_c2s       = 200 --同步创建角色
prot_create_char_s2c       = 201

prot_session_bind_char_c2s = 202 --session绑定角色
prot_session_bind_char_s2c = 203

prot_login_server_c2s      = 204 --玩家进入游戏
prot_login_server_s2c      = 205

prot_get_charinfo_c2s      = 206 --获取角色信息
prot_get_charinfo_s2c      = 207

-- 同步创建角色
-- 角色在登陆那边已经做了,只是由客户端把消息带给服务器而已
protDict[prot_create_char_c2s] = {
	charid = -1,		-- 角色id
	accountid = -1,		-- 账户id
	charname = "",		-- 角色名
	charjob = -1,		-- 角色职业
	idfa = "",          -- 设备编号
	cid = -1,           -- 平台编号
	bind = -1,          -- 是否绑定 0 未绑定 1 绑定
	createdate=-1,         -- 帐号创建日期
}
protDict[prot_create_char_s2c] = {
	ret = 0,			-- 成功
}

-- session绑定角色
protDict[prot_session_bind_char_c2s] = {
	charid = -1,		-- 角色id
}
protDict[prot_session_bind_char_s2c] = {
	session = "",		-- 返回绑定角色id的session
	ret = 0,
}

-- 玩家进入游戏
protDict[prot_login_server_c2s] = {
	charid = -1,
	charname = "",
	sign = "",	-- sign 由登陆服务器返回,客户端再发给服务器
}
protDict[prot_login_server_s2c] = {
	ret = -1,
	charid = -1,
	session = "",
	scene = "",
}

-- 获取角色信息
protDict[prot_get_charinfo_c2s] = {
	charid = -1,
}
protDict[prot_get_charinfo_s2c] = {
	charid = -1,		-- 角色id
	accountid = -1,		-- 账户id
	charname = "",		-- 角色名
	charjob = -1,		-- 角色职业
    charlv = -1,        -- 角色等级
    charexp = -1,       -- 角色经验
    chardiamond = -1,   -- 角色钻石
    chargold = -1,      -- 角色元宝
    charbattleeff = -1, -- 角色战力
    sceneid = -1,       -- 角色所在场景id
    baggridcnt = -1,    -- 角色背包格子数
    charvp = -1,        -- 角色体力
}

