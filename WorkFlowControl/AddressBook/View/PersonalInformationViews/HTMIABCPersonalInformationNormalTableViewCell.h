//
//  PersonalInformationNormalTableViewCell.h
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTMIABCTD_UserModel;
@class HTMIABCSYS_UserModel;

@interface HTMIABCPersonalInformationNormalTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (copy,nonatomic)HTMIABCTD_UserModel * td_UserModel;
@property (copy,nonatomic)HTMIABCSYS_UserModel * sys_UserModel;

@property (weak, nonatomic) IBOutlet UILabel *fieldNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *editEnableImageVIew;

@end
