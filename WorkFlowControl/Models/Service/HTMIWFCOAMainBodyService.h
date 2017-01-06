//
//  HTMIWFCOAMainBodyService.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "HTMIWFCOAMainBodyEntity.h"

#import "HTMIWFCOAInfoRegion.h"
#import "HTMIWFCOAMatterFormFieldItem.h"
#import "HTMIWFCOAAttachEntity.h"

#import "HTMIWFCOATableItemsEntity.h"

typedef void(^OAMainBodyBlock) (id obj,id detaile,id attachment,NSArray *segmentTitleArray, NSDictionary *maxWidthDic,NSError *error);


@interface HTMIWFCOAMainBodyService : NSObject


/**
 *  滑动子表
 */
@property (nonatomic, strong) NSMutableArray *sliderArray;

/**
 *  每个滑动子表的最大宽度数组
 */
@property (nonatomic, strong) NSMutableArray *eachMaxWidthArray;


/**
 *  所有滑动子表的最大宽度数组
 */
@property (nonatomic, strong) NSMutableDictionary *allMaxWidthDic;

/**
 *  滑动子表,是否加
 */
@property (nonatomic, assign) NSInteger index;


- (void)mainBodyWithContext:(NSDictionary *)context MatterID:(NSString *)matterID isFlowid:(BOOL)isFlowid andDocType:(NSString *)docType andKind:(NSString *)kind block:(OAMainBodyBlock)block;

- (void)myLeaveWithFlowID:(NSString *)flowID block:(OAMainBodyBlock)block;

@end
