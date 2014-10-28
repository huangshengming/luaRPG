//
//  MarketAPIDefine.h
//  FGClient
//
//  Created by 神利 on 13-5-20.
//
//

#ifndef __FGClient__MarketAPIDefine__
#define __FGClient__MarketAPIDefine__
#include "WholeDefine.h"

typedef enum{
    kMarketGeneral  = 100, //通用版
    kMarketPP       = 102, //pp
    kMarket91       = 101, //91
    KMarketUC       = 103, //UC
    KMarketTB       = 104, //同步
    kMarketSB       = 105, //版署
    kMarket37Wan    = 106, //37玩
    kMarketTC       = 107, //繁体
    kMarket5GWan    = 108, //5Gwan逗将三国
    kMarketItools   = 109, //itools
    kMarketpgYuan   = 110, //苹果园
    kMarket5GWanCC  = 111, //5Gwan曹操去哪儿
    kMarketNearme   = 112,
    kMarketDownjoy  = 113,
    kMarketMi       = 114,
    kMarketHuawei   = 115,
    kMarketGfan     = 116,
    kMarket360      = 117,
    kMarketDk       = 118,
    kMarketWdj      = 119,
    kMarketYyb      = 120,
    kMarket3gmh     = 121,
    kMarketSougou   = 122,
    kMarketMmy      = 123,
    kMarketYouxin   = 124,
    kMarketXunlei   = 125,
    kMarketJinli    = 126,
    kMarketKuaiyong = 127,
    kMarketKupai    = 128,
    kMarketKuaiwan  = 129,
    
    kMarket37WanIOS = 141,//37玩IOS
    
    kMarketInt800   = 800, //策划
    kMarketInt801   = 801, //开发
} kMarketType;




#define ADDONECIDKEY(cid,cidkey) addOneCidKey((cid),(cidkey));

/***ios正式*****/

//AppStore cid
#define CID_w_100 100
#define CID_KEY_100 "aiUCHncQQ5xGZcdGPaxezQK50GfOzR4V"
//91
#define CID_w_101 101
#define CID_KEY_101 "mYqFR3AbWnCDogNVG908aQz9XnZYynzB"
//pp
#define CID_w_102 102
#define CID_KEY_102 "9vaRbkEgxGJCAAYXIspEhn9e7VUtLQ8b"
//低清pp
#define CID_w_202 202
#define CID_KEY_202 "MfnKlraEYQlarxdD4cr2FpobUcJpShND"
//uc
#define CID_w_103 103
#define CID_KEY_103 "W2V3uCJl9YQCNU9YLLO9pUJjhtPYXjIK"
//同步推
#define CID_w_104 104
#define CID_KEY_104 "IzFgOTNpLhXB0ek0O3dEwrjnr1LsaLhk"
//37玩 android
#define CID_w_106 106
#define CID_KEY_106 "By83Al4Wbab5qYcAHQZnSWvugTz8SBtj"
//繁体
#define CID_w_107 107
#define CID_KEY_107 "ek6iDx7NdefKZUBVseCCE6TCEQktPrlc"
//5GwanNiming逗将三国
#define CID_w_108 108
#define CID_KEY_108 "GCmAE8ndE4AiVdM8VK6WEq4OC3xdXOMS"
//itools
#define CID_w_109 109
#define CID_KEY_109 "ccXxLfIVDicrWyQSSR8S04Rhg6AJYCU8"

//5Gwan曹操去哪儿
#define CID_w_111 111
#define CID_KEY_111 "XPf9v7zcbaraYSaA5lVDsrmGrmXTCBKz"

#define CID_w_112 112
#define CID_KEY_112 "7vdjcMN6eCVAes6B0ejkzs4spTK9eTKc"

#define CID_w_113 113
#define CID_KEY_113 "j2wPvcIGvgQ6vkZkY8eUDuDo6xFxr8vB"

#define CID_w_114 114
#define CID_KEY_114 "2gpJ0WSWLlOeuL8smnczSkutVqrSLHAE"

