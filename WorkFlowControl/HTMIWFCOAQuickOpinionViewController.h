//
//  HTMIWFCOAQuickOpinionViewController.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/28.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@protocol HTMIWFCOAQuickOpinionViewController <NSObject>

-(void)quickOpinion:(NSString *)opinion;

-(void)addCommonOpinion:(NSString *)opinion;

@end


@interface HTMIWFCOAQuickOpinionViewController : HTMIWFCBaseViewController

/**
 *  表单传过来的意见
 */
@property (nonatomic, copy) NSString *opinionString;

@property(nonatomic,strong)id<HTMIWFCOAQuickOpinionViewController> delegate;

@end
