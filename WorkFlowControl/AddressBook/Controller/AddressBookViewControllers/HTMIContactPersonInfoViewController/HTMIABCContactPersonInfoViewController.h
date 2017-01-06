//
//  HTMIABCContactPersonInfoViewController.h
//  AddressBook
//
//  Created by wlq on 16/4/10.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@class HTMIABCSYS_UserModel;

@interface HTMIABCContactPersonInfoViewController : HTMIWFCBaseViewController

/**
 *  用户信息模型
 */
@property (nonatomic,strong) HTMIABCSYS_UserModel * sys_UserModel;

@end
