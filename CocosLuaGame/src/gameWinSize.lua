---
-- scene适配相关
-- @module gameWinSize
-- @author csp
-- @copyright usugame

require("Cocos2d")


local _winSizeManagemant = nil

---
-- scene适配相关
-- @type gameWinSize  Node

gameWinSize =class("gameWinSize",function()
    return cc.Node:create()
end)

---
-- gameWinSize 获取单例
-- @return userdata gameWinSize单例
function gameWinSize:getInstance()
    if _winSizeManagemant==nil then
        _winSizeManagemant = gameWinSize.new()
        _winSizeManagemant:retain()
    end
    return _winSizeManagemant
end

function gameWinSize:ctor()
    local function _fSceneScale()
        local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local visSize = cc.Director:getInstance():getVisibleSize()
        local winSize = cc.Director:getInstance():getWinSize()
        local _mSx = visSize.width/winSize.width
        local _mSy = visSize.height/winSize.height
        self._nSceneSale= math.min(_mSx,_mSy)
        if self._nSceneSale == _mSx then
            self._nScaleDir = 1
            self._nOrigin = (visSize.height/self._nSceneSale-winSize.height)/2  

        else
            self._nScaleDir = 2   
            self._nOrigin =(visSize.width/self._nSceneSale-winSize.width)/2
        end
    end
    self._nScaleDir = 1
    self._nSceneSale= 1
    self._nOrigin = 0
    _fSceneScale()
    print("游戏scene缩放方向是：",self._nScaleDir)
    print("游戏scene缩放偏移像素是：",self._nOrigin)
end

---
-- 设置需要设置适配的scene的缩放
-- @tparam CCScene scene 需要设置适配的scene
-- @usage 
-- gameWinSize:getInstance():setSceneScale(scene)
function gameWinSize:setSceneScale(scene)
    scene:setScale(self._nSceneSale)
end
---
-- 获取当前scene的适配缩放系数
-- @treturn number _nSceneSale 当前scene的适配缩放系数
-- @usage local scale =  gameWinSize:getInstance():GetSceneScale()
function gameWinSize:GetSceneScale()
    return self._nSceneSale
end
---
-- 获取当前scene的适配缩放偏移量
-- @treturn number _nOrigin 当前scene的适配缩放偏移量
-- @usage local Origin =  gameWinSize:getInstance():GetSceneOrigin()
function gameWinSize:GetSceneOrigin()
    return self._nOrigin
end
---
-- 获取当前scene的适配缩放偏移量（可理解为x，y方向的黑边长度）
-- @treturn number x 当前scene的适配缩放x方向偏移量
-- @treturn number y 当前scene的适配缩放y方向偏移量
-- @usage local Origin =  gameWinSize:getInstance():GetSceneOriginPos()
function gameWinSize:GetSceneOriginPos()
    local x,y = 0,0
    if self._nScaleDir == 1 then
        y = self._nOrigin
    else
        x = self._nOrigin
    end
    return x,y
end
---
-- 获取当前scene的适配缩放偏移方向
-- @treturn number _nScaleDir 返回值-> 1：将超出屏幕的宽缩回(如ipad)  返回值-> 2：将超出屏幕的高缩回（如5s）
-- @usage local dir =  gameWinSize:getInstance():GetSceneDir()
function gameWinSize:GetSceneDir()
    return self._nScaleDir
end
---
-- 设置需要设置适配的node的偏移(向左下偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignLeftBottom(node)

function gameWinSize:AlignLeftBottom(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 1 then
        py = y-self._nOrigin
    else
        px = x-self._nOrigin
    end
    node:setPosition(px,py)
    return px,py 
end
---
-- 设置需要设置适配的node的偏移(向右上偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignRightTop(node)
function gameWinSize:AlignRightTop(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 1 then
        py = y+self._nOrigin
    else
        px = x+self._nOrigin
    end
    node:setPosition(px,py)
    return px,py 
end
---
-- 设置需要设置适配的node的偏移(向左上偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignLeftTop(node)
function gameWinSize:AlignLeftTop(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 1 then
        py = y+self._nOrigin
    else
        px = x-self._nOrigin
    end
    node:setPosition(px,py)
    return px,py
end
---
-- 设置需要设置适配的node的偏移(向右下偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignRightBottom(node)
function gameWinSize:AlignRightBottom(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 1 then
        py = y-self._nOrigin
    else
        px = x+self._nOrigin
    end
    node:setPosition(px,py)
    return px,py
end
---
-- 设置需要设置适配的node的偏移(向左偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignLeft(node)
function gameWinSize:AlignLeft(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 2 then
        px = x-self._nOrigin
    end
    node:setPosition(px,py)
    return px,py
end
---
-- 设置需要设置适配的node的偏移(向右偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignRight(node)
function gameWinSize:AlignRight(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 2 then
        px = x+self._nOrigin
    end
    node:setPosition(px,py)
    return px,py
end
---
-- 设置需要设置适配的node的偏移(向上偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignTop(node)
function gameWinSize:AlignTop(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 1 then
        py = y+self._nOrigin
    end
    node:setPosition(px,py)
    return px,py
end
---
-- 设置需要设置适配的node的偏移(向下偏移)
-- @tparam ccNode node 需要适配偏移的node
-- @treturn number x 适配偏移后坐标x
-- @treturn number y 适配偏移后坐标y
-- @usage local x,y = gameWinSize:getInstance():AlignBottom(node)
function gameWinSize:AlignBottom(node)
    local x,y = node:getPosition()
    local px,py = x,y
    if self._nScaleDir == 1 then
        py = y-self._nOrigin
    end
    node:setPosition(px,py)
    return px,py
end

return gameWinSize
