--- 伤害数字显示
-- 2014-09-20 13:44:44 by zx 

require("Cocos2d")

-- @param _obj  添加到得父类
-- @param _direction 人物方向
-- @param _num  伤害数值
-- @param _x,_y 位置
-- @param _bool true == 暴击 | false == 非暴击

function hurtNumberShow(_obj,_direction,_num,_x,_y,_bool)
    
    local num = nil
    if true == _bool then
        num = string.format("%d", _num)
    elseif false == _bool then
        num = string.format("%d", _num)
    end

    local strPath = ( _bool ) and string.format("fonts/bb.png") or string.format("fonts/pt.png")
    local x = ( _bool ) and 40 or 31    
    local y = ( _bool ) and 39 or 30 
    local hurt = cc.LabelAtlas:_create(num,strPath,x,y,string.byte('0'))
    
    local rx = math.random(-33,33)
    local ry = math.random(10,60)
    hurt:setPosition(_x+rx, _y+ry)

    --hurt:setScaleX(0.7)
    --hurt:setScaleY(0.7)
    hurt:setAnchorPoint( cc.p(0.5, 0.5) )
    _obj:addChild( hurt,10000)   
     isCrit = _bool
    if  hurt then
        --- Bezier 曲线
        local _bezierConfig = { cc.p( 0  , 70 ),
                                cc.p( 130 * ( -1 ) ^ _direction * -1 , 70 ),
                                cc.p( 130 * ( -1 ) ^ _direction * -1, -50  ),
                              } 
        local bezierBy = cc.BezierBy:create(0.5, _bezierConfig)

        --- Move
        local moveBy = cc.MoveBy:create(0.5, { x = 0, y = 100})
        --- Fade
        local fadeIn  = cc.FadeIn:create(0.1)
        local fadeOut = cc.FadeOut:create(0.2)

        ---Scale
        local scale = (  isCrit ) and ( cc.ScaleTo:create(0.01,2) ) or ( cc.ScaleTo:create(0.01, 2) )

        local function hurtCallBack()
            if hurt then
                print("移除了伤害。 ( Log Position: hurtNumber.lua -- 64 by zx)")
                 hurt:removeFromParent()
            end
        end
        
        --[[hurt:runAction( cc.Sequence:create( cc.Spawn:create(fadeIn, scale) , cc.ScaleTo:create(0.02,1),
            cc.Spawn:create(fadeIn, scale) , cc.ScaleTo:create(0.04,1),
            cc.DelayTime:create(0.5),
            cc.Spawn:create(moveBy,fadeOut),
            cc.CallFunc:create(hurtCallBack)
        )]]
        
        
        
        hurt:runAction( cc.Sequence:create( cc.Spawn:create(fadeIn, scale) , cc.ScaleTo:create(0.08,1),
                                            cc.DelayTime:create(0.5),
                                            cc.Spawn:create(moveBy,fadeOut),
                                            cc.CallFunc:create(hurtCallBack)
                                            )
                       )
        --[[hurt:runAction( cc.Sequence:create( cc.Spawn:create(          cc.EaseSineOut:create(bezierBy),scale)      ,
                                                         --cc.ScaleTo:create(0.05,1)              ,
                                            cc.CallFunc:create(hurtCallBack)
                                            )
                       )]]
    end
end

