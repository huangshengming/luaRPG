data_monster={
Monster={
[20001]={
name="怪物1",
mold=2,
faction=2,
camp=0,
type=1,
class=0,
sex=1,
hurtType=0,
status=1,
skill=0,
templetAI=0,
templetHS=1,
att=100,
hp=32000,
mp=100,
},
[20002]={
name="怪物2",
mold=2,
faction=2,
camp=0,
type=1,
class=0,
sex=1,
hurtType=0,
status=1,
skill=0,
templetAI=0,
templetHS=1,
att=100,
hp=32000,
mp=100,
},
},
MonsterGroup={
[30001]={
monster={20001,},--20001,20001,20001,
},
[30002]={
monster={20002,20002,20002,20002,},
},
[30003]={
monster={20001,20001,20002,20002,},
},
},
}-- end of file
