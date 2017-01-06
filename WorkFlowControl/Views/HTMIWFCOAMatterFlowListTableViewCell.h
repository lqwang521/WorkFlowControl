//
//  HTMIWFCOAMatterFlowListTableViewCell.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTMIWFCOAMatterFlowListEntity.h"

@interface HTMIWFCOAMatterFlowListTableViewCell : UITableViewCell

@property(nonatomic,strong)HTMIWFCOAMatterFlowListEntity *flowList;

@property(nonatomic,strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *myStepName;
@property (nonatomic, strong)UIButton *myOAUserName;
@property (nonatomic, strong)UILabel *myAction;
@property (nonatomic, strong)UILabel *myComments;
@property (nonatomic, strong)NSString *myUserID;



//flowList.stepName,flowList.OAUserName,flowList.action,flowList.Comments
@property(nonatomic,strong)UILabel *timeLabel;

@property(nonatomic,strong)UIImageView *headImageView;
@property(nonatomic,strong)UIImageView *circleImageHTMIWFCView;
-(void)creatMatterFlowListCell:(HTMIWFCOAMatterFlowListEntity *)flowList andmyIdentfier:(int)identfierInt;

@end
