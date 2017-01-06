//
//  HTMIWFCEditOpinionViewController.h
//  MXClient
//
//  Created by 赵志国 on 16/7/27.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTMIWFCEditOpinionViewControllerBlock)(NSString *string);

@interface HTMIWFCEditOpinionViewController : UIViewController

@property (nonatomic, copy) NSString *titleString;

@property (nonatomic, copy) NSString *opinionString;

@property (nonatomic, copy) HTMIWFCEditOpinionViewControllerBlock opinionBlock;

@end