#define CID_w_115 115
#define CID_KEY_115 "lbsHgkJSrU6VobOUsUuENrrifBv6gCar"

#define CID_w_116 116
#define CID_KEY_116 "9Bwb2I6kCZTEOCuRAXhJezUD5hzRM2NL"

#define CID_w_117 117
#define CID_KEY_117 "swA9i6XLizHReyFOcw5NbHTZqsD6NZU5"

#define CID_w_118 118
#define CID_KEY_118 "53NZvdUODFjmJtL8QrHwdIBMIy51rDUm"

#define CID_w_119 119
#define CID_KEY_119 "tF1w3ftXeJraBUYobNPwl8GSz0saCW3V"

#define CID_w_120 120
#define CID_KEY_120 "pvovlGNa7gFCbBIcWlVFQtqPO5Q4v4uc"

#define CID_w_121 121
#define CID_KEY_121 "8jejrpEktCn3GNtYXHZLSM0htVj9DWgB"

#define CID_w_122 122
#define CID_KEY_122 "F6e2VADzLyDl5HvNO5klic4Q5TZuN4Ii"

#define CID_w_123 123
#define CID_KEY_123 "ZFKns7vHTibno0vQqVSEphlA4DTO9YZY"

#define CID_w_124 124
#define CID_KEY_124 "8YcU2lBosKPK7ZiPn2rSnkYuASLkYKWX"

#define CID_w_125 125
#define CID_KEY_125 "8kCAh67awl94O6RNZYkCVuZMiTMAXauV"

#define CID_w_126 126
#define CID_KEY_126 "jjPl407sdLP5NjG0gPnX2K5qphHarwTN"

#define CID_w_127 127
#define CID_KEY_127 "tEiN372BhD1vz87qe3mzneGOTmWcKvj1"

#define CID_w_128 128
#define CID_KEY_128 "gb2Zmo6GTW8uMsishmL4uLgT3VRHWXTB"

#define CID_w_129 129
#define CID_KEY_129 "UXlEsDv5zRJEWIWOkh5aVIV8Gn8MsvHU"

//腾讯
#define CID_w_130 130
#define CID_KEY_130 "zOoPQd8lwl6lKffXTNUoja9BXcOtR1Vi"
//安智
#define CID_w_131 131
#define CID_KEY_131 "f1xgkvyFBo0CmmgNtRy9gc14tbQw8CUK"
//联想
#define CID_w_132 132
#define CID_KEY_132 "sUDzEN4d2emNM6lL0Henkq9imCCDdkg7"
//拇指玩
#define CID_w_133 133
#define CID_KEY_133 "y0Y5ayV5ZnG5kXOv8Pi3kR2QN55irTsj"
//步步高
#define CID_w_134 134
#define CID_KEY_134 "wlR5rg7h07tyQLLzfAijCGZwHtTxXyTf"
//应用汇
#define CID_w_135 135
#define CID_KEY_135 "DqcBW1Y9XgMQoCejnImZC7S47Wmca75r"
//魅族
#define CID_w_136 136
#define CID_KEY_136 "v6BznxT641JaZCXEXtnj7hFxEQooLof8"
//新浪游戏
#define CID_w_137 137
#define CID_KEY_137 "hDlLGPYaFkQ9cW8GZMMOfPfBOokTYRPH"
//奥软
#define CID_w_138 138
#define CID_KEY_138 "OEbTy0GTpRVtlagm1j3uZbYZULWyMuSK"
//手游天下
#define CID_w_139 139
#define CID_KEY_139 "tqtyEf4h5MwDvqUI4enzq7CdydcDh3G4"
//5G集成91安卓版
#define CID_w_140 140
#define CID_KEY_140 "c5gJymUsflwTcnqsTwF8jHN1Te9hOYVj"
//37WAN IOS
#define CID_w_141 141
#define CID_KEY_141 "4twPOeEsDA0VJUm683cGOoULxlNZKXQ5"
//pps
#define CID_w_142 142
#define CID_KEY_142 "MFfbDhg3hIK9RFWGXlndobULIohofYES"
//酷狗
#define CID_w_143 143
#define CID_KEY_143 "2ELaG9xjsGbnzZiULvyi8INMa44YeEdM"
//益玩
#define CID_w_144 144
#define CID_KEY_144 "7kGIyZRWWZvD4ZHZdig1py3LZNdVy12b"
//优酷
#define CID_w_145 145
#define CID_KEY_145 "JecVFKwCIG9YQa7Pia2uxaLpMEPN4ghV"
//8849
#define CID_w_146 146
#define CID_KEY_146 "ovlOTMttWw0vIzrElDBCsC99RjslJHJu"
//浩动安卓
#define CID_w_147 147
#define CID_KEY_147 "uSSaib70emCORls7Giz9AEzIOnyZecXy"
//手盟
#define CID_w_148 148
#define CID_KEY_148 "vaY1U7vLcrBsYQMy9TvqCT3sckfxv81G"
//浩动IOS
#define CID_w_149 149
#define CID_KEY_149 "PZ6osTb3W3b4kZk4BKCJou8qb6Skhtve"
//爱思 IOS
#define CID_w_150 150
#define CID_KEY_150 "a4SGkb21WFlRJHMci8wftvg4xfW2dask"
//三星
#define CID_w_151 151
#define CID_KEY_151 "socusVBDloNMd6hY4RhpPZexKxZ326rQ"


