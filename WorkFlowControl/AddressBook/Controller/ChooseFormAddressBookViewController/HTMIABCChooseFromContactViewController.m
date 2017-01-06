//
//  HTMIChooseFromContactController.m
//  MXClient
//
//  Created by wlq on 16/6/22.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCChooseFromContactViewController.h"

#import "HTMIABCChooseFromOrganizationViewController.h"
#import "HTMIABCAddressBookSelectedView.h"
#import "HTMIABCAddressBookManager.h"
//cell
#import "HTMIABCChooseFromTopContactsTableViewCell.h"
#import "HTMIABCContactDataHelper.h"
#import "HTMIABCDBHelper.h"

#import "HTMIABCSelectedFromAddressBookTableViewCell.h"

#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_DepartmentModel.h"
#import "HTMIABCDynamicTreeNode.h"

#import "HTMIABCContactPersonInfoViewController.h"
#import "UIColor+HTMIWFCHex.h"

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

#define SECTION_HEIGHT 30.0

@interface HTMIABCChooseFromContactViewController()<UITableViewDelegate,UITableViewDataSource>
{
    /**
     *  是否为正在搜索
     */
    BOOL _isSearch;
}
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

//动画需要
@property (nonatomic,strong) CALayer *dotLayer;

@property (nonatomic,assign) CGFloat endPointX;

@property (nonatomic,assign) CGFloat endPointY;

@property (nonatomic,strong) UIBezierPath *path;

@property (nonatomic,strong)HTMIABCAddressBookSelectedView * htmiAddressBookSelectedView;

@property (nonatomic,strong)UITableView *searchTableView;
/**<服务器数据源*/
@property (nonatomic,strong) NSMutableArray *serverDataArr;
/**<搜索结果数据源*/
@property (strong, nonatomic) NSMutableArray *searchDataSource;
/**<索引数据源*/
@property (strong, nonatomic) NSMutableArray * indexDataSource;
/**<所有行数组*/
@property (strong, nonatomic) NSMutableArray *allDataSource;
/**<内容行数组*/
@property (strong, nonatomic) NSMutableArray *showingContentDataSource;

/**
 *  已选择的数组
 */
@property (strong, nonatomic) NSMutableArray *selectedDataSource;

@end

@implementation HTMIABCChooseFromContactViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;// 这句代码的意思是不让它扩展布局
    
    //注册顶部标签滑动监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseFormAddressBookViewControllerSelectIndexChange:) name:@"ChooseFormAddressBookViewControllerSelectIndexChange" object:nil];
    
    //初始化页面
    [self initUI];
    
    //初始化数据
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)dealloc{
   
}

#pragma mark - UITableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {
        return 1;
    }
    else{
        
        if (!_isSearch) {
            return self.allDataSource.count;
        }else {
            return 1;
        }
    }
}
// 设置section的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    //    if ([tableView isEqual:self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView])
    //    {
    //        return SECTION_HEIGHT;
    //    }
    //    else
    return SECTION_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
        return self.selectedDataSource.count;
    }
    
    if (!_isSearch) {
        return [self.allDataSource[section] count];
    }else {
        return self.searchDataSource.count;
    }
}

//头部索引标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
        return nil;
    }
    else{
        if (!_isSearch) {
            return self.indexDataSource[section];
        }else {
            return nil;
            
        }
    }
}

