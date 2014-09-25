--- 菜单层
-- 2014-09-19 16:57:33

require("Cocos2d")
require "math"
menuLayer = class("menuLayer",function()
	return cc.Layer:create()
end)

function menuLayer:initMenuItem()

	self.visibleSize    =   cc.Director:getInstance():getVisibleSize()
    self.visibleOrigin  =   cc.Director:getInstance():getVisibleOrigin()
    self.is = false
   
	--[[self.bigmenu = cc.MenuItemImage:create("menu/bigmenu1.png","menu/bigmenu.png") 
	self.bigmenuPos = cc.p( self.visibleSize.width, self.bigmenu:getContentSize().height/2 ) 
	self.bigmenu:setPosition(self.bigmenuPos)
	self.bigmenu:setZOrder(10)]]

	---add 2014-09-24 12:30:21 by zx
	self.bigmenu1 = cc.MenuItemImage:create("menu/bigmenu.png","menu/bigmenu1.png")
	self.bigmenu2 = cc.MenuItemImage:create("menu/bigmenu1.png","menu/bigmenu.png")
	self.bigmenu  = cc.MenuItemToggle:create(self.bigmenu1, self.bigmenu2)
	self.bigmenuPos = cc.p( self.visibleSize.width, self.bigmenu:getContentSize().height/2 ) 
	self.bigmenu:setPosition(self.bigmenuPos)
	self.bigmenu:setZOrder(10)
	require("sceneManagement.menuParticle"):createParticle(self.bigmenu1)
	require("sceneManagement.menuParticle"):createParticle(self.bigmenu2)

	--公会
	self.guild = cc.MenuItemImage:create("menu/guild.png","menu/guild.png")	
	self.guildPos = cc.p(self.bigmenuPos.x - self.bigmenu:getContentSize().width/2 - self.guild:getContentSize().width/2 - 50,
							self.guild:getContentSize().height/2)				
	self.guild:setPosition( self.guildPos )

	--神兽
	self.pet = cc.MenuItemImage:create("menu/pet.png","menu/pet.png")
	self.petPos = cc.p(self.guildPos.x - self.guild:getContentSize().width/2 - self.pet:getContentSize().width/2 - 50,
							self.pet:getContentSize().height/2)					
	self.pet:setPosition( self.petPos )

	--剑魂
	self.jh = cc.MenuItemImage:create("menu/jh.png","menu/jh.png")	
	self.jhPos = cc.p(self.petPos.x - self.pet:getContentSize().width/2 - self.jh:getContentSize().width/2 - 50,
							self.jh:getContentSize().height/2)				
	self.jh:setPosition(self.jhPos )

	--强化
	self.strengthen = cc.MenuItemImage:create("menu/strengthen.png","menu/strengthen.png")			
	self.strengthenPos = cc.p(self.jhPos.x - self.jh:getContentSize().width/2 - self.strengthen:getContentSize().width/2 - 50,
							self.strengthen:getContentSize().height/2)
	self.strengthen:setPosition( self.strengthenPos )

	-- 培养
	self.train = cc.MenuItemImage:create("menu/train.png","menu/train.png")					
	self.trainPos = cc.p(self.strengthenPos.x - self.strengthen:getContentSize().width/2 - self.train:getContentSize().width/2 - 50,
							self.train:getContentSize().height/2)
	self.train:setPosition( self.trainPos )

	require("sceneManagement.menuParticle"):createParticle(self.train)

	--技能
	self.skill = cc.MenuItemImage:create("menu/skill.png","menu/skill.png")	
	self.skillPos = cc.p(self.trainPos.x - self.train:getContentSize().width/2 - self.skill:getContentSize().width/2 - 50,
							self.skill:getContentSize().height/2)
	self.skill:setPosition(self.skillPos )
	require("sceneManagement.menuParticle"):createParticle(self.skill)
	--背包
	self.bag = cc.MenuItemImage:create("menu/bag.png","menu/bag.png")					
	self.bagPos = cc.p(self.skillPos.x- self.skill:getContentSize().width/2 - self.bag:getContentSize().width/2 - 50,
							self.bag:getContentSize().height/2)
	self.bag:setPosition( self.bagPos)

	--人物
	self.character = cc.MenuItemImage:create("menu/character.png","menu/character.png")          
	self.characterPos = cc.p(self.bagPos.x - self.bag:getContentSize().width/2 - self.character:getContentSize().width/2 - 50,
							self.character:getContentSize().height/2)
	self.character:setPosition( self.characterPos)



	--系统
	self.system = cc.MenuItemImage:create("menu/system.png","menu/system.png")
	self.systemPos = cc.p(self.visibleSize.width ,
							self.bigmenuPos.y + self.system:getContentSize().height/2 + self.bigmenu:getContentSize().width/2 + 50)	
	self.system:setPosition( self.systemPos )

	--排行榜
	self.billboard = cc.MenuItemImage:create("menu/billboard.png","menu/billboard.png")				
	self.billboardPos = cc.p(self.visibleSize.width ,
							self.systemPos.y + self.system:getContentSize().height/2 + self.billboard:getContentSize().width/2 + 50)
	self.billboard:setPosition(self.billboardPos )

	--好友
	self.friend = cc.MenuItemImage:create("menu/friend.png","menu/friend.png")					
	self.friendPos = cc.p(self.visibleSize.width ,
							self.billboardPos.y + self.billboard:getContentSize().height/2 + self.friend:getContentSize().width/2 + 50)
	self.friend:setPosition(self.friendPos )




	---
	--竞技场
	self.pvp = cc.MenuItemImage:create("menu/pvp.png","menu/pvp.png")
	self.pvpPos = cc.p(self.bigmenu:getPositionX() - self.bigmenu:getContentSize().width/2 - self.pvp:getContentSize().width/2 - 50,
							self.pvp:getContentSize().height/2 )						
	self.pvp:setPosition( self.bigmenuPos)
	require("sceneManagement.menuParticle"):createParticle(self.pvp)

	--精英副本
	self.elite = cc.MenuItemImage:create("menu/elite.png","menu/elite.png")						
	self.elite:setPosition( self.bigmenuPos)
	self.elitePos = cc.p( self.pvpPos.x - self.pvp:getContentSize().width/2 - self.elite:getContentSize().width/2 - 50,
							self.elite:getContentSize().height/2)
	require("sceneManagement.menuParticle"):createParticle(self.elite)
	--挑战boss
	self.challengeBoss = cc.MenuItemImage:create("menu/challengeBoss.png","menu/challengeBoss.png")				
	self.challengeBoss:setPosition( self.bigmenuPos)
	self.challengeBossPos = cc.p( self.elitePos.x - self.elite:getContentSize().width/2 - self.challengeBoss:getContentSize().width/2 - 50,
							self.challengeBoss:getContentSize().height/2)



	--活动抽奖
	self.lucky = cc.MenuItemImage:create("menu/lucky.png","menu/lucky.png")						
	self.lucky:setPosition( self.bigmenuPos)	
	self.luckyPos = cc.p(self.visibleSize.width ,
							self.bigmenuPos.y + self.bigmenu:getContentSize().height/2 + self.lucky:getContentSize().width/2 + 50)

	require("sceneManagement.menuParticle"):createParticle(self.lucky)
	--任务
	self.task = cc.MenuItemImage:create("menu/task.png","menu/task.png")						
	self.task:setPosition( self.bigmenuPos)	
	self.taskPos = cc.p(self.visibleSize.width ,
							self.bigmenuPos.y + self.bigmenu:getContentSize().height/2 + self.lucky:getContentSize().width/2 + 50 + self.lucky:getContentSize().height/2 + self.task:getContentSize().width/2 + 50)


	---懒得截图了,QQ还有截图限制次数，fuck
