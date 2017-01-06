//
// HTMIWFCOAMatterInfo.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.



//待办

#import <Foundation/Foundation.h>

#import "HTMIWFCAttentEntity.h"

@interface HTMIWFCOAMatterInfo : NSObject

@property (nonatomic, copy)NSString *DocID;    //ID
@property (nonatomic, copy)NSString *DocTitle; //标题
@property (nonatomic, copy)NSString *SendFrom; //用户名称
@property (nonatomic, copy)NSString *SendDate; //事件
@property (nonatomic, copy)NSString *DocType;  //类型
@property (nonatomic, copy)NSString *iconId; //图片
@property (nonatomic, copy)NSString *kind;

+ (HTMIWFCOAMatterInfo *)parserMyMatterInfoByResultDic:(NSDictionary *)dic;

+ (HTMIWFCAttentEntity *)parserMyAttentionByResultDic:(NSDictionary *)dic;

@end
