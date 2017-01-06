//
//  HTMIWFCMIMainBodyViewController.h
//  MXClient
//
//  Created by chong on 16/7/28.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMIWFCMIMainBodyViewController : UIViewController

@property (nonatomic, copy)NSString *AttachmentID;

@property(nonatomic,copy)NSString *matterID;
@property(nonatomic,copy)NSString *docType;
@property (nonatomic, strong)NSString *urlPNG;
@property (nonatomic, strong)NSString *docTitle;
@property (nonatomic, strong)NSString *kind;

@end
