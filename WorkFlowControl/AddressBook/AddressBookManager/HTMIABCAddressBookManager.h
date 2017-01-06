//
//  HTMIAddressBookSingletonClass.h
//  MXClient
//
//  Created by wlq on 16/4/13.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMIABCSYS_DepartmentModel;
@class HTMIABCSYS_UserModel;

@interface HTMIABCAddressBookManager : NSObject

// 返回单例
+(instancetype)sharedInstance;

/**
 *  缓存人员显示结构数组
 */
@property (nonatomic,strong)NSMutableArray *tdUserModelArray;

/**
 *  缓存常用联系人
 */
@property (nonatomic,strong)NSMutableArray *topContactsArray;

/**
 *  当前用户模型
 */
@property (nonatomic,strong)HTMIABCSYS_UserModel *currentUserModel;

/**
 *  用来判断是否为保密字段
 *
 *  @param secretFlag            保密程度字段
 *  @param someOneDepartmentCode 部门code
 *
 *  @return 能否显示
 */
- (BOOL)canShowBySecretFlag:(short)secretFlag someOneDepartmentCode:(NSString *)someOneDepartmentCode;

@end
