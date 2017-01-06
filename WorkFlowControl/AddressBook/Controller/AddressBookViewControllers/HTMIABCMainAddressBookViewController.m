//
//  SearchDisplayMainTableViewController.m
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//

#import "HTMIABCMainAddressBookViewController.h"



//viewcontroller
#import "HTMIABCChooseFunctionViewController.h"
#import "HTMIABCCompanyAddressBookViewController.h"
#import "HTMIABCContactPersonInfoViewController.h"

//view
#import "HTMIABCAddressBookPersonTableViewCell.h"

//model
#import "HTMIABCSYS_UserModel.h"

//others
#import "objc/runtime.h"//运行时
#import "HTMIABCAddressBookManager.h"
#import "HTMIWFCZipArchive.h"//解压文件
#import "HTMIABCDBHelper.h"//数据库操作
#import "HTMIABCContactDataHelper.h"//处理模型排序相关
//#import "Loading.h"
#import "HTMIWFCAFNManager.h"//网络请求
#import "HTMIABCChooseFormAddressBookViewController.h"//测试使用
#import "HTMIABCCommonHelper.h"
//#import "MXNetworkListView.h"
#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
#endif

//#import <MXKit/MXPublicNumber.h>

#import "UISearchBar+HTMIWFCSearchBar.h"
#import "UIColor+HTMIWFCHex.h"

//TableView内容为空展示
#import "UIScrollView+HTMIWFCEmptyDataSet.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCSettingManager.h"

#import "HTMIWFCApi.h"

#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCMasonry.h"

#define kHeaderViewFontSize 17
#define kHeaderViewTextColor RGBA(51, 51, 51, 1)

#define appWidth  [UIScreen mainScreen].bounds.size.width
#define appHeight  [UIScreen mainScreen].bounds.size.height
#define deviceVersion  [[[UIDevice currentDevice] systemVersion] floatValue]//系统版本号

/** 十六进制字符串转颜色 */
#define kColorWithString(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//等比布局使用
#define kW(R)  ((R)*(kScreenWidth)/320)
#define kH(R)  ((R)*(kScreenHeight)/568)

//表单部分zzg    处理方法：5\6一样，6p为他们的1.1倍
#define kW6(R) (IS_IPHONE_6P ? R*1.1 : R)
#define kH6(R) (IS_IPHONE_6P ? R*1.1 : R)

#define formLineWidth kW6(1.5)
#define formLineColor [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]
#define sidesPlace kW6(5)//label字体距两边的距离


#ifdef DEBUG

#define HTLog(...) NSLog(__VA_ARGS__)

#define HTLogDetail(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define HTLog(...)

#define HTLogDetail(fmt, ...)

#endif

#define ISFormType 1

// 2.获得RGB颜色
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)




//start 定义弱引用和强引用

#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif

//end

@interface HTMIABCMainAddressBookViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>{
    //    MXNetworkListView *networkListView;
    UIView *myCoverView;
}

@property (atomic )BOOL pullDown;

@property (strong, nonatomic) UITableView *friendTableView;

@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (nonatomic,strong) NSMutableArray *serverDataArr;//服务器数据源

@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/

@property (strong, nonatomic) NSMutableArray * indexDataSource;/**<索引数据源*/

@property (strong, nonatomic) NSMutableArray *allDataSource;/**<行数组*/

@property (assign, nonatomic) BOOL isSearch;

/**
 *  联系人个数
 */
@property (assign, nonatomic) long personCount;

//常用联系人个数Label
@property (strong, nonatomic) UILabel * personNumerLable;

/**
 *  记录要删除的数据
 */
@property (strong, nonatomic)NSIndexPath * indexPath;

@property (strong, nonatomic)UIView *customNavigationView;

@property (strong, nonatomic)UIButton *leftButton;

@property (assign, nonatomic)BOOL needShowBottomBar;

@end

@implementation HTMIABCMainAddressBookViewController

