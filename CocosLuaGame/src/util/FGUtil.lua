

function FGUtilStringSplit(str,split_char)
	-------------------------------------------------------
	-- 增加不为空的判断 避免字符串中间或最后的符号后无内容带来的转表后的空值
	-- 参数:待分割的字符串,分割字符
	-- 返回:子串表.(含有空串)
	local sub_str_tab = {};
	while (true) do
		local pos = string.find(str, split_char);
		if (not pos) then
			if str ~= "" then
				sub_str_tab[#sub_str_tab + 1] = str;
			end
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		if str ~= "" then 
			sub_str_tab[#sub_str_tab + 1] = sub_str;
			str = string.sub(str, pos + 1, #str);
		end
	end

	return sub_str_tab;
	-- 以上代码为网上搜索拷贝,未曾阅读过,估计没问题
end

-- 深拷贝Lua表,n阶深拷贝
function FGUtilDeepCopyTable(t, n)
	local newT = {}
	if n == nil then	-- 默认为1阶深拷贝
		n = 1
	end
	for i,v in pairs(t) do
		if n>0 and type(v) == "table" then
			local T = FGUtilDeepCopyTable(v, n-1)
			newT[i] = T
		else
			local x = v
			newT[i] = x
		end
	end
	return newT
end

--返回一个table的copy
function FGDeepCopy(source)
	if source then
		local destiny = {}
	
		for key, value in pairs(source) do
			if type(value) == "table" then
				destiny[key] = FGDeepCopy(value)
			else
				destiny[key] = value
			end
		end
	
		return destiny
	else
		return nil
	end
end

-- 代替pairs函数，使按key值顺序遍历数组
function FGUtilPairsByKeys(t, f)
	if t == nil then
		return
	end
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0                 -- iterator variable
    local iter = function ()    -- iterator function
       i = i + 1
       if a[i] == nil then return nil
       else return a[i], t[a[i]]
       end
    end
    return iter
end

-- 获取本地时间戳－毫秒
function FGGetTickCountMS()
	local stamp = capi_gettickcount()
	return stamp
end

-- 获取随机数
function FGRandom(num)
    local rnd = capi_random(num)
    return rnd
end

-- 获取0到1之间的随机数
function FGRandom_0_1()
    local rnd = capi_random_0_1()
    return rnd
end

-- 获取-1到1之间的随机数
function FGRandom_minus1_1()
    local rnd = capi_random_minus1_1()
    return rnd
end

function GFIsHostileByFaction(faction1,faction2)

    if faction1==g_bioFactionType.friend or faction1==g_bioFactionType.friendPets  then
        if faction2==g_bioFactionType.enemies or  faction2==g_bioFactionType.enemiesPets then
           return true 
        end
     end
     if faction1== g_bioFactionType.enemies  or faction1==g_bioFactionType.enemiesPets then
        if  faction2== g_bioFactionType.friend or faction2==g_bioFactionType.friendPets then
           return true
        end
     end
    return false
     
end


--打印table
function pprint(lua_table, indent)
    print("\n\n")
    if type(lua_table) == "table" then
        print_table(lua_table, indent)
    else
        print(tostring(lua_table))
    end
    print("\n\n")
end

function print_table(lua_table, indent)
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print(formatting)
            print_table(v, indent + 1)
            print(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting..szValue..",")
        end
    end
end

-- @param1 self对象
-- @param2 要执行的函数名称(string)
-- @param3 不定参数
-- @return 返回执行的结果
function GFcallSuperFunction(...)
    
    local args = {...}
    if #args<2  then 
        return
    end
    local tempself= args[1]
    local functionName=args[2]
    local myfunction= nil
    local tempSuper= getmetatable(tempself)
    myfunction= tempSuper[functionName]
    while myfunction ==nil and tempSuper~=nil  do
        local nowsuper =getmetatable(tempSuper)
        if nowsuper == tempSuper then
            break
        end
        tempSuper= nowsuper
        if tempSuper ~=nil then
            myfunction= tempSuper[functionName]
        end
    end
    table.remove(args,2)
    if myfunction then
        return  myfunction(unpack(args))
    end
end

