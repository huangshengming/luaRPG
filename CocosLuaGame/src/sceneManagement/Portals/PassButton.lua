---
-- 9.15 
-- 传送按钮

require("Cocos2d")

PassButton = class("PassButton",function(_fileName)
	return cc.MenuItemImage:create(_fileName,_fileName)
	end)


function PassButton:create(_fileName)
	local button = PassButton.new(_fileName)
	return button
end

function PassButton:ctor()
	self.type = nil
	local function click()
		if 1 == self.type then
			print("副本传送")
			elseif 2 == self.type then
				print("经验传送")
				elseif nil == self.type then 
					print("类型空了。。传毛")
				end
	end
    self:registerScriptTapHandler(click)
end	

function PassButton:setType(type)
	self.type = type
end

function PassButton:setShow(_bool)
	self:setVisible(_bool)
end



return PassButton
