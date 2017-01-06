//
//  WorkFlowControl.m
//  WorkFlowControl
//
//  Created by wlq on 16/10/12.
//  Copyright © 2016年 htmitech. All rights reserved.
//

#import "WorkFlowControl.h"

//#import "HTMIABCDBHelper.h"
//#import "HTMIABCPersonalInformationViewController.h"
//#import "HTMIABCMainAddressBookViewController.h"

#import "HTMIWFCSettingManager.h"
#import "HTMIWFCOATodoAndDoneViewController.h"
#import "HTMIWFCSettingManager.h"

#import "AddressBookControl.h"

//#import "MXKit.h"
//#import "MXChat.h"
//#import "MXContacts.h"
//#import "MXCircle.h"
//#import "MXAppCenter.h"
//#import "MXError.h"

//
//  MXConfig.h
//  MXClient
//
//  Created by liyang on 14/11/17.
//  Copyright (c) 2014年 MXClient. All rights reserved.
//

#ifndef MXClient_MXConfig_h
#define MXClient_MXConfig_h
//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"EMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"PORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"EMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"SoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]

//禁用share extention
#define MX_DISABLE_SHARE_EXTENSION 1


#define BaseURL  [NSString stringWithFormat: @"%@%@/%@/api/", EMUrl, [EMPORT isEqualToString:@"80"] ? @"" : [NSString stringWithFormat:@":%@", EMPORT], EMapiDir]



////公司通讯录
#define CLIENT_SHOW_CONTACT_COMPANY 1
//隐藏功能号,显示得话可以去掉这个配置
#define CLIENT_HIDDEN_PUBLIC_ACCOUNT 1
//隐藏群聊，显示得话可以去掉这个配置
#define CLIENT_HIDDEN_MULTI_CHAT 1


//#define MX_PORT @"8086"
//#define MX_MQTT_URL @"114.112.89.94"
//#define MX_MQTT_PORT @"1883"
#define CLIENT_SHOW_EXT_NETWORK 1
#define CLIENT_SHOW_MAIL 0
#define CLIENT_SHOW_USER_TAB_BAR 1
#define CLIENT_SHOW_CONTACT_COMPANY 1

#define UMENG_CHANNEL  @""
#define UMENG_KEY  @"5487ca5bfd98c52bc2000f5d"
//                   55914e5e67e58ecdb2002589

//#define EXTEND_DAIL_NUM @"600"

#define MX_AV_URL @"www.minxing365.com"
#define MX_AV_PORT @"8906"
#define MX_ENABLE_VIDEO 1

#define MX_ENABLE_NETWORK_CHANGE 1

#define MX_ENABLE_RESET_PASSWORD 1

#define MX_ENABLE_WATERMASK 1

#define MX_CUSTOM_CLIENT_ID  @"1"

#define CLIENT_SHOW_EXT_NETWORK 1
#define CLIENT_SHOW_MAIL 0
#define CLIENT_SHOW_USER_TAB_BAR 1
#define CLIENT_SHOW_CONTACT_COMPANY 1
#define CLIENT_ENCRYPT_CELLPHONE 0
#define MX_ENABLE_PRODUCE 1
#define MX_ENABLE_WATERMASK 1

#define MX_SHARE_CIRCLE @"SHAREEXTENSION_CIRCLE"
#define MX_SHARE_CHAT @"SHAREEXTENSION_CHAT"
#define MX_SHARE_GORUPID @"group.com.htmitech.emportal"
#define MX_SHARE_REQUEST_HEADER @"MX_SHARE_REQUEST_HEADER"
#define MX_SHART_TOKEN @"MXSHARE_TOKEN"
#define MX_SHARE_CAHTARRAY @"MX_SHARE_CAHTARRAY"
#define MX_ENABLE_ADDRESS_MAIL 1

#define MX_DISABLE_SHARE_EXTENSION 1

#endif

//
//  MXConst.h
//  MXClient
//
//  Created by liyang on 14/11/6.
//  Copyright (c) 2014年 MXClient. All rights reserved.
//

#ifndef MXClient_MXConst_h
#define MXClient_MXConst_h

typedef enum {
    MESSAGE_TYPE_TEXT,//文本
    MESSAGE_TYPE_TASK,//待办
    MESSAGE_TYPE_ACTIVITY,//活动
    MESSAGE_TYPE_POLL,//投票
    MESSAGE_TYPE_QUESTION,//问题
    MESSAGE_TYPE_ANNOUNCE,//公告
    MESSAGE_TYPE_THIRDPART//三方应用
} MESSAGE_TYPE;

