//
//  HTMIWFCOATableItemsEntity.h
//  MXClient
//
//  Created by 赵志国 on 16/4/22.
//  Copyright (c) 2016年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIWFCOATableItemsEntity : NSObject

@property(nonatomic,copy)NSString *tabID;
@property(nonatomic,copy)NSString *tableName;
@property(nonatomic,copy)NSString *flowID;
@property(nonatomic,assign)NSInteger tableType;//1的时候才显示表单
@property(nonatomic,strong)NSArray *regionsArray;

@property (nonatomic, strong) NSMutableArray *childFormArray;
@property (nonatomic, strong) NSMutableArray *childFormRegionArray;

@end
