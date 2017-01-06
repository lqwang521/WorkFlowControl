//
//  HTMIWFCOAMatterFlowListEntity.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

//流程

#import <Foundation/Foundation.h>

@interface HTMIWFCOAMatterFlowListEntity : NSObject

@property(nonatomic,copy)NSString *action;
@property(nonatomic,copy)NSString *actionTime;
@property(nonatomic,copy)NSString *stepName;
@property(nonatomic,assign)NSInteger stepOrder;
@property(nonatomic,copy)NSString *oaUserID;
@property(nonatomic,copy)NSString *userID;
@property (nonatomic, copy)NSString *OAUserName;
@property (nonatomic, copy)NSString *Comments;

@end
