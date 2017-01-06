//
//  HTMIWFCOAOperationProtocol.h
//  MXClient
//
//  Created by 赵志国 on 15/7/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OAOperationDelegate <NSObject>

- (void)oaOperationDelegateMustEditFeildItems:(NSArray *)mustEditFeildItems;

- (void)oaOperationDelegateEditOperationForKey:(NSString *)key value:(NSString *)value mode:(NSString *)mode
                      input:(NSString *)input formkey:(NSString *)formkey;

@end

@interface HTMIWFCOAOperationProtocol : NSObject

@end
