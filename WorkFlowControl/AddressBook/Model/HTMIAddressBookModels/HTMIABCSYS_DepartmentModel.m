//
//  HTMIABCSYS_DepartmentModel.m
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCSYS_DepartmentModel.h"

@implementation HTMIABCSYS_DepartmentModel

//重写初始化方法 设置选中状态为未选中
- (instancetype)init
{
    self = [super init];
    //默认单选用户
    if (self) {
        self.isCheck = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkStateChangeForUpdateiIsCheck:) name:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil];
        
    }
    return self;
}

- (void)checkStateChangeForUpdateiIsCheck:(NSNotification *)note{
    
    @try {
        
        if (note) {
            
            NSDictionary * checkStateDic = (NSDictionary *)note.userInfo;
            
            NSString *checkStateString = checkStateDic[@"checkState"];
            NSString *nodeIdString = checkStateDic[@"nodeId"];
            
            if ([self.DepartmentCode isEqualToString:nodeIdString]) {
                self.isCheck = [checkStateString boolValue];
            }
        }
        
    } @catch (NSException *exception) {
        //        [Bugly reportException:exception];
    } @finally {
        
    }
}

- (id)copyWithZone:(NSZone *)zone{
    
    HTMIABCSYS_DepartmentModel *copy = [[[self class] allocWithZone:zone] init];
    
    copy.DepartmentCode = [self.DepartmentCode copy];
    copy.ShortName = [self.ShortName copy];
    copy.FullName = [self.FullName copy];
    copy.OrganiseType = [self.OrganiseType copy];
    copy.ParentDepartment = [self.ParentDepartment copy];
    copy.ParentDepartment = [self.ParentDepartment copy];
    copy.PostCode = [self.PostCode copy];
    copy.Telephone = [self.Telephone copy];
    copy.Fax = [self.Fax copy];
    copy.Address = [self.Address copy];
    copy.Remark = [self.Remark copy];
    copy.IsDelete = self.IsDelete;
    copy.CreatedBy = [self.CreatedBy copy];
    copy.CreatedDate = [self.CreatedDate copy];
    copy.ModifiedBy = [self.ModifiedBy copy];
    copy.ModifiedDate = [self.ModifiedDate copy];
    copy.UniversalPwd = [self.UniversalPwd copy];
    copy.Pinyin = [self.Pinyin copy];
    copy.OULabel = [self.OULabel copy];
    copy.OULevel = self.OULevel;
    copy.ADCode = [self.ADCode copy];
    copy.AppCode = [self.AppCode copy];
    copy.UniversalCode = [self.UniversalCode copy];
    copy.IP = [self.IP copy];
    copy.Port = [self.Port copy];
    copy.ThirdDepartmentId = [self.ThirdDepartmentId copy];
    copy.DisOrder = self.DisOrder;
    
    //wlq add
    copy.PinYinQuanPin = [self.PinYinQuanPin copy];
    
    //wlq add 2016/16/04/20
    copy.isCheck = self.isCheck;
    
    //wlq add 2016/16/07/1
    copy.chooseType = self.chooseType;
    
    return copy;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
