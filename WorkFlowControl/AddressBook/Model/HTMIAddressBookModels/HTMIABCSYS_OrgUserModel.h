//
//  HTMIABCSYS_OrgUserModel.h
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  人员部门关系
 */
@interface HTMIABCSYS_OrgUserModel : NSObject

@property (nonatomic,copy) NSString *UserId;
@property (nonatomic,assign) int ID;
@property (nonatomic,copy) NSString * DepartmentCode;
@property (nonatomic,copy) NSString * CreatedBy;
@property (nonatomic,copy) NSString * CreatedDate;

@property (nonatomic,assign) int DisOrder;

@end
