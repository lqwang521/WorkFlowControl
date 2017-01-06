//
//  Userdefault.m
//  Express
//
//  Created by admin on 15/6/16.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "HTMIABCUserdefault.h"

@implementation HTMIABCUserdefault

//用户ID
+ (NSString*)defaultLoadUserID{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"UserID"] ==  nil ? @"":[defaults objectForKey:@"UserID"];
}

+ (void)defaultSaveUserID:(NSString *)a{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:@"UserID"];
    [defaults synchronize];
}

//通讯录同步时间戳
+ (NSString *)defaultLoadAddressBookSynchronizationeventStamp{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"AddressBookSynchronizationeventStamp"]  ==  nil ? @"": [defaults objectForKey:@"AddressBookSynchronizationeventStamp"];
}
+ (void)defaultSaveAddressBookSynchronizationeventStamp:(NSString *)a{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:@"AddressBookSynchronizationeventStamp"];
    [defaults synchronize];
}

//通讯录文件地址
+ (NSString *)defaultLoadAddressBookPath{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"AddressBook"] ==  nil ? @"": [defaults objectForKey:@"AddressBook"];
}
+ (void)defaultSaveAddressBookPath:(NSString *)a{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:@"AddressBook"];
    [defaults synchronize];
}

//界面风格
+ (NSString *)defaultLoadViewStyle{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:@"fengge"] ==  nil ? @"": [defaults objectForKey:@"fengge"];
}
+ (void)defaultSaveViewStyle:(NSString *)a{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:@"fengge"];
    [defaults synchronize];
}



+ (NSString*)defaultLoadbug
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults] ;
    return [defaults objectForKey:@"bug"] ==  nil ? @"": [defaults objectForKey:@"bug"];
}

+ (void)defaultSavebug:(NSString *)a
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:a  forKey:@"bug"];
    [defaults synchronize];
}



@end
