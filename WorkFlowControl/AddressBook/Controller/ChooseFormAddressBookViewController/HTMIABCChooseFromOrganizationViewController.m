//
//  HTMIABCChooseFormAddressBookViewController.m
//  MXClient
//
//  Created by wlq on 16/4/19.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCChooseFromOrganizationViewController.h"

//cell
#import "HTMIABCSelectedFromAddressBookTableViewCell.h"
#import "HTMIABCChooseFromAddressBookTableViewCell.h"

//model
#import "HTMIABCSYS_UserModel.h"//用户
#import "HTMIABCSYS_DepartmentModel.h"//部门

//others
#import "HTMIABCDBHelper.h"//数据库
//#import "Loading.h"//加载
#import "UIColor+HTMIWFCHex.h"
#import "HTMIABCAddressBookSelectedView.h"
//查看联系人信息
#import "HTMIABCContactPersonInfoViewController.h"

#import "UISearchBar+HTMIWFCSearchBar.h"

//TableView内容为空展示
#import "UIScrollView+HTMIWFCEmptyDataSet.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCSettingManager.h"
#import "HTMIWFCSVProgressHUD.h"

//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]

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
#define SECTION_HEIGHT 30.0
#define kHSelectedViewHeight 50

@interface HTMIABCChooseFromOrganizationViewController ()
<UIGestureRecognizerDelegate,
UISearchBarDelegate,
UITableViewDelegate,
UITableViewDataSource,
CAAnimationDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>
{
    /**
     *  是否为正在搜索
     */
    BOOL _isSearch;
}

#pragma mark --控件属性

/**
 *  搜索框
 */
@property (strong, nonatomic) UISearchBar *mainSearchBar;

/**
 *  搜索TableView
 */
@property (strong, nonatomic) UITableView *searchTableView;


/**
 *  已选择view
 */
@property (nonatomic,strong) HTMIABCAddressBookSelectedView *htmiAddressBookSelectedView;


#pragma mark --自定义属性

/**
 *  是否是单选
 */
@property (nonatomic,assign)BOOL isSingleSelection;

/**
 *  选择类型
 */
@property (nonatomic,assign)ChooseType chooseType;

/**
 *  指定的人员或者部门集合
 */
@property (nonatomic,strong)NSMutableArray * specificArray;

/**
 *  搜索结果数据源
 */
@property (strong, nonatomic) NSMutableArray *searchDataSource;

/**
 *  行数组
 */
@property (strong, nonatomic) NSMutableArray *allDataSource;

/**
 *  已选择的数组
 */
@property (strong, nonatomic) NSMutableArray *selectedDataSource;

/**
 *  记录当前点击的部门（当前页面的上一级部门）
 */
@property (nonatomic,strong)HTMIABCSYS_DepartmentModel *departmentModel;

/**
 *  上级部门集合
 */
@property (strong, nonatomic) NSMutableArray *higherLevelDepartmentArray;

/**
 *  用来存放已经被选中的集合
 */
//@property (strong, nonatomic) NSMutableArray *selectedDepartmentArray;

//@property (nonatomic,assign) NSUInteger totalOrders;
//动画需要

@property (nonatomic,strong) CALayer *dotLayer;

@property (nonatomic,assign) CGFloat endPointX;

@property (nonatomic,assign) CGFloat endPointY;

@property (nonatomic,strong) UIBezierPath *path;

@end

@implementation HTMIABCChooseFromOrganizationViewController

//默认初始化方法
- (instancetype)init{
    self = [super init];
    //默认单选用户
    if (self) {
        //不允许直接调用init进行初始化，如果这样调用程序就会崩溃
        //HTMI_Assert(NO);
        NSAssert(NO, @"不能直接使用莫用初始化方法进行调用");
        
        self.chooseType = ChooseTypeUserFromAll;
        self.isSingleSelection = YES;
    }
    return self;
}

#pragma mark - 初始化方法

- (instancetype)initWithChooseType:(ChooseType)chooseType isSingleSelection:(BOOL)isSingleSelection
                     specificArray:(NSArray *)specificArray{
    self = [super init];
    //默认单选用户
    if (self) {
        
        self.chooseType = chooseType;
        self.isSingleSelection = isSingleSelection;
        
        if (specificArray) {
            self.specificArray = [NSMutableArray arrayWithArray:specificArray];
        }
    }
    return self;
}

#pragma mark --生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;// 这句代码的意思是不让它扩展布局
    //注册顶部标签滑动监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseFormAddressBookViewControllerSelectIndexChange:) name:@"ChooseFormAddressBookViewControllerSelectIndexChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myClickReturn) name:@"HTMI_AddressBook_ClickReturn" object:nil];
    //初始化页面
    [self initUI];
    
    //初始化数据
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//移除所有通知
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    HTLog(@"HTMIABCChooseFromOrganizationViewController");
}


