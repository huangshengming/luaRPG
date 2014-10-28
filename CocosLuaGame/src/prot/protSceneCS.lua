---
-- CS 场景相关
-- ID段:9800~9849
-- @module ProtBioInstance
-- @author 张微
-- @copyright usugame





-- 进入某个场景
protSceneChange_C2S = 9101
protSceneChange_S2C = 9102








--场景切换
protDict[protSceneChange_C2S] = {
    destination = -1,           --目的地 如城镇间 副本房间切换
}


protDict[protSceneChange_S2C] = {
    nextScene = -1,             --S2C 下一个场景
    --
}


