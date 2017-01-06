//
//  HTMIABCChooseFromTopContactsTableViewCell.h
//  MXClient
//
//  Created by wlq on 16/6/30.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HTMIABCSYS_UserModel;
@class HTMIABCDynamicTreeNode;
@interface HTMIABCChooseFromTopContactsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (strong, nonatomic)HTMIABCDynamicTreeNode *htmiDynamicTreeNode;

@property (strong, nonatomic)HTMIABCSYS_UserModel *sys_UserModel;

typedef void (^CheckBlock)(HTMIABCChooseFromTopContactsTableViewCell *returnCell);

/**
 *  选中状态改变回调方法
 */
@property (nonatomic,copy)CheckBlock checkBlock;

- (IBAction)clickCheckButton:(id)sender;

@end
