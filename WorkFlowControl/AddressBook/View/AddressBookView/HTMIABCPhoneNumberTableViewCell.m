//
//  HTMIABCPhoneNumberTableViewCell.m
//  MXClient
//
//  Created by wlq on 16/7/6.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCPhoneNumberTableViewCell.h"
#import "UIImage+HTMIWFCWM.h"

@implementation HTMIABCPhoneNumberTableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"HTMIABCPhoneNumberTableViewCell";
    HTMIABCPhoneNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCPhoneNumberTableViewCell" owner:nil options:nil][0];
    }

    return cell;
}

@end
