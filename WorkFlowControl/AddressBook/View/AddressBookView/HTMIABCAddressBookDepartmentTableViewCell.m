//
//  HTMIABCAddressBookDepartmentTableViewCell.m
//  AddressBook
//
//  Created by wlq on 16/4/11.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCAddressBookDepartmentTableViewCell.h"

#import "UIImage+HTMIWFCWM.h"

@implementation HTMIABCAddressBookDepartmentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"HTMIABCAddressBookDepartmentTableViewCell";
    HTMIABCAddressBookDepartmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCAddressBookDepartmentTableViewCell" owner:nil options:nil][0];
    }

    return cell;
}

@end
