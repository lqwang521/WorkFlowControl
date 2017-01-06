//
//  HTMISearchPersonViewController.m
//  AddressBook
//
//  Created by wlq on 16/4/10.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCSearchContactPersonViewController.h"

#import "HTMIABCDBHelper.h"

//viewcontroller
#import "HTMIABCContactPersonInfoViewController.h"

//view
#import "HTMIABCAddressBookPersonTableViewCell.h"

//model
#import "HTMIABCSYS_UserModel.h"

//others
#import "HTMIABCAddressBookManager.h"
#import "HTMIABCCommonHelper.h"

#import "UISearchBar+HTMIWFCSearchBar.h"
#import "UIColor+HTMIWFCHex.h"
#import "UIViewController+HTMIWFCSetTitleFont.h"

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




@interface HTMIABCSearchContactPersonViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (strong, nonatomic) UITableView *friendTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *serverDataArr;//服务器数据源
@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/
@property (strong, nonatomic) NSMutableArray *allDataSource;/**<行数组*/

@end

@implementation HTMIABCSearchContactPersonViewController

#pragma mark --生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self addnav:YES title:@"按姓名查找联系人"];
    [self customNavigationController:YES title:@"按姓名查找联系人"];
    
    //初始化数据
    [self initData];
    
    [self.view addSubview:self.friendTableView];
    
    [self.view addSubview:self.searchBar];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //隐藏键盘
    [HTMIABCCommonHelper hideKeyBoard];
    
    self.navigationController.navigationBarHidden = NO;
    _searchBar.showsCancelButton = NO;
    _searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchDataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HTMIABCAddressBookPersonTableViewCell * cell = [HTMIABCAddressBookPersonTableViewCell cellWithTableView:tableView];
    
    
    
    HTMIABCSYS_UserModel * model = self.searchDataSource[indexPath.row];
    
    cell.sys_UserModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([self.searchDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
        
        HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)self.searchDataSource[indexPath.row];
        
        HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
        vc.sys_UserModel = model;
        
        //跳转到联系人信息页面
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
    
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
                
                self.searchDataSource = userArray;
                
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
        
        
        self.friendTableView.tableFooterView.hidden = YES;
        
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
     self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = NO;
        _searchBar.showsCancelButton = NO;
        _searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    }];
    
    self.friendTableView.tableFooterView.hidden = NO;
    
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    
    [_friendTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [_searchBar resignFirstResponder];
}

#pragma mark - Init

- (void)initData {
    
    //获取常用联系人
    //HTMIABCT_UserRelationshipModel 包含 HTMIABCSYS_UserModel
    self.serverDataArr = [[HTMIABCDBHelper sharedYMDBHelperTool] getContactList];
}

#pragma mark --私有方法

/**
 *  获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
 *
 *  @param aString 汉字字符串
 *
 *  @return 大写拼音首字母
 */
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

#pragma mark --Getter

- (UITableView *)friendTableView {
    
    if (!_friendTableView) {
        _friendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight-44) style:UITableViewStylePlain];
        _friendTableView.backgroundColor = [UIColor whiteColor];
        // 设置tableFooterView为一个空的View，这样就不会显示多余的空白格子了
        _friendTableView.tableFooterView = [[UIView alloc] init];
        
        _friendTableView.delegate = self;
        _friendTableView.dataSource = self;
    }
    return _friendTableView;
}

- (UISearchBar *)searchBar {
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

- (NSMutableArray *)serverDataArr{
    if (!_serverDataArr) {
        _serverDataArr = [NSMutableArray array];
    }
    return _serverDataArr;
}

- (NSMutableArray *)searchDataSource{
    if (!_searchDataSource) {
        _searchDataSource = [NSMutableArray array];
    }
    return _searchDataSource;
}

@end