#pragma mark --生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LayoutstartCancell)
                                                 name:@"startCancellstartCancell"
                                               object:nil];
    
    //[self customNavigationController:NO title:@"通讯录"];
    //注册同步完成监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbAddressBookSyncDone:) name:@"HTMI_AddressBook_Sync_Done" object:nil];
    
    //使用自定义导航栏
    [self.view addSubview:self.customNavigationView];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.friendTableView];
    
    
    //侧边栏按钮添加
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [self.customNavigationView addSubview:self.leftButton];
    
    /*
     UIButton *btnLeft = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
     [btnLeft setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_community_list_phone" ] forState:UIControlStateNormal];
     [btnLeft setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_community_list_phone" ] forState:UIControlStateHighlighted];
     btnLeft.backgroundColor = [UIColor clearColor];
     
     btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
     [btnLeft addTarget:self action:@selector(clickLeftBarButtonItem) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:btnLeft];
     
     self.navigationItem.leftBarButtonItem = back;// @[negativeSpacer, back];
     
     UIButton *btnRight = [UIButton new];
     
     [btnRight setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_add_phone"] forState:UIControlStateNormal];
     [btnRight setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_add_phone"] forState:UIControlStateHighlighted];
     btnRight.backgroundColor = [UIColor clearColor];
     btnRight.frame = CGRectMake(0, 0, 44, 44);
     btnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -31);
     
     [btnRight addTarget:self action:@selector(clickRightBarButtonItem) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
     self.navigationItem.rightBarButtonItem = right;
     */
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.leftButton removeTarget:self action:@selector(clickLeftBarButtonItem) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton addTarget:self action:@selector(clickLeftBarButtonItem) forControlEvents:UIControlEventTouchUpInside];

    if (self.navigationController.viewControllers.count > 1) {

        [self.leftButton setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone"] forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone"] forState:UIControlStateHighlighted];
        self.needShowBottomBar = NO;
    }
    else{
        
        [self.leftButton setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_community_list_phone"] forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_community_list_phone"] forState:UIControlStateHighlighted];
        self.needShowBottomBar = YES;
    }
    
    self.navigationController.navigationBarHidden = YES;
    self.customNavigationView.hidden = NO;
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    
    if (self.navigationController.viewControllers.count > 1) {
        self.friendTableView.frame = CGRectMake(0, 44 + 64, kScreenWidth, kScreenHeight-104);
    }
    else{
        self.friendTableView.frame = CGRectMake(0, 44 + 64, kScreenWidth, kScreenHeight-148);
    }
    
    self.friendTableView.tableFooterView.hidden = NO;
    self.searchBar.frame = CGRectMake(0, 64, kScreenWidth, 44);
    
    //这里需要添加同步，解压文件，插入数据库
    //判断是否在正在同步
    if (![HTMIABCDBHelper sharedYMDBHelperTool].isSyncDBing) {
        
        //[Loading hiddonLoadingWithView:self.view];
        [HTMIWFCSVProgressHUD dismiss];
        //获取常用联系人
        HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
        
        if (addressBookSingletonClass.topContactsArray.count <= 0) {
            addressBookSingletonClass.topContactsArray = [[HTMIABCDBHelper sharedYMDBHelperTool] getContactList];
        }
        //持有数组
        self.serverDataArr = addressBookSingletonClass.topContactsArray;
        
        self.allDataSource = [HTMIABCContactDataHelper getFriendListDataBy:self.serverDataArr];
        self.indexDataSource = [HTMIABCContactDataHelper getFriendListSectionBy:[self.allDataSource mutableCopy]];
        
        if (self.serverDataArr && self.serverDataArr.count >0) {
            
            self.personCount = self.serverDataArr.count;
            self.personNumerLable.text = [NSString stringWithFormat:@"%ld位联系人",self.personCount];
        }
        else{
            self.personNumerLable.text = @"0位联系人";
        }
        [self.friendTableView reloadData];
        
        self.friendTableView.userInteractionEnabled = YES;
        
    }
    else{
        //[Loading hiddonLoadingWithView:self.view];
        //[Loading showLoadingWithView:self.view];
        
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeNone];
        
        self.friendTableView.userInteractionEnabled = NO;
    }
    
    if (self.needShowBottomBar) {
        
        self.tabBarController.tabBar.hidden = NO;
    }
    else{
        self.tabBarController.tabBar.hidden = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //如果是从别的页面跳转过来的，要隐藏底部
    if (self.needShowBottomBar) {
        
        self.hidesBottomBarWhenPushed = NO;
    }
    
    //隐藏键盘
    [HTMIABCCommonHelper hideKeyBoard];
    
    self.navigationController.navigationBarHidden = NO;
    self.searchBar.showsCancelButton = NO;
    //_searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    
    self.searchBar.frame = CGRectMake(0, 64, kScreenWidth, 44);
    
    self.searchBar.text = @"";
    self.isSearch = NO;
    [self.friendTableView reloadData];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.isSearch) {
        return self.allDataSource.count;
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.isSearch) {
        return [self.allDataSource[section] count];
    }else {
        return self.searchDataSource.count;
    }
}

