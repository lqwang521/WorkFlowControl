//
//  HTMIABCAddressBookDepartmentTableViewCell.h
//  AddressBook
//
//  Created by wlq on 16/4/11.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMIABCAddressBookDepartmentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *departmentNameLabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
