//
//  HTMIWFCSettingManager.m
//  MXClient
//
//  Created by wlq on 16/6/14.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCSettingManager.h"

#import "UIColor+HTMIWFCHex.h"

// 2.获得RGB颜色
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)

@implementation HTMIWFCSettingManager

// 返回单例
+ (instancetype)manager
{
    return [[super alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HTMIWFCSettingManager *_manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}


#pragma mark - Getters and Setters

- (UIColor *)defaultBackgroundColor{
    if (!_defaultBackgroundColor) {
        _defaultBackgroundColor = [UIColor whiteColor];
    }
    return _defaultBackgroundColor;
}

- (NSInteger)choosePageTagHight{
    
    if (!_choosePageTagHight) {
        _choosePageTagHight = 0;
    }
    return _choosePageTagHight;
}

- (BOOL)navigationBarIsLightColor{
    if (!_navigationBarIsLightColor) {
        _navigationBarIsLightColor = NO;
    }
    return _navigationBarIsLightColor;
}

- (BOOL)isNeedHideAddressBookPersonPhoneNumber{
    if (!_isNeedHideAddressBookPersonPhoneNumber) {
        _isNeedHideAddressBookPersonPhoneNumber = YES;
    }
    return _isNeedHideAddressBookPersonPhoneNumber;
}

- (UIColor *)blueColor{
    if (!_blueColor) {
        _blueColor = RGB(0, 122, 255);//蓝色
    }
    return _blueColor;
}

- (UIColor *)navigationBarColor{
    
    if (!_navigationBarColor) {
        
        _navigationBarColor = self.blueColor;//默认蓝色导航栏
    }
    return _navigationBarColor;
}

- (UIColor *)navigationBarTitleFontColor{
    if (!_navigationBarTitleFontColor) {
        
        if (self.navigationBarIsLightColor) {//如果是白色色调，导航栏字体颜色需要改成黑色
            _navigationBarTitleFontColor = RGB(67, 67, 67);
        }
        else{
            _navigationBarTitleFontColor = RGB(249, 249, 249);
        }
    }
    return _navigationBarTitleFontColor;
}


- (UIColor *)randomColor{
    
    ///取名字的32位md5最后一位  对应的  ASCII 十进制值 的末尾值 ( 0 - 9 ) 对应的颜色为底色
    NSInteger index = arc4random() % 10;//(NSInteger)[[string md5_32] characterAtIndex:31];
    //约定的颜色值
    NSString *colorHex = @"0DB8F6,00D3A3,FCD240,F26C13,EE523D,4C90FB,FFBF45,48A6DF,00B25E,EC606C";
    NSArray *colorHexArray = [colorHex componentsSeparatedByString:@","];
    //取到颜色值
    _randomColor = [UIColor colorFromHexCode:[colorHexArray objectAtIndex:index]];
    
    return _randomColor;
}

- (HeaderImageType)headerImageType{
    return HeaderImageTypeLastTwo;
}

- (UIColor *)segmentedControlBackgroundColor{
    
    if (!_segmentedControlBackgroundColor) {
        
        if (self.navigationBarIsLightColor) {//如果是白色色调
            _segmentedControlBackgroundColor = [UIColor whiteColor];
        }
        else{
            _segmentedControlBackgroundColor = self.navigationBarColor;
        }
        
    }
    return   _segmentedControlBackgroundColor;
}

- (UIColor *)segmentedControlTintColor{
    if (!_segmentedControlTintColor) {
        if (self.navigationBarIsLightColor) {//如果是白色色调
            _segmentedControlTintColor = self.blueColor;
        }
        else{
            _segmentedControlTintColor = [UIColor whiteColor];
        }
    }
    return   _segmentedControlTintColor;
}


@end
