//
//  CompanyAddressBookViewController.h
//  AddressBook
//
//  Created by wlq on 16/4/4.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@class HTMIABCSYS_DepartmentModel;

@interface HTMIABCCompanyAddressBookViewController : HTMIWFCBaseViewController

/**
 *  部门模型
 */
@property (nonatomic,strong)HTMIABCSYS_DepartmentModel *departmentModel;

@end
