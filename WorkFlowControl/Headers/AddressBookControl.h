//
//  AddressBookControl.h
//  AddressBookControl
//
//  Created by wlq on 16/10/8.
//  Copyright © 2016年 htmitech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "HTMIABCHeaderImageType.h"

#import "HTMIABCEMIManager.h"

#import "HTMIABCChooseType.h"

#import "HTMIABCSYS_UserModel.h"

#import "HTMIABCSYS_DepartmentModel.h"

#import "HTMIABCChooseFormAddressBookViewController.h"

@interface AddressBookControl : NSObject{
    
    
    
}

/**
 初始化并同步通讯录数据库
 */
+ (void)syncAddressBook;

/**
 登录EMM

 @param UserId    用户名
 @param password  密码
 @param EMMUrl    EMM接口地址
 @param PORT      端口
 @param EMMapiDir 访问路径
 @param SoftWare  软件编码
 @param succeed   成功回调
 @param failure   失败回调
 */
+ (void)LoginEMMWithUserId:(NSString *)UserId passWord:(NSString *)password emmUrl:(NSString *)EMMUrl port:(NSString *)PORT emmapiDir:(NSString *)EMMapiDir softWare:(NSString *)SoftWare succeed:(void (^)())succeed failure:(void (^)(NSError *))failure;

/**
 获取个人信息ViewController

 @return 获取个人信息VC
 */
+(UIViewController *)getPersonalInformationViewController;


/**
 获取通讯录ViewController

 @return 获取通讯录VC
 */
+(UIViewController *)getMainAddressBookViewController;

/**
 设置是否隐藏通讯录手机号码的中间4位 默认：隐藏

 @param isHiden 是否隐藏
 */
+ (void)setAddressBookHideInTheMiddleOfPhoneNumber:(BOOL)isHiden;

/**
 设置通讯了头像风格 无网络头像，默认显示姓名后两位

 @param headerImageType 通讯了头像风格
 */
+ (void)setHeaderImageType:(HeaderImageType)headerImageType;

/**
 设置导航栏是否是浅色 默认不是浅色

 @param isLightColor 导航栏是否是浅色
 */
+ (void)setNavigationBarIsLightColor:(BOOL)isLightColor;

/**
 设置导航栏颜色

 @param navigationBarColor 导航栏颜色
 */
+ (void)setNavigationBarColor:(UIColor *)navigationBarColor;

/**
 设置按钮颜色

 @param buttonTintColor 按钮颜色(例如导航栏按钮上的颜色)
 */
+ (void)setButtonTintColor:(UIColor *)buttonTintColor;


@end
