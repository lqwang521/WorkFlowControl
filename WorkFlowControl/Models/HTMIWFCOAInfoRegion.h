//
//  HTMIWFCOAInfoRegion.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/2.
//  Copyright (c) 2015年 MXClient. All rights reserved.


//表单

#import <Foundation/Foundation.h>
#import "HTMIWFCOAMatterFormFieldItem.h"

@interface HTMIWFCOAInfoRegion : NSObject

@property (nonatomic, copy) NSString *regionID;
@property (nonatomic, assign) NSInteger displayOrder;
@property (nonatomic, assign) BOOL vlineVisible;
@property (nonatomic, strong) NSArray *feildItemList;
@property (nonatomic, assign) NSInteger backColor;
@property (nonatomic, assign) BOOL isTable;
@property (nonatomic, copy) NSString *tableID;
@property (nonatomic, copy) NSString *parentTableID;

/**
 *  新子表
 */
@property (nonatomic, assign) BOOL IsSplitRegion;
@property (nonatomic, assign) NSInteger SplitAction;
@property (nonatomic, copy) NSString *ParentRegionID;
/**
 *  滑动子表
 */
@property (nonatomic, assign) NSInteger ScrollFlag;
@property (nonatomic, assign) NSInteger ScrollFixColCount;

@property (nonatomic, assign) BOOL isOpen;

+ (NSMutableArray *)parserInforRegionBydic:(NSDictionary *)dic;

@end
