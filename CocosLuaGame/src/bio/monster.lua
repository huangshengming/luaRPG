require "Cocos2d"
require("armatureRender.armatureDraw")

local function sxcLog( ... )
	print("sxcLog:", ...)
end

local ai_action = {
	close_to_player = 1,
	away_from_player = 2
}

local bioClass = require("bio.bio")

local monster = class("monster", bioClass)

function monster:create(dyId,staticId,name,faction)
    local mstr = monster.new(dyId,staticId,name,faction)
    mstr:enterNextState(g_bioStateType.standing)
    return mstr
end

function monster:ctor(dyId,staticId,name,faction)
	 self.super.ctor(self,dyId,staticId,name,faction)
	 self._canChangeDir = true
     self.speedWalkVx = self.speedWalkVx / 4
     self._safeDist = 300
     self._atkdt = 3
     self._atkcd = 0
     self._bActived = false
end

function monster:aiExecute(dt)
	if self.state == g_bioStateType.standing then
		self:onStanding()
	elseif self.state == g_bioStateType.walking then
		self:onWalking(dt)
	end
end

function monster:onStanding()
	local roleDir = g_playerObj:getDirection()
	local rolePosX = g_playerObj:getPositionX()
	local myDir = self:getDirection()
	local myPosX = self:getPositionX()
	local dx = myPosX - rolePosX

	if self._bActived == false then
		if math.abs(dx) <= self._safeDist then
			self._bActived = true
			self:enterNextState(g_bioStateType.walking)
		end
	elseif self._bActived == true then
		self:enterNextState(g_bioStateType.walking)
	end
end

function monster:onWalking(dt)

	local roleDir = g_playerObj:getDirection()
	local rolePosX = g_playerObj:getPositionX()
	local myDir = self:getDirection()
	local myPosX = self:getPositionX()
	local dx = myPosX - rolePosX
	
	if self._atkcd > 0 then self._atkcd = self._atkcd - dt end

	if self._atkcd <= 0 and FGRandom_0_1() > 0.9 then
		self:attack(1)
	end

	--怪物朝向修正
	if dx > 0 then --玩家在怪左边
		if myDir ~= g_bioDirectionType.left and self._canChangeDir == true then
			self:setDirection(g_bioDirectionType.left)
		end
	elseif dx <= 0 then --玩家在怪右边
		if myDir ~= g_bioDirectionType.right then
			self:setDirection(g_bioDirectionType.right)
		end
	end
	
	if math.abs(dx) < 5 and FGRandom_0_1() < 0.5 and self._canChangeDir == true then
		if myDir == g_bioDirectionType.left then
			self:setDirection(g_bioDirectionType.right)
		elseif myDir == g_bioDirectionType.right then
			self:setDirection(g_bioDirectionType.left)
		end
		dx = -dx
		self:setPositionX(myPosX+dx)
		self._canChangeDir = false
	end

    myDir = self:getDirection()

	if myDir == g_bioDirectionType.left then
		if dx > 200 and self._action ~= ai_action.close_to_player then
			self.vx = math.abs(self.vx)
			self._action = ai_action.close_to_player
		elseif dx > 0 and dx < 5 and self._action ~= ai_action.away_from_player then
			self.vx = -math.abs(self.vx)
			self._action = away_from_player
		else
			self._canChangeDir = true
		end
	elseif myDir == g_bioDirectionType.right then
		if dx < -200 and self._action ~= ai_action.close_to_player then
			self.vx = math.abs(self.vx)
			self._action = ai_action.close_to_player
		elseif dx > -5 and dx < 0 and self._action ~= ai_action.away_from_player then
			self.vx = -math.abs(self.vx)
			self._action = away_from_player
		else
			self._canChangeDir = true
		end
	end
end

function monster:attackEnd_to_standing()
    local ret = self.super.attackEnd_to_standing(self)
    self._atkcd = self._atkdt
    return ret
end

return monster
