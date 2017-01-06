//
//  HTMIWFCOAMatterFlowListTableViewController.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/1.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMIWFCOAMatterFlowListTableViewController : UITableViewController

@property(nonatomic,strong)NSString *matterID;
@property (nonatomic,strong)NSArray *userID;
@property(nonatomic,copy)NSString *docType;
@property(nonatomic,copy)NSString *kind;


@property(nonatomic,strong)NSDictionary *lastFlowDic;

@end