//头部索引标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.isSearch) {
        return self.indexDataSource[section];
    }else {
        return nil;
    }
}

//右侧索引列表
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.isSearch) {
        return self.indexDataSource;
    }else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HTMIABCAddressBookPersonTableViewCell * cell = [HTMIABCAddressBookPersonTableViewCell cellWithTableView:tableView];
    
    if (!self.isSearch) {
        HTMIABCSYS_UserModel * model = self.allDataSource[indexPath.section][indexPath.row];
        cell.sys_UserModel = model;
    }else{
        
        HTMIABCSYS_UserModel * model = self.searchDataSource[indexPath.row];
        
        cell.sys_UserModel = model;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //viewforHeader
    id label = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!label) {
        label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14.5f]];
        [label setTextColor:[UIColor grayColor]];
        [label setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    }
    [label setText:[NSString stringWithFormat:@"  %@",self.indexDataSource[section+1]]];
    return label;
}

//索引点击事件
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index-1;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //删除包裹
        UIAlertView * aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该联系人？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [aler show];
        
        self.indexPath = indexPath;
        
        aler.tag = 1001;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isSearch) {
        
        //不是检索的情况
        if ([self.allDataSource[indexPath.section][indexPath.row] isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
            
        }
        else if([self.allDataSource[indexPath.section][indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]){
            
            HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)self.allDataSource[indexPath.section][indexPath.row];
            
            HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
            vc.sys_UserModel = model;
            
            self.tabBarController.tabBar.hidden = YES;
            self.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            
        }
        
    }else{
        
        if ([self.searchDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
            
            HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)self.searchDataSource[indexPath.row];
            
            HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
            vc.sys_UserModel = model;
            //跳转到联系人信息页面
            self.tabBarController.tabBar.hidden = YES;
            self.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}

#pragma mark - UIAlertView代理方法

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        if (buttonIndex == 0) {
            //为了让删除按钮回去
            [self.friendTableView reloadData];
        }
        else
        {
            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
            
            NSString *UserID = [userdefaults objectForKey:@"UserID"] ==  nil ? @"":[userdefaults objectForKey:@"UserID"];
            NSString *UserName = [userdefaults objectForKey:@"UserName"]==  nil ? @"":[userdefaults objectForKey:@"UserName"];
            NSString *OA_UserId = [userdefaults objectForKey:@"OA_UserId"]==  nil ? @"":[userdefaults objectForKey:@"OA_UserId"];
            NSString *OA_UserName = [userdefaults objectForKey:@"OA_UserName"]==  nil ? @"":[userdefaults objectForKey:@"OA_UserName"];
            NSString *ThirdDepartmentId = [userdefaults objectForKey:@"ThirdDepartmentId"]==  nil ? @"":[userdefaults objectForKey:@"ThirdDepartmentId"];
            NSString *ThirdDepartmentName = [userdefaults objectForKey:@"ThirdDepartmentName"]==  nil ? @"":[userdefaults objectForKey:@"ThirdDepartmentName"];
            NSString *attribute1 = [userdefaults objectForKey:@"attribute1"]==  nil ? @"":[userdefaults objectForKey:@"attribute1"];
            NSString *OA_UnitId = [userdefaults objectForKey:@"OA_UnitId"]==  nil ? @"":[userdefaults objectForKey:@"OA_UnitId"];
            NSString *MRS_UserId = [userdefaults objectForKey:@"MRS_UserId"]==  nil ? @"":[userdefaults objectForKey:@"MRS_UserId"];
            
            //比以前多的
            NSString *IsEMIUser = [userdefaults objectForKey:@"IsEMIUser"]==  nil ? @"":[userdefaults objectForKey:@"IsEMIUser"];
            NSString *NetworkName = [userdefaults objectForKey:@"NetworkName"]==  nil ? @"":[userdefaults objectForKey:@"NetworkName"];
            
            
            NSMutableDictionary *myDic1 = [NSMutableDictionary dictionary];
            
            [myDic1 setObject:UserID forKey:@"UserID"];
            [myDic1 setObject:UserName forKey:@"UserName"];
            [myDic1 setObject:OA_UserId forKey:@"OA_UserId"];
            [myDic1 setObject:OA_UnitId forKey:@"OA_UnitId"];
            [myDic1 setObject:OA_UserName forKey:@"OA_UserName"];
            [myDic1 setObject:MRS_UserId forKey:@"MRS_UserId"];
            [myDic1 setObject:ThirdDepartmentId forKey:@"ThirdDepartmentId"];
            [myDic1 setObject:ThirdDepartmentName forKey:@"ThirdDepartmentName"];
            [myDic1 setObject:attribute1 forKey:@"attribute1"];
            
            [myDic1 setObject:IsEMIUser forKey:@"IsEMIUser"];
            [myDic1 setObject:NetworkName forKey:@"NetworkName"];
            
            NSMutableDictionary *myDic2 = [NSMutableDictionary dictionary];
            [myDic2 setObject:myDic1 forKey:@"context"];
            
            
            HTMIABCSYS_UserModel * model = self.allDataSource[self.indexPath.section][self.indexPath.row];
            [myDic2 setObject:UserID forKey:@"UserId"];
            [myDic2 setObject:model.UserId forKey:@"CUserId"];
            
            
            //            [Loading showLoadingWithView:self.view];
            [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeNone];
            
            [HTMIWFCApi RemoveTopContact:myDic2 succeed:^(id dicResult) {
                //                [Loading hiddonLoadingWithView:self.view];
                [HTMIWFCSVProgressHUD dismiss];
                if (dicResult && [dicResult isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary  * dicMessage = [dicResult objectForKey:@"Message"];
                    
                    if (dicMessage && [dicMessage isKindOfClass:[NSDictionary class]]) {
                        //NSString * statusCode = [dicMessage objectForKey:@"StatusCode"];
                        NSString * statusCode = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusCode"]];
                        
                        if ([statusCode isEqualToString:@"200"]) {
                            
                            //删除数据库中的
                            [[HTMIABCDBHelper sharedYMDBHelperTool]deleteUser:model.UserId];
                            
                            //从本地缓存中删除
                            for (int i = 0; i < self.serverDataArr.count; i++) {
                                
                                HTMIABCSYS_UserModel *tempModel = self.serverDataArr[i];
                                if ([model.UserId isEqualToString:tempModel.UserId]) {
                                    [self.serverDataArr removeObjectAtIndex:i];
                                    break;
                                }
                            }
                            
                            //执行删除操作，删除页面显示的数据源
                            [self.allDataSource[self.indexPath.section] removeObjectAtIndex:self.indexPath.row];
                            self.personCount -= 1;
                            self.personNumerLable.text = [NSString stringWithFormat:@"%ld位联系人",self.personCount];
                            
                            NSMutableArray * array = self.allDataSource[self.indexPath.section];
                            if (array.count <= 0) {
                                
                                [self.allDataSource removeObjectAtIndex:self.indexPath.section];
                                
                                [self.indexDataSource removeObjectAtIndex:self.indexPath.section +1];
                            }
                            
                            [self.friendTableView reloadData];
                        }
                        else{
                            [HTMIWFCSVProgressHUD showErrorWithStatus:@"删除常用联系人失败" duration:2.0];
                            
                        }
                    }
                }
                
            } failure:^(NSError *error) {
                //                [Loading hiddonLoadingWithView:self.view];
                [HTMIWFCSVProgressHUD dismiss];
                [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
            }];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //1、清空整个搜索结果数组
    [self.searchDataSource removeAllObjects];
    [self.friendTableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:@""];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (userArray && userArray.count > 0) {
                self.isSearch = YES;
                self.searchDataSource = userArray;
                
                [self.friendTableView reloadData];
            }
        });
    });
    
}