- (void)deleteSeletedCell:(HTMIABCSelectedFromAddressBookTableViewCell *)returnCell{
    
    if (self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeUserFromSpecific){
        
        //设置为未选中状态
        returnCell.sys_UserModel.isCheck = NO;
        //删除页面上的
        NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
        [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.sys_UserModel.UserId] forKey:@"nodeId"];
        [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
        /*
         HTMIABCSYS_UserModel * sysUsermodel = self.selectedDataSource[[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row];
         int departmentCodeLength = sysUsermodel.departmentCode.length;
         //这个部门上级的所有部门取消选中
         for (int i = 0; i < self.selectedDepartmentArray.count; i++) {
         HTMIABCSYS_DepartmentModel * model = self.selectedDepartmentArray[i];
         //可能是他的父部门
         if (departmentCodeLength >= model.DepartmentCode.length) {
         
         NSString * strCut = [sysUsermodel.departmentCode substringToIndex:model.DepartmentCode.length];
         
         if ([strCut isEqualToString:model.DepartmentCode]) {
         [self.selectedDepartmentArray removeObjectAtIndex:i];
         i--;
         }
         }
         //下级部门不用处理取消选中
         }
         */
    }
    else if(self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecific){
        
        //设置为未选中状态
        returnCell.sys_DepartmentModel.isCheck = NO;
        //删除页面上的
        NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
        [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
        [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
        
        /*
         HTMIABCSYS_DepartmentModel * sys_DepartmentModel = self.selectedDataSource[[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row];
         
         int departmentCodeLength = sys_DepartmentModel.DepartmentCode.length;
         
         //这个部门上级的所有部门取消选中
         for (int i = 0; i < self.selectedDepartmentArray.count; i++) {
         HTMIABCSYS_DepartmentModel * model = self.selectedDepartmentArray[i];
         //可能是他的父部门
         if (departmentCodeLength >= model.DepartmentCode.length) {
         
         NSString * strCut = [sys_DepartmentModel.DepartmentCode substringToIndex:model.DepartmentCode.length];
         
         if ([strCut isEqualToString:model.DepartmentCode]) {
         [self.selectedDepartmentArray removeObjectAtIndex:i];
         i--;
         }
         }
         }*/
    }
    else if(self.chooseType == ChooseTypeOrganization){
        //删除页面上的
        NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
        if (returnCell.sys_DepartmentModel) {
            //设置为未选中状态
            returnCell.sys_DepartmentModel.isCheck = NO;
            [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
        }
        else if(returnCell.sys_UserModel){
            //设置为未选中状态
            returnCell.sys_UserModel.isCheck = NO;
            [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.sys_UserModel.UserId] forKey:@"nodeId"];
        }
        
        [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
    }
    
    /*
     //删除之前应该将页面的也删除
     if ([self.selectedDataSource[[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row] isMemberOfClass:[HTMIABCSYS_UserModel class]]) {//人员选择
     HTMIABCSYS_UserModel * model = self.selectedDataSource[[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row];
     
     for (id object in self.allDataSource) {
     if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
     HTMIABCSYS_UserModel * sys_UserModel = object;
     if ([model.UserId isEqualToString:sys_UserModel.UserId ]) {
     
     sys_UserModel.isCheck = NO;
     
     break;
     }
     }
     else{
     
     HTMIABCSYS_DepartmentModel * DepartmentModel = object;
     
     BOOL exist = NO;
     
     for (HTMIABCSYS_DepartmentModel * sys_DepartmentModel in self.selectedDepartmentArray) {
     
     if ([sys_DepartmentModel.DepartmentCode isEqualToString:DepartmentModel.DepartmentCode]) {
     
     exist = YES;
     break;
     }
     }
     if (exist == NO) {
     DepartmentModel.isCheck = NO;
     }
     }
     }
     }
     else{//部门
     
     HTMIABCSYS_DepartmentModel * model = self.selectedDataSource[[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row];
     
     for (id object in self.allDataSource) {
     if ([object isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
     HTMIABCSYS_DepartmentModel * sys_DepartmentModel = object;
     if ([model.DepartmentCode isEqualToString:sys_DepartmentModel.DepartmentCode ]) {
     
     sys_DepartmentModel.isCheck = NO;
     break;
     }
     }
     }
     }*/
    
    
    NSIndexPath * indexPath = [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell];
    //执行删除操作
    [self.selectedDataSource removeObjectAtIndex:[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row];
    if (indexPath) {
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
    //设置当前选中人数
    [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
    [self.htmiAddressBookSelectedView updateFrame:self.htmiAddressBookSelectedView.htmiReOrderTableView];
    
    self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
    self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
    [self setCartImage];
}

// 设置section的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if ([tableView isEqual:self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView])
    {
        return SECTION_HEIGHT;
    }
    else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SECTION_HEIGHT)];
    
    if (section == 0) {
        
        UIButton *clear = [UIButton buttonWithType:UIButtonTypeCustom];
        clear.frame= CGRectMake(self.view.bounds.size.width - 100, 0, 100, SECTION_HEIGHT);
        [clear setTitle:@"清空已选择" forState:UIControlStateNormal];
        [clear setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        clear.titleLabel.textAlignment = NSTextAlignmentCenter;
        clear.titleLabel.font = [UIFont systemFontOfSize:12];
        [clear addTarget:self action:@selector(clearShoppingCart:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:clear];
        
        //底部加一条线
        UIView * splitView = [[UIView alloc]initWithFrame:CGRectMake(0, SECTION_HEIGHT - 1, kScreenWidth, 1)];
        splitView.backgroundColor = [UIColor colorWithHex:@"#CCCCCC"];// ;
        [view addSubview:splitView];
    }
    
    view.backgroundColor = [UIColor whiteColor];
    return view;
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {
        return self.selectedDataSource.count;
    }
    else{
        //主TableView中，需要判断是否是搜索
        if (!_isSearch) {
            return [self.allDataSource count];
        }else {
            return self.searchDataSource.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
        
        // 定义唯一标识
        static NSString *CellIdentifier = @"Cell";
        // 通过唯一标识创建cell实例
        HTMIABCSelectedFromAddressBookTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
        if (!cell) {
            
            cell = [[HTMIABCSelectedFromAddressBookTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        if ([self.selectedDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]) {//人员选择
            HTMIABCSYS_UserModel * model = self.selectedDataSource[indexPath.row];
            cell.sys_UserModel = model;
            cell.sys_DepartmentModel = nil;
        }
        else{//部门选择
            HTMIABCSYS_DepartmentModel * model = self.selectedDataSource[indexPath.row];
            cell.sys_DepartmentModel = model;
            cell.sys_UserModel = nil;
        }
        
        if (self.selectedDataSource.count > 0) {
            if (self.selectedDataSource.count - 1 == indexPath.row) {
                [cell  setSpliteViewHiden:YES];
            }
            else{
                [cell  setSpliteViewHiden:NO];
            }
        }
        
        @weakify(cell);
        @weakify(self);
        cell.deleteBlock = ^(HTMIABCSelectedFromAddressBookTableViewCell * returnCell){
            @strongify(self);
            @strongify(cell);
            [self deleteSeletedCell:cell];
            
        };
        
        //设置当前选中人数
        [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
        [self setCartImage];
        
        return cell;
        
    }
    else{//正常的或者是搜索的TableView
        
        //不是选择的情况
        if (!_isSearch){
            
            HTMIABCChooseFromAddressBookTableViewCell * cell = [HTMIABCChooseFromAddressBookTableViewCell cellWithTableView:tableView];
            
            if ([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]) {//人员选择
                HTMIABCSYS_UserModel * model = self.allDataSource[indexPath.row];
                model.chooseType = self.chooseType;
                cell.sys_UserModel = model;
                cell.sys_DepartmentModel = nil;
                //处理用户数据和选中事件
                [self dealWithUser:model cell:cell];
                
            }
            else{//部门
                
                HTMIABCSYS_DepartmentModel * model = self.allDataSource[indexPath.row];
                model.chooseType = self.chooseType;
                cell.sys_DepartmentModel = model;
                cell.sys_UserModel = nil;
                //处理部门数据和选中事件
                [self dealWithDepartment:model cell:cell];
                
            }
            
            return cell;
        }else{

            HTMIABCChooseFromAddressBookTableViewCell * cell = [HTMIABCChooseFromAddressBookTableViewCell cellWithTableView:tableView];
            
            if ([self.searchDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                HTMIABCSYS_UserModel * model = self.searchDataSource[indexPath.row];
                
                cell.sys_UserModel = model;
                cell.sys_DepartmentModel = nil;
                //处理用户数据和选中事件
                [self dealWithUser:model cell:cell];
            }
            else{//部门
                
                HTMIABCSYS_DepartmentModel * model = self.searchDataSource[indexPath.row];
                
                cell.sys_DepartmentModel = model;
                cell.sys_UserModel = nil;
                
                //处理部门数据和选中事件
                [self dealWithDepartment:model cell:cell];
            }
            
            cell.checkButton.enabled = YES;
            cell.checkImageView.hidden = NO;
            cell.pushImageView.hidden = YES;
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView != self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {
        
        if (!_isSearch) {//不是检索的情况
            
            HTMIABCChooseFromAddressBookTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            NSObject * model = self.allDataSource[indexPath.row];
            
            if ([model isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
                vc.sys_UserModel = (HTMIABCSYS_UserModel *)model;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
            
            if ([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
                
                HTMIABCSYS_DepartmentModel * model = self.allDataSource[indexPath.row];
                //点击部门跳转，将检索出来的存入页面数组中
                if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecific) {
                    //判断能否跳转
                    
                    if (cell.pushImageView.hidden == YES) {
                        return;
                    }
                    
                    //检索部门以及子部门的所有用户
                    [self.higherLevelDepartmentArray addObject:model];
                    
                    self.departmentModel = [model copy];
                    
                    [self.allDataSource removeAllObjects];
                    //刷新列表
                    [self.searchTableView reloadData];
                    
                    
                    //[Loading showLoadingWithView:nil];
                    [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeNone];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //获取当前子部门 --从数据库
                        self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartments:model.DepartmentCode];
                        
                        for (HTMIABCSYS_DepartmentModel *objectSelected in self.selectedDataSource) {
                            
                            for (HTMIABCSYS_DepartmentModel *object in self.allDataSource) {
                                
                                if ([object.DepartmentCode isEqualToString:objectSelected.DepartmentCode]) {
                                    object.isCheck = YES;
                                }
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            //[Loading hiddonLoadingWithView:nil];
                            [HTMIWFCSVProgressHUD dismiss];
                            
                            [self.searchTableView reloadData];
                        });
                    });
                }
                else if(self.chooseType == ChooseTypeUserFromAll ||self.chooseType == ChooseTypeUserFromSpecific || self.chooseType == ChooseTypeOrganization)
                {
                    //判断能否跳转
                    HTMIABCChooseFromAddressBookTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                    if (cell.pushImageView.hidden == YES) {
                        return;
                    }
                    
                    //检索部门以及子部门的所有用户
                    [self.higherLevelDepartmentArray addObject:model];
                    
                    self.departmentModel = [model copy];
                    
                    [self.allDataSource removeAllObjects];
                    //刷新列表
                    [self.searchTableView reloadData];
                    
                    //[Loading showLoadingWithView:nil];
                    [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeNone];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //获取当前子部门和人员 -从数据库
                        self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:model.DepartmentCode];
                        
                        for (NSObject * objectSelected in self.selectedDataSource) {
                            
                            if ([objectSelected isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                                HTMIABCSYS_UserModel *objectSelectedUserModel =  (HTMIABCSYS_UserModel *)objectSelected;
                                for (id object in self.allDataSource) {
                                    
                                    if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                                        HTMIABCSYS_UserModel *model =  object;
                                        if ([model.UserId isEqualToString:objectSelectedUserModel.UserId]) {
                                            model.isCheck = YES;
                                            
                                        }
                                    }
                                    else{
                                        
                                        //HTMIABCSYS_DepartmentModel *model =  object;
                                        
                                        /*for (HTMIABCSYS_DepartmentModel *sysModel in self.selectedDepartmentArray) {
                                         if ([model.DepartmentCode isEqualToString:sysModel.DepartmentCode]) {
                                         model.isCheck = YES;
                                         }
                                         }*/
                                        
                                    }
                                }
                            }
                            else{
                                HTMIABCSYS_DepartmentModel *objectSelectedDepartmentModel =  (HTMIABCSYS_DepartmentModel *)objectSelected;
                                for (id object in self.allDataSource) {
                                    
                                    if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                                        
                                    }
                                    else{
                                        HTMIABCSYS_DepartmentModel *model =  object;
                                        
                                        if ([model.DepartmentCode isEqualToString:objectSelectedDepartmentModel.DepartmentCode]) {
                                            model.isCheck = YES;
                                        }
                                        
                                        
                                        /*
                                         HTMIABCSYS_DepartmentModel *model =  object;
                                         for (HTMIABCSYS_DepartmentModel *sysModel in self.selectedDepartmentArray) {
                                         if ([model.DepartmentCode isEqualToString:sysModel.DepartmentCode]) {
                                         model.isCheck = YES;
                                         }
                                         }*/
                                    }
                                }
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            //[Loading hiddonLoadingWithView:nil];
                            [HTMIWFCSVProgressHUD dismiss];
                            [self.searchTableView reloadData];
                        });
                    });
                }
            }
            else if([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]){
                //如果是人员不用处理
                
            }
            else{
                
            }
            
        }else{//检索的情况不需要处理
            
            NSObject * model = self.searchDataSource[indexPath.row];
            if ([model isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
                vc.sys_UserModel = (HTMIABCSYS_UserModel *)model;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
    }
    else{//不处理底部TableView的选择事件
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _isSearch = YES;
    //1、清空整个搜索结果数组
    [self.searchDataSource removeAllObjects];
    [self.searchTableView reloadData];
    
    if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecific) {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * departmentArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:searchText inDepartment:self.departmentModel.DepartmentCode];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (departmentArray && departmentArray.count > 0) {
                    
                    for (HTMIABCSYS_DepartmentModel* objectSelected in self.selectedDataSource) {
                        
                        for (HTMIABCSYS_DepartmentModel * object in departmentArray) {
                            
                            if ([object.DepartmentCode isEqualToString:objectSelected.DepartmentCode]) {
                                
                                object.isCheck = YES;
                            }
                        }
                    }
                    
                    //                    _isSearch = YES;
                    self.searchDataSource = departmentArray;
                    
                    [self.searchTableView reloadData];
                }
            });
        });
    }
    /* else if (self.chooseType == ChooseTypeDepartmentFromSpecific){
     NSString * suoxie = @"";
     NSMutableString *sb = [NSMutableString new];
     for(int i = 0 ; i < searchText.length; i++){
     
     suoxie = [self firstCharactor:[searchText substringWithRange:NSMakeRange(i,1)]];
     
     [sb appendString:suoxie];
     }
     
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"PinYinQuanPin contains %@",[self transformToPinyin:searchText]];
     
     NSArray * arrTemp = [self.allDataSource filteredArrayUsingPredicate:predicate];
     if (arrTemp) {
     _isSearch = YES;
     self.searchDataSource =  [NSMutableArray arrayWithArray:arrTemp];
     [self.searchTableView reloadData];
     }
     }*/
    else if (self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeUserFromSpecific){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:self.departmentModel.DepartmentCode];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (userArray && userArray.count > 0) {
                    
                    for (HTMIABCSYS_UserModel * objectSelected in self.selectedDataSource) {
                        
                        for (HTMIABCSYS_UserModel * object in userArray) {
                            
                            if ([object.UserId isEqualToString:objectSelected.UserId]) {
                                object.isCheck = YES;
                            }
                        }
                    }
                    
                    //                    _isSearch = YES;
                    self.searchDataSource = userArray;
                    
                    [self.searchTableView reloadData];
                }
            });
        });
    }
    else if (self.chooseType == ChooseTypeUserFromSpecific){
        /*
         NSString * suoxie = @"";
         NSMutableString *sb = [NSMutableString new];
         for(int i = 0 ; i < searchText.length; i++){
         
         suoxie = [self firstCharactor:[searchText substringWithRange:NSMakeRange(i,1)]];
         
         [sb appendString:suoxie];
         }
         
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"suoXie contains %@ or Mobile contains %@ or Telephone contains %@ or pinyin contains %@", sb, searchText,searchText,[searchText lowercaseString]];
         
         NSArray * arrTemp = [self.allDataSource filteredArrayUsingPredicate:predicate];
         if (arrTemp) {
         _isSearch = YES;
         self.searchDataSource =  [NSMutableArray arrayWithArray:arrTemp];
         [self.searchTableView reloadData];
         }*/
    }
    else if (self.chooseType == ChooseTypeOrganization){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * departmentArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:searchText inDepartment:self.departmentModel.DepartmentCode];
            NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:self.departmentModel.DepartmentCode];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSMutableArray * allSearchDateArray = [NSMutableArray arrayWithArray:departmentArray];
                [allSearchDateArray addObjectsFromArray:userArray];
                
                if (allSearchDateArray && allSearchDateArray.count > 0) {
                    
                    for (NSObject* objectSelected in self.selectedDataSource) {
                        
                        if ([objectSelected isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
                            HTMIABCSYS_DepartmentModel * sys_DepartmentModelSelected =  (HTMIABCSYS_DepartmentModel *)objectSelected;
                            for (HTMIABCSYS_DepartmentModel * object in departmentArray) {
                                
                                if ([object.DepartmentCode isEqualToString:sys_DepartmentModelSelected.DepartmentCode]) {
                                    
                                    object.isCheck = YES;
                                }
                            }
                        }
                        else{
                            
                            HTMIABCSYS_UserModel * sys_UserModelSelected =  (HTMIABCSYS_UserModel *)objectSelected;
                            for (HTMIABCSYS_UserModel * object in userArray) {
                                if ([object.UserId isEqualToString:sys_UserModelSelected.UserId]) {
                                    object.isCheck = YES;
                                }
                            }
                        }
                    }
                    
                    //                    _isSearch = YES;
                    self.searchDataSource = allSearchDateArray;
                    
                    [self.searchTableView reloadData];
                }
            });
        });
    }
}

