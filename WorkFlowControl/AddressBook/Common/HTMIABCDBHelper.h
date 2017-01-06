//
//  YMDBHelper.h
//  Pedometer
//
//  Created by ymsc on 15/8/11.
//  Copyright (c) 2015年 ymsc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMIWFCFMDB.h"

@class HTMIABCSYS_DepartmentModel;

@class HTMIABCSYS_UserModel;

@interface HTMIABCDBHelper : NSObject

@property(nonatomic,strong) HTMIWFCFMDatabaseQueue *queue;

/**
 *  用来标志是否正在同步数据库
 */
@property(nonatomic,assign) BOOL isSyncDBing;


/**
 *  程序启动同步通讯录
 */
- (void)syncAddressBook;


#pragma mark --对整个数据库操作
/**
 *  创建数据库以及表
 *
 *  @return 是否成功
 */
- (void)creatDatabaseAndTables;


/**
 *  同步数据库
 *
 *  @return 同步结果
 */
- (NSString *)syncDB;

#pragma mark -




#pragma mark --部门表操作

/**
 *  获取部门表中的根节点
 *
 *  @return 部门模型
 */
- (HTMIABCSYS_DepartmentModel *)getRootDepartment;


/**
 *  获取部门和用户（排序后的）
 *
 *  @param DepartmentCode 部门
 *
 *  @return 部门和用户集合
 */
- (NSMutableArray *)getDepartmentAndUsers:(NSString *)DepartmentCode;


/**
 *  根据部门的code获取部门
 *
 *  @param DepartmentCode 部门code
 *
 *  @return 部门模型
 */
- (HTMIABCSYS_DepartmentModel *)getDepartmentByDepartmentCode:(NSString *)DepartmentCode;

/**
 *  通过搜索拼音获取部门
 *
 *  @param searchString 搜索条件
 *
 *  @return 部门数组
 */
- (NSMutableArray *)getDepartmentBySearchString:(NSString *)searchString inDepartment:(NSString *)departmentCode;


/**
 *  获取部门下的一级子部门
 *
 *  @param DepartmentCode 部门节点
 *
 *  @return 部门数组
 */
- (NSMutableArray *)getDepartments:(NSString *)DepartmentCode;




#pragma mark --常用联系人表操作（T_UserRelationship）
/**
 *  获取常用联系人
 *
 *  @return 常用联系人数组
 */
- (NSMutableArray *)getContactList;

#pragma mark --用户属性表表操作（TD_User）

/**
 *  获取人员属性配置数据集合
 *
 *  @return 员属性配置数据集合
 */
- (NSMutableArray *)getTD_Users;

#pragma mark --用户表操作

/**
 *  检索部门下的用户
 *
 *  @param strSearchString   检索字符串
 *  @param strDepartmentCode 部门code
 *
 *  @return 用户集合
 */
- (NSMutableArray *)searchUsersBySearchString:(NSString *)strSearchString inDepartment:(NSString *)strDepartmentCode;


#pragma mark --删除常用联系人

/**
 *  删除常用联系人
 *
 *  @param userId 用户id
 */
- (void)deleteUser:(NSString * )userId;


#pragma mark --当前用户信息的修改

/**
 *  获取当前用户详细信息
 *
 *  @param userId 用户Id
 *
 *  @return 用户信息
 */
-(HTMIABCSYS_UserModel *)getCurrentUserInfo:(NSString *)userId;

/**
 *  更新当前用户信息
 *
 *  @param model 用户信息模型
 */
- (void)UpdateCurrentUserInfo:(HTMIABCSYS_UserModel *)model;

/**
 *  通过字段名称更新数据库
 *
 *  @param userId    用户id
 *  @param fieldNameLower 字段名小写的
 *  @param value     值
 */
- (void)UpdateCurrentUserInfoByUserId:(NSString *)userId fieldNameLower:(NSString *)fieldNameLower value:(NSString *)value;

/**
 *  获取指定部门下人员的数量
 *
 *  @param departemntCode 部门id
 *
 *  @return 部门下人员数量
 */
- (NSString *)getUserCountByDepartemntCode:(NSString *)departemntCode;

/**
 *  判断部门下是否有部门
 *
 *  @param departmentCode 部门code
 *
 *  @return 是否存在
 */
- (BOOL)existDepartmentInDepartment:(NSString *)departmentCode;

/**
 *  判断部门下是否有人员
 *
 *  @param departmentCode 部门code
 *
 *  @return 是否存在
 */
- (BOOL)existUserInDepartment:(NSString *)departmentCode;

#pragma mark --属性

@property (nonatomic,assign)BOOL isSyncAddressBook;

/**
 *  保存同步时间戳
 */
@property (nonatomic,copy)NSString *synchronizationeventStamp;

#pragma mark --单例

//HTMIWFCHMSingletonH(YMDBHelperTool)
+ (instancetype)sharedYMDBHelperTool;

@end
