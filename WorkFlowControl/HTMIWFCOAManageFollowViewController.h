//
//  HTMIWFCOAManageFollowViewController.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/26.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@protocol OAManegerFollowViewControllerDelegate <NSObject>

-(void)followDidSelected:(NSArray *)selected hasSelectedRoute:(NSArray *)hasSelectedRoute;

@end

@interface HTMIWFCOAManageFollowViewController : HTMIWFCBaseViewController

@property(nonatomic,strong)NSString *resultInfo;//路由or人员
@property(nonatomic,strong)NSArray *resultList;//路由or人员的名单
@property(nonatomic,assign)BOOL IsMultiSelectResult;//是否多选
@property(nonatomic,assign)BOOL IsFreeSelectUser;//是否自由选择
@property(nonatomic,assign)NSInteger retCode;//判断是路由还是人员
@property(nonatomic,strong)NSDictionary *hasSelectedRoute;//只有选人时的路由ID

@property(nonatomic,weak)id<OAManegerFollowViewControllerDelegate>delegate;

@end