--[[
	self.pay = cc.MenuItemImage:create()							--充值
	self.getGold = cc.MenuItemImage:create()						--领金币
	self.award = cc.MenuItemImage:create()						--领奖
	self.active = cc.MenuItemImage:create()						--活动
	self.shop = cc.MenuItemImage:create()							--商城
	]]
end

function menuLayer:ItemMoveCallBack()

	local function longCome()
		--- long x 收回
		self.character:runAction( cc.MoveTo:create(0.3, self.bigmenuPos ) )
		self.bag:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 
		self.skill:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 
		self.train:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 
		self.strengthen:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 
		self.jh:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 
		self.pet:runAction( cc.MoveTo:create( 0.3 , self.bigmenuPos ) ) 
		self.guild:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) )
		--- long y 收回
		self.system:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 		
		self.billboard:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) ) 
		self.friend:runAction( cc.MoveTo:create( 0.3  , self.bigmenuPos ) )
	end

	local function longGo()
		--- long x 放出
		self.character:runAction( cc.MoveTo:create(0.3, self.characterPos ) )
		self.bag:runAction( cc.MoveTo:create( 0.3  , self.bagPos ) ) 
		self.skill:runAction( cc.MoveTo:create( 0.3  , self.skillPos ) ) 
		self.train:runAction( cc.MoveTo:create( 0.3  , self.trainPos ) ) 
		self.strengthen:runAction( cc.MoveTo:create( 0.3  , self.strengthenPos ) ) 
		self.jh:runAction( cc.MoveTo:create( 0.3  , self.jhPos ) ) 
		self.pet:runAction( cc.MoveTo:create( 0.3 , self.petPos ) ) 
		self.guild:runAction( cc.MoveTo:create( 0.3  , self.guildPos ) )
		--- long y 放出
		self.system:runAction( cc.MoveTo:create( 0.3  , self.systemPos ) ) 		
		self.billboard:runAction( cc.MoveTo:create( 0.3  , self.billboardPos ) ) 
		self.friend:runAction( cc.MoveTo:create( 0.3  , self.friendPos ) )
	end

	local function shortCome()
		--- short x 收回
		self.challengeBoss:runAction( cc.MoveTo:create(0.3, self.bigmenuPos ))
		self.elite:runAction( cc.MoveTo:create(0.3, self.bigmenuPos ))
		self.pvp:runAction( cc.MoveTo:create(0.3, self.bigmenuPos ))
		--- short y 收回
		self.lucky:runAction( cc.MoveTo:create(0.3, self.bigmenuPos ))
		self.task:runAction( cc.MoveTo:create(0.3,  self.bigmenuPos))
	end

	local function shortGo()
		--- short x 放出
		self.challengeBoss:runAction( cc.MoveTo:create(0.3, self.challengeBossPos ))
		self.elite:runAction( cc.MoveTo:create(0.3, self.elitePos ))
		self.pvp:runAction( cc.MoveTo:create(0.3, self.pvpPos ))
		--- short y 放出
		self.lucky:runAction( cc.MoveTo:create(0.3, self.luckyPos ))
		self.task:runAction( cc.MoveTo:create(0.3,  self.taskPos))
	end

	if not self.is then
		longCome()
		shortGo()
		self.is = true
	else
		shortCome()
		longGo()
		self.is = false
	end
	
end

---
-- 子菜单点击响应
function menuLayer:ItemClickCallBack()
	local function _char()
		local _char = require("sceneManagement/selectLayers/character")
		_char:SetLayerVisible(true)
        _char:GetListener():setEnabled(true)
        _char:GetListener():setSwallowTouches(true)
	end
	self.character:registerScriptTapHandler(_char)

	
end

function menuLayer:bigmenuEvent()
	self.bigmenu:registerScriptTapHandler(function() self:ItemMoveCallBack() end)
end

function menuLayer:createLayer()
	local layer = menuLayer.new()
	
	self:initMenuItem()
	self:bigmenuEvent()
	self:ItemClickCallBack()
	local menu = cc.Menu:create(self.character, self.bag, self.skill, self.train, self.strengthen, self.jh, self.pet, self.guild,
								self.system, self.billboard, self.friend, self.challengeBoss, self.elite, self.pvp, self.lucky, self.task,self.bigmenu)
	menu:setPosition(0,0)
	layer:addChild(menu)

	return layer
end


return menuLayer