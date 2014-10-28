//
//  FGgamePlatformAPI.m
//  FGClient
//
//  Created by 神利 on 13-7-11.
//
//

#include "FGgamePlatformAPI.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <string.h>


string getDeviceIdentification()
{
    string macaddr= getMacAddress();
    string deviceid=macaddr;
//    string idfa= getIdfa();
//    if(idfa!="")
//    {
//        deviceid+="@";
//        deviceid+=idfa;
//        
//    }

    return deviceid;
    
    
}

string getBundleIdentifier()
{

    
    return  [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey] UTF8String];

}

string getGameName()
{
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey] UTF8String];
}



string getDeviceName()
{
    return "Mac";
}
string getDeviceType()
{
    return "Mac";
}
string getDeviceSysVerSion()
{
    return "Mac";
}
string getMacAddress()
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return "";
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return "";
    }
    
    if ((buf = (char*)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return "";
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return "";
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);

    char outbuff[512]={0};
    
    snprintf(outbuff, 512,"%02X:%02X:%02X:%02X:%02X:%02X",*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));

    
    free(buf);
    
    return outbuff;

}

