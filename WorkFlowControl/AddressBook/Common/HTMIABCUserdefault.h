//
//  Userdefault.h
//  Express
//
//  Created by admin on 15/6/16.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIABCUserdefault : NSObject

//用户ID
+(NSString*)defaultLoadUserID;
+(void)defaultSaveUserID:(NSString *)a;

//通讯里同步时间戳
+ (NSString *)defaultLoadAddressBookSynchronizationeventStamp;
+ (void)defaultSaveAddressBookSynchronizationeventStamp:(NSString *)a;

//通讯录文件地址
+ (NSString *)defaultLoadAddressBookPath;
+ (void)defaultSaveAddressBookPath:(NSString *)a;

//界面风格
+ (NSString *)defaultLoadViewStyle;
+ (void)defaultSaveViewStyle:(NSString *)a;

//报异常
+(NSString*)defaultLoadbug;
+(void)defaultSavebug:(NSString *)a;


@end
