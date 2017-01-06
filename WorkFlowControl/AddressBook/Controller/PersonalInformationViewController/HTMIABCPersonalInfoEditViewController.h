//
//  HTMIABCPersonalInfoEditViewController.h
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

//model
@class HTMIABCTD_UserModel;
@class HTMIABCSYS_UserModel;

@interface HTMIABCPersonalInfoEditViewController : HTMIWFCBaseViewController

/**
 *  用户属性字段配置模型
 */
@property (strong,nonatomic)HTMIABCTD_UserModel * td_UserModel;

/**
 *  用户信息模型
 */
@property (strong,nonatomic)HTMIABCSYS_UserModel * sys_UserModel;

@end
