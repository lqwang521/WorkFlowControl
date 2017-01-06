//
//  HTMIWFCAttentEntity.h
//  MXClient
//
//  Created by 赵志国 on 2016/9/27.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIWFCAttentEntity : NSObject

@property (nonatomic, assign) NSInteger idInteger;
@property (nonatomic, copy) NSString *UserId;
@property (nonatomic, copy)NSString *DocID;    //ID
@property (nonatomic, copy)NSString *DocTitle; //标题
@property (nonatomic, copy)NSString *SendFrom; //用户名称
@property (nonatomic, copy)NSString *SendDate; //事件
@property (nonatomic, copy)NSString *DocType;  //类型
@property (nonatomic, copy)NSString *iconId; //图片
@property (nonatomic,copy)NSString *kind;
/**
 * 是否已关注
 */
@property (nonatomic, copy) NSString *attentionFlag;
/**
 * 是否允许推送
 */
@property (nonatomic, copy) NSString *allowPush;

@end
