//
//  CompanyAddressBookViewController.m
//  AddressBook
//
//  Created by wlq on 16/4/4.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCCompanyAddressBookViewController.h"

#import "HTMIWFCSVProgressHUD.h"
//Controller
#import "HTMIABCContactPersonInfoViewController.h"

//view
#import "HTMIABCAddressBookPersonTableViewCell.h"
#import "HTMIABCAddressBookDepartmentTableViewCell.h"

//model
#import "HTMIABCSYS_DepartmentModel.h"
#import "HTMIABCSYS_UserModel.h"

//other
#import "HTMIABCDBHelper.h"
#import "HTMIABCAddressBookManager.h"
//#import "HTMIABCCommonHelper.h"
//#import "loading.h"
#import "UISearchBar+HTMIWFCSearchBar.h"
#import "UIColor+HTMIWFCHex.h"

//TableView内容为空展示
#import "UIScrollView+HTMIWFCEmptyDataSet.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIABCCommonHelper.h"

#import "HTMIWFCSettingManager.h"

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

@interface HTMIABCCompanyAddressBookViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>

@property (strong, nonatomic) UITableView *friendTableView;

@property (strong, nonatomic) UISearchBar *searchBar;

/**
 *  搜索结果数据源
 */
@property (strong, nonatomic) NSMutableArray *searchDataSource;

/**
 *  行数组
 */
@property (strong, nonatomic) NSMutableArray *allDataSource;

/**
 *  部门下的所有人员
 */
@property (strong, nonatomic) NSMutableArray *allPersonInCurrnetDepartment;

/**
 *  是否正在查询
 */
@property (assign, nonatomic) BOOL isSearch;

@end

@implementation HTMIABCCompanyAddressBookViewController


#pragma mark --生命周期

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (self.departmentModel && self.departmentModel.ShortName) {
        [self customNavigationController:YES title:self.departmentModel.ShortName];
    }
    else{
        [self customNavigationController:YES title:@"单位通讯录"];
    }
    
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    
    //wlq update 2016/05/11 适配风格
    
    [btnRight setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"btn_quick_return"] forState:UIControlStateNormal];
    [btnRight setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"btn_quick_return"] forState:UIControlStateHighlighted];
    btnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -31);
    
    btnRight.backgroundColor = [UIColor clearColor];
    [btnRight addTarget:self action:@selector(clickRightBarButtonItem) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = right;
    
    //初始化页面
    [self.view addSubview:self.friendTableView];
    [self.view addSubview:self.searchBar];
    
    //初始化数据
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];;
    self.searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    self.friendTableView.frame = CGRectMake(0, 44, kScreenWidth, kScreenHeight-108);
    _isSearch = NO;
    [self.friendTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //隐藏键盘
    [HTMIABCCommonHelper hideKeyBoard];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    _searchBar.showsCancelButton = NO;
    _searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    
    _searchBar.text = @"";
    _isSearch = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    
}