//设配型号
typedef NS_ENUM(NSInteger, TypeIphone) {
    
    TypeIphone5AndBelow = 0,
    TypeIphone6 =1,//iphone6 普通模式
    TypeIphone6Magnify = 2,
    TypeIphone6Plus = 3,// 6puls
    TypeIphone6PlusMagnify = 4
};

//typedef void(^finishCallback)(id object, MXError *error);
//typedef BOOL(^handleNativeCallback)(id object, MXError *error);
//typedef BOOL(^handleLogoutCallback)(id object, MXError *error);

#define kGesturePassCodeSwitch          @"kGesturePassCodeSwitch"
#define NO_NET_WORK [Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable
////蓝色
//#define navBarColor [UIColor colorWithRed:26.0/255.0 green:133.0/255.0 blue:255.0/255.0 alpha:1.0];
//绿色   导航栏颜色
//#define navBarColor [UIColor colorWithRed:81.0/255.0 green:195.0/255.0 blue:39.0/255.0 alpha:1.0];

//获取系统版本
#define deviceVersion  [[[UIDevice currentDevice] systemVersion] floatValue]
#define GetLocalResStr(key) NSLocalizedStringFromTable(key, @"MXStrings", key)
#define ColorWithRGB(R, G, B, Alpha) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:Alpha]
#define appWidth  [UIScreen mainScreen].bounds.size.width
#define appHeight  [UIScreen mainScreen].bounds.size.height
#define appFrame    [UIScreen mainScreen].bounds

#define kIPhoneType  ([UIScreen mainScreen].bounds.size.width < 375 ? 0 : [UIScreen mainScreen].scale < 3 ? 1: ([UIScreen mainScreen].bounds.size.width == 375 ? 4 : 3))

#endif



@implementation WorkFlowControl

+ (void)syncAddressBook{
    [AddressBookControl syncAddressBook];
}

+ (void)LoginEMMWithUserId:(NSString *)UserId passWord:(NSString *)password emmUrl:(NSString *)EMMUrl port:(NSString *)PORT emmapiDir:(NSString *)EMMapiDir softWare:(NSString *)SoftWare succeed:(void (^)())succeed failure:(void (^)(NSError *))failure{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setObject:EMMUrl forKey:@"HTMIWFCEMMUrl"];
    [user setObject:PORT forKey:@"HTMIWFCPORT"];
    [user setObject:EMMapiDir forKey:@"HTMIWFCEMapiDir"];
    [user setObject:SoftWare forKey:@"HTMIWFCSoftWare"];
    
    [HTMIWFCOATodoAndDoneViewController loginEMM:UserId password:password succeed:^(NSString * data) {
        
        if ([data isEqualToString:@"Success"]) {
            
            [self syncAddressBook];
            
            succeed();
            
        }else{
            NSLog(@"EMM登录失败");
        }
        
    } failure:^(NSError * error) {
        failure(error);
    }];
}

+(UIViewController *)getPersonalInformationViewController
{
    return  [AddressBookControl getPersonalInformationViewController];
}

+(UIViewController *)getOATodoAndDoneViewController
{
    HTMIWFCOATodoAndDoneViewController * vc = [[HTMIWFCOATodoAndDoneViewController alloc]init];
    return vc;
}

+(UIViewController *)getMainAddressBookViewController
{
    return [AddressBookControl getMainAddressBookViewController];
}

//设置是否隐藏通讯录手机号码的中间4位
+ (void)setAddressBookHideInTheMiddleOfPhoneNumber:(BOOL)isHiden
{
    [HTMIWFCSettingManager manager].isNeedHideAddressBookPersonPhoneNumber = isHiden;
    [AddressBookControl setAddressBookHideInTheMiddleOfPhoneNumber:isHiden];
}

//设置通讯了头像风格
+ (void)setHeaderImageType:(HeaderImageType)headerImageType
{
    [HTMIWFCSettingManager manager].headerImageType = headerImageType;
    [AddressBookControl setHeaderImageType:headerImageType];
}

//设置导航栏是否是浅色
+ (void)setNavigationBarIsLightColor:(BOOL)isLightColor{
    
    [HTMIWFCSettingManager manager].navigationBarIsLightColor = isLightColor;
    [AddressBookControl setNavigationBarIsLightColor:isLightColor];
}

