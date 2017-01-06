//
//  HTMIABCTD_UserFieldSecretModel.h
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <Foundation/Foundation.h>


@class HTMIABCTD_UserModel;

/**
 *  定义某个保密字段哪些人能看
 */
@interface HTMIABCTD_UserFieldSecretModel : NSObject

@property (nonatomic,copy) NSString * UserId;

@property (nonatomic,copy) NSString * FieldName;

@property (nonatomic,strong) HTMIABCTD_UserModel *mTD_User;

@end
