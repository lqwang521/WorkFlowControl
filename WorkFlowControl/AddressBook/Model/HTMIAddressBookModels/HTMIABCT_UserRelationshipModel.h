//
//  HTMIABCT_UserRelationshipModel.h
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMIABCSYS_UserModel.h"

/**
 *  用户的常用联系人
 */
@interface HTMIABCT_UserRelationshipModel : NSObject

@property (nonatomic,copy) NSString * UserId;
@property (nonatomic,copy) NSString * CUserId;
@property (nonatomic,copy) NSString * header;

@property (nonatomic,strong) HTMIABCSYS_UserModel * mSYS_User ;

@end