//用来控制是否可以编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_HidePageTag" object:@"0" userInfo:nil];
    self.view.backgroundColor = [UIColor colorWithHex:@"#F2F2F4"];
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = YES;
        self.mainSearchBar.showsCancelButton = YES;
        
        self.mainSearchBar.frame = CGRectMake(0, 20, kScreenWidth, 44);
        self.searchTableView.frame = CGRectMake(0, 44 + 20, kScreenWidth, kScreenHeight - 64 - kHSelectedViewHeight);
        self.htmiAddressBookSelectedView.frame = CGRectMake(0, kScreenHeight - kHSelectedViewHeight, kScreenWidth, 50);
        
        CGRect rect = [self.view convertRect:self.htmiAddressBookSelectedView.shoppingCartBtn.frame fromView:self.htmiAddressBookSelectedView];
        _endPointX = rect.origin.x + 15;
        _endPointY = rect.origin.y + 35;
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_HidePageTag" object:@"1" userInfo:nil];
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = NO;
        self.mainSearchBar.showsCancelButton = NO;
        
        self.mainSearchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
        self.searchTableView.frame = CGRectMake(0, 44, kScreenWidth, kScreenHeight - 64 - [[HTMIWFCSettingManager manager] choosePageTagHight]- 44 -kHSelectedViewHeight);
        self.htmiAddressBookSelectedView.frame = CGRectMake(0, kScreenHeight - kHSelectedViewHeight - [[HTMIWFCSettingManager manager] choosePageTagHight] - 64, CGRectGetWidth(self.view.bounds), 50);
        CGRect rect = [self.view convertRect:self.htmiAddressBookSelectedView.shoppingCartBtn.frame fromView:self.htmiAddressBookSelectedView];
        _endPointX = rect.origin.x + 15;
        _endPointY = rect.origin.y + 35;
    }];
    
    [self.mainSearchBar resignFirstResponder];
    self.mainSearchBar.text = @"";
    _isSearch = NO;
    
    //可能是在当前页面进行的搜索，所以搜索选择完人员之后需要进行处理
    if (self.chooseType == ChooseTypeDepartmentFromAll){
        
        for (HTMIABCSYS_DepartmentModel *objectSelected in self.selectedDataSource) {
            
            for (HTMIABCSYS_DepartmentModel *object in self.allDataSource) {
                
                if ([object.DepartmentCode isEqualToString:objectSelected.DepartmentCode]) {
                    object.isCheck = YES;
                }
            }
        }
        
    }else if(self.chooseType == ChooseTypeUserFromAll){
        
        for (HTMIABCSYS_UserModel * objectSelected in self.selectedDataSource) {
            
            for (id object in self.allDataSource) {
                
                if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                    HTMIABCSYS_UserModel *model =  object;
                    if ([model.UserId isEqualToString:objectSelected.UserId]) {
                        model.isCheck = YES;
                    }
                }
            }
        }
    }
    
    [self.searchTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    //    [self.mainSearchBar resignFirstResponder];
    [self searchBarResignAndChangeUI];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    [self searchBarResignAndChangeUI];
    
}

