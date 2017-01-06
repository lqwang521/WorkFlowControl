//
//  HTMIWFCOAAttachmentEntity.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/17.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMIWFCOAAttachmentListEntity.h"

@interface HTMIWFCOAAttachmentEntity : NSObject

@property(nonatomic,copy)NSString *isFinished;
@property(nonatomic,strong)NSDictionary *DocFileInfoResult;

@property (nonatomic, strong) HTMIWFCOAAttachmentListEntity *attachList;

@end
