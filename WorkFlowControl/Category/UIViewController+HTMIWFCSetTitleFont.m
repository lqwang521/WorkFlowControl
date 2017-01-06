//
//  UIViewController+HTMIWFCSetTitleFont.m
//  MXClient
//
//  Created by wlq on 16/5/10.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCSettingManager.h"

/** 导航栏字体 （用来设置系统导航栏） */
#define HTMINavigationBarTitleFont \


@implementation UIViewController (HTMIWFCSetTitleFont)


- (void)customNavigationController:(BOOL)canReturn title:(NSString *)title
{
    
    //设置导航栏背景色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithRenderColorHTMIWFC:[[HTMIWFCSettingManager manager] navigationBarColor] renderSize:CGSizeMake(10., 10.)] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;//的模糊效果，默认为YES
    self.navigationController.navigationBar.tintColor = [[HTMIWFCSettingManager manager] navigationBarColor];
    //隐藏底部边线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    if (canReturn == YES) {
        
        UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        [btnLeft setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateNormal];
        [btnLeft setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateHighlighted];
        btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
        
        btnLeft.backgroundColor = [UIColor clearColor];
        
        
        [btnLeft addTarget:self action:@selector(myClickReturn) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:btnLeft];
        
        self.navigationItem.leftBarButtonItem = back;
    }
    
    self.navigationItem.title = title;
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [[HTMIWFCSettingManager manager] navigationBarTitleFontColor],NSForegroundColorAttributeName,
      [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0],
      NSFontAttributeName,nil]];
    
}

- (void)myClickReturn
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