- (void)searchBarResignAndChangeUI{
    
    [self.mainSearchBar resignFirstResponder];//失去第一响应
    
    [self changeSearchBarCancelBtnTitleColor:self.mainSearchBar];//改变布局
    
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    UIFont *font = [UIFont boldSystemFontOfSize:14.0];
    UIColor *textColor = RGBA(102, 102, 102, 1);
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    if (self.mainSearchBar.text.length > 0) {
        NSString *text = @"暂无搜索结果，请重试";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    else{
        return nil;
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.mainSearchBar.text.length > 0) {
        return [UIImage getPNGImageHTMIWFC:@"img_search_fruitless"];
    }
    else{
        return nil;
    }
}

#pragma mark --事件

///**
// * 完成点击事件
// */
//- (void)clickDone{
//
//}

/**
 *  返回按钮点击事件
 */
- (void)myClickReturn{
    
    if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization || self.chooseType == ChooseTypeUserFromSpecific || self.chooseType == ChooseTypeDepartmentFromSpecific){
        
        if (self.higherLevelDepartmentArray.count > 0) {
            
            [self.higherLevelDepartmentArray removeLastObject];
            
            if (self.higherLevelDepartmentArray.count <= 0) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else{
                
                //选中之后可能是当前部门下的全选，如果是全选，将部门添加到选中部门的集合中
                [self checkCurrentModelisCheckAll];
                
                HTMIABCSYS_DepartmentModel *model = [self.higherLevelDepartmentArray lastObject] ;
                
                self.departmentModel = [model copy];
                
                if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecific) {
                    
                    [self.allDataSource removeAllObjects];
                    //刷新列表
                    [self.searchTableView reloadData];
                    
                    
                    //                    [Loading showLoadingWithView:nil];
                    //
                    //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //
                    //获取当前子部门 --从数据库
                    self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartments:model.DepartmentCode];
                    
                    for (HTMIABCSYS_DepartmentModel *objectSelected in self.selectedDataSource) {
                        
                        for (HTMIABCSYS_DepartmentModel *object in self.allDataSource) {
                            
                            if ([object.DepartmentCode isEqualToString:objectSelected.DepartmentCode]) {
                                object.isCheck = YES;
                            }
                        }
                    }
                    
                    //                        dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[Loading hiddonLoadingWithView:nil];
                    [HTMIWFCSVProgressHUD dismiss];
                    [self.searchTableView reloadData];
                    //                        });
                    //                    });
                }
                else if(self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization || self.chooseType == ChooseTypeUserFromSpecific)
                {
                    
                    [self.allDataSource removeAllObjects];
                    //刷新列表
                    [self.searchTableView reloadData];
                    
                    //                    [Loading showLoadingWithView:nil];
                    //
                    //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //
                    //获取当前子部门和人员 -从数据库
                    self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:model.DepartmentCode];
                    
                    
                    for (id object in self.allDataSource) {
                        
                        for (NSObject * objectSelected in self.selectedDataSource) {
                            
                            if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                                HTMIABCSYS_UserModel *model =  object;
                                
                                if ([objectSelected isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                                    if ([model.UserId isEqualToString:((HTMIABCSYS_UserModel *)objectSelected).UserId]) {
                                        model.isCheck = YES;
                                    }
                                }
                            }
                            else{
                                HTMIABCSYS_DepartmentModel *model =  object;
                                if ([objectSelected isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
                                    if ([model.DepartmentCode isEqualToString:((HTMIABCSYS_DepartmentModel *)objectSelected).DepartmentCode]) {
                                        model.isCheck = YES;
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    //                        dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[Loading hiddonLoadingWithView:nil];
                    [HTMIWFCSVProgressHUD dismiss];
                    [self.searchTableView reloadData];
                    //                        });
                    //                    });
                }
                
                
                //刷新表格
                [self.searchTableView reloadData];
            }
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 *  初始化控件
 */
- (void)initUI{
    
    [self.view addSubview:self.searchTableView];
    [self.view addSubview:self.mainSearchBar];
    [self.view addSubview:self.htmiAddressBookSelectedView];
    
    CGRect rect = [self.view convertRect:self.htmiAddressBookSelectedView.shoppingCartBtn.frame fromView:self.htmiAddressBookSelectedView];
    
    _endPointX = rect.origin.x + 15;
    _endPointY = rect.origin.y + 35;
    
    
    self.searchTableView.tableFooterView = [UIView new];
    
    self.mainSearchBar.showsCancelButton = NO;
}

/**
 *  初始化数据
 */
- (void)initData{
    
    //判断选择类型
    if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization || self.chooseType == ChooseTypeDepartmentFromSpecific ||  self.chooseType == ChooseTypeUserFromSpecific) { //从所有部门中选择.
        
        HTMIABCSYS_DepartmentModel * sys_DepartmentModel = [[HTMIABCDBHelper sharedYMDBHelperTool]getRootDepartment];
        //虚拟一个根节点以上的部门 DepartmentCode = 根节点的parentCode 添加到
        HTMIABCSYS_DepartmentModel * model = [HTMIABCSYS_DepartmentModel new];
        model.DepartmentCode = sys_DepartmentModel.ParentDepartment;
        self.departmentModel = model;
        [self.higherLevelDepartmentArray addObject:model];
        
        //[Loading showLoadingWithView:nil];
        [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeNone];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //根据上级部门检索
            if (self.departmentModel == nil) {
                
                //说明是根节点
                self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:sys_DepartmentModel.ParentDepartment];
                
            }
            else{
                //获取
                self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:self.departmentModel.DepartmentCode];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[Loading hiddonLoadingWithView:nil];
                [HTMIWFCSVProgressHUD dismiss];
                
                [self.searchTableView reloadData];
            });
        });
    }
    /*else if (self.chooseType == ChooseTypeDepartmentFromSpecific){//从指定的部门中选择
     
     
     for (NSString *object in self.specificArray) {
     
     HTMIABCSYS_DepartmentModel * model = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentByDepartmentCode:object];
     if (model) {
     [self.allDataSource addObject:model];
     [self.searchDataSource addObject:model];
     }
     
     }
     
     [self.searchTableView reloadData];
     
     }*/
    /*else if (self.chooseType == ChooseTypeUserFromSpecific) {
     
     for (NSString *object in self.specificArray) {
     
     HTMIABCSYS_UserModel * model = [[HTMIABCDBHelper sharedYMDBHelperTool]getCurrentUserInfo:object];
     if (model) {
     [self.allDataSource addObject:model];
     [self.searchDataSource addObject:model];
     }
     
     }
     [self.searchTableView reloadData];
     
     } */
    
}

