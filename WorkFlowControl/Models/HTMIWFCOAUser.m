//
//  OAUser.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/26.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAUser.h"

@implementation HTMIWFCOAUser

+ (HTMIWFCOAUser *)parserMyUserByDic:(NSDictionary *)dic
{
    HTMIWFCOAUser *user = [[HTMIWFCOAUser alloc]init];
    
    NSDictionary *dict = [dic objectForKey:@"Result"];
    
    NSMutableDictionary *dicMutable = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    for (id key in dict)
    {
        
        
        //wlq add 2016/04/20
        if ([dict objectForKey:key] && ![[dict objectForKey:key] isKindOfClass:[NSNull class]]) {
            
            [userdefaults setObject:[dict objectForKey:key] forKey:key];
            
            [dicMutable setObject: [dict objectForKey:key]
                           forKey:key];
            
        }
        else{
            [userdefaults setObject:@"" forKey:key];
        }
    }
    
    user.userID = [dicMutable objectForKey:@"UserID"];
    
    if ([user.userID isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"UserID"])
        {
            [dicMutable removeObjectForKey:@"UserID"];
        }
        
    }else{
        [userdefaults setObject:user.userID forKey:@"kOA_userIDString"];
    }
    
    
    user.oa_userID = [dicMutable objectForKey:@"OA_UserId"];
    
    if ([user.oa_userID isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"OA_UserId"])
        {
            [dicMutable removeObjectForKey:@"OA_UserId"];
        }
        
    }else{
        [userdefaults setObject:user.oa_userID forKey:@"kOA_userIDStringAAAA"];
    }
    
    user.oa_unitId = [dicMutable objectForKey:@"OA_UnitId"];

    if ([user.oa_unitId isKindOfClass:[NSNull class]] ) {
        
        if([[dicMutable allKeys] containsObject:@"OA_UnitId"])
        {
            [dicMutable removeObjectForKey:@"OA_UnitId"];
        }
        
        
    }
    
    user.thirdDepartmentId = [dict objectForKey:@"ThirdDepartmentId"];
    if ([user.thirdDepartmentId isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"ThirdDepartmentId"])
        {
            [dicMutable removeObjectForKey:@"ThirdDepartmentId"];
        }
        
    }
    user.thirdDepartmentName = [dict objectForKey:@"ThirdDepartmentName"];
    
    if ([user.thirdDepartmentName isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"ThirdDepartmentName"])
        {
            [dicMutable removeObjectForKey:@"ThirdDepartmentName"];
        }
    }
    
    user.attribute1 = [dict objectForKey:@"attribute1"];
    
    if ([user.attribute1 isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"attribute1"])
        {
            [dicMutable removeObjectForKey:@"attribute1"];
        }
    }
    
    user.MRS_UserId = [dict objectForKey:@"MRS_UserId"];
    if ([user.MRS_UserId isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"MRS_UserId"])
        {
            [dicMutable removeObjectForKey:@"MRS_UserId"];
        }
    }else{
        [userdefaults setObject:user.MRS_UserId forKey:@"kOA_MRS_UserId"];
    }
    
    user.userName = [dicMutable objectForKey:@"UserName"];
    if ([user.userName isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"UserName"])
        {
            [dicMutable removeObjectForKey:@"UserName"];
        }
        
    }else{
        [userdefaults setObject:user.userName forKey:@"kUserNameNSString"];
    }
    user.oa_userName = [dicMutable objectForKey:@"OA_UserName"];
    
    if ([user.oa_userName isKindOfClass:[NSNull class]]) {
        
        if([[dicMutable allKeys] containsObject:@"OA_UserName"])
        {
            [dicMutable removeObjectForKey:@"OA_UserName"];
        }
        
    }else{
        [userdefaults setObject:user.oa_userName forKey:@"kOA_UserNameString"];
    }
    
    
    [userdefaults setObject:dicMutable forKey:@"kContextDictionary"];
    
    return user;
}

- (id)initWithUserID:(NSString *)userID andEserName:(NSString *)userName andOAUserID:(NSString *)oaUserID andOAUserName:(NSString *)oaUserName
{
    self = [super init];
    if (self)
    {
        self.userID = userID;
        self.userName = userName;
        self.oa_userID = oaUserID;
        self.oa_userName = oaUserName;
    }
    return self;
}

@end
