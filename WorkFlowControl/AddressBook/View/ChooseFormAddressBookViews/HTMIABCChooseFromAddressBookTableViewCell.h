//
//  HTMIABCChooseFromAddressBookTableViewCell.h
//  MXClient
//
//  Created by wlq on 16/4/19.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTMIABCSYS_UserModel;
@class HTMIABCSYS_DepartmentModel;

@interface HTMIABCChooseFromAddressBookTableViewCell : UITableViewCell

typedef void (^CheckBlock)(HTMIABCChooseFromAddressBookTableViewCell *returnCell);

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pushImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pushViewTrailingConstraint;

/**
 *  选中状态改变回调方法
 */
@property (nonatomic,copy)CheckBlock checkBlock;

@property (nonatomic,strong)HTMIABCSYS_UserModel * sys_UserModel;

@property (nonatomic,strong)HTMIABCSYS_DepartmentModel *sys_DepartmentModel;


@end