- (void)clickRightBarButtonItem{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_isSearch) {
        return self.allDataSource.count;
    }else {
        return self.searchDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_isSearch) {
        //不是检索的情况
        if ([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
            
            HTMIABCAddressBookDepartmentTableViewCell * cell = [HTMIABCAddressBookDepartmentTableViewCell cellWithTableView:tableView];
            
            HTMIABCSYS_DepartmentModel * model = self.allDataSource[indexPath.row];
            cell.departmentNameLabel.text = model.ShortName;
            return cell;
        }
        else if([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]){
            
            HTMIABCAddressBookPersonTableViewCell * cell = [HTMIABCAddressBookPersonTableViewCell cellWithTableView:tableView];
            HTMIABCSYS_UserModel * model = self.allDataSource[indexPath.row];
            cell.sys_UserModel = model;
            return cell;
        }
        else{
            return nil;
        }
        
    }else{
        
        if([self.searchDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]){
            HTMIABCAddressBookPersonTableViewCell * cell = [HTMIABCAddressBookPersonTableViewCell cellWithTableView:tableView];
            HTMIABCSYS_UserModel * model = self.searchDataSource[indexPath.row];
            
            cell.sys_UserModel = model;
            return cell;
        }
        else{
            return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isSearch) {
        //不是检索的情况
        if ([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
            //点击的是部门
            HTMIABCSYS_DepartmentModel * model = self.allDataSource[indexPath.row];
            
            
            HTMIABCCompanyAddressBookViewController * vc = [HTMIABCCompanyAddressBookViewController new];
            vc.departmentModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]){
            HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)self.allDataSource[indexPath.row];
            
            HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
            vc.sys_UserModel = model;
            //跳转到联系人信息页面
            
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
            
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //1、清空整个搜索结果数组
    [self.searchDataSource removeAllObjects];
    _isSearch = YES;
    [self.friendTableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray * userArray;
        if (self.departmentModel == nil) {
            userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:nil];
        }else{
            userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:self.departmentModel.DepartmentCode];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (userArray && userArray.count > 0) {
                
                [self.searchDataSource addObjectsFromArray:userArray];
                
                [self.friendTableView reloadData];
            }
        });
    });
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    self.view.backgroundColor = [UIColor colorWithHex:@"#F2F2F4"];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = YES;
        _searchBar.frame = CGRectMake(0, 20, kScreenWidth, 44);
        _searchBar.showsCancelButton = YES;
        
    }];
    
    self.friendTableView.frame = CGRectMake(0, 44, kScreenWidth, kScreenHeight-44);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = NO;
        _searchBar.showsCancelButton = NO;
        _searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    }];
    
    self.friendTableView.frame =  CGRectMake(0, 44, kScreenWidth, kScreenHeight-108);
    
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    _isSearch = NO;
    [self.friendTableView reloadData];
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

#pragma mark --事件

//重写分类的方法
/**
 *  返回按钮点击事件
 */
- (void)myClickReturn{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark --私有方法

/**
 *  汉字转拼音
 *
 *  @param strChinese 汉字
 *
 *  @return 拼音
 */
- (NSString *)transformToPinyin:(NSString *)strChinese{
    
    NSMutableString *mutableString = [NSMutableString stringWithString:strChinese];
    
    CFStringTransform((CFMutableStringRef)mutableString,NULL,kCFStringTransformToLatin,false);
    
    mutableString = (NSMutableString*)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString * strResult =  [mutableString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return strResult;
}

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

/**
 *  初始化数据
 */
- (void)initData{
    
//    [Loading showLoadingWithView:self.view];
    
    [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeClear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //根据上级部门检索
        if (self.departmentModel == nil) {
            
            HTMIABCSYS_DepartmentModel * sys_DepartmentModel = [[HTMIABCDBHelper sharedYMDBHelperTool]getRootDepartment];
            
            //说明是根节点
            self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:sys_DepartmentModel.ParentDepartment];
        }
        else{
            //获取
            self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:self.departmentModel.DepartmentCode];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[Loading hiddonLoadingWithView:self.view];
            [HTMIWFCSVProgressHUD dismiss];
            
            [self.friendTableView reloadData];
        });
    });
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

#pragma mark --Getters And Setters

- (UITableView *)friendTableView {
    
    if (!_friendTableView) {
        _friendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight-108) style:UITableViewStylePlain];
        _friendTableView.backgroundColor = [UIColor whiteColor];
        // 设置tableFooterView为一个空的View，这样就不会显示多余的空白格子了
        _friendTableView.tableFooterView = [[UIView alloc] init];
        _friendTableView.delegate = self;
        _friendTableView.dataSource = self;
        _friendTableView.emptyDataSetSource = self;
        _friendTableView.emptyDataSetDelegate = self;
    }
    return _friendTableView;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
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

- (NSMutableArray *)searchDataSource{
    if (!_searchDataSource) {
        _searchDataSource = [NSMutableArray array];
    }
    return _searchDataSource;
}

- (NSMutableArray *)allDataSource{
    if (!_allDataSource) {
        _allDataSource = [NSMutableArray array];
    }
    return _allDataSource;
}

- (NSMutableArray *)allPersonInCurrnetDepartment{
    if (!_allPersonInCurrnetDepartment) {
        _allPersonInCurrnetDepartment = [NSMutableArray array];
    }
    return _allPersonInCurrnetDepartment;
}

@end