#pragma mark -- 处理部门Cell(包括选中事件)

/**
 *  处理部门Cell
 *
 *  @param model 部门模型
 *  @param cell  cell
 */
- (void)dealWithDepartment:(HTMIABCSYS_DepartmentModel *)model  cell:(HTMIABCChooseFromAddressBookTableViewCell *)cell{
    
    cell.checkBlock = ^(HTMIABCChooseFromAddressBookTableViewCell *returnCell){ //选中后触发的事件
        
        //block中不应该依赖
        returnCell.sys_DepartmentModel.isCheck = !returnCell.sys_DepartmentModel.isCheck;
        
        
        if (returnCell.sys_DepartmentModel.isCheck == YES) {
            
            //加入购物车动画
            CGRect parentRect = [returnCell convertRect:returnCell.checkImageView.frame toView:self.view];
            [self JoinCartAnimationWithRect:parentRect];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
            [dic setObject:@"1" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            //如果是单选需要处理
            if (self.isSingleSelection == YES) {
                
                [self dealDepartmentSingleSelectionCheck:returnCell];
                
            }
            else{
                
                [self dealDepartmentMultiSelectCheck:returnCell];
            }
        }
        else{
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            //如果是单选需要处理
            if (self.isSingleSelection == YES) {
                
                [self dealDepartmentSingleSelectionUnCheck:returnCell];
            }
            else{
                [self dealDepartmentMultiSelectUnCheck:returnCell];
            }
        }
        
        [self setCartImage];
        [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
    };
}

#pragma mark --部门单选选中处理

/**
 *  部门单选选中处理
 *
 *  @param returnCell TableViewCell
 */
- (void)dealDepartmentSingleSelectionCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    //如果已选数组中有那么就将已选数组中的移除，将这个添加进去，没有直接添加
    //wlq add
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        
    }
    else{
        if (self.selectedDataSource.count > 0) {
            
            /*
             //先获取最后一个，将模型的isCheck属性设置成NO
             NSObject * selectedModel = [self.selectedDataSource lastObject];
             
             if ([selectedModel isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
             HTMIABCSYS_DepartmentModel * sys_DepartmentModelSelected = (HTMIABCSYS_DepartmentModel *)selectedModel;
             
             for (id object in self.allDataSource) {
             if ([object isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
             HTMIABCSYS_DepartmentModel * sys_DepartmentModel = object;
             if ([sys_DepartmentModelSelected.DepartmentCode isEqualToString:sys_DepartmentModel.DepartmentCode ]) {
             sys_DepartmentModel.isCheck = NO;
             }
             }
             }
             
             if (_isSearch == YES) {
             //wlq add 当时选择的时候需要处理选择结果中选中多个的问题
             //检索出来的可能有部门也可能有用户
             for (NSObject * tempModel in self.searchDataSource) {
             if ([tempModel isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
             
             HTMIABCSYS_DepartmentModel * selected = (HTMIABCSYS_DepartmentModel *)tempModel;
             if ([selected.DepartmentCode isEqualToString:sys_DepartmentModelSelected.DepartmentCode]) {
             selected.isCheck = NO;
             }
             }
             }
             }
             
             }
             else{
             HTMIABCSYS_UserModel * sys_UserModelSelected = (HTMIABCSYS_UserModel *)selectedModel;
             
             for (id object in self.allDataSource) {
             if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
             HTMIABCSYS_UserModel * sys_UserModel = object;
             if ([sys_UserModelSelected.UserId isEqualToString:sys_UserModel.UserId]) {
             sys_UserModel.isCheck = NO;
             }
             }
             }
             }*/
            //先获取最后一个，将模型的isCheck属性设置成NO
            
            //自由选择需要被考虑
            NSObject * selectedModel = [self.selectedDataSource lastObject];
            
            if (selectedModel) {
                
                NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
                if ([selectedModel isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                    HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)selectedModel;
                    model.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
                    [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",model.UserId] forKey:@"nodeId"];
                }
                else{
                    HTMIABCSYS_DepartmentModel * model = (HTMIABCSYS_DepartmentModel *)selectedModel;
                    model.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
                    [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",model.DepartmentCode] forKey:@"nodeId"];
                }
                
                [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
            }
            
            [self.selectedDataSource removeAllObjects];//先移除再添加
            [self.selectedDataSource insertObject:[returnCell.sys_DepartmentModel copy] atIndex:0];
        }
        else{
            [self.selectedDataSource insertObject:[returnCell.sys_DepartmentModel copy] atIndex:0];
        }
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
    }
}

#pragma mark --部门单选取消选中处理

- (void)dealDepartmentSingleSelectionUnCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    //wlq add
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        
    }
    else{
        /*
         //如果已选数组中有那么就将已选数组中的移除，将这个添加进去，没有直接添加
         //先获取最后一个，将模型的isCheck属性设置成NO
         HTMIABCSYS_DepartmentModel * model = [self.selectedDataSource lastObject];
         
         for (id object in self.allDataSource) {
         if ([object isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]){
         HTMIABCSYS_DepartmentModel * sys_DepartmentModel = object;
         if ([model.DepartmentCode isEqualToString:sys_DepartmentModel.DepartmentCode ]) {
         sys_DepartmentModel.isCheck = NO;
         }
         }
         }*/
        
        //        HTMIABCDynamicTreeNode * node = [self.selectedDataSource lastObject];
        //
        //        if (node) {
        //            node.isCheck = NO;
        //        }
        
        [self.selectedDataSource removeAllObjects];//
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
    }
}

#pragma mark --部门多选选中处理


- (void)dealDepartmentMultiSelectCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    
    //wlq add
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        /*
         //用户多选时可以选择部门进行选择子部门的所有人员
         
         //1、从数据库中获取所有字部门的人员，添加到集合，并且去除重复的
         
         NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:@"" inDepartment:returnCell.sys_DepartmentModel.DepartmentCode];
         
         //获取所有子部门
         NSMutableArray * arrayDepartArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:@"" inDepartment:returnCell.sys_DepartmentModel.DepartmentCode];
         
         //应该去除重复
         for (int i = 0; i < arrayDepartArray.count; i++) {
         
         HTMIABCSYS_DepartmentModel *sysDepartmentModel = arrayDepartArray[i];
         for (HTMIABCSYS_DepartmentModel *model in self.selectedDepartmentArray) {
         
         if ([sysDepartmentModel.DepartmentCode isEqualToString:model.DepartmentCode]) {
         
         [arrayDepartArray removeObjectAtIndex:i];
         i--;
         }
         }
         }
         
         [self.selectedDepartmentArray addObjectsFromArray:arrayDepartArray];
         //把它本身也装进去
         [self.selectedDepartmentArray addObject:[returnCell.sys_DepartmentModel copy]];
         
         #warning 用户多了会造成卡顿
         //去除重复的添加到选中集合中
         for (int i = 0; i < userArray.count; i++) {
         
         HTMIABCSYS_UserModel *sys_UserModelAll = userArray[i];
         for (HTMIABCSYS_UserModel *sys_UserModel in self.selectedDataSource) {
         
         if ([sys_UserModelAll.UserId isEqualToString:sys_UserModel.UserId]) {
         
         [userArray removeObjectAtIndex:i];
         i--;
         }
         }
         }
         
         //wlq update 插入到最前面
         NSRange range = NSMakeRange(0, [userArray count]);
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
         
         [self.selectedDataSource insertObjects:userArray atIndexes:indexSet];
         [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
         */
    }
    else if (self.chooseType == ChooseTypeDepartmentFromAll){
        /*
         //获取所有子部门
         NSMutableArray * arrayDepartArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:@"" inDepartment:returnCell.sys_DepartmentModel.DepartmentCode];
         
         //将自身插入到数组中
         [arrayDepartArray insertObject:[returnCell.sys_DepartmentModel copy] atIndex:0];
         
         //去除重复的添加到选中集合中
         for (int i = 0; i < arrayDepartArray.count; i++) {
         
         HTMIABCSYS_DepartmentModel * sys_DepartmentModel = arrayDepartArray[i];
         for (HTMIABCSYS_DepartmentModel *model in self.selectedDataSource) {
         
         if ([sys_DepartmentModel.DepartmentCode isEqualToString:model.DepartmentCode]) {
         
         [arrayDepartArray removeObjectAtIndex:i];
         i--;
         }
         }
         }
         
         NSRange range = NSMakeRange(0, [arrayDepartArray count]);
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
         
         [self.selectedDataSource insertObjects:arrayDepartArray atIndexes:indexSet];
         [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
         */
        
        //判断是否在已选数组中存在如果存在那么不添加
        BOOL isExist = NO;
        
        for (HTMIABCSYS_DepartmentModel *sysModel in self.selectedDataSource) {
            if ([sysModel.DepartmentCode isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
                isExist = YES;
            }
        }
        
        if (isExist == NO) {
            
            [self.selectedDataSource insertObject:[returnCell.sys_DepartmentModel copy] atIndex:0];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        }
        
    }
    else{
        
        //判断是否在已选数组中存在如果存在那么不添加
        BOOL isExist = NO;
        
        for (HTMIABCSYS_DepartmentModel *sysModel in self.selectedDataSource) {
            if ([sysModel.DepartmentCode isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
                isExist = YES;
            }
        }
        
        if (isExist == NO) {
            
            [self.selectedDataSource insertObject:[returnCell.sys_DepartmentModel copy] atIndex:0];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        }
    }
}


#pragma mark --部门多选取消选中处理

- (void)dealDepartmentMultiSelectUnCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    //wlq add 取消选中部门的处理
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        /*
         int departmentCodeLength = returnCell.sys_DepartmentModel.DepartmentCode.length;
         
         for (int i= 0; i < self.selectedDataSource.count; i++) {
         
         HTMIABCSYS_UserModel *sys_UserModel = self.selectedDataSource[i];
         //1、这个部门下的全部设置为不选中的状态
         if (sys_UserModel.departmentCode.length >= departmentCodeLength) { //可能在这个部门下面的
         
         NSString * strCut = [sys_UserModel.departmentCode substringToIndex:departmentCodeLength];
         
         if ([strCut isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
         
         //直接移除
         [self.selectedDataSource removeObjectAtIndex:i];
         i--;
         }
         }
         }
         
         //这个部门上级的所有部门取消选中
         for (int i = 0; i < self.selectedDepartmentArray.count; i++) {
         HTMIABCSYS_DepartmentModel * model = self.selectedDepartmentArray[i];
         //可能是他的父部门
         if (departmentCodeLength >= model.DepartmentCode.length) {
         
         NSString * strCut = [returnCell.sys_DepartmentModel.DepartmentCode substringToIndex:model.DepartmentCode.length];
         
         if ([strCut isEqualToString:model.DepartmentCode]) {
         [self.selectedDepartmentArray removeObjectAtIndex:i];
         i--;
         }
         
         }
         else{//下级部门也要取消选中
         
         //当前部门截取长度
         NSString * strCut = [model.DepartmentCode substringToIndex:departmentCodeLength];
         
         if ([strCut isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
         
         //直接移除
         [self.selectedDepartmentArray removeObjectAtIndex:i];
         i--;
         }
         }
         
         }
         
         [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
         */
        
    }
    else if (self.chooseType == ChooseTypeDepartmentFromAll){
        /*
         
         int departmentCodeLength = returnCell.sys_DepartmentModel.DepartmentCode.length;
         
         for (int i= 0; i < self.selectedDataSource.count; i++) {
         
         HTMIABCSYS_DepartmentModel *sys_DepartmentModel = self.selectedDataSource[i];
         //1、这个部门下的全部设置为不选中的状态
         if (sys_DepartmentModel.DepartmentCode.length >= departmentCodeLength) { //可能在这个部门下面的
         
         NSString * strCut = [sys_DepartmentModel.DepartmentCode substringToIndex:departmentCodeLength];
         
         if ([strCut isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
         
         //直接移除
         [self.selectedDataSource removeObjectAtIndex:i];
         i--;
         }
         }
         else{
         
         NSString * strCut = [returnCell.sys_DepartmentModel.DepartmentCode substringToIndex:sys_DepartmentModel.DepartmentCode.length];
         
         if ([strCut isEqualToString:sys_DepartmentModel.DepartmentCode]) {
         [self.selectedDataSource removeObjectAtIndex:i];
         i--;
         }
         
         }
         }
         
         [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
         //self.selectedCountLabel.text = [NSString stringWithFormat:@"%d",self.selectedDataSource.count];
         */
        //判断是否在已选数组中存在如果存在那么不添加
        for (HTMIABCSYS_DepartmentModel *sysModel in self.selectedDataSource) {
            
            if ([sysModel.DepartmentCode isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
                
                [self.selectedDataSource removeObject:sysModel];
                [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
                
                break;
            }
        }
        
    }
    else{
        //判断是否在已选数组中存在如果存在那么不添加
        for (HTMIABCSYS_DepartmentModel *sysModel in self.selectedDataSource) {
            
            if ([sysModel.DepartmentCode isEqualToString:returnCell.sys_DepartmentModel.DepartmentCode]) {
                
                [self.selectedDataSource removeObject:sysModel];
                [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
                
                break;
            }
        }
    }
}


#pragma mark -- *********************************************************************************************************

#pragma mark -- 处理用户Cell(包括选中事件)

/**
 *  处理用户cell
 *
 *  @param model 用户模型
 *  @param cell  cell
 */
- (void)dealWithUser:(HTMIABCSYS_UserModel *)model cell:(HTMIABCChooseFromAddressBookTableViewCell *)cell{
    
    //处理选中事件
    cell.checkBlock = ^(HTMIABCChooseFromAddressBookTableViewCell *returnCell){ //选中后触发的事件
        
        returnCell.sys_UserModel.isCheck = !returnCell.sys_UserModel.isCheck;
        
        if (returnCell.sys_UserModel.isCheck == YES) {
            
            //加入购物车动画
            CGRect parentRect = [returnCell convertRect:returnCell.checkImageView.frame toView:self.view];
            [self JoinCartAnimationWithRect:parentRect];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.sys_UserModel.UserId] forKey:@"nodeId"];
            [dic setObject:@"1" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            //如果是单选需要处理
            if (self.isSingleSelection == YES) {
                
                [self dealUserSingleSelectionCheck:returnCell];
            }
            else{
                
                [self dealUserMultiSelectCheck:returnCell];
            }
        }
        else{
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.sys_UserModel.UserId] forKey:@"nodeId"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            //如果是单选需要处理
            if (self.isSingleSelection == YES) {
                
                [self dealUserSingleSelectionUnCheck:returnCell];
                
            }
            else{
                
                [self dealUserMultiSelectUnCheck:returnCell];
            }
        }
        
        [self setCartImage];
        [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
    };
}


#pragma mark -- 用户单选选中处理

/**
 *  部门单选选中处理
 *
 *  @param returnCell TableViewCell
 */
- (void)dealUserSingleSelectionCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    //如果已选数组中有那么就将已选数组中的移除，将这个添加进去，没有直接添加
    
    if (self.selectedDataSource.count > 0) {
        //需要考虑可能是自由选
        //先获取最后一个，将模型的isCheck属性设置成NO
        NSObject * model = [self.selectedDataSource lastObject];
        
        if (model) {
            
            if ([model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                
                HTMIABCSYS_UserModel * sys_UserModel = (HTMIABCSYS_UserModel *)model;
                sys_UserModel.isCheck = NO;
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSString stringWithFormat:@"%@",sys_UserModel.UserId] forKey:@"nodeId"];
                [dic setObject:@"0" forKey:@"checkState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            }
            else{
                
                HTMIABCSYS_DepartmentModel *sys_DepartmentModel = (HTMIABCSYS_DepartmentModel *)model;
                sys_DepartmentModel.isCheck = NO;
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSString stringWithFormat:@"%@",sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
                [dic setObject:@"0" forKey:@"checkState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            }
        }
        
        /*
         //先获取最后一个，将模型的isCheck属性设置成NO
         NSObject * model = [self.selectedDataSource lastObject];
         
         if ([model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
         
         HTMIABCSYS_UserModel * selectedHTMIABCSYS_UserModel = (HTMIABCSYS_UserModel *)model;
         for (id object in self.allDataSource) {
         if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
         HTMIABCSYS_UserModel * sys_UserModel = object;
         if ([selectedHTMIABCSYS_UserModel.UserId isEqualToString:sys_UserModel.UserId ]) {
         sys_UserModel.isCheck = NO;
         }
         }
         }
         
         if (_isSearch == YES) {
         //wlq add 当时选择的时候需要处理选择结果中选中多个的问题
         //检索出来的可能有部门也可能有用户
         for (NSObject * tempModel in self.searchDataSource) {
         if ([tempModel isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
         
         HTMIABCSYS_UserModel * selected = (HTMIABCSYS_UserModel *)tempModel;
         if ([selected.UserId isEqualToString:selectedHTMIABCSYS_UserModel.UserId]) {
         selected.isCheck = NO;
         }
         }
         }
         }
         else{
         
         }
         }*/
        
        [self.selectedDataSource removeAllObjects];//先移除再添加
        [self.selectedDataSource insertObject:[returnCell.sys_UserModel copy] atIndex:0];
    }
    else{
        [self.selectedDataSource insertObject:[returnCell.sys_UserModel copy] atIndex:0];
    }
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
}

#pragma mark --用户单选取消选中处理

- (void)dealUserSingleSelectionUnCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    
    [self.selectedDataSource removeAllObjects];
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
}

#pragma mark --用户多选选中处理

- (void)dealUserMultiSelectCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    
    //判断是否在已选数组中存在如果存在那么不添加
    BOOL isExist = NO;
    
    for (HTMIABCSYS_UserModel *sysModel in self.selectedDataSource) {
        if ([sysModel.UserId isEqualToString:returnCell.sys_UserModel.UserId]) {
            isExist = YES;
        }
    }
    
    if (isExist == NO) {
        
        [self.selectedDataSource insertObject:[returnCell.sys_UserModel copy] atIndex:0];
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
    }
}

#pragma mark --用户多选取消选中处理

- (void)dealUserMultiSelectUnCheck:(HTMIABCChooseFromAddressBookTableViewCell *)returnCell{
    
    
    if (self.chooseType == ChooseTypeUserFromAll){
        
        /*
         int departmentCodeLength = returnCell.sys_UserModel.departmentCode.length;
         
         //这个部门上级的所有部门取消选中
         for (int i = 0; i < self.selectedDepartmentArray.count; i++) {
         HTMIABCSYS_DepartmentModel * model = self.selectedDepartmentArray[i];
         //可能是他的父部门
         if (departmentCodeLength >= model.DepartmentCode.length) {
         
         NSString * strCut = [returnCell.sys_UserModel.departmentCode substringToIndex:model.DepartmentCode.length];
         
         if ([strCut isEqualToString:model.DepartmentCode]) {
         [self.selectedDepartmentArray removeObjectAtIndex:i];
         i--;
         }
         
         }
         //下级部门不用处理取消选中
         }*/
    }
    
    //判断是否在已选数组中存在如果存在那么不添加
    for (HTMIABCSYS_UserModel *sysModel in self.selectedDataSource) {
        
        if ([sysModel.UserId isEqualToString:returnCell.sys_UserModel.UserId]) {
            
            [self.selectedDataSource removeObject:sysModel];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
            
            break;
        }
    }
}

#pragma mark - 私有方法

/**
 *  遍历改变搜索框 取消按钮的文字颜色
 */
- (void)changeSearchBarCancelBtnTitleColor:(UIView *)view{
    
    if (view) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *getBtn = (UIButton *)view;
            
            [getBtn setEnabled:YES];//设置可用
            
            [getBtn setUserInteractionEnabled:YES];
            
            //设置取消按钮字体的颜色“#0374f2”
            [getBtn setTitleColor:[UIColor colorWithHexString:@"#0374f2"] forState:UIControlStateReserved];
            
            [getBtn setTitleColor:[UIColor colorWithHexString:@"#0374f2"] forState:UIControlStateDisabled];
            
            return;
            
        }else{
            
            for (UIView *subView in view.subviews) {
                
                [self changeSearchBarCancelBtnTitleColor:subView];
            }
        }
        
    }else{
        
        return;
    }
}

