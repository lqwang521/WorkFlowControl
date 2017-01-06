//
//  HTMIWFCBaseViewController.m
//  MXClient
//
//  Created by wlq on 16/5/30.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCBaseViewController.h"

#import "HTMIWFCSettingManager.h"

@implementation HTMIWFCBaseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (self.navigationController) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;      // 手势有效设置为YES  无效为NO
            self.navigationController.interactivePopGestureRecognizer.delegate = self;    // 手势的代理设置为self
        }
    }
}

@end
