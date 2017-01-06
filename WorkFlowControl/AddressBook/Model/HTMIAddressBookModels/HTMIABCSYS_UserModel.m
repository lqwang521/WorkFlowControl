//
//  HTMIABCSYS_UserModel.m
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCSYS_UserModel.h"

@implementation HTMIABCSYS_UserModel

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
    
    NSDictionary * checkStateDic = (NSDictionary *)note.userInfo;
    NSString *checkStateString = checkStateDic[@"checkState"];
    NSString *nodeIdString = checkStateDic[@"nodeId"];
    
    if ([self.UserId isEqualToString:nodeIdString]) {
        self.isCheck = [checkStateString boolValue];
    }
}

- (id)copyWithZone:( NSZone *)zone{
    
    HTMIABCSYS_UserModel *copy = [[[self class] allocWithZone:zone] init];
    
    copy.FullName = [self.FullName copy];
    
    copy.DisOrder = self.DisOrder;
    
    copy.UserId = [self.UserId copy];
    copy.Password = [self.Password copy];
    copy.PasswordKey = [self.PasswordKey copy];
    copy.PasswordIV = [self.PasswordIV copy];
    
    copy.Gender = self.Gender;
    
    
    copy.ISDN = [self.ISDN copy];
    copy.Email = [self.Email copy];
    
    
    copy.Status = self.Status;
    copy.Telephone = [self.Telephone copy];
    copy.Fax = [self.Fax copy];
    copy.Office = [self.Office copy];
    
    copy.SignPics = [self.SignPics copy];
    copy.Pics = [self.Pics copy];
    copy.UserType = self.UserType;
    
    
    copy.PasswordLastChanged = [self.PasswordLastChanged copy];
    copy.Mobile = [self.Mobile copy];
    copy.Position = [self.Position copy];
    copy.Photosurl = [self.Photosurl copy];
    copy.RePasswordDate = [self.RePasswordDate copy];
    copy.RePasswordKey = [self.RePasswordKey copy];
    copy.CreatedBy = [self.CreatedBy copy];
    copy.CreatedDate = [self.CreatedDate copy];
    copy.ModifiedBy = [self.ModifiedBy copy];
    copy.ModifiedDate = [self.ModifiedDate copy];
    copy.PhotosurlAttchmentGuid = [self.PhotosurlAttchmentGuid copy];
    copy.ThirdUserId = [self.ThirdUserId copy];
    copy.attribute1 = [self.attribute1 copy];
    copy.attribute2 = [self.attribute2 copy];
    copy.attribute3 = [self.attribute3 copy];
    copy.attribute4 = [self.attribute4 copy];
    copy.attribute5 = [self.attribute5 copy];
    
    
    copy.IsEMPUser = self.IsEMPUser;
    copy.IsEMIUser = self.IsEMIUser;
    
    copy.ext1 = [self.ext1 copy];
    copy.ext2 = [self.ext2 copy];
    copy.ext3 = [self.ext3 copy];
    copy.ext4 = [self.ext4 copy];
    copy.ext5 = [self.ext5 copy];
    copy.ext6 = [self.ext6 copy];
    copy.ext7 = [self.ext7 copy];
    copy.ext8 = [self.ext8 copy];
    copy.ext9 = [self.ext9 copy];
    copy.ext10 = [self.ext10 copy];
    
    copy.header = [self.header copy];
    
    copy.suoXie = [self.suoXie copy];
    
    copy.pinyin = [self.pinyin copy];
    
    copy.userInfoDic = [self.userInfoDic copy];
    
    copy.isCheck = self.isCheck;
    
    copy.departmentCode = [self.departmentCode copy];
    
    //wlq add 2016/16/07/1
    copy.chooseType = self.chooseType;
    
    return copy;
}

-(NSMutableDictionary *)userInfoDic{
    if (!_userInfoDic) {
        _userInfoDic = [NSMutableDictionary dictionary];
        
    }
    return _userInfoDic;
}

#pragma mark -- 通过字符串来创建该字符串的Setter方法，并返回

- (SEL)creatSetterWithPropertyName:(NSString *)propertyName{
    
    //1.首字母大写
    propertyName = propertyName.capitalizedString;
    
    //2.拼接上set关键字
    propertyName = [NSString stringWithFormat:@"set%@:", propertyName];
    
    //3.返回set方法
    return NSSelectorFromString(propertyName);
}

/************************************************************************
 *
 *参数：
 *适用情况：
 ************************************************************************/
- (void)assginToPropertyWithDictionary:(NSString *)propertyString value:(NSString *)valueString{
    
    ///2.1 通过getSetterSelWithAttibuteName 方法来获取实体类的set方法
    SEL setSel = [self creatSetterWithPropertyName:propertyString];
    
    if ([self respondsToSelector:setSel]) {
        ///2.2 获取字典中key对应的value
        NSString  *value = [NSString stringWithFormat:@"%@", valueString];
        
        ///2.3 把值通过setter方法赋值给实体类的属性
        [self performSelectorOnMainThread:setSel
                               withObject:value
                            waitUntilDone:[NSThread isMainThread]];
    }
}

///通过运行时获取当前对象的所有属性的名称，以数组的形式返回
- (NSArray *)allPropertyNames{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    
    ///存储属性的个数
    unsigned int propertyCount = 0;
    
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
    
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        
        const char * propertyName = property_getName(property);
        
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    ///释放
    free(propertys);
    
    return allNames;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
