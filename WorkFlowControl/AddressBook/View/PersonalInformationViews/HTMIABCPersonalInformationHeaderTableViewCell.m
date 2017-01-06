//
//  HTMIABCPersonalInformationHeaderTableViewCell.m
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCPersonalInformationHeaderTableViewCell.h"
#import "UIImage+HTMIWFCWM.h"

@implementation HTMIABCPersonalInformationHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
 
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"HTMIABCPersonalInformationHeaderTableViewCell";
    HTMIABCPersonalInformationHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCPersonalInformationHeaderTableViewCell" owner:nil options:nil][0];
    }
    return cell;
}

@end
