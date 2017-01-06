//
//  HTMIABCChooseFormAddressBookViewController.h
//  MXClient
//
//  Created by wlq on 16/4/19.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIABCBaseViewController.h"

#import "HTMIABCChooseType.h"
@interface HTMIABCChooseFormAddressBookViewController : HTMIABCBaseViewController

typedef void (^ResultBlock)(NSArray *resultArray, NSArray *selectedRouteArray);



/**
 *  指定类型的初始化方法
 *
 *  @param chooseType        选择类型
 *  @param isSingleSelection 是否是单选
 *  @param specificArray     指定的人员或者部门数组
 *
 *  @return 类的实例
 */
- (instancetype)initWithChooseType:(ChooseType)chooseType isSingleSelection:(BOOL)isSingleSelection
                     specificArray:(NSArray *)specificArray isTree:(BOOL)isTree;

@property (nonatomic, copy) ResultBlock resultBlock;

/**
 *  是否是单选
 */
@property (nonatomic,assign)BOOL isSingleSelection;

/**
 *  选择类型
 */
@property (nonatomic,assign)ChooseType chooseType;

/**
 *  自定义标题
 */
@property (nonatomic, copy) NSString * titleString;

/**
 *  指定的人员或者部门集合
 */
@property (nonatomic,strong)NSMutableArray * specificArray;

/**
 *  以选择路径
 */
@property (nonatomic, strong) NSArray * selectedRouteArray;

- (NSMutableArray *)selectedDataSource;

@end
