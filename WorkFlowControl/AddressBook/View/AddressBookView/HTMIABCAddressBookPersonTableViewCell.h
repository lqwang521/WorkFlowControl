//
//  DemoCell.h
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//  https://github.com/Lanmaq/iOS_HelpOther_WorkSpace


#import <UIKit/UIKit.h>
@class HTMIABCSYS_UserModel;

@interface HTMIABCAddressBookPersonTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneLabelTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneOrDepartmentLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;

@property (strong, nonatomic)  UIWebView *webView;

- (IBAction)clickMessageButton:(id)sender;

- (IBAction)clickPhoneButton:(id)sender;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (strong, nonatomic) HTMIABCSYS_UserModel * sys_UserModel;



@end