/**
 *  选中之后可能是当前部门下的全选，如果是全选，将部门添加到选中部门的集合中
 */
- (void)checkCurrentModelisCheckAll{
    /*
     //wlq add 选中之后可能是当前部门下的全选，如果是全选，将部门添加到选中部门的集合中
     
     BOOL isAllCheck = YES;
     for (id object in self.allDataSource) {
     if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
     HTMIABCSYS_UserModel * sys_UserModel = object;
     if (sys_UserModel.isCheck == NO) {
     //说明有没选中的那么跳出循环,不添加
     isAllCheck = NO;
     break;
     }
     }
     else if ([object isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]){
     HTMIABCSYS_DepartmentModel * sys_DepartmentModel = object;
     if (sys_DepartmentModel.isCheck == NO) {
     //说明有没选中的那么跳出循环,不添加
     isAllCheck = NO;
     break;
     }
     }
     }
     
     if (isAllCheck) {
     
     if (self.chooseType == ChooseTypeDepartmentFromAll) {
     
     //自己创建一个部门模型，用来表示部门下的部门已经全选了
     HTMIABCSYS_DepartmentModel * sys_DepartmentModel = [HTMIABCSYS_DepartmentModel new];
     sys_DepartmentModel.DepartmentCode = self.departmentModel.DepartmentCode;
     [self.selectedDataSource addObject:sys_DepartmentModel];
     }
     else{
     //自己创建一个部门模型，用来表示部门下的人员和部门已经全选了
     HTMIABCSYS_DepartmentModel * sys_DepartmentModel = [HTMIABCSYS_DepartmentModel new];
     sys_DepartmentModel.DepartmentCode = self.departmentModel.DepartmentCode;
     [self.selectedDepartmentArray addObject:sys_DepartmentModel];
     }
     }
     */
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

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

//清除所有已选
- (void)clearShoppingCart:(UIButton *)sender
{
    for (NSObject *objectInCycle in self.selectedDataSource) {
        
        if ([objectInCycle isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
            
            HTMIABCSYS_UserModel * sys_UserModel = (HTMIABCSYS_UserModel *)objectInCycle;
            sys_UserModel.isCheck = NO;
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",sys_UserModel.UserId] forKey:@"nodeId"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
        }
        else{
            
            HTMIABCSYS_DepartmentModel *sys_DepartmentModel = (HTMIABCSYS_DepartmentModel *)objectInCycle;
            sys_DepartmentModel.isCheck = NO;
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
        }
    }
    
    [self.selectedDataSource removeAllObjects];
    
    self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
    [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:0];
    [self setCartImage];
    [self.htmiAddressBookSelectedView dismissAnimated:YES];
    
    /*
     //删除已选的部门数据
     [self.selectedDepartmentArray removeAllObjects];*/
    
    /*
     for (id object in self.allDataSource) {
     if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
     HTMIABCSYS_UserModel * sys_UserModel = object;
     sys_UserModel.isCheck = NO;
     }
     else if ([object isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
     HTMIABCSYS_DepartmentModel *sys_DepartmentModel = object;
     sys_DepartmentModel.isCheck = NO;
     }
     }
     [self.searchTableView reloadData];
     */
}

//设置按钮图片
- (void)setCartImage
{
    if (self.selectedDataSource.count > 0) {
        [self.htmiAddressBookSelectedView setCartImage:@"icon_personnel_selected"];
    }
    else{
        [self.htmiAddressBookSelectedView setCartImage:@"icon_personnel_normal"];
    }
}

#pragma mark -加入购物车动画
- (void) JoinCartAnimationWithRect:(CGRect)rect
{
    CGFloat startX = rect.origin.x;
    CGFloat startY = rect.origin.y;
    
    _path= [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(startX, startY)];
    //三点曲线
    [_path addCurveToPoint:CGPointMake(_endPointX, _endPointY)
             controlPoint1:CGPointMake(startX, startY)
             controlPoint2:CGPointMake(startX - 180, startY - 200)];
    
    _dotLayer = [CALayer layer];
    _dotLayer.backgroundColor = [UIColor redColor].CGColor;
    _dotLayer.frame = CGRectMake(0, 0, 15, 15);
    _dotLayer.cornerRadius = (15 + 15) /4;
    [self.view.layer addSublayer:_dotLayer];
    [self groupAnimation];
}

#pragma mark - 组合动画
- (void)groupAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"alpha"];
    alphaAnimation.duration = 0.5f;
    alphaAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    alphaAnimation.toValue = [NSNumber numberWithFloat:0.1];
    alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,alphaAnimation];
    groups.duration = 0.8f;
    groups.removedOnCompletion = NO;
    groups.fillMode = kCAFillModeForwards;
    groups.delegate = self;
    [groups setValue:@"groupsAnimation" forKey:@"animationName"];
    [_dotLayer addAnimation:groups forKey:nil];
    
    [self performSelector:@selector(removeFromLayer:) withObject:_dotLayer afterDelay:0.8f];
}