//右侧索引列表
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
        return nil;
    }
    else{
        if (!_isSearch) {
            return self.indexDataSource;
        }else {
            return nil;
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
        
        if (self.isTree) {
            HTMIABCDynamicTreeNode * node =  (HTMIABCDynamicTreeNode *)self.selectedDataSource[indexPath.row];
            cell.htmiDynamicTreeNode = node;
            
        }else{
            HTMIABCDynamicTreeNode *node = [[HTMIABCDynamicTreeNode alloc] init];
            NSObject * model = self.selectedDataSource[indexPath.row];
            
            if ([model isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                HTMIABCSYS_UserModel * sys_UserModel = (HTMIABCSYS_UserModel *)model;
                node.isDepartment = NO;
                node.originX = 0;
                node.fatherNodeId = sys_UserModel.departmentCode;
                //如果是人，nodeid就是人的id
                node.nodeId = sys_UserModel.UserId;
                node.name = sys_UserModel.FullName;
                node.model = sys_UserModel;
                cell.sys_UserModel = sys_UserModel;
            }else{
                HTMIABCSYS_DepartmentModel *sys_DepartmentModel = (HTMIABCSYS_DepartmentModel *)model;
                node.isDepartment = YES;
                node.originX = 0;
                node.fatherNodeId = sys_DepartmentModel.ParentDepartment;
                //如果是人，nodeid就是人的id
                node.nodeId = sys_DepartmentModel.DepartmentCode;
                node.name = sys_DepartmentModel.FullName;
                node.model = sys_DepartmentModel;
                cell.sys_DepartmentModel = sys_DepartmentModel;
            }
            //选择类型
            node.chooseType = self.chooseType;
            cell.htmiDynamicTreeNode = node;
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
            if (self.isTree) {
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSString stringWithFormat:@"%@",cell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
                [dic setObject:@"0" forKey:@"checkState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            }
            [self deleteSeletedCell:cell];
            
        };
        
        //设置当前选中人数
        [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
        [self setCartImage];
        
        return cell;
        
    }
    else{
        
        HTMIABCChooseFromTopContactsTableViewCell * cell = [HTMIABCChooseFromTopContactsTableViewCell cellWithTableView:tableView];
        
        if (!_isSearch) {
            
            if ([self.allDataSource[indexPath.section][indexPath.row] isKindOfClass:[HTMIABCDynamicTreeNode class]]) {
                HTMIABCDynamicTreeNode *node = self.allDataSource[indexPath.section][indexPath.row];
                cell.htmiDynamicTreeNode = node;
            }
            else{
                HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)self.allDataSource[indexPath.section][indexPath.row];
                
                HTMIABCDynamicTreeNode *node = [[HTMIABCDynamicTreeNode alloc] init];
                
                node.isDepartment = NO;
                node.originX = 0;
                node.fatherNodeId = model.departmentCode;
                //如果是人，nodeid就是人的id
                node.nodeId = model.UserId;
                node.name = model.FullName;
                node.model = model;
                //选择类型
                node.chooseType = self.chooseType;
                self.allDataSource[indexPath.section][indexPath.row] = node;
                cell.htmiDynamicTreeNode = node;
                cell.sys_UserModel = model;
                
                [self.showingContentDataSource addObject:node];
            }
            
            @weakify(self);
            @weakify(cell);
            cell.checkBlock = ^(HTMIABCChooseFromTopContactsTableViewCell *returnCell){
                @strongify(cell);
                @strongify(self);
                
                BOOL isCheckState;
                if (self.isTree) {
                    cell.htmiDynamicTreeNode.isCheck = !cell.htmiDynamicTreeNode.isCheck;
                    isCheckState = cell.htmiDynamicTreeNode.isCheck;
                }
                else{
                    cell.sys_UserModel.isCheck = !cell.sys_UserModel.isCheck;
                    isCheckState = cell.sys_UserModel.isCheck;
                }
                
                if (isCheckState) {//选中
                    
                    //加入购物车动画
                    CGRect parentRect = [returnCell convertRect:cell.checkImageView.frame toView:self.view];
                    [self JoinCartAnimationWithRect:parentRect];
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                    if (self.isTree) {
                        
                        [dic setObject:[NSString stringWithFormat:@"%@",cell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
                        
                    }else{
                        [dic setObject:[NSString stringWithFormat:@"%@",cell.sys_UserModel.UserId] forKey:@"nodeId"];
                        
                    }
                    [dic setObject:@"1" forKey:@"checkState"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
                    
                    //如果是单选需要处理
                    if (self.isSingleSelection == YES) {
                        
                        [self dealUserSingleSelectionCheck:cell];
                        
                    }
                    else{
                        
                        
                        [self dealUserMultiSelectCheck:cell];
                    }
                }
                else{//取消选中
                    //如果是单选需要处理
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                    if (self.isTree) {
                        
                        [dic setObject:[NSString stringWithFormat:@"%@",cell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
                        
                    }else{
                        [dic setObject:[NSString stringWithFormat:@"%@",cell.sys_UserModel.UserId] forKey:@"nodeId"];
                        
                    }
                    [dic setObject:@"0" forKey:@"checkState"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
                    
                    if (self.isSingleSelection == YES) {
                        
                        [self dealUserSingleSelectionUnCheck:cell];
                    }
                    else{
                        
                        [self dealUserMultiSelectUnCheck:cell];
                    }
                }
                
                [self setCartImage];
                [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
                self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
                self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
            };
            
        }else{
            //搜索
            //        HTMIABCSYS_UserModel * model = self.searchDataSource[indexPath.row];
            //        cell.sys_UserModel = model;
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
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
    else{
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
}

//索引点击事件
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index-1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView != self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
        if (!_isSearch) {
            
            HTMIABCDynamicTreeNode * node = (HTMIABCDynamicTreeNode *)self.allDataSource[indexPath.section][indexPath.row];
            
            HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
            vc.sys_UserModel = (HTMIABCSYS_UserModel *)node.model;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}

#pragma mark - 私有方法

/**
 *  监听滑动事件
 *
 *  @param note 通知对象
 */
- (void)chooseFormAddressBookViewControllerSelectIndexChange:(NSNotification *)note{
    
    NSString * pageNumberString = @"";
    if (self.chooseType == ChooseTypeUserFromSpecific) {
        pageNumberString = @"1";
    }else{
        pageNumberString = @"0";
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

//清除所有已选
- (void)clearShoppingCart:(UIButton *)sender{
    
    if (self.isTree) {
        //清除页面上已选择的
        for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
            nodeInCycle.isCheck = NO;
            
            if (self.isTree) {
                
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:[NSString stringWithFormat:@"%@",nodeInCycle.nodeId] forKey:@"nodeId"];
                [dic setObject:@"0" forKey:@"checkState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
            }
        }
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:@"0" forKey:@"departmentCode"];
        [dic setObject:@"-1" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
    }else{
        for (HTMIABCSYS_UserModel *model in self.selectedDataSource) {
            model.isCheck = NO;
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",model.UserId] forKey:@"nodeId"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
        }
    }
    
    [self.selectedDataSource removeAllObjects];
    self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
    [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:0];
    [self setCartImage];
    [self.htmiAddressBookSelectedView dismissAnimated:YES];
}

//删除单个用户
- (void)deleteSeletedCell:(HTMIABCSelectedFromAddressBookTableViewCell *)returnCell{
    
    if (self.isTree) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        
        //删除之前应该将页面的也删除
        returnCell.htmiDynamicTreeNode.isCheck = NO;
        
        //删除页面上的
        NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
        [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
        [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
    }else{
        
        //删除之前应该将页面的也删除
        returnCell.sys_UserModel.isCheck = NO;
        //删除页面上的
        NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
        [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.sys_UserModel.UserId] forKey:@"nodeId"];
        [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
    }
    
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

#pragma mark -- 用户单选选中处理

/**
 *  部门单选选中处理
 *
 *  @param returnCell TableViewCell
 */
- (void)dealUserSingleSelectionCheck:(HTMIABCChooseFromTopContactsTableViewCell *)returnCell{
    //树形的
    if (self.isTree) {
        
        //先将他设置为不选中
        HTMIABCDynamicTreeNode * node = [self.selectedDataSource lastObject];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"1" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        
        if (node) {
            node.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
            
            NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
            [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",node.nodeId] forKey:@"nodeId"];
            [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",node.fatherNodeId] forKey:@"departmentCode"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        }
        
        if (_isSearch == YES) {
        }
        
        [self.selectedDataSource removeAllObjects];//先移除再添加
        
        [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
        
    }
    else{
        
        //自由选择需要被考虑，可能已选中是部门
        NSObject * model = [self.selectedDataSource lastObject];
        
        if (model) {
            
            NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
            
            if ([model isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                HTMIABCSYS_UserModel * sys_UserModel = (HTMIABCSYS_UserModel *)model;
                sys_UserModel.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
                NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
                [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",sys_UserModel.UserId] forKey:@"nodeId"];
            }
            else{
                HTMIABCSYS_DepartmentModel * sys_DepartmentModel = (HTMIABCSYS_DepartmentModel *)model;
                sys_DepartmentModel.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
                
                [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",sys_DepartmentModel.DepartmentCode] forKey:@"nodeId"];
            }
            [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
        }
        
        if (_isSearch == YES) {
            
        }
        
        [self.selectedDataSource removeAllObjects];//先移除再添加
        
        [self.selectedDataSource insertObject:returnCell.sys_UserModel atIndex:0];
    }
    
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
}

#pragma mark --用户单选取消选中处理

- (void)dealUserSingleSelectionUnCheck:(HTMIABCChooseFromTopContactsTableViewCell *)returnCell{
    
    if (self.isTree) {
        
        HTMIABCDynamicTreeNode * node = [self.selectedDataSource lastObject];
        
        if (node) {
            node.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
            //设置其他节点的已选人数-1
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",node.fatherNodeId] forKey:@"departmentCode"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        }
        
        if (_isSearch == YES) {
            
        }
    }
    else{
        HTMIABCSYS_UserModel * model = [self.selectedDataSource lastObject];
        
        if (model) {
            model.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
            //设置其他节点的已选人数-1
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",model.UserId] forKey:@"departmentCode"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        }
    }
    
    [self.selectedDataSource removeAllObjects];
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
}

#pragma mark --用户多选选中处理

- (void)dealUserMultiSelectCheck:(HTMIABCChooseFromTopContactsTableViewCell *)returnCell{
    
    if (self.isTree) {
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"1" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        
        //判断是否在已选数组中存在如果存在那么不添加
        BOOL isExist = NO;
        
        for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
            if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
                isExist = YES;
            }
        }
        
        //如果是从搜索中获取的数据需要将搜索出来的的替换到页面上
        if (_isSearch) {
            
        }
        
        if (isExist == NO) {
            
            [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        }
        
    }else{
        //判断是否在已选数组中存在如果存在那么不添加
        BOOL isExist = NO;
        
        for (HTMIABCSYS_UserModel *nodeInCycle in self.selectedDataSource) {
            if ([nodeInCycle.UserId isEqualToString:returnCell.sys_UserModel.UserId]) {
                isExist = YES;
            }
        }
        
        //如果是从搜索中获取的数据需要将搜索出来的的替换到页面上
        if (_isSearch) {
            
        }
        
        if (isExist == NO) {
            
            [self.selectedDataSource insertObject:returnCell.sys_UserModel atIndex:0];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        }
    }
}

#pragma mark --用户多选取消选中处理

- (void)dealUserMultiSelectUnCheck:(HTMIABCChooseFromTopContactsTableViewCell *)returnCell{
    
    if (self.isTree) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
        
        for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
            
            if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
                nodeInCycle.isCheck = NO;
                
                [self.selectedDataSource removeObject:nodeInCycle];
                [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
                
                break;
            }
        }
    }else{
        for (HTMIABCSYS_UserModel *nodeInCycle in self.selectedDataSource) {
            
            if ([nodeInCycle.UserId isEqualToString:returnCell.sys_UserModel.UserId]) {
                nodeInCycle.isCheck = NO;
                
                [self.selectedDataSource removeObject:nodeInCycle];
                [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
                
                break;
            }
        }
    }
}

//设置按钮图片
- (void)setCartImage{
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
 *  初始化控件
 */
- (void)initUI{
    
    [self.view addSubview:self.searchTableView];
    [self.view addSubview:self.htmiAddressBookSelectedView];
    
    CGRect rect = [self.view convertRect:self.htmiAddressBookSelectedView.shoppingCartBtn.frame fromView:self.htmiAddressBookSelectedView];
    
    _endPointX = rect.origin.x + 15;
    _endPointY = rect.origin.y + 35;
    
    //self.mainSearchBar.showsCancelButton = NO;
}

- (void)initData{
    
    //获取常用联系人
    HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
    
    if (addressBookSingletonClass.topContactsArray.count <= 0) {
        addressBookSingletonClass.topContactsArray = [[HTMIABCDBHelper sharedYMDBHelperTool] getContactList];
    }else{
        //将选中状态设置为faluse
        for (HTMIABCSYS_UserModel *model in addressBookSingletonClass.topContactsArray) {
            model.isCheck = NO;
        }
    }
    
    //持有数组
    self.serverDataArr = addressBookSingletonClass.topContactsArray;
    
    self.allDataSource = [HTMIABCContactDataHelper getFriendListDataBy:self.serverDataArr];
    self.indexDataSource = [HTMIABCContactDataHelper getFriendListSectionBy:[self.allDataSource mutableCopy]];
    
    [self.searchTableView reloadData];
}

#pragma mark --Getter
#define kHSelectedViewHeight 50
- (HTMIABCAddressBookSelectedView *)htmiAddressBookSelectedView{
    if (!_htmiAddressBookSelectedView) {
        
        _htmiAddressBookSelectedView = [[HTMIABCAddressBookSelectedView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kHSelectedViewHeight - [[HTMIWFCSettingManager manager] choosePageTagHight]  - 64, CGRectGetWidth(self.view.bounds), 50) inView:self.view withObjects:nil];
        _htmiAddressBookSelectedView.parentView = self.view;
        _htmiAddressBookSelectedView.htmiReOrderTableView.tableView.delegate = self;
        _htmiAddressBookSelectedView.htmiReOrderTableView.tableView.dataSource = self;
        _htmiAddressBookSelectedView.backgroundColor = [UIColor whiteColor];
    }
    return _htmiAddressBookSelectedView;
}

- (UITableView *)searchTableView{
    
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - [[HTMIWFCSettingManager manager] choosePageTagHight] -kHSelectedViewHeight) style:UITableViewStylePlain];
        _searchTableView.backgroundColor = [UIColor whiteColor];
        _searchTableView.tableFooterView = [[UIView alloc] init];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
    }
    return _searchTableView;
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

- (NSMutableArray *)specificArray{
    if (!_specificArray) {
        _specificArray = [NSMutableArray array];
    }
    return _specificArray;
}

- (NSMutableArray *)selectedDataSource{
    if (!_selectedDataSource) {
        _selectedDataSource = [self.myParentViewController selectedDataSource];//[NSMutableArray array];
    }
    return _selectedDataSource;
}

- (NSMutableArray *)showingContentDataSource{
    if (!_showingContentDataSource) {
        _showingContentDataSource = [NSMutableArray array];
    }
    return _showingContentDataSource;
}

@end
