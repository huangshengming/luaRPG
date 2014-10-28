---
-- 拖动通用控件
-- @module GeneralView
-- @author csp
-- @copyright usugame
require "Cocos2d"
---
-- GeneralView移动到目标的目标效果模式
-- @GeneralViewMoveMode
-- @param NONE 无效果
-- @param ZOOE 放大1.2倍
GeneralViewMoveMode = {
    NONE=1,
    ZOOE=2,
}
---
-- GeneralView
-- @type GeneralView ImageView
local GeneralView = class("GeneralView",function()
    return ccui.ImageView:create()
end)

---
-- GeneralView的创建
-- @preturn userdata self 创建返回GeneralView
function GeneralView:create()
    return GeneralView.new()
end
---
-- 设置GeneralView的移动模式
-- @param mode 提供移动到目标区域效果模式 GeneralViewMoveMode.NONE（无效果）,GeneralViewMoveMode.ZOOE(放大1.2倍)
-- @usage view:setMoveMode(GeneralViewMoveMode.ZOOE)
function GeneralView:setMoveMode(mode)
	self._moveMode = mode
end

function GeneralView:ctor()
	self._moveTargetHander = nil
	self._moveHander = nil
	self._moveSprite = nil
	self._moveTagets = {}
	self._schedulerId = nil
    self._moveMode = GeneralViewMoveMode.NONE
	self._isMoveAble = true
    
	

   
   
    GFRecAddViewListioner(self)
     
	 local function onNodeEvent(event)
        if "cleanup" == event then 
            GFRecRemoveListioner(self)
            if self._schedulerId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerId)
            end
        end
      end
	self:registerScriptHandler(onNodeEvent)
	

	
    local function touchEvent(sender,eventType)
        self:_event(eventType)
    end    
    GFcallSuperFunction(self,"addTouchEventListener",touchEvent)
end
---
-- 设置事件回调
-- @tparam function hander 回调函数格式：hander(sender,eventType)
function GeneralView:addTouchEventListener(hander)
    local function touchEvent(sender,eventType)
        hander(sender,eventType)
        self:_event(eventType)
    end 
    GFcallSuperFunction(self,"addTouchEventListener",touchEvent)
end

---
-- 设置是否允许拖动
-- @tparam bool isAble 设置控件是否允许拖动，默认不可以
function GeneralView:setMoveEnabled(isAble)
    self._isMoveAble = isAble
end
---
-- 设置事件拖动到目标点回调
-- @tparam function hander 回调函数格式：hander(sender,targetObj)
-- @usage 
-- function handler(sender,targetObj) 
-- print("..") 
-- end
-- view:registerMoveTaegetHander(handler)
function GeneralView:registerMoveTaegetHander(handler)
	self._moveTargetHander = handler
end

---
-- 设置事件拖动时的回调（创建返回拖动类）
-- @tparam function hander hander需要创建返回node，回调函数格式：hander(sender)
-- @usage 
-- function handler(sender,targetObj) 
-- local  moveSp = ccui.ImageView:create()  
-- scene:addChild(moveSp)
-- return moveSp
-- end
-- view:registerMoveingHander(handler)
function GeneralView:registerMoveingHander(handler)
    self._moveHander = handler
    self:setMoveTarget(self)
end

---
-- 设置GeneralView拖动的目标点
-- @tparam ccNode node 拖动的目标点node
-- @usage 
-- view:setMoveTarget(button)
function GeneralView:setMoveTarget(obj)
    local isE = false
    for i,v in pairs(self._moveTagets) do
        if obj == v then
            isE = true
            break
        end
    end
    if not isE then
        table.insert(self._moveTagets,obj)
    end
end

function GeneralView:_moveIngMode(eventType)
    if not self._isMoveAble then return end
    if self._moveMode == GeneralViewMoveMode.NONE then return end
   
    local location = self:getTouchEndPosition()
    if eventType == ccui.TouchEventType.moved then 
        location = self:getTouchMovePosition()
    elseif eventType == ccui.TouchEventType.began then 
        if self._moveMode == GeneralViewMoveMode.ZOOE then
            self.startScale = self:getScale()
            self:setScale(self.startScale*1.2)
        end
    end
  
    if self._moveMode == GeneralViewMoveMode.ZOOE then
        if eventType == ccui.TouchEventType.began then 
            for k,v in ipairs(self._moveTagets) do
                if v ~= self then      
                    v.startScale = v:getScale()
                end
            end
        elseif eventType == ccui.TouchEventType.moved then
            for k,v in ipairs(self._moveTagets) do    
                local _rect = v:getBoundingBox()
                local isP = cc.rectContainsPoint(_rect,location)
                if isP then
                    v:setScale(v.startScale*1.2)
                else
                    v:setScale(v.startScale)
                end 
            end
        else
            for k,v in ipairs(self._moveTagets) do      
                v:setScale(v.startScale)
            end
        end
    end
    
end

function GeneralView:_event(eventType)
    if eventType == ccui.TouchEventType.began then          
    elseif eventType == ccui.TouchEventType.moved then       
        if self._moveHander and self._isMoveAble then
            if not self._moveSprite then
                self._moveSprite = self._moveHander(self)
                      
                local tick = function(dt)
                    self:_tick(dt)
                end
                if not self._schedulerId then
                    self._schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick,0,false)
                end
                
            end
            if self._moveSprite then
                local pos = self:getTouchMovePosition()
                local par = self._moveSprite:getParent()        
                local posS = pos
              
                if par then 
                    posS =  par:convertToNodeSpace(pos)
                end
                self._moveSprite:setPosition(posS) 
            end             
        end
    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        self:_executeMoveTaget()

        if self._moveSprite then
            self._moveSprite:removeFromParentAndCleanup(true)
            self._moveSprite = nil
        end
        if self._schedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerId)
            self.schedulerId = nil
        end
        
    end
    self:_moveIngMode(eventType)
end



function GeneralView:_tick(dt)
    local ch = self:getChildren()
    for k,v in pairs(ch or {}) do
        local state = true
        if self._moveSprite then
            state = false 
        end

      --  v:setVisible(state)
    end
end
function GeneralView:_isInTarget()
    local location = self:getTouchEndPosition()
    for k,v in ipairs(self._moveTagets) do    
        local _rect = v:getBoundingBox()
        local isP = cc.rectContainsPoint(_rect,location)
        if isP then
            return v 
        end 
	end
	return false
end

function GeneralView:_executeMoveTaget()
    if not self._isMoveAble then return end
    local taget = self:_isInTarget()
    if taget and self._moveTargetHander then
        self._moveTargetHander(self,taget)
	end
end
return GeneralView