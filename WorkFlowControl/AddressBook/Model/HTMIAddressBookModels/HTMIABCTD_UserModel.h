//
//  HTMIABCTD_UserModel.h
//  AddressBook
//
//  Created by wlq on 16/4/7.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  人员属性定义
 */
@interface HTMIABCTD_UserModel : NSObject

@property (nonatomic,copy) NSString * FieldName;
@property (nonatomic,copy) NSString * DisLabel ;

//public int DisOrder;
@property (nonatomic,assign) int DisOrder;

//public boolean IsActive;
//public boolean EnabledEdit;
@property (nonatomic,assign) BOOL IsActive;
@property (nonatomic,assign) BOOL EnabledEdit;

//public short SecretFlag;
//public short Action;
@property (nonatomic,assign) short SecretFlag;
@property (nonatomic,assign) short Action;

//wql add 2016/04/19
@property (nonatomic,copy) NSString * contentString;


@end

