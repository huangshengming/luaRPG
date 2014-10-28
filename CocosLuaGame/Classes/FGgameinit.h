//
//  FGgameinit.h
//  FGClient
//
//  Created by 神利 on 13-6-8.
//
//

#ifndef __FGClient__FGgameinit__
#define __FGClient__FGgameinit__

#include <iostream>
#include "cocos2d.h"
#include <deque>
using namespace cocos2d;
using namespace std;


class FGgameinit : public Node
{
public:
    static FGgameinit* SharedIntance();
    static void DestroyInstance();
    ~FGgameinit();
    FGgameinit();
    
    bool copyfileAndUnzip(const char* fileName);
    
    //打开游戏刚启动界面
    void initStartGameview();
    void initStartGameviewGeneral();
    void initStartGameviewStartPage();
    void startPageCallBack(Ref* obj);
    //初始化资源 包括不释放标记资源加载
    void initImageResources();
    //音效加载
    void initSounResources();
    //打开更新界面
    void gotoUpdateView();
    //draw bg
    void CreateBgInit();
    //渲染动画效果
    void showEffect();
    
    void copyFileUpdate(float dt);
    void initResourcesUpdate(float dt);
private:
    deque<string>copyfileName;
    deque<SEL_CallFunc>Function;
    Label*  LabelTitle;
};


void ShowGameVersion();
int CFGdeleteGameVersion(lua_State* L);
int CFGDrawInitBg(lua_State* L);


#endif /* defined(__FGClient__FGgameinit__) */
