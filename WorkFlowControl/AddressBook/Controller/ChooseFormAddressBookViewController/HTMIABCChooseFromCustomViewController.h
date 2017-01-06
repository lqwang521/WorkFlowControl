//
//  HTMIABCChooseFromCustomViewController.h
//  MXClient
//
//  Created by wlq on 16/6/22.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCBaseViewController.h"
#import "HTMIABCChooseType.h"

#import "HTMIABCChooseFormAddressBookViewController.h"

@interface HTMIABCChooseFromCustomViewController : HTMIWFCBaseViewController

@property (nonatomic,assign)BOOL isTree;

@property (nonatomic,weak) HTMIABCChooseFormAddressBookViewController *myParentViewController;

- (instancetype)initWithChooseType:(ChooseType)chooseType isSingleSelection:(BOOL)isSingleSelection
                     specificArray:(NSArray *)specificArray;

@end