//用来控制是否可以编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    self.view.backgroundColor = [UIColor colorWithHex:@"#F2F2F4"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.customNavigationView.hidden = YES;
        _searchBar.frame = CGRectMake(0, 20, kScreenWidth, 44);
        _searchBar.showsCancelButton = YES;
        
        self.friendTableView.tableFooterView.hidden = YES;
        
        if (self.navigationController.viewControllers.count > 1) {
            self.friendTableView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        }
        else{
            self.friendTableView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-108);
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    [UIView animateWithDuration:0.3 animations:^{
        //self.navigationController.navigationBarHidden = NO;
        _searchBar.showsCancelButton = NO;
        //_searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
        self.customNavigationView.hidden = NO;
        
        _searchBar.frame = CGRectMake(0, 64, kScreenWidth, 44);
    }];
    
    self.friendTableView.tableFooterView.hidden = NO;
    //self.friendTableView.frame = CGRectMake(0, 44 + 64, kScreenWidth, kScreenHeight-148);
    if (self.navigationController.viewControllers.count > 1) {
        self.friendTableView.frame = CGRectMake(0, 44 + 64, kScreenWidth, kScreenHeight-104);
    }
    else{
        self.friendTableView.frame = CGRectMake(0, 44 + 64, kScreenWidth, kScreenHeight-148);
    }
    
    
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    self.isSearch = NO;
    [_friendTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [_searchBar resignFirstResponder];
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    UIFont *font = [UIFont boldSystemFontOfSize:14.0];
    UIColor *textColor = RGBA(102, 102, 102, 1);
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    if (self.searchBar.text.length > 0) {
        NSString *text = @"暂无搜索结果，请重试";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    else{
        
        return nil;
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.searchBar.text.length > 0) {
        return [UIImage getPNGImageHTMIWFC:@"img_search_fruitless"];
    }
    else{
        return nil;
    }
}

#pragma mark - 切换网络（左侧边栏的弹出与返回）
//
//- (void)myBtn:(UIButton *)sender {
//    if (networkListView && networkListView.frame.origin.x == 0) {
//        //左侧边栏 返回
//        [self startCancell];
//    }else{
//        //左侧边栏 弹出
//        [self startPullDownn];
//    }
//}
//
//- (void)startCancell {
//    [UIView animateWithDuration:.2f animations:^(){
//        CGFloat positionOffset = 0;
//        if (deviceVersion >=7) {
//            positionOffset = 0;
//        }
//        //wlq update 2016/05/13 适配屏幕
//        networkListView.frame = CGRectMake(-kScreenWidth/4*3, positionOffset, kScreenWidth/4*3, appHeight-positionOffset);
//        [myCoverView removeFromSuperview];
//    } completion:^(BOOL finished) {
//
//        //更新方法是在这个对象中的，如果释放了，更新方法就不执行了
//        //        [networkListView removeFromSuperview];
//        //        networkListView = nil;
//
//    }];
//    self.pullDown = NO;
//}
//
//- (void)startPullDownn{
//    CGFloat positionOffset = 0;
//    int height = 67;
//    if (deviceVersion >= 7) {
//        height = 0;
//    }
//    positionOffset = 0;
//    //创建左侧边栏
//    if (!networkListView) {
//        //wlq update 2016/05/11 适配风格
//        networkListView = [[MXNetworkListView alloc] initWithFrame:CGRectMake(-kScreenWidth/4*3,positionOffset, kScreenWidth/4*3, appHeight-positionOffset)];
//
//        [self.view.window addSubview:networkListView];
//    }
//
//    if (!myCoverView) {
//        myCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,appWidth, appHeight)];
//        myCoverView.backgroundColor = [UIColor blackColor];
//        myCoverView.alpha = 0.8;
//        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(networkChangee:)];
//        [myCoverView addGestureRecognizer:gesture];
//    }
//
//    [self.view.window bringSubviewToFront:networkListView];
//    //A insertSubView B belowSubview:C   是将B插入A并且在A已有的子视图C的下面
//    [self.view.window insertSubview:myCoverView belowSubview:networkListView];
//
//    [UIView animateWithDuration:.2f animations:^(){
//        networkListView.frame = CGRectMake(0, positionOffset, kScreenWidth/4*3, appHeight-positionOffset);
//        self.pullDown = YES;
//    } completion:^(BOOL finished) {
//        self.pullDown = NO;
//    }];
//}
//
//- (void)networkChangee:(id)sender {
//    MXKit *MXObj = [MXKit shareMXKit];
//    [MXObj closeFunctionView];
//    //networkListView是左侧边栏  一个view的frame 包含它的矩形形状（size）的长和宽。
//    //和它在父视图中的坐标原点（origin）x和y坐标
//    if (networkListView && networkListView.frame.origin.x == 0 && self.pullDown == NO) {
//        //左侧边栏 返回
//        [self startCancell];
//    }else{
//        //左侧边栏 弹出
//        [self startPullDownn];
//    }
//}
//
//- (void)LayoutstartCancell{
//    [self startCancell];
//}


#pragma mark --事件

- (void)clickLeftBarButtonItem{
    
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        //        if (networkListView && networkListView.frame.origin.x == 0) {
        //            //左侧边栏 返回
        //            [self startCancell];
        //        }else{
        //            //左侧边栏 弹出
        //            [self startPullDownn];
        //        }
    }
}

