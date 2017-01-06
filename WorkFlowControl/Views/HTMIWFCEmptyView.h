//
//  HTMIWFCEmptyView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/4.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTMIEmptyActionBlock)(void);
typedef void(^HTMIEmptyGoToCheckBlock)(void);

@interface HTMIWFCEmptyView : UIView

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view padding:(UIEdgeInsets)padding;

+ (BOOL)viewHasEmptyView:(UIView *)view;

+ (void)removeFormView:(UIView *)view;

+ (HTMIWFCEmptyView *)reloadErrorView:(HTMIEmptyActionBlock)action goToCheck:(HTMIEmptyGoToCheckBlock)goToCheck;

+ (HTMIWFCEmptyView *)reloadTimeOutView:(HTMIEmptyActionBlock)action;

+ (HTMIWFCEmptyView *)emptyViewWithImage:(UIImage *)image andTips:(NSString *)tips;

+ (HTMIWFCEmptyView *)commonEmptyView;

+ (HTMIWFCEmptyView *)emptyViewForProject;

+ (HTMIWFCEmptyView *)emptyViewForTask;

+ (HTMIWFCEmptyView *)emptyViewForJoinedProject;

+ (HTMIWFCEmptyView *)emptyViewForCreateProject:(HTMIEmptyActionBlock)action;

@end
