//
//  HTMIWFCOAMatterFlowListService.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMIWFCOAMatterFlowListEntity.h"

@interface HTMIWFCOAMatterFlowListService : NSObject

+ (NSMutableArray *)parserMatterFlowListByDictionary:(NSDictionary *)dic;

@end
