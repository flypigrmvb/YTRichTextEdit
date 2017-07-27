//
//  UtilMacro.h
//  MobileExperience
//
//  Created by Liyu on 15/7/16.
//  Copyright (c) 2015年 NetDragon. All rights reserved.
//

#ifndef MobileExperience_UtilMacro_h
#define MobileExperience_UtilMacro_h

#import <dlfcn.h>
#import <sys/types.h>

#define kScreenHeight           [UIScreen mainScreen].bounds.size.height    //获取屏幕高度
#define kScreenWidth            [UIScreen mainScreen].bounds.size.width     //获取屏幕宽度
#define _(x)                    NSLocalizedString(x, @"")


#define CACHE_PATH              [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]


/**
 *  定义单例
 *
 *  @param
 *  使用方法:在.h文件中声明单例，使用AS_SINGLETON  在.m文件中定义单例，使用DEF_SINGLETON
 *  调用方法：使用[单例名称 sharedInstance]
 *
 */
#undef	AS_SINGLETON
#define AS_SINGLETON \
+ (instancetype)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON \
+ (instancetype)sharedInstance{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
} \


#define convertLength(x)        x
#define convertFontSize(x)      x

//通用颜色宏定义
//参数格式为：FFFFFF
#define colorWithRGB(rgbValue)  colorWithRGBAndA(rgbValue, 1.0)

//参数格式为：FFFFFF, 1.0
#define colorWithRGBAndA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((0x##rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((0x##rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(0x##rgbValue & 0xFF)) / 255.0 alpha:alphaValue]
//参数格式为：FFFFFFFF
#define colorWithARGB(argbValue) \
[UIColor colorWithRed:((float)((0x##argbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((0x##argbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(0x##argbValue & 0xFF)) / 255.0 \
alpha:((float)((0x##argbValue & 0xFF000000) >> 24)) / 255.0]


// 颜色宏定义
#define SNColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define SNColorARGB(a,r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
// 随机色宏定义
#define SNRandomColor SNColorARGB(0.4, arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


#endif
