//
//  HTMIWFCOAAttachEntity.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/4.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//



//附件

#import <Foundation/Foundation.h>

typedef void(^HTMIWFCOAAttachEntityBlock) (id response);
@interface HTMIWFCOAAttachEntity : NSObject


@property(nonatomic,copy)NSString *attachID;
@property(nonatomic,copy)NSString *attachTitle;
@property(nonatomic,copy)NSString *attachType;
@property(nonatomic,assign)NSInteger attachSize;
@property(nonatomic,assign)BOOL encrypt;
@property(nonatomic,copy)NSString *localPath;

+ (NSMutableArray *)requestAttachByDic:(NSDictionary *)dic;


@end
