//
//  PersonalInformationNormalTableViewCell.m
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCPersonalInformationNormalTableViewCell.h"
#import "UIImage+HTMIWFCWM.h"
#import "HTMIABCTD_UserModel.h"
#import "HTMIABCSYS_UserModel.h"

@implementation HTMIABCPersonalInformationNormalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"HTMIABCPersonalInformationNormalTableViewCell";
    HTMIABCPersonalInformationNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCPersonalInformationNormalTableViewCell" owner:nil options:nil][0];
    }
    return cell;
}

#pragma mark - Getters and Setters

- (void)setTd_UserModel:(HTMIABCTD_UserModel *)td_UserModel{
    _td_UserModel = td_UserModel;
    
    //在此处控制页面的显示
    if (_td_UserModel.EnabledEdit) {
        self.editEnableImageVIew.hidden = NO;
    }
    else{
        self.editEnableImageVIew.hidden = YES;
    }
    self.fieldNameLabel.text = _td_UserModel.DisLabel;
    
    if ([_td_UserModel.FieldName isEqualToString:@"FullName"]) {//2姓名
        self.contentLabel.text = self.sys_UserModel.FullName.length >0 ? self.sys_UserModel.FullName:@"未填写";
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Gender"]){//3性别
        
        //0女1男
        if (self.sys_UserModel.Gender == 1) {
            self.contentLabel.text = @"男";
        }
        else if(self.sys_UserModel.Gender == 0){
            self.contentLabel.text = @"女";
        }
        else{
            self.contentLabel.text = @"未填写";
        }
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Email"]){//4电子邮件
        self.contentLabel.text = self.sys_UserModel.Email.length >0 ? self.sys_UserModel.Email:@"未填写";
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Telephone"]){//5电话
        self.contentLabel.text = self.sys_UserModel.Telephone.length >0 ? self.sys_UserModel.Telephone:@"未填写";
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Office"]){//6办公电话
        self.contentLabel.text = self.sys_UserModel.Office.length >0 ? self.sys_UserModel.Office:@"未填写";
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Mobile"]){//7手机号码
        self.contentLabel.text = self.sys_UserModel.Mobile.length >0 ? self.sys_UserModel.Mobile:@"未填写";
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Fax"]){//8传真
        self.contentLabel.text = self.sys_UserModel.Fax.length >0 ? self.sys_UserModel.Fax:@"未填写";
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Position"]){//9职务
        self.contentLabel.text = self.sys_UserModel.Position.length >0 ? self.sys_UserModel.Position:@"未填写";
    }
    
#pragma mark --暂未使用，保留字段
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext1"]){
        self.contentLabel.text = self.sys_UserModel.ext1.length >0 ? self.sys_UserModel.ext1:@"未填写";
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext2"]){
        self.contentLabel.text = self.sys_UserModel.ext2.length >0 ? self.sys_UserModel.ext2:@"未填写";
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext3"]){
        self.contentLabel.text = self.sys_UserModel.ext3.length >0 ? self.sys_UserModel.ext3:@"未填写";
        
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext4"]){
        self.contentLabel.text = self.sys_UserModel.ext4.length >0 ? self.sys_UserModel.ext4:@"未填写";
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext5"]){
        self.contentLabel.text = self.sys_UserModel.ext5.length >0 ? self.sys_UserModel.ext5:@"未填写";
        
    }else if ([_td_UserModel.FieldName isEqualToString:@"Ext6"]){
        
        self.contentLabel.text = self.sys_UserModel.ext6.length >0 ? self.sys_UserModel.ext6:@"未填写";
    }else if ([_td_UserModel.FieldName isEqualToString:@"Ext7"]){
        
        self.contentLabel.text = self.sys_UserModel.ext7.length >0 ? self.sys_UserModel.ext7:@"未填写";
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext8"]){
        
        self.contentLabel.text = self.sys_UserModel.ext8.length >0 ? self.sys_UserModel.ext8:@"未填写";
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext9"]){
        
        self.contentLabel.text = self.sys_UserModel.ext9.length >0 ? self.sys_UserModel.ext9:@"未填写";
    }
    else if ([_td_UserModel.FieldName isEqualToString:@"Ext10"]){
        
        self.contentLabel.text = self.sys_UserModel.ext10.length >0 ? self.sys_UserModel.ext10:@"未填写";
    }
    else{
        NSString * str = [self.td_UserModel.FieldName lowercaseString];
        
        if (str && str.length > 0) {
            
            NSString * strValue = [self.sys_UserModel.userInfoDic objectForKey:str];
            
            self.contentLabel.text = strValue.length > 0 ? strValue:@"未填写";
        }
    }
}

@end
