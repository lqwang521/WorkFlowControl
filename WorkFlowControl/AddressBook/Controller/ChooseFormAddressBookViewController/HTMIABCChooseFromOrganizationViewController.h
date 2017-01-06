//
//  HTMIABCChooseFormAddressBookViewController.h
//  MXClient
//
//  Created by wlq on 16/4/19.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"
#import "HTMIABCChooseType.h"

#import "HTMIABCChooseFormAddressBookViewController.h"

@interface HTMIABCChooseFromOrganizationViewController : HTMIWFCBaseViewController

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
                     specificArray:(NSArray *)specificArray;

@property (nonatomic, copy) ResultBlock resultBlock;

@property (nonatomic,weak) HTMIABCChooseFormAddressBookViewController *myParentViewController;


@end