- (void)removeFromLayer:(CALayer *)layerAnimation{
    
    [layerAnimation removeFromSuperlayer];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"animationName"]isEqualToString:@"groupsAnimation"]) {
        
        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shakeAnimation.duration = 0.25f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:0.9];
        shakeAnimation.toValue = [NSNumber numberWithFloat:1];
        shakeAnimation.autoreverses = YES;
        [self.htmiAddressBookSelectedView.shoppingCartBtn.layer addAnimation:shakeAnimation forKey:nil];
    }
}

/**
 *  监听滑动事件
 *
 *  @param note 通知对象
 */
- (void)chooseFormAddressBookViewControllerSelectIndexChange:(NSNotification *)note{
    NSString * pageNumberString = @"";
    if (self.chooseType == ChooseTypeUserFromSpecific) {
        pageNumberString = @"2";
    }else{
        pageNumberString = @"1";
    }
    if ([note.object isEqualToString:pageNumberString]) {
        //刷新已选TableView
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        
        //设置当前选中人数
        [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
        //[self.htmiAddressBookSelectedView updateFrame:self.htmiAddressBookSelectedView.htmiReOrderTableView];
        
        self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
        [self setCartImage];
    }
}

#pragma mark --Getter

- (HTMIABCAddressBookSelectedView *)htmiAddressBookSelectedView{
    if (!_htmiAddressBookSelectedView) {
        
        _htmiAddressBookSelectedView = [[HTMIABCAddressBookSelectedView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kHSelectedViewHeight - [[HTMIWFCSettingManager manager] choosePageTagHight] - 64, kScreenWidth, 50) inView:self.view withObjects:nil];
        _htmiAddressBookSelectedView.parentView = self.view;
        _htmiAddressBookSelectedView.htmiReOrderTableView.tableView.delegate = self;
        _htmiAddressBookSelectedView.htmiReOrderTableView.tableView.dataSource = self;
        _htmiAddressBookSelectedView.backgroundColor = [UIColor whiteColor];
    }
    return _htmiAddressBookSelectedView;
}

- (UISearchBar *)mainSearchBar{
    if (!_mainSearchBar) {
        _mainSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        _mainSearchBar.delegate = self;
        if (self.chooseType == ChooseTypeDepartmentFromAll ||self.chooseType == ChooseTypeDepartmentFromSpecific ||self.chooseType == ChooseTypeDepartmentFromSpecificOnly) {
            _mainSearchBar.placeholder = @"拼音";
        }
        else{
            _mainSearchBar.placeholder = @"姓名/拼音/手机号/短号";
        }
        _mainSearchBar.showsCancelButton = NO;
        
        UIImage* searchBarBg = [self GetImageWithColor:[UIColor colorWithHex:@"#F2F2F4"] andHeight:44.0f];
        //设置背景图片
        [_mainSearchBar setBackgroundImage:searchBarBg];
        
        UITextField *searchField = [_mainSearchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.layer.cornerRadius = 5.0f;
            searchField.layer.borderColor = [UIColor whiteColor].CGColor;
            searchField.layer.borderWidth = 1;
            searchField.layer.masksToBounds = YES;
        }
        
        [_mainSearchBar fm_setCancelButtonTitle:@"取消"];
        _mainSearchBar.tintColor = [[HTMIWFCSettingManager manager] blueColor];
        //修正光标颜色
        [searchField setTintColor:[UIColor grayColor]];
    }
    return _mainSearchBar;
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

- (UITableView *)searchTableView{
    
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight - 64 - [[HTMIWFCSettingManager manager] choosePageTagHight]- 44 -kHSelectedViewHeight) style:UITableViewStylePlain];
        _searchTableView.backgroundColor = [UIColor whiteColor];
        // 设置tableFooterView为一个空的View，这样就不会显示多余的空白格子了
        _searchTableView.tableFooterView = [[UIView alloc] init];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.emptyDataSetSource = self;
        _searchTableView.emptyDataSetDelegate = self;
    }
    return _searchTableView;
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

- (NSMutableArray *)selectedDataSource{
    if (!_selectedDataSource) {
        _selectedDataSource = [self.myParentViewController selectedDataSource];//[NSMutableArray array];
    }
    return _selectedDataSource;
}

- (NSMutableArray *)higherLevelDepartmentArray{
    if (!_higherLevelDepartmentArray) {
        _higherLevelDepartmentArray = [NSMutableArray array];
    }
    return _higherLevelDepartmentArray;
}

/*
 - (NSMutableArray *)selectedDepartmentArray{
 if (!_selectedDepartmentArray) {
 _selectedDepartmentArray = [NSMutableArray array];
 }
 return _selectedDepartmentArray;
 }*/

- (NSMutableArray *)specificArray{
    if (!_specificArray) {
        _specificArray = [NSMutableArray array];
    }
    return _specificArray;
}

@end