//手势响应事件 执行点击功能号
- (void)clickFunctionNumber:(UITapGestureRecognizer *)sender{
    
    //wlq 暂时注释
    /*
     UIViewController *vc = [[MXPublicNumber sharedInstance] getPublicNumberViewController];
     [[MXPublicNumber sharedInstance] addPublicAcc];
     self.tabBarController.tabBar.hidden = YES;
     self.hidesBottomBarWhenPushed = YES;
     [self.navigationController pushViewController:vc animated:YES];
     */
    /*
     //从组织结构所有部门中进行单选
     HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:ChooseTypeUserFromSpecific isSingleSelection:NO specificArray:[NSMutableArray array] isTree:YES];
     
     vc.resultBlock = ^(NSArray *resultArray){
     
     //选择完成后，点击完成按钮会跳转回当前调用页面，执行这个回调方法
     //在这里对返回结果数组进行处理(如果选择的是人员返回的就是人员UserId字符串数组，如果是部门返回的就是DepartmentCode字符串数组)
     
     };
     
     [self.navigationController pushViewController:vc animated:YES];*/
    
    //    HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:ChooseTypeDepartmentFromAll isSingleSelection:NO specificArray:nil];
    
    //    HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:ChooseTypeDepartmentFromSpecific isSingleSelection:YES];
    
    //    HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:ChooseTypeUserFromAll isSingleSelection:YES];
    
    //    HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:ChooseTypeUserFromSpecific isSingleSelection:YES];
    
    //    [self.navigationController pushViewController:vc animated:YES];
}

