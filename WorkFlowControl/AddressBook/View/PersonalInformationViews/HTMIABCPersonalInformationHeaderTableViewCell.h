//
//  HTMIABCPersonalInformationHeaderTableViewCell.h
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMIABCPersonalInformationHeaderTableViewCell : UITableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end
