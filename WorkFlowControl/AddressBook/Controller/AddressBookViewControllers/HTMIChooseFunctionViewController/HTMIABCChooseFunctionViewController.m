//
//  HTMIABCChooseFunctionViewController.m
//  AddressBook
//
//  Created by wlq on 16/4/10.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCChooseFunctionViewController.h"

//viewcontroller
#import "HTMIABCCompanyAddressBookViewController.h"
#import "HTMIABCSearchContactPersonViewController.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "HTMIWFCSettingManager.h"

@interface HTMIABCChooseFunctionViewController ()

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *addressBookView;

@end

@implementation HTMIABCChooseFunctionViewController

#pragma mark --生命周期

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;

    [self customNavigationController:YES title:@"通讯录"];
 
    self.searchView.layer.borderColor = [UIColor grayColor].CGColor;
    self.searchView.layer.borderWidth = 1;
    
    UITapGestureRecognizer *tapSearchPerson= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickSearchPerson:)];
    tapSearchPerson.numberOfTapsRequired = 1;
    [self.searchView addGestureRecognizer:tapSearchPerson];
    
    self.addressBookView.layer.borderColor = [UIColor grayColor].CGColor;
    self.addressBookView.layer.borderWidth = 1;
    
    UITapGestureRecognizer *tapCompanyAddressBook= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickCompanyAddressBook:)];
    tapCompanyAddressBook.numberOfTapsRequired = 1;
    [self.addressBookView addGestureRecognizer:tapCompanyAddressBook];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --事件

//手势响应事件 执行查找
- (void)clickSearchPerson:(UITapGestureRecognizer *)sender{
    HTMIABCSearchContactPersonViewController *vc = [HTMIABCSearchContactPersonViewController new];
 
    [self.navigationController pushViewController:vc animated:YES];
}

//手势响应事件 执行点击单位通讯录
- (void)clickCompanyAddressBook:(UITapGestureRecognizer *)sender{
    HTMIABCCompanyAddressBookViewController *vc = [HTMIABCCompanyAddressBookViewController new];
  
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
