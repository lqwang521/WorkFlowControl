//
//  HTMIABCPhoneNumberTableViewCell.h
//  MXClient
//
//  Created by wlq on 16/7/6.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMIABCPhoneNumberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *splitView;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
