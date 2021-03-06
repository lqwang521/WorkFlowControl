//
//  HTMIWFCSelectView.h
//  单选多选
//
//  Created by 赵志国 on 16/6/16.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTMIWFCSelectViewMultiSelectionBlock)(NSArray *array);
typedef void(^HTMIWFCSelectViewSingleSelectionBlock)(NSString *string);

typedef NS_ENUM(NSInteger, selectType) {
    SingleSelectionID = 0,
    SingleSelectionName,
    SingleSelectionValue,
    MultiSelectionID,
    MultiSelectionName,
    MultiSelectionValue,
};

@interface HTMIWFCSelectView : UIView

/**
 *  block 返回单选的字符串
 */
@property (nonatomic, copy) HTMIWFCSelectViewSingleSelectionBlock SingleSelectionBlock;

/**
 *  block 返回多选的数组
 */
@property (nonatomic, copy) HTMIWFCSelectViewMultiSelectionBlock MultiSelectionBlock;

/**
 *  单选还是多选
 */
@property (nonatomic, assign) selectType selectType;

/**
 *  idArray
 */
@property (nonatomic, strong) NSMutableArray *idArray;

/**
 *  nameArray
 */
@property (nonatomic, strong) NSMutableArray *nameArray;

/**
 *  valueArray
 */
@property (nonatomic, strong) NSMutableArray *valueArray;

- (instancetype)initWithFrame:(CGRect)frame dicsArray:(NSArray *)dicsArray selectType:(selectType)selectType isMustInput:(BOOL)isMustInput value:(NSString *)valueString;

@end
