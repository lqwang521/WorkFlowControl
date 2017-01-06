//
//  HTMIWFCOATodoAndDoneViewController.h
//  MXClient
//
//  Created by 赵志国 on 16/3/8.
//  Copyright (c) 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@interface HTMIWFCOATodoAndDoneViewController : HTMIWFCBaseViewController


//+ (instancetype)sharedHTMIWFCOATodoAndDoneViewController;

@property (nonatomic, copy)NSString *homePageString;//homePage 跳转过来的标示

/**
 *  控制顶部页签的显示
 *
 *  @param selectIndex 标签Index
 */
- (void)setSegmentControlSelecteIndex:(NSString *)selectIndex;

+ (void)loginEMM:(NSString *)name password:(NSString *)password succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure;


@end