//人人
#define CID_w_152 152
#define CID_KEY_152 "6au9xaZ11joWomVk6MCvgWTLo0g8xFf9"
//绿岸
#define CID_w_153 153
#define CID_KEY_153 "DbkiqmIKLQtgxz218jSa1iB9unSOliic"
//起点
#define CID_w_154 154
#define CID_KEY_154 "8y2pAfBEw8l3bA6LhB964uhev7iIFBMb"

//冰雪
#define CID_w_155 155
#define CID_KEY_155 "Nkk4Fu03c3WcmRL7jwubuqWs9zzNb9Av"
//海马
#define CID_w_156 156
#define CID_KEY_156 "s6DKLIorRYxmx7pumrOhVnAGM2QSGHoO"
//平安
#define CID_w_157 157
#define CID_KEY_157 "6SVpRXNQxT8vHo3Qom9mmjfVpu6Wbfd7"
//UCUC
#define CID_w_158 158
#define CID_KEY_158 "TpFBbeRU9bfvUIeRrEySuRP0z32roIMH"

//柴米
#define CID_w_159 159
#define CID_KEY_159 "ycXghtgjP6QE5ZSduzTXVNtedviwUgA0"
//海马安卓
#define CID_w_160 160
#define CID_KEY_160 "dYgVmHEIu1rOgfwzwud2mK8sQYzBpOpk"
//光速
#define CID_w_161 161
#define CID_KEY_161 "SKyAsW26aW2XqwbVypy8MGMGtqQGUmdD"
//酷动
#define CID_w_162 162
#define CID_KEY_162 "oLoIl8LPUt7hzJiCAWPNx2v4ANslI0gG"
//YY
#define CID_w_163 163
#define CID_KEY_163 "3yGorm9dAoIrKZWYDR9TYZ9jdgJqey4Z"


/****内部测试***/
//策划
#define CID_w_800 800
#define CID_KEY_800 "ilBTKfKnusV9JUOzceyxRTQHMCsgehos"
//开发
#define CID_w_801 801
#define CID_KEY_801 "cYHCzhGk3Tmqv5skmF1IYQjjnEQpEjae"

//sb版署
#define CID_w_105 105
#define CID_KEY_105 "1QU2vo8mEMwS3EKjAzgNUlr00q3QIbPz"



#define CID_w(a)   CID_w_##a
#define CID_KEY(a) CID_KEY_##a


inline std::string FGgameGetCIDKEY(int cid)
{
    std::string tempbuff="";
    map <int,string >::iterator iter = g_cidkeyMap.find(cid);
 
    if(iter!=g_cidkeyMap.end())
    {
        tempbuff=iter->second;
    }
    return tempbuff;
}

