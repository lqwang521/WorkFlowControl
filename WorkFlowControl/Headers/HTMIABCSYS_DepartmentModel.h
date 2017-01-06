//
//  HTMIABCSYS_DepartmentModel.h
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMIABCChooseType.h"

/**
 *  部门
 */
@interface HTMIABCSYS_DepartmentModel : NSObject<NSCopying>


@property (nonatomic,copy) NSString *DepartmentCode;
@property (nonatomic,copy) NSString * ShortName;
@property (nonatomic,copy) NSString * FullName;
@property (nonatomic,copy) NSString * OrganiseType;
@property (nonatomic,copy) NSString * ParentDepartment;
@property (nonatomic,copy) NSString * PostCode;
@property (nonatomic,copy) NSString * Telephone;
@property (nonatomic,copy) NSString * Fax;
@property (nonatomic,copy) NSString * Address;
@property (nonatomic,copy) NSString * Remark;

@property (nonatomic,assign) int IsDelete;

@property (nonatomic,copy) NSString * CreatedBy;
@property (nonatomic,copy) NSString * CreatedDate;
@property (nonatomic,copy) NSString * ModifiedBy;
@property (nonatomic,copy) NSString * ModifiedDate;
@property (nonatomic,copy) NSString * UniversalPwd;
@property (nonatomic,copy) NSString * Pinyin;
@property (nonatomic,copy) NSString * OULabel;
@property (nonatomic,assign) int OULevel;
@property (nonatomic,copy) NSString * ADCode;
@property (nonatomic,copy) NSString * AppCode;
@property (nonatomic,copy) NSString * UniversalCode;
@property (nonatomic,assign) int IsVirtual;
@property (nonatomic,copy) NSString * IP;
@property (nonatomic,copy) NSString * Port;
@property (nonatomic,copy) NSString * ThirdDepartmentId;
@property (nonatomic,assign) int DisOrder;

@property (nonatomic,copy) NSString * PinYinQuanPin;

//wlq add 2016/16/04/20
@property (assign, nonatomic) BOOL isCheck;

/**
 *  选择类型
 */
@property (nonatomic,assign)ChooseType chooseType;

@end

