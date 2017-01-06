//
//  HTMIWFCSettingManager.m
//  MXClient
//
//  Created by wlq on 16/6/14.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCEMIManager.h"

#import "HTMIWFCSVProgressHUD.h"

@implementation HTMIWFCEMIManager

+ (instancetype)manager
{
    return [[super alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HTMIWFCEMIManager *_manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

#pragma mark - 方法

+ (void)mxChat:(NSArray *)userArray withViewController:(UIViewController *)vc{
    
    NSString* errorString = [HTMIWFCEMIManager manager].chatCallBack(userArray,vc);
    
    if (errorString.length > 0) {
        [HTMIWFCSVProgressHUD showErrorWithStatus:errorString duration:2.0];
    }
}

@end
