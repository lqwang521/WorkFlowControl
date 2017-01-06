//
//  HTMIWFCSettingManager.h
//  MXClient
//
//  Created by wlq on 16/6/14.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//#import "HTMIABCHeaderImageType.h"
#import "HTMIABCHeaderImageType.h"

@interface HTMIWFCSettingManager : NSObject

+ (instancetype)manager;


/**
 *  通讯录是否需要隐藏中间的号码（例如152****7410）
 */
@property (nonatomic, assign) BOOL isNeedHideAddressBookPersonPhoneNumber;

/**
 *  导航栏颜色为白色或者浅色
 */
@property (nonatomic, assign) BOOL navigationBarIsLightColor;

/**
 *  蓝色
 */
@property (nonatomic, copy) UIColor *blueColor;

/**
 *  导航栏颜色
 */
@property (nonatomic, copy) UIColor *navigationBarColor;

/**
 *  导航栏字体颜色
 */
@property (nonatomic, copy) UIColor *navigationBarTitleFontColor;

/**
 *  选项卡控件背景色
 */
@property (nonatomic, copy) UIColor *segmentedControlBackgroundColor;

/**
 *  选项卡控件色调
 */
@property (nonatomic, copy) UIColor *segmentedControlTintColor;

/**
 *  选择页面页签的高度
 */
@property (nonatomic, assign)NSInteger choosePageTagHight;

/**
 *  页面背景色
 */
@property (nonatomic, copy) UIColor *defaultBackgroundColor;

/**
 *  随机色 (从固定的几个颜色中随机)
 */
@property (nonatomic, copy) UIColor *randomColor;

/** 通讯录默认头像风格*/
@property (nonatomic, assign)HeaderImageType headerImageType;

@end
