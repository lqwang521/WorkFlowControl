//
//  HTMIAddressBookSingletonClass.m
//  MXClient
//
//  Created by wlq on 16/4/13.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCAddressBookManager.h"

#import "HTMIABCSYS_DepartmentModel.h"

#import "HTMIABCSYS_UserModel.h"

#import "HTMIABCDBHelper.h"

#import "HTMIABCUserdefault.h"

@implementation HTMIABCAddressBookManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HTMIABCAddressBookManager *_manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

// 返回单例
+(instancetype)sharedInstance
{
    return [[super alloc] init];
}

- (BOOL)canShowBySecretFlag:(short)secretFlag someOneDepartmentCode:(NSString *)someOneDepartmentCode{
    
    if (secretFlag == 0) {//公开
        return YES;
    }
    else if (secretFlag == 1) {//同级敏感
        
        NSString * currentUserDepartmentCodeString = self.currentUserModel.departmentCode;
        
        
        //可能是”我的“下级
        if (someOneDepartmentCode.length > currentUserDepartmentCodeString.length) {
            
            NSString * subCutString = [someOneDepartmentCode
                                       substringToIndex:currentUserDepartmentCodeString.length];
            
            if ([subCutString isEqualToString:currentUserDepartmentCodeString]) {//是我的下级我能看
                return YES;
            }
            else{
                //不是我的下级，是其他部门的下级
                return NO;
            }
            
        }
        else{
            
            //可能是”我的“同级
            if (someOneDepartmentCode.length == currentUserDepartmentCodeString.length) {
                
                if ([someOneDepartmentCode
                     isEqualToString:currentUserDepartmentCodeString]) {
                    //是同级
                    return NO;
                }
                else{
                    //只是部门code长度相同而已
                    return NO;
                }
            }
            else{
                //肯定是上级，不一定是”我的“直属上级
#warning 是所有上级都可以看，还是只有直属上级可以看，这个暂时不确定
                //只有我的直属上级可以看
                NSString * upCutString = [currentUserDepartmentCodeString
                                          substringToIndex:someOneDepartmentCode.length];
                
                if ([upCutString isEqualToString:someOneDepartmentCode] ) {
                    
                    return YES;
                }
                else{
                    return NO;
                }
            }
        }
    }
    else if (secretFlag == 2) {//下级敏感
        NSString * currentUserDepartmentCodeString = self.currentUserModel.departmentCode;
        
        //可能是”我的“下级
        if (someOneDepartmentCode.length > currentUserDepartmentCodeString.length) {
            
            NSString * subCutString = [someOneDepartmentCode
                                       substringToIndex:currentUserDepartmentCodeString.length];
            
            if ([subCutString isEqualToString:currentUserDepartmentCodeString]) {//是我的下级我能看
                return YES;
            }
            else{
                //不是我的下级，是其他部门的下级
                return NO;
            }
        }
        else{
            
            //可能是”我的“同级
            if (someOneDepartmentCode.length == currentUserDepartmentCodeString.length) {
                
                if ([someOneDepartmentCode
                     isEqualToString:currentUserDepartmentCodeString]) {
                    //是同级
                    return YES;
                    
                }
                else{
                    //只是部门code长度相同而已
                    return NO;
                }
            }
            else{
                //肯定是上级，不一定是”我的“直属上级
#warning 是所有上级都可以看，还是只有直属上级可以看，这个暂时不确定
                //只有我的直属上级可以看
                NSString * upCutString = [currentUserDepartmentCodeString
                                          substringToIndex:someOneDepartmentCode.length];
                
                if ([upCutString isEqualToString:someOneDepartmentCode] ) {
                    
                    return YES;
                }
                else{
                    return NO;
                }
            }
        }
        
    }
    else if (secretFlag == 3) {//保密，只有保密白名单中的人才可以看
#warning 没有白名单
        if (NO) {//需要判断是否在白名单中
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return YES;
    }
}

#pragma mark --Getters And Setters

-(NSMutableArray *)tdUserModelArray{
    
    if (!_tdUserModelArray) {
        _tdUserModelArray = [NSMutableArray array];
    }
    
    if (_tdUserModelArray.count <= 0) {
        _tdUserModelArray = [[HTMIABCDBHelper sharedYMDBHelperTool] getTD_Users];
    }
    
    return _tdUserModelArray;
}

-(NSMutableArray *)topContactsArray{
    
    if (!_topContactsArray) {
        _topContactsArray = [NSMutableArray array];
    }
    return _topContactsArray;
}

-(HTMIABCSYS_UserModel *)currentUserModel{
    if (!_currentUserModel) {
        _currentUserModel = [HTMIABCSYS_UserModel new];
        
        NSString * userIdString = [HTMIABCUserdefault defaultLoadUserID];
        //从数据库获取当前用户的信息
        _currentUserModel =  [[HTMIABCDBHelper sharedYMDBHelperTool] getCurrentUserInfo:userIdString];
        
    }
    return _currentUserModel;
}

@end
