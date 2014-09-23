
function GFPlayerLeftControl(event)
    if g_playerObj~=nil then
        local state = g_playerObj.state
        local dir = g_playerObj.direction
        if event == g_walkingType.walkLeft then
            --print("ActionTransform : g_walkingType.walkLeft")
            state = g_bioStateType.walking
            dir = g_bioDirectionType.left
        elseif event == g_walkingType.walkRight then
            --print("ActionTransform : g_walkingType.walkRight")
            state = g_bioStateType.walking
            dir = g_bioDirectionType.right
        elseif event == g_walkingType.runLeft then
            --print("ActionTransform : g_walkingType.runLeft")
            state = g_bioStateType.running
            dir = g_bioDirectionType.left
        elseif event == g_walkingType.runRight then
            --print("ActionTransform : g_walkingType.runRight")
            state = g_bioStateType.running
            dir = g_bioDirectionType.right
        elseif event == g_walkingType.standing then
            --print("ActionTransform : g_walkingType.standing")
            state = g_bioStateType.standing
            dir = nil
        end

        g_playerObj:setLeftControlOrder(state,dir)
    end
end


function GFPlayerRightControl(event)
    if g_playerObj~=nil then
        local state = g_playerObj.state
        if event == g_gestureType.click then
            --print("ActionTransform : g_gestureType.click")
            g_playerObj:setRightControlAttackOrder(g_attackOrderType.click)
        elseif event == g_gestureType.left then
            --print("ActionTransform : g_gestureType.left")
        elseif event == g_gestureType.right then
            --print("ActionTransform : g_gestureType.right")
        elseif event == g_gestureType.up then
            --print("ActionTransform : g_gestureType.up")
            state = g_bioStateType.jumpUp
            if state~=g_playerObj.state then
                g_playerObj:enterNextState(state)
            end
        elseif event == g_gestureType.down then
            --print("ActionTransform : g_gestureType.down")
        end
    end
end

