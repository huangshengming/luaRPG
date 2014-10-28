---
-- 主角信息模块
-- @module char
-- @author csp
-- @copyright usugame

require "Cocos2d"

local _gameCharData = nil


char =class("char",function()
    return cc.Node:create()
end)


function char:getInstance()
    if _gameCharData==nil then
        _gameCharData = char.new()
        _gameCharData:retain()
    end
    return _gameCharData
end

function char:ctor()
	self:dataInit()
	GFRecAddDataListioner(self)
end



function char:dataInit()
	self._nCharId = -1			-- 角色id
	self._nAccountId = -1 		-- 账户id
	self._sName = ""			-- 角色名
	self._nJob = -1				-- 角色职业
	self._nLevel = -1			-- 角色等级
	self._nExp = -1    			-- 角色经验
	self._nDiamond = -1			-- 角色钻石
	self._nGold = -1 			-- 角色金币
	self._nBattleEff  = -1		-- 角色战力
	self._nsceneId = -1			-- 角色所在场景id
	self._nBagNum = -1			-- 角色背包格子数
	self._nVp = -1				-- 角色体力
end

function char:sendGetData(charid)
	local prot = GFProtGet(prot_get_charinfo_c2s)
	prot.charid = charid
    GFSendOneMsg(prot)
end

function char:recMessageProc(prot)
    if prot.protId == prot_get_charinfo_s2c then

    	self._nCharId = prot.charid 			-- 角色id
    	self._nAccountId = prot.accountid 		-- 账户id
		self._sName = prot.charname				-- 角色名
		self._nJob = prot.charjob				-- 角色职业
		self._nLevel = prot.charlv				-- 角色等级
		self._nExp = prot.charexp     			-- 角色经验
		self._nDiamond = prot.chardiamond 		-- 角色钻石
		self._nGold = prot.chargold 			-- 角色金币
		self._nBattleEff  = prot.charbattleeff	-- 角色战力
		self._nsceneId = prot.sceneid			-- 角色所在场景id
		self._nBagNum = prot.baggridcnt			-- 角色背包格子数
		self._nVp = prot.charvp					-- 角色体力
		
    end
end

function char:getLevel()
	return self._nLevel
end

function char:getCharId()
	return self._nCharId
end

function char:getName()
	return self._sName
end

function char:getExp()
	return self._nExp
end
function char:getJob()
	return self._nJob
end
function char:getSceneId()
	return self:_nsceneId
end
function char:getVp()
	return self._nVp
end
function char:getDiamond()
	return self._nDiamond
end
function char:getGold()
	return self._nGold
end
function char:getBattleEff()
	return self._nBattleEff
end
function char:getBagNum()
	return self._nBagNum
end