//手势响应事件 执行点击单位通讯录
- (void)clickCompanyAddressBook:(UITapGestureRecognizer *)sender{
    
    HTMIABCCompanyAddressBookViewController *vc = [HTMIABCCompanyAddressBookViewController new];
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)clickRightBarButtonItem{
    
    //跳转到选项卡页面
    HTMIABCChooseFunctionViewController * vc = [HTMIABCChooseFunctionViewController new];
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 监听数据库同步通知的方法

- (void)dbAddressBookSyncDone:(NSNotification *)note{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //初始化数据
        [self initData];
        [self.friendTableView reloadData];
        
        //        [Loading hiddonLoadingWithView:self.view];
        [HTMIWFCSVProgressHUD dismiss];
    });
    
}

#pragma mark --私有方法

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    if (aString) {
        //转成了可变字符串
        NSMutableString *str = [NSMutableString stringWithString:aString];
        //先转换为带声调的拼音
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
        //再转换为不带声调的拼音
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
        //转化为大写拼音
        NSString *pinYin = [str capitalizedString];
        
        if (pinYin.length > 0) {
            //获取并返回首字母
            return [pinYin substringToIndex:1];
        }
        else{
            return @"";
        }
    }else{
        return @"";
    }
}

#pragma mark - Init

- (void)initData {
    
    //获取常用联系人
    HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
    addressBookSingletonClass.topContactsArray = [[HTMIABCDBHelper sharedYMDBHelperTool] getContactList];
    
    //持有数组
    self.serverDataArr = addressBookSingletonClass.topContactsArray;
    
    self.allDataSource = [HTMIABCContactDataHelper getFriendListDataBy:self.serverDataArr];
    self.indexDataSource = [HTMIABCContactDataHelper getFriendListSectionBy:[self.allDataSource mutableCopy]];
    
    if (self.serverDataArr && self.serverDataArr.count >0) {
        
        self.personCount = self.serverDataArr.count;
        self.personNumerLable.text = [NSString stringWithFormat:@"%ld位联系人",self.personCount];
    }
    else{
        self.personNumerLable.text = @"0位联系人";
    }
}

