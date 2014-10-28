require("staticData.data_monster")
require("staticData.data_resConf")

monsterDataUse = {
    getMonster = nil,             --获取目标怪物
    getFaction = nil,             --获取怪物派系
    getResConf = nil,			  --获取生物资源相关配置
}

monsterDataUse.getMonster = function(id)
    local tag = data_monster[id] 
    if tag==nil then
        print("erro:getMonster is nil,id=",id)
    end
    return tag            
end

monsterDataUse.getFaction = function(id)
    local monster = monsterDataUse.getMonster(id)
    return monster.faction
end


monsterDataUse.getResConf = function(id)
    local bio
    --暂时 ID段落
    if id > 100 then
    	bio = data_resConf.Monster[id]
    else 
    	bio = data_resConf.player[id]
    end
    return bio
end