inline void addOneCidKey(int cid ,std::string key)
{
    
    map <int,string >::iterator iter = g_cidkeyMap.find(cid);
  
    if(iter==g_cidkeyMap.end())
    {
        g_cidkeyMap.insert(make_pair(cid,key));
    }
}
inline const char* FGMarketGetMarketName(int cid)
{
    switch (cid) {
        case 100:
            return "AppStore";
            break;
        case 101:
            return "91";
            break;
        case 102:
            return "PP";
            break;
        case 202:
            return "低清PP";
            break;
        case 103:
            return "UC";
            break;
        case 104:
            return "同步推";
            break;
        case 106:
            return "37wan安卓";
            break;
        case 107:
            return "繁体appstore";
            break;
        case 108:
            return "5GwanNiming";
            break;
        case 109:
            return "itools";
            break;
        case 110:
            return "苹果园";
            break;
        case 111:
            return "5Gwan";
            break;
        case 112:
            return "nearme";
            break;
        case 113:
            return "downjoy";
            break;
        case 114:
            return "mi";
            break;
        case 115:
            return "HUAWEI";
            break;
        case 116:
            return "gfan";
            break;
        case 117:
            return "360";
            break;
        case 118:
            return "多酷";
            break;
        case 119:
            return "豌豆荚";
            break;
        case 120:
            return "应用宝";
            break;
        case 121:
            return "3G门户";
            break;
        case 122:
            return "搜狗";
            break;
        case 123:
            return "木蚂蚁";
            break;
        case 124:
            return "有信";
            break;
        case 125:
            return "迅雷";
            break;
        case 126:
            return "金立";
            break;
        case 127:
            return "快用";
            break;
        case 128:
            return "酷派";
            break;
        case 129:
            return "快玩";
            break;
        case 130:
            return "腾讯移动";
            break;
        case 131:
            return "安智";
            break;
        case 132:
            return "联想";
            break;
        case 133:
            return "拇指玩";
            break;
        case 134:
            return "步步高";
            break;
        case 135:
            return "应用汇";
            break;
        case 136:
            return "魅族";
            break;
        case 137:
            return "新浪手游";
            break;
        case 138:
            return "奥软";
            break;
        case 139:
            return "手游天下";
            break;
        case 140:
            return "5G集成91安卓";
            break;
        case 141:
            return "37玩IOS";
            break;
        case 142:
            return "pps";
            break;
        case 143:
            return "酷狗";
            break;
        case 144:
            return "益玩";
            break;
        case 145:
            return "优酷";
            break;
        case 146:
            return "8849";
            break;
        case 147:
            return "浩动Android";
            break;
        case 148:
            return "手盟";
            break;
        case 149:
            return "浩动iOS";
            break;
        case 150:
            return "爱思iOS";
            break;
        case 151:
            return "三星";
            break;
        case 800:
            return "内部800";
            break;
        case 801:
            return "内部801";
            break;
        default:
            break;
    }
    return "Unknow";
}

