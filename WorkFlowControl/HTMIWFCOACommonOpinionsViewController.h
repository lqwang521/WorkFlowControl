//
//  HTMIWFCOACommonOpinionsViewController.h
//  MXClient
//
//  Created by 赵志国 on 15/12/14.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@protocol OACommonOpinionTableViewController <NSObject>

-(void)addCommonOpinion:(NSString *)opinion;

@end

@interface HTMIWFCOACommonOpinionsViewController : HTMIWFCBaseViewController

/**
 *  判断是否表单进入
 */
@property (nonatomic, copy) NSString *isFormGo;

@property(nonatomic,strong)id<OACommonOpinionTableViewController> delegate;

@end
