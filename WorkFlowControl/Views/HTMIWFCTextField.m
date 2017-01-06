//
//  HTMIWFCTextField.m
//  CustomInputView
//
//  Created by wlq on 16/7/11.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIWFCTextField.h"

@implementation HTMIWFCTextField

/**
 *  禁止复制粘贴
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