//设置导航栏颜色
+ (void)setNavigationBarColor:(UIColor *)navigationBarColor{
    
    [HTMIWFCSettingManager manager].navigationBarColor = navigationBarColor;
    [AddressBookControl setNavigationBarColor:navigationBarColor];
}

//设置按钮颜色
+ (void)setButtonTintColor:(UIColor *)buttonTintColor{
    [HTMIWFCSettingManager manager].blueColor = buttonTintColor;
    [AddressBookControl setNavigationBarColor:buttonTintColor];
}


////初始化即时通讯
//+ (void)initEMI
//{
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//
//    [user setObject:@"http://115.28.200.252" forKey:@"MX_URL"];
//    [user setObject:@"80" forKey:@"MX_PORT"];
//    [user setObject:@"115.28.200.252" forKey:@"MX_MQTT_URL"];
//    [user setObject:@"1883" forKey:@"MX_MQTT_PORT"];
//
//    MXKit *MXObj = [MXKit shareMXKit];
//    
//    //wlq update start 修改敏行导航栏按钮和标题样式并且适配色调
//    
//    //[MXObj setTitleBarAttribute:HTMINavigationBarTitleFont];
//    
//    UIColor * fontColor = [UIColor whiteColor];
//    
//    //    if ([kApplicationHue isEqualToString:@"_white"]) {//如果是白色色调
//    //        fontColor = kApplicationHueBlueColor;
//    //    }
//    //    else{
//    //        fontColor = [UIColor whiteColor];
//    //    }
//    
//    [MXObj setItemBarAttribute:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName :[UIFont systemFontOfSize:14]}];
//    
//    //wlq update end
//    
//    [MXObj setWindowToMXKit:[UIApplication sharedApplication].keyWindow];//self.window
//    [MXObj handleUpgrade:^(id result, MXError *error) {
//        [MXObj initMinyou:CLIENT_SHOW_MAIL];
//        [MXObj initUserTabBar:CLIENT_SHOW_USER_TAB_BAR];
//        [MXObj initBaseColor:[HTMIWFCSettingManager manager].navigationBarColor];
//#ifdef CLIENT_ENCRYPT_CELLPHONE
//        [MXObj initEncryptCellphonePatten:CLIENT_ENCRYPT_CELLPHONE];
//#endif
//        
//#ifdef MX_CUSTOM_CLIENT_ID
//        [MXObj initCustomClientID:MX_CUSTOM_CLIENT_ID];
//#endif
//        
//#ifdef MX_ENABLE_WATERMASK
//        [MXObj initWarterMask:MX_ENABLE_WATERMASK];
//#endif
//        
//#ifdef CLIENT_HIDDEN_PUBLIC_ACCOUNT
//        [MXObj initHidePublicAccount:CLIENT_HIDDEN_PUBLIC_ACCOUNT];
//#endif
//        
//#ifdef CLIENT_HIDDEN_MULTI_CHAT
//        [MXObj initHideMultiChat:CLIENT_HIDDEN_MULTI_CHAT];
//#endif
//        
//#ifdef MX_ENABLE_ADDRESS_MAIL
//        [MXObj initEnableAddressEmail:MX_ENABLE_ADDRESS_MAIL];
//#endif
//        
//#ifdef MX_DISABLE_APPCENTERDRAWLINE
//        [MXObj initEnableDrawLine:MX_DISABLE_APPCENTERDRAWLINE];
//#endif
//        
//#ifdef MX_DISABLE_DOWNLOAD
//        [MXObj initDisableDownload:MX_DISABLE_DOWNLOAD];
//#endif
//        //浏览器分享菜单的相关颜色
//        [MXObj initSepeartorColor:ColorWithRGB(88, 166, 255, 1)];
//        [MXObj initSelectedColor:ColorWithRGB(40, 104, 182, 1)];
//        [MXObj initDisableCompanyContact:CLIENT_SHOW_CONTACT_COMPANY];
//        
//#ifdef MX_DISABLE_EMAIL_CONVERSATION
//        [MXObj initDisableEmailConversation:MX_DISABLE_EMAIL_CONVERSATION];
//#endif
//        
//#ifdef MX_DISABLE_SHARE_EXTENSION
//        [MXObj initDisableShareExtension:MX_DISABLE_SHARE_EXTENSION];
//#endif
//        
//#ifdef MX_DISABLE_MXMAIL
//        [MXObj initDisableMXMail:MX_DISABLE_MXMAIL];
//#endif
//        
//#ifdef MX_HIDE_CIRCLE_CREATION
//        [MXObj initHideCircleCreation:MX_HIDE_CIRCLE_CREATION];
//#endif
//        
//#ifdef MX_GET_EMAIL_INTERVAL
//        //        [MXObj initEmailInterval:MX_GET_EMAIL_INTERVAL];
//#endif
//        //        if(_serverURL) {
//        //            [MXObj init:_serverURL withPort:_port withMqttUrl:_mqttURL withMqttPort:_mqttPort];
//        //        } else {
//        [MXObj init:MX_URL withPort:MX_PORT withMqttUrl:MX_MQTT_URL withMqttPort:MX_MQTT_PORT];
//        //        }
//#ifdef EXTEND_DAIL_NUM
//        [MXObj initExtendDailNumber:EXTEND_DAIL_NUM];
//#endif
//        
//#ifdef MX_ENABLE_NETWORK_CHANGE
//        [[MXAppCenter sharedInstance] setSwitchNetworkInAppCenter:MX_ENABLE_NETWORK_CHANGE];
//#endif
//        
//#ifdef MX_ENABLE_APP_CENTER_ADD_BUTTON
//        [[MXAppCenter sharedInstance] initEnableAppCenterAddButton:MX_ENABLE_APP_CENTER_ADD_BUTTON];
//#endif
//        
//        [MXObj registForceLoginCallback:^(id result, MXError *error) {
//            if(result && !error)
//            {
//                //                [SVProgressHUD dismiss];
//                //                [self showMain];
//            }
//            else
//            {
//                //                //show error
//                //                NSLog(@"login minxing error, error === %@", error.description);
//                //                [SVProgressHUD dismiss];
//                //                if ([error.description isEqualToString:@"(null)"] ||
//                //                    [error.description isEqualToString:@"null"]) {
//                //                    error.description = GetLocalResStr(@"mx_default_error");
//                //                }
//                //                [SVProgressHUD showErrorWithStatus:error.description];
//            }
//        }];
//        
//        [MXObj registTabSelectCallback:^(id result, MXError *error){
//            if(!error) {
//                NSNumber *index = (NSNumber *)result;
//                //                [self.tabBarController setSelectedIndex:index.intValue];
//            }
//        }];
//        
//        __weak typeof(self) weakSelf = self;
//        [MXObj registLogout:^(id result, MXError *error){
//            if (result && !error) {
//                
//                //                                self.chatNavC = nil;
//                //                                self.addressBookNavC = nil;
//                //                                self.todoNavC = nil;
//                //                                self.manageNavC = nil;
//                //
//                //                                self.addressbookVC = nil;
//                //                                //                todoView = nil;
//                //                                self.oaManageVC = nil;
//                //                                self.chatVC = nil;
//                
//                [[MXChat sharedInstance] cleanChatViewController];
//                [[MXCircle sharedInstance] cleanCircleViewController];
//                [[MXContacts sharedInstance] cleanContactsViewController];
//                [[MXAppCenter sharedInstance] cleanAppCenterViewController];
//                
//                //                                weakSelf.tabBarController.viewControllers = nil;
//                //
//                //                                MXLoginViewController *loginViewController = [[MXLoginViewController alloc] init];
//                //                                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//                //                                weakSelf.window.rootViewController = nav;
//                //                                [weakSelf.window makeKeyAndVisible];
//            }
//        }];
//        [MXObj updateUnreadCount:^(id result, MXError *error){
//            if (result && !error) {
//                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameChangeNetworkUnreadCount object:result];
//            }
//        }];
//        
//        [MXObj registPushServiceCallback:^(id result, MXError *error) {
//            //这里的推送收到的时候是一个非主线程的推送,如果用户需要更新UI，请自行切换到主线程
//            NSLog(@"receiver push from server==%@", result);
//#ifdef MX_ENABLE_VIDEO
//            //            [self registVideoPushService:result];
//#endif
//            
//            //敏行判断版本升级
//            //            NSArray *arr = [result JSONValue];
//            //            if(arr)
//            //            {
//            //                if([arr isKindOfClass:[NSDictionary class]])
//            //                {
//            //                    if([[(NSDictionary *)arr objectForKey:@"event"] isEqualToString:@"upgrade"])
//            //                    {
//            //                        NSString *version_code = [(NSDictionary *)arr objectForKey:@"version_code"];
//            //                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//            //                        NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
//            //                        if ([version_code doubleValue] > [minorVersion doubleValue])
//            //                        {
//            //                            self.isNew = YES;
//            //                        }
//            //                    }
//            //                }
//            //            }
//        }];
//        
//        //这里暂时这样初始化，以后会传入用户名和密码
//        [MXObj login:^(id result, MXError *error){
//            if (result &&!error) {
//                NSString *userName = [[MXKit shareMXKit] getMXUserDefaultValueForKey:@"user_name"];
//                if(userName) {
//                    NSNumber *passCodeNum = [[MXKit shareMXKit] getMXUserDefaultValueForKey:userName];
//                    NSData *data = [[MXKit shareMXKit] getMXUserDefaultBinaryValueForKey:@"gesturePassCode"];
//                    if(data) {
//                        NSDictionary *dic = nil;
//                        if([data isKindOfClass:[NSData class]]) {
//                            dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//                        } else {
//                            dic = (NSDictionary *)data;
//                        }
//                        BOOL enablePassCode = NO;
//                        if([dic isKindOfClass:[NSDictionary class]])
//                        {
//                            NSDictionary *me = [[MXKit shareMXKit] getCurrentUser];
//                            int account_id = [[me objectForKey:@"account_id"] intValue];
//                            if(dic &&([[dic objectForKey:@"userid"] intValue] == account_id))
//                            {
//                                enablePassCode = [[dic objectForKey:@"gesturePassCode"] boolValue];
//                            }
//                        }
//                        
//                        //                        self.isNeedShowGestureCode = NO;
//                        //                        if(passCodeNum && [passCodeNum intValue] > 0 && enablePassCode)
//                        //                        {
//                        //                            self.isNeedShowGestureCode = YES;
//                        //                        }
//                    }
//                    
//                    //                    if(self.isNeedShowGestureCode)
//                    //                    {
//                    //                        [self showGesturePassCode:YES andNavBarHidden:YES];
//                    //                    }
//                    //                    else
//                    //                    {
//                    //                        //有token进入主页面
//                    //                        [weakSelf showMain];
//                    //                    }
//                    //
//                    //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    //                        [weakSelf startVersionCheck:YES];
//                    //                    });
//                } else {
//                    //                    MXLoginViewController *loginViewController = [[MXLoginViewController alloc] init];
//                    //                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//                    //                    weakSelf.window.rootViewController = nav;
//                    //                    [weakSelf.window makeKeyAndVisible];
//                }
//            }
//            else if(!result)
//            {
//                //                //没有token，加载登陆页面
//                //                MXLoginViewController *loginViewController = [[MXLoginViewController alloc] init];
//                //                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//                //                weakSelf.window.rootViewController = nav;
//                //                [weakSelf.window makeKeyAndVisible];
//            }
//        }];
//    }];
//    
//    //    MXKit *MXObjqqqq = [MXKit shareMXKit];
//    //    [MXObjqqqq init:MX_URL withPort:MX_PORT withMqttUrl:MX_MQTT_URL withMqttPort:MX_MQTT_PORT];
//    //
//    //    if([@"wanglq" caseInsensitiveCompare:@"getconfig"] == NSOrderedSame)
//    //    {
//    
//    NSString *message = [NSString stringWithFormat:@"1.url==%@:%@\n2.im_url=%@\n3.im_port=%@", MX_URL,MX_PORT, MX_URL, MX_MQTT_PORT];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"配置信息" message:message delegate:self cancelButtonTitle:GetLocalResStr(@"mx_system_sure") otherButtonTitles:nil, nil];
//    [alert show];
//    //        return;
//    //    }
//    
//    [self registLoginCallback];
//    
//    [MXObj login:@"wanglq" withPassword:@"wlq1234"];
//    //    [[MXKit shareMXKit] setMXUserDefaultValue:@"wanglq" forKey:@"user_name"];
//}
//
//
///**
// *  敏行新版kit包需要
// */
//+ (void)registLoginCallback {
//    MXKit *MXObj = [MXKit shareMXKit];
//    [MXObj registLoginCallback:^(id result, MXError *error){
//        if(result && !error)
//        {
//            
//            //            [SVProgressHUD dismiss];
//            //            [self showMain];
//            //
//            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            //                [self startVersionCheck:YES];
//            //            });
//        }
//        else
//        {
//            //show error
//            NSLog(@"login minxing error, error === %@", error.description);
//            //            [SVProgressHUD dismiss];
//            //            if ([error.description isEqualToString:@"(null)"] ||
//            //                [error.description isEqualToString:@"null"]) {
//            //                error.description = GetLocalResStr(@"mx_default_error");
//            //            }
//            //            [SVProgressHUD showErrorWithStatus:error.description];
//        }
//    }];
//}


@end
