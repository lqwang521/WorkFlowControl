//
//  HTMIWFCOAMatterOperationViewController.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/31.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

#import "HTMIWFCDCPathButton.h"

@protocol HTMIWFCOAMatterOperationViewControllerDelegate <NSObject>

-(void)tableViewReloadData;

@end


@interface HTMIWFCOAMatterOperationViewController : HTMIWFCBaseViewController<HTMIWFCDCPathButtonDelegate>

@property(nonatomic,copy)NSString *matterID;
@property(nonatomic,copy)NSString *docTitle;//详情页标题
@property(nonatomic,copy)NSString *docType;
@property(nonatomic,copy)NSString *kind;
@property(nonatomic,copy)NSString *flowid;
@property(nonatomic,copy)NSString *urlPNG;
@property (nonatomic, copy) NSString *sendFrom;
@property (nonatomic, copy) NSString *sendDate;
@property (nonatomic, copy) NSString *iconID;

@property(nonatomic,weak)id<HTMIWFCOAMatterOperationViewControllerDelegate> delegate;

@end
