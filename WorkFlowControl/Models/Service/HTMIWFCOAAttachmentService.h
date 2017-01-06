//
//  HTMIWFCOAAttachmentService.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/17.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMIWFCOAAttachmentEntity.h"

@interface HTMIWFCOAAttachmentService : NSObject

+ (HTMIWFCOAAttachmentEntity *)parserAttachmentByDictionary:(NSDictionary *)dic;

@end