/**
 *  生成图片
 *
 *  @param color  图片颜色
 *  @param height 图片高度
 *
 *  @return 生成的图片
 */
- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - Getters and Setters


- (UIView *)customNavigationView{
    if (!_customNavigationView) {
        
        _customNavigationView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        _customNavigationView.userInteractionEnabled = YES;
        
        UIImageView *myImg = [[UIImageView alloc]initWithFrame:_customNavigationView.frame];
        myImg.userInteractionEnabled = YES;
        //wlq update 2016/05/11 适配风格
        myImg.image = [UIImage imageWithRenderColorHTMIWFC:[[HTMIWFCSettingManager manager] navigationBarColor] renderSize:CGSizeMake(10., 10.)];
        [_customNavigationView addSubview:myImg];
        
        UILabel *myL = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, kScreenWidth - 100, 44)];
        //标题
        myL.text = @"通讯录";
        //wlq update 2016/05/11 适配风格
        myL.textColor = [[HTMIWFCSettingManager manager] navigationBarTitleFontColor];
        myL.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
        myL.lineBreakMode = NSLineBreakByTruncatingTail;
        
        myL.textAlignment = NSTextAlignmentCenter;
        [_customNavigationView addSubview:myL];
        
        UIView * navAddView = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth-44, 20, 44, 44)];
        [_customNavigationView addSubview:navAddView];
    }
    
    return _customNavigationView;
}

- (UITableView *)friendTableView{
    if (!_friendTableView) {
        
        _friendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + 64, kScreenWidth, kScreenHeight-148) style:UITableViewStylePlain];
        _friendTableView.backgroundColor = [UIColor whiteColor];
        
        _friendTableView.tableHeaderView = self.headerView;
        _friendTableView.tableHeaderView.backgroundColor = [UIColor whiteColor];

        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        footView.backgroundColor = [UIColor clearColor];
        
        //文字
        self.personNumerLable = [[UILabel alloc]init];
        self.personNumerLable.font = [UIFont systemFontOfSize:14];
        self.personNumerLable.text = @"0位联系人";
        self.personNumerLable.textAlignment = NSTextAlignmentCenter;
        [footView addSubview:self.personNumerLable];
        
        [self.personNumerLable mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
            make.center.equalTo(footView);
            
            //将size设置成(kScreenWidth,30)
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, 30));
        }];
        
        _friendTableView.tableFooterView = footView;
        
        //右侧索引view的背景色
        _friendTableView.sectionIndexBackgroundColor = _friendTableView.backgroundColor;
        _friendTableView.delegate = self;
        _friendTableView.dataSource = self;
        _friendTableView.emptyDataSetSource = self;
        _friendTableView.emptyDataSetDelegate = self;
    }
    return _friendTableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        //        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"姓名/拼音/手机号/短号";
        _searchBar.showsCancelButton = NO;
        
        UIImage* searchBarBg = [self GetImageWithColor:[UIColor colorWithHex:@"#F2F2F4"] andHeight:44.0f];
        //设置背景图片
        [_searchBar setBackgroundImage:searchBarBg];
        
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.layer.cornerRadius = 5.0f;
            searchField.layer.borderColor = [UIColor whiteColor].CGColor;
            searchField.layer.borderWidth = 1;
            searchField.layer.masksToBounds = YES;
        }
        
        [_searchBar fm_setCancelButtonTitle:@"取消"];
        _searchBar.tintColor = [[HTMIWFCSettingManager manager] blueColor];
        //修正光标颜色
        [searchField setTintColor:[UIColor grayColor]];
    }
    return _searchBar;
}

