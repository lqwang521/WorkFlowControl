//
//  HTMIABCSYS_UserModel.h
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <objc/runtime.h>

#import "HTMIABCSYS_DepartmentModel.h"
#import "HTMIABCTD_UserModel.h"
#import "HTMIABCTD_UserFieldSecretModel.h"

#import "HTMIABCChooseType.h"

/**
 *  人员
 */
@interface HTMIABCSYS_UserModel : NSObject<NSCopying>

//wlq add 用于部门节点下人员排序
@property (nonatomic,assign) int DisOrder;

@property (nonatomic,copy) NSString * UserId;
@property (nonatomic,copy) NSString * Password;
@property (nonatomic,copy) NSString * PasswordKey;
@property (nonatomic,copy) NSString * PasswordIV;
@property (nonatomic,copy) NSString * FullName;
//public short Gender = 0;
@property (nonatomic,assign) int Gender;

@property (nonatomic,copy) NSString * ISDN;
@property (nonatomic,copy) NSString * Email;
//public short Status;
@property (nonatomic,assign) int Status;
@property (nonatomic,copy) NSString * Telephone;
@property (nonatomic,copy) NSString * Fax;
@property (nonatomic,copy) NSString * Office;

//public Bitmap SignPics;
//public Bitmap Pics;
//public int UserType;
@property (nonatomic,copy)NSData * SignPics;
@property (nonatomic,copy)NSData * Pics;
@property (nonatomic,assign) int UserType;

@property (nonatomic,copy) NSString * PasswordLastChanged;
@property (nonatomic,copy) NSString * Mobile;
@property (nonatomic,copy) NSString * Position;
@property (nonatomic,copy) NSString * Photosurl;
@property (nonatomic,copy) NSString * RePasswordDate;
@property (nonatomic,copy) NSString * RePasswordKey;
@property (nonatomic,copy) NSString * CreatedBy;
@property (nonatomic,copy) NSString * CreatedDate;
@property (nonatomic,copy) NSString * ModifiedBy;
@property (nonatomic,copy) NSString * ModifiedDate;
@property (nonatomic,copy) NSString * PhotosurlAttchmentGuid;
@property (nonatomic,copy) NSString * ThirdUserId;
@property (nonatomic,copy) NSString * attribute1;
@property (nonatomic,copy) NSString * attribute2;
@property (nonatomic,copy) NSString * attribute3;
@property (nonatomic,copy) NSString * attribute4;
@property (nonatomic,copy) NSString * attribute5;

//public Short IsEMPUser;
//public Short IsEMIUser;
@property (nonatomic,assign) int IsEMPUser;
@property (nonatomic,assign) int IsEMIUser;

@property (nonatomic,copy) NSString * ext1;
@property (nonatomic,copy) NSString * ext2;
@property (nonatomic,copy) NSString * ext3;
@property (nonatomic,copy) NSString * ext4;
@property (nonatomic,copy) NSString * ext5;
@property (nonatomic,copy) NSString * ext6;
@property (nonatomic,copy) NSString * ext7;
@property (nonatomic,copy) NSString * ext8;
@property (nonatomic,copy) NSString * ext9;
@property (nonatomic,copy) NSString * ext10;
@property (nonatomic,copy) NSString * header;
@property (nonatomic,copy) NSString * suoXie;
@property (nonatomic,copy) NSString *pinyin;

/**
 *  存放用户信息字典，用来修改个人信息时动态配置
 */
@property (nonatomic,copy)NSMutableDictionary *userInfoDic;


//wlq add 2016/16/04/20
@property (assign, nonatomic) BOOL isCheck;

/**
 *  选择类型
 */
@property (nonatomic,assign)ChooseType chooseType;

/**
 *  默认头像背景色
 */
@property (nonatomic,copy)UIColor * headerBackGroundColor;

/**
 *  所在部门
 */
@property (nonatomic,copy) NSString *departmentCode;

- (NSArray *)allPropertyNames;

- (SEL)creatSetterWithPropertyName:(NSString *)propertyName;

- (void)assginToPropertyWithDictionary:(NSString *)propertyString value:(NSString *)valueString;
    
@end