/*********加了cid和cidkey一定要在这个加初始化*********/
inline void initCIDkey()
{
    ADDONECIDKEY(CID_w(800),CID_KEY(800));
    ADDONECIDKEY(CID_w(801),CID_KEY(801));
    
    ADDONECIDKEY(CID_w(100),CID_KEY(100));
    ADDONECIDKEY(CID_w(101),CID_KEY(101));
    ADDONECIDKEY(CID_w(102),CID_KEY(102));
    ADDONECIDKEY(CID_w(202),CID_KEY(202));
    ADDONECIDKEY(CID_w(103),CID_KEY(103));
    ADDONECIDKEY(CID_w(104),CID_KEY(104));
    ADDONECIDKEY(CID_w(105), CID_KEY(105));
    ADDONECIDKEY(CID_w(106), CID_KEY(106));
    ADDONECIDKEY(CID_w(107), CID_KEY(107));
    ADDONECIDKEY(CID_w(108), CID_KEY(108));
    ADDONECIDKEY(CID_w(109), CID_KEY(109));
    ADDONECIDKEY(CID_w(111), CID_KEY(111));
    ADDONECIDKEY(CID_w(112), CID_KEY(112));
    ADDONECIDKEY(CID_w(113), CID_KEY(113));
    ADDONECIDKEY(CID_w(114), CID_KEY(114));
    ADDONECIDKEY(CID_w(115), CID_KEY(115));
    ADDONECIDKEY(CID_w(116), CID_KEY(116));
    ADDONECIDKEY(CID_w(117), CID_KEY(117));
    ADDONECIDKEY(CID_w(118), CID_KEY(118));
    ADDONECIDKEY(CID_w(119), CID_KEY(119));
    ADDONECIDKEY(CID_w(120), CID_KEY(120));
    ADDONECIDKEY(CID_w(121), CID_KEY(121));
    ADDONECIDKEY(CID_w(122), CID_KEY(122));
    ADDONECIDKEY(CID_w(123), CID_KEY(123));
    ADDONECIDKEY(CID_w(124), CID_KEY(124));
    ADDONECIDKEY(CID_w(125), CID_KEY(125));
    ADDONECIDKEY(CID_w(126), CID_KEY(126));
    ADDONECIDKEY(CID_w(127), CID_KEY(127));
    ADDONECIDKEY(CID_w(128), CID_KEY(128));
    ADDONECIDKEY(CID_w(129), CID_KEY(129));
    ADDONECIDKEY(CID_w(130), CID_KEY(130));
    ADDONECIDKEY(CID_w(131), CID_KEY(131));
    ADDONECIDKEY(CID_w(132), CID_KEY(132));
    ADDONECIDKEY(CID_w(133), CID_KEY(133));
    ADDONECIDKEY(CID_w(134), CID_KEY(134));
    ADDONECIDKEY(CID_w(135), CID_KEY(135));
    ADDONECIDKEY(CID_w(136), CID_KEY(136));
    ADDONECIDKEY(CID_w(137), CID_KEY(137));
    ADDONECIDKEY(CID_w(138), CID_KEY(138));
    ADDONECIDKEY(CID_w(139), CID_KEY(139));
    ADDONECIDKEY(CID_w(140), CID_KEY(140));
    ADDONECIDKEY(CID_w(141), CID_KEY(141));
    ADDONECIDKEY(CID_w(142), CID_KEY(142));
    ADDONECIDKEY(CID_w(143), CID_KEY(143));
    ADDONECIDKEY(CID_w(144), CID_KEY(144));
    ADDONECIDKEY(CID_w(145), CID_KEY(145));
    ADDONECIDKEY(CID_w(146), CID_KEY(146));
    ADDONECIDKEY(CID_w(147), CID_KEY(147));
    ADDONECIDKEY(CID_w(148), CID_KEY(148));
    ADDONECIDKEY(CID_w(149), CID_KEY(149));
    ADDONECIDKEY(CID_w(150), CID_KEY(150));
    ADDONECIDKEY(CID_w(151), CID_KEY(151));
    ADDONECIDKEY(CID_w(152), CID_KEY(152));
    ADDONECIDKEY(CID_w(153), CID_KEY(153));
    ADDONECIDKEY(CID_w(154), CID_KEY(154));
    ADDONECIDKEY(CID_w(155), CID_KEY(155));
    ADDONECIDKEY(CID_w(156), CID_KEY(156));
    ADDONECIDKEY(CID_w(157), CID_KEY(157));
    ADDONECIDKEY(CID_w(158), CID_KEY(158));
    ADDONECIDKEY(CID_w(159), CID_KEY(159));
    ADDONECIDKEY(CID_w(160), CID_KEY(160));
    ADDONECIDKEY(CID_w(161), CID_KEY(161));
    ADDONECIDKEY(CID_w(162), CID_KEY(162));
    ADDONECIDKEY(CID_w(163), CID_KEY(163));
}


#endif
