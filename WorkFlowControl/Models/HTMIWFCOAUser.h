//
//  OAUser.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/26.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIWFCOAUser : NSObject

@property(nonatomic,copy)NSString *userID;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *oa_userID;
@property(nonatomic,copy)NSString *oa_userName;
@property(nonatomic,copy)NSString *MRS_UserId;
@property(nonatomic,copy)NSString *thirdDepartmentId;
@property(nonatomic,copy)NSString *thirdDepartmentName;
@property(nonatomic,copy)NSString *attribute1;
@property(nonatomic,copy)NSString *oa_unitId;

+ (HTMIWFCOAUser *)parserMyUserByDic:(NSDictionary *)dic;

- (id)initWithUserID:(NSString *)userID andEserName:(NSString *)userName andOAUserID:(NSString *)oaUserID andOAUserName:(NSString *)oaUserName;

@end