- (NSMutableArray *)serverDataArr{
    if (!_serverDataArr) {
        _serverDataArr = [NSMutableArray array];
    }
    return _serverDataArr;
}

- (NSMutableArray *)indexDataSource{
    if (!_indexDataSource) {
        _indexDataSource = [NSMutableArray array];
    }
    return _indexDataSource;
}

- (NSMutableArray *)allDataSource{
    if (!_allDataSource) {
        _allDataSource = [NSMutableArray array];
    }
    return _allDataSource;
}

- (NSMutableArray *)searchDataSource{
    if (!_searchDataSource) {
        _searchDataSource = [NSMutableArray array];
    }
    return _searchDataSource;
}

- (UIView *)headerView{
    if (!_headerView) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        headerView.backgroundColor = [UIColor clearColor];
        _headerView = headerView;
        
        UIView * firstLineView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        firstLineView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:firstLineView];
        
        UITapGestureRecognizer *tapFunctionNumberView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickFunctionNumber:)];
        tapFunctionNumberView.numberOfTapsRequired = 1;
        [firstLineView addGestureRecognizer:tapFunctionNumberView];
        
        //功能号图片
        UIImageView * functionNumberimageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 10, 40, 40)];
        functionNumberimageView.image = [UIImage getPNGImageHTMIWFC:@"icon_office_accounts"];
        [firstLineView addSubview:functionNumberimageView];
        
        //文字
        UILabel * functionNumberLable = [[UILabel alloc]initWithFrame:CGRectMake(66, 15, 120, 30)];
        functionNumberLable.font = [UIFont systemFontOfSize:kHeaderViewFontSize];//plus 上回进行适当的放大
        functionNumberLable.textColor = kHeaderViewTextColor;
        functionNumberLable.text = @"功能号";
        [firstLineView addSubview:functionNumberLable];
        
        UIView * line = [[UIView alloc]init];
        line.backgroundColor = RGB(239, 240, 240);//RGBA(0, 0, 0, 0.25);//[UIColor lightGrayColor];//
        [firstLineView addSubview:line];
        
        [line mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
            make.right.equalTo(firstLineView.mas_right).with.offset(0);
            make.bottom.equalTo(firstLineView.mas_bottom).with.offset(0);
            make.left.equalTo(firstLineView.mas_left).with.offset(10);
            make.height.mas_equalTo(@0.5);
        }];
        
        UIView * SecondLineView = [[UIView alloc ]initWithFrame:CGRectMake(0, 60, kScreenWidth, 60)];
        SecondLineView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:SecondLineView];
        
        UITapGestureRecognizer *tapCompanyAddressBookView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickCompanyAddressBook:)];
        tapCompanyAddressBookView.numberOfTapsRequired = 1;
        [SecondLineView addGestureRecognizer:tapCompanyAddressBookView];
        
        //图片
        UIImageView * companyAddressBookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 10, 40, 40)];
        companyAddressBookImageView.image = [UIImage getPNGImageHTMIWFC:@"icon_book"];
        [SecondLineView addSubview:companyAddressBookImageView];
        
        //文字
        UILabel * companyAddressBookLable = [[UILabel alloc]initWithFrame:CGRectMake(66, 15, 120, 30)];
        companyAddressBookLable.font = [UIFont systemFontOfSize:kHeaderViewFontSize];
        companyAddressBookLable.textColor = kHeaderViewTextColor;
        companyAddressBookLable.text = @"单位通讯录";
        [SecondLineView addSubview:companyAddressBookLable];
    }
    return _headerView;
}

- (void)setIsSearch:(BOOL)isSearch{
    _isSearch = isSearch;
    if (_isSearch) {
        if (_friendTableView) {
            UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
            [_friendTableView setTableHeaderView:view];
        }
    }
    else{
        [_friendTableView setTableHeaderView:self.headerView];
    }
}

#pragma mark - 单例

static id _instance = nil;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedAddressBookViewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}


@end
