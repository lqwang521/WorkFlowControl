//
//  HTMIWFCSettingManager.h
//  MXClient
//
//  Created by wlq on 16/6/14.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString * (^mxChatBlock)(NSArray * array,UIViewController * vc);

@interface HTMIWFCEMIManager : NSObject{

}

+ (instancetype)manager;


/**
 *  聊天方法回调
 */
@property (nonatomic, copy) mxChatBlock chatCallBack;


/**
 敏行聊天方法，需要先设置聊天方法回调

 @param userArray 用户组
 @param vc        控制器
 */
+ (void)mxChat:(NSArray *)userArray withViewController:(UIViewController *)vc;
 
@end
