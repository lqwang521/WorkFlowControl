//
//  HTMIChooseFromContactController.m
//  MXClient
//
//  Created by wlq on 16/6/22.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCChooseFromOrganizationTreeViewController.h"


#import "HTMIABCAddressBookSelectedView.h"

#import "HTMIABCDynamicTreeNode.h"

//cell
#import "HTMIABCDynamicTreeCell.h"
#import "HTMIABCSelectedFromAddressBookTableViewCell.h"

#import "HTMIABCDBHelper.h"
//model
#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_DepartmentModel.h"

#import "UIColor+HTMIWFCHex.h"

#import "HTMIABCContactPersonInfoViewController.h"
#import "UISearchBar+HTMIWFCSearchBar.h"

//TableView内容为空展示
#import "UIScrollView+HTMIWFCEmptyDataSet.h"

#import "HTMIWFCSettingManager.h"

#import "UIImage+HTMIWFCWM.h"

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

@interface HTMIABCChooseFromOrganizationTreeViewController()
<UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>{
    
    /**
     *  是否为正在搜索
     */
    BOOL _isSearch;
}

/**
 *  搜索框
 */
@property (strong, nonatomic) UISearchBar *mainSearchBar;

/**
 *  TableView
 */
@property (nonatomic,strong) UITableView *searchTableView;

/**
 *  已选择view
 */
@property (nonatomic,strong) HTMIABCAddressBookSelectedView *htmiAddressBookSelectedView;

//动画需要
@property (nonatomic,strong) CALayer *dotLayer;

@property (nonatomic,assign) CGFloat endPointX;

@property (nonatomic,assign) CGFloat endPointY;

@property (nonatomic,strong) UIBezierPath *path;

/**
 *  已选择的数组
 */
@property (strong, nonatomic) NSMutableArray *selectedDataSource;

/** 用来存放已经被选中的集合 */
@property (strong, nonatomic) NSMutableArray *selectedDepartmentArray;

//收回节点需要删除的cell
@property (nonatomic,strong) NSMutableArray *deleteIndexPathArray;
//收回节点需要删除的数据
@property (nonatomic,strong) NSMutableIndexSet *deleteIndexSet;

@property (nonatomic,strong) NSMutableArray *allDataSource;

/** 用来缓存数据 */
@property (strong, nonatomic) NSMutableDictionary *cacheDic;

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
 *  根节点
 */
@property (strong, nonatomic) HTMIABCDynamicTreeNode *rootNode;
@end

@implementation HTMIABCChooseFromOrganizationTreeViewController

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
    //注册顶部标签滑动监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseFormAddressBookViewControllerSelectIndexChange:) name:@"ChooseFormAddressBookViewControllerSelectIndexChange" object:nil];
    
    [self.view addSubview:self.mainSearchBar];
    [self.view addSubview:self.searchTableView];
    [self.view addSubview:self.htmiAddressBookSelectedView];
    
    CGRect rect = [self.view convertRect:self.htmiAddressBookSelectedView.shoppingCartBtn.frame fromView:self.htmiAddressBookSelectedView];
    
    _endPointX = rect.origin.x + 15;
    _endPointY = rect.origin.y + 35;
    
    //初始化根节点
    [self.allDataSource addObject:self.rootNode];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

//移除所有通知
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    HTLog(@"HTMIABCChooseFromOrganizationTreeViewController");
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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

// 设置section的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if ([tableView isEqual:self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView])
    {
        return SECTION_HEIGHT;
    }
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {//已选择的TableView
        
        // 定义唯一标识
        static NSString *CellIdentifier = @"Cell";
        // 通过唯一标识创建cell实例
        HTMIABCSelectedFromAddressBookTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
        if (!cell) {
            
            cell = [[HTMIABCSelectedFromAddressBookTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        HTMIABCDynamicTreeNode * node =  (HTMIABCDynamicTreeNode *)self.selectedDataSource[indexPath.row];
        cell.htmiDynamicTreeNode = node;
        
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
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",cell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
            [dic setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
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
        
        static NSString *CellIdentifier = @"HTMIABCDynamicTreeCell";
        
        HTMIABCDynamicTreeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* topObjects = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCDynamicTreeCell" owner:self options:nil];
            cell = [topObjects objectAtIndex:0];
        }
        
        //不是选择的情况
        if (!_isSearch){
            
            HTMIABCDynamicTreeNode * node =  (HTMIABCDynamicTreeNode *)self.allDataSource[indexPath.row];
            cell.htmiDynamicTreeNode = node;
            
            if ([node.model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {//人员选择
                
                //处理用户数据和选中事件
                [self dealWithUser:node cell:cell];
                
            }
            else{//部门
                
                //处理部门数据和选中事件
                [self dealWithDepartment:node cell:cell];
            }
            
            return cell;
        }else{
            
            HTMIABCDynamicTreeNode * node =  (HTMIABCDynamicTreeNode *)self.searchDataSource[indexPath.row];
            cell.htmiDynamicTreeNode = node;
            
            //搜索的时候需要隐藏
            cell.plusImageView.hidden = YES;
            
            if ([node.model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                
                //处理用户数据和选中事件
                [self dealWithUser:node cell:cell];
            }
            else{//部门
                
                //处理部门数据和选中事件
                [self dealWithDepartment:node cell:cell];
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView != self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView) {
        
        if (!_isSearch) {//不是检索的情况
            HTMIABCDynamicTreeNode * node =  (HTMIABCDynamicTreeNode *)self.allDataSource[indexPath.row];
            if (!node.isDepartment) {
                HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
                vc.sys_UserModel = (HTMIABCSYS_UserModel *)node.model;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
            
            //if ([node.model isMemberOfClass:[HTMIABCSYS_DepartmentModel class]]) {
            
            //HTMIABCSYS_DepartmentModel * model = self.allDataSource[indexPath.row];
            //点击部门跳转，将检索出来的存入页面数组中
            
            //if (self.chooseType == ChooseTypeDepartmentFromAll) {
            
            //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //
            //                        //获取当前子部门 --从数据库
            //                        self.allDataSource = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartments:node.nodeId];
            //
            //                        for (HTMIABCSYS_DepartmentModel *objectSelected in self.selectedDataSource) {
            //
            //                            for (HTMIABCSYS_DepartmentModel *object in self.allDataSource) {
            //
            //                                if ([object.DepartmentCode isEqualToString:objectSelected.DepartmentCode]) {
            //                                    object.isCheck = YES;
            //                                }
            //                            }
            //                        }
            //
            //                        dispatch_async(dispatch_get_main_queue(), ^{
            //
            
            //                        });
            //                    });
            //                }
            //                else if(self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization)
            //                {
            //判断能否跳转
            //HTMIABCChooseFromAddressBookTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (node.isDepartment) {
                if (node.isOpen) {
                    
                    //减
                    [self minusNodesByNode:node];
                    node.isOpen = NO;
                    [self.allDataSource removeObjectsAtIndexes:self.deleteIndexSet];
                    [self.searchTableView deleteRowsAtIndexPaths:self.deleteIndexPathArray  withRowAnimation:UITableViewRowAnimationBottom];
                    
                    [self.deleteIndexSet removeAllIndexes];
                    [self.deleteIndexPathArray removeAllObjects];
                }
                else{
                    //加一个
                    NSUInteger index = indexPath.row + 1;
                    
                    [self addSubNodesByFatherNode:node atIndex:index];
                }
                
                HTMIABCDynamicTreeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                //[cell fillWithNode:self.allDataSource[indexPath.row]];
                
                //设置数据
                cell.htmiDynamicTreeNode = self.allDataSource[indexPath.row];
                
                //}
            }
        }
        else{//搜索
            HTMIABCDynamicTreeNode * node =  (HTMIABCDynamicTreeNode *)self.searchDataSource[indexPath.row];
            if (!node.isDepartment) {
                HTMIABCContactPersonInfoViewController *vc = [[HTMIABCContactPersonInfoViewController alloc]init];
                vc.sys_UserModel = (HTMIABCSYS_UserModel *)node.model;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        //            else if([self.allDataSource[indexPath.row] isMemberOfClass:[HTMIABCSYS_UserModel class]]){
        //                //如果是人员不用处理
        //
        //            }
        //            else{
        //
        //            }
        
    }else{//检索的情况不需要处理
        
        
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    _isSearch = YES;
    
    //1、清空整个搜索结果数组
    [self.searchDataSource removeAllObjects];
    [self.searchTableView reloadData];
    
    if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecific) {
        
        NSMutableArray * departmentNodeArray = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * departmentArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:searchText inDepartment:self.rootNode.nodeId];
            
            
            if (departmentArray && departmentArray.count > 0) {
                
                for (HTMIABCSYS_DepartmentModel *model in departmentArray) {
                    
                    HTMIABCDynamicTreeNode *node = [[HTMIABCDynamicTreeNode alloc] init];
                    
                    node.isDepartment = YES;
                    node.originX = 0;
                    node.fatherNodeId = model.ParentDepartment;
                    //如果是人，nodeid就是人的id
                    node.nodeId = model.DepartmentCode;
                    node.name = model.FullName;
                    node.model = model;
                    //选择类型
                    node.chooseType = self.chooseType;
                    [departmentNodeArray addObject:node];
                }
                
                for (HTMIABCDynamicTreeNode * nodeInCycleSelected in self.selectedDataSource) {
                    
                    for (HTMIABCDynamicTreeNode * object in departmentNodeArray) {
                        
                        if ([object.nodeId isEqualToString:nodeInCycleSelected.nodeId]) {
                            object.isCheck = YES;
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.searchDataSource = departmentNodeArray;
                if (departmentNodeArray.count > 0) {
                    
                    [self.searchTableView reloadData];
                }
            });
        });
    }
    /*else if (self.chooseType == ChooseTypeDepartmentFromSpecific){
     
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
     }
     
     }  */
    else if (self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeUserFromSpecific){
        
        NSMutableArray * userNodeArray = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:self.rootNode.nodeId];
            
            if (userArray && userArray.count > 0) {
                
                for (HTMIABCSYS_UserModel *model in userArray) {
                    
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
                    [userNodeArray addObject:node];
                }
                
                for (HTMIABCDynamicTreeNode * nodeInCycleSelected in self.selectedDataSource) {
                    
                    for (HTMIABCDynamicTreeNode * object in userNodeArray) {
                        
                        if ([object.nodeId isEqualToString:nodeInCycleSelected.nodeId]) {
                            object.isCheck = YES;
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                self.searchDataSource = userNodeArray;
                if (userNodeArray.count > 0) {
                    [self.searchTableView reloadData];
                }
                
            });
        });
    }
    /*else if (self.chooseType == ChooseTypeUserFromSpecific){
     
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
     }
     
     } */
    else if (self.chooseType == ChooseTypeOrganization){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * departmentNodeArray = [NSMutableArray array];
            NSMutableArray * userNodeArray = [NSMutableArray array];
            
            NSMutableArray * departmentArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:searchText inDepartment:self.rootNode.nodeId];
            NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:searchText inDepartment:self.rootNode.nodeId];
            
            
            //装换成节点模型
            for (HTMIABCSYS_DepartmentModel * model in departmentArray) {
                
                HTMIABCDynamicTreeNode *node = [[HTMIABCDynamicTreeNode alloc] init];
                
                node.isDepartment = YES;
                node.fatherNodeId = model.ParentDepartment;
                node.nodeId = model.DepartmentCode;
                node.name = model.FullName;
                node.model = model;
                
                //选择类型
                node.chooseType = self.chooseType;
                /** 部门需要显示部门下人员个数 */
                NSString * countString = [[HTMIABCDBHelper sharedYMDBHelperTool]getUserCountByDepartemntCode:node.nodeId];
                node.userCount = countString;
                [departmentNodeArray addObject:node];
                
            }
            for (HTMIABCSYS_UserModel *model in userArray) {
                
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
                [userNodeArray addObject:node];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray * allSearchDateArray = [NSMutableArray arrayWithArray:departmentNodeArray];
                [allSearchDateArray addObjectsFromArray:userNodeArray];
                
                //1、清空整个搜索结果数组
                //                [self.searchDataSource removeAllObjects];
                //                [self.searchTableView reloadData];
                //                _isSearch = YES;
                
                for (HTMIABCDynamicTreeNode * nodeInCycleSelected in self.selectedDataSource) {
                    
                    for (HTMIABCDynamicTreeNode * object in allSearchDateArray) {
                        
                        if ([object.nodeId isEqualToString:nodeInCycleSelected.nodeId]) {
                            object.isCheck = YES;
                        }
                    }
                }
                
                self.searchDataSource = allSearchDateArray;
                if (allSearchDateArray.count > 0) {
                    [self.searchTableView reloadData];
                }
                
                /*
                 if (allSearchDateArray && allSearchDateArray.count > 0) {
                 
                 for (HTMIABCDynamicTreeNode* node in self.selectedDataSource) {
                 
                 if (node.isDepartment) {
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
                 
                 _isSearch = YES;
                 self.searchDataSource = allSearchDateArray;
                 
                 [self.searchTableView reloadData];
                 }
                 */
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
        self.searchTableView.frame = CGRectMake(0, 44, kScreenWidth, kScreenHeight - 64 - [[HTMIWFCSettingManager manager] choosePageTagHight] - 44 -kHSelectedViewHeight);
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
        
        for (HTMIABCDynamicTreeNode *objectSelected in self.selectedDataSource) {
            
            for (HTMIABCDynamicTreeNode *object in self.allDataSource) {
                
                if ([object.nodeId isEqualToString:objectSelected.nodeId]) {
                    object.isCheck = YES;
                }
            }
        }
        
    }else if(self.chooseType == ChooseTypeUserFromAll){
        
        for (HTMIABCDynamicTreeNode * objectSelected in self.selectedDataSource) {
            
            for (HTMIABCDynamicTreeNode * object in self.allDataSource) {
                
                if ([object.nodeId isEqualToString:objectSelected.nodeId]) {
                    object.isCheck = YES;
                }
            }
        }
    }
    
    [self.searchTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
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

#pragma mark - 底部已选择bar相关

//清除所有已选
- (void)clearShoppingCart:(UIButton *)sender
{
    //清除页面上已选择的
    
    for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
        nodeInCycle.isCheck = NO;
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",nodeInCycle.nodeId] forKey:@"nodeId"];
        [dic setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dic];
    }
    
    /*
     //取消当前页面选中的
     for (HTMIABCDynamicTreeNode *nodeInCycle in self.allDataSource) {
     
     if (nodeInCycle.isCheck) {
     nodeInCycle.isCheck = NO;
     }
     }
     */
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:@"0" forKey:@"departmentCode"];
    [dic setObject:@"-1" forKey:@"checkState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
    
    [self.selectedDataSource removeAllObjects];
    self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
    [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:0];
    [self setCartImage];
    [self.htmiAddressBookSelectedView dismissAnimated:YES];
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

#pragma mark - private methods

- (HTMIABCDynamicTreeNode *)rootNode
{
    if (!_rootNode) {
        
        HTMIABCSYS_DepartmentModel * sys_DepartmentModel = [[HTMIABCDBHelper sharedYMDBHelperTool]getRootDepartment];
        
        _rootNode = [[HTMIABCDynamicTreeNode alloc] init];
        _rootNode.originX = 10.f;
        _rootNode.isDepartment = YES;
        _rootNode.fatherNodeId = nil;
        _rootNode.praentTreeNode = nil;
        _rootNode.nodeId = sys_DepartmentModel.DepartmentCode;
        _rootNode.name = sys_DepartmentModel.ShortName;
        _rootNode.model = sys_DepartmentModel;
        
        NSString * countString = [[HTMIABCDBHelper sharedYMDBHelperTool]getUserCountByDepartemntCode:_rootNode.nodeId];
        _rootNode.userCount = countString;
        //选择类型
        _rootNode.chooseType = self.chooseType;
    }
    return _rootNode;
}

//添加子节点
- (void)addSubNodesByFatherNode:(HTMIABCDynamicTreeNode *)fatherNode atIndex:(NSInteger )index
{
    HTMIABCDynamicTreeNode *openNode;
    int  currentCount  = -1;
    if (fatherNode)
    {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *cellIndexPaths = [NSMutableArray array];
        
        NSUInteger count = index;
        
        //这部门是处理将已经选中的设置为选中
        //
        if(self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization)
        {
            
        }
        
        NSMutableArray * tempArray = [self.cacheDic objectForKey:fatherNode.nodeId];
        
        if (tempArray && tempArray.count > 0) {
            array = tempArray;
            for (int i = 0; i < array.count; i++) {
                HTMIABCDynamicTreeNode *node = array[i];
                
                for (HTMIABCDynamicTreeNode *selectedNode in self.selectedDataSource) {
                    
                    //如果部门或者是人员已选中和当前从数据库中的匹配设置选中状态为已选中
                    if ([selectedNode.nodeId isEqualToString:node.nodeId]) {
                        
                        //node = selectedNode;
                        node.isCheck = YES;
                    }
                }
                /*
                 // begin
                 //这个问题只有装到数组中才能解决
                 
                 if (node.isOpen) {
                 openNode = node;//[self addSubNodesByFatherNode:node atIndex:count];
                 currentCount = count;
                 }
                 //end
                 */
                
                [cellIndexPaths addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
                
            }
        }
        else{
            //获取当前子部门和人员 -从数据库
            NSMutableArray * departmentCodeAndUserArray = [NSMutableArray array];
            if(self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization || self.chooseType == ChooseTypeUserFromSpecific)
            {
                departmentCodeAndUserArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentAndUsers:fatherNode.nodeId];
                
            }else if (self.chooseType == ChooseTypeDepartmentFromAll|| self.chooseType == ChooseTypeDepartmentFromSpecific){
                
                departmentCodeAndUserArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartments:fatherNode.nodeId];
            }
            
            for (NSObject *object in departmentCodeAndUserArray){
                
                HTMIABCDynamicTreeNode *node = [[HTMIABCDynamicTreeNode alloc] init];
                if ([object isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
                    
                    HTMIABCSYS_UserModel *model =  (HTMIABCSYS_UserModel *)object;
                    node.isDepartment = NO;
                    node.originX = 0;
                    node.fatherNodeId = model.departmentCode;
                    //如果是人，nodeid就是人的id
                    node.nodeId = model.UserId;
                    node.name = model.FullName;
                    node.model = model;
                    node.praentTreeNode = fatherNode;
                    
                    //选择类型
                    node.chooseType = self.chooseType;
                }
                else{
                    
                    HTMIABCSYS_DepartmentModel *model =  (HTMIABCSYS_DepartmentModel *)object;
                    node.isDepartment = YES;
                    node.originX = fatherNode.originX + 10/*space*/;
                    node.fatherNodeId = model.ParentDepartment;
                    node.nodeId = model.DepartmentCode;
                    node.name = model.FullName;
                    node.model = model;
                    node.praentTreeNode = fatherNode;
                    //选择类型
                    node.chooseType = self.chooseType;
                    
                    if(self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization)
                    {
                        /** 部门需要显示部门下人员个数 */
                        NSString * countString = [[HTMIABCDBHelper sharedYMDBHelperTool]getUserCountByDepartemntCode:node.nodeId];
                        node.userCount = countString;
                    }
                }
                
                [array addObject:node];
                [cellIndexPaths addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
            }
            
            for (HTMIABCDynamicTreeNode *selectedNode in self.selectedDataSource) {
                
                
                //for (HTMIABCDynamicTreeNode *nodeFromDB in array) {
                for (int i = 0; i < array.count; i++) {
                    
                    HTMIABCDynamicTreeNode *nodeFromDB = array[i];
                    
                    if(self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization)
                    {
                        //wlq add
                        //遍历已选 设置选中状态以及选择的人数
                        if (!selectedNode.isDepartment) {
                            //这个人员在这个部门下面
                            
                            if (nodeFromDB.isDepartment) {
                                //可能是父部门的
                                if (selectedNode.fatherNodeId.length >= nodeFromDB.nodeId.length) {
                                    
                                    NSString * strCut = [selectedNode.fatherNodeId substringToIndex:nodeFromDB.nodeId.length];
                                    
                                    //一定是父部门
                                    if ([strCut isEqualToString:nodeFromDB.nodeId]) {
                                        
                                        int currentCount = [nodeFromDB.selectedUserCount intValue];
                                        
                                        nodeFromDB.selectedUserCount = [NSString stringWithFormat:@"%d",currentCount + 1];
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    //如果部门或者是人员已选中和当前从数据库中的匹配设置选中状态为已选中
                    if ([selectedNode.nodeId isEqualToString:nodeFromDB.nodeId]) {
                        //                        nodeFromDB = selectedNode;
                        nodeFromDB.isCheck = YES;
                    }
                }
            }
            
            //进行缓存
            [self.cacheDic setObject:array forKey:fatherNode.nodeId];
        }
        
        if (array.count > 0) {
            fatherNode.isOpen = YES;
            
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index,[array count])];
            
            [self.allDataSource insertObjects:array atIndexes:indexes];
            [self.searchTableView insertRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            //            /* begin */
            //            if (openNode.isOpen) {
            //                [self addSubNodesByFatherNode:openNode atIndex:currentCount + 1];
            //            }
            //            /* end */
        }
    }
}

//根据节点减去子节点
- (void)minusNodesByNode:(HTMIABCDynamicTreeNode *)node
{
    if (node) {
        
        NSMutableArray *nodes = [NSMutableArray arrayWithArray:self.allDataSource];
        for (HTMIABCDynamicTreeNode *nd in nodes) {
            if ([nd.fatherNodeId isEqualToString:node.nodeId]) {
                
                NSUInteger index = [nodes indexOfObject:nd];
                [self.deleteIndexPathArray addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                [self.deleteIndexSet addIndex:index];
                
                [self minusNodesByNode:nd];
            }
        }
        
        node.isOpen = NO;
    }
}

- (void)deleteSeletedCell:(HTMIABCSelectedFromAddressBookTableViewCell *)returnCell{
    
    if (self.chooseType == ChooseTypeUserFromAll  || self.chooseType == ChooseTypeUserFromSpecific|| self.chooseType == ChooseTypeOrganization){
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
    }
    else if(self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecific){
        
    }
    
    //删除之前应该将页面的也删除
    returnCell.htmiDynamicTreeNode.isCheck = NO;
    //删除页面上的
    NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
    [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
    [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
    
    /*
     //删除页面上的
     for (HTMIABCDynamicTreeNode *nodeInCycle in self.allDataSource) {
     if ([returnCell.htmiDynamicTreeNode.nodeId isEqualToString:nodeInCycle.nodeId]) {
     nodeInCycle.isCheck = NO;
     }
     }
     */
    
    NSIndexPath * indexPath = [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell];
    //执行删除操作
    [self.selectedDataSource removeObjectAtIndex:[self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView indexPathForCell:returnCell].row];
    if (indexPath) {
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    //[self.searchTableView reloadData];
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
    
    //设置当前选中人数
    [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
    [self.htmiAddressBookSelectedView updateFrame:self.htmiAddressBookSelectedView.htmiReOrderTableView];
    
    self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
    self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
    [self setCartImage];
}

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

#pragma mark -- 处理部门Cell(包括选中事件)

/**
 *  处理部门Cell
 *
 *  @param model 部门模型
 *  @param cell  cell
 */
- (void)dealWithDepartment:(HTMIABCDynamicTreeNode *)node cell:(HTMIABCDynamicTreeCell *)returnCell{
    @weakify(returnCell);
    returnCell.checkBlock = ^(HTMIABCDynamicTreeCell *cell){ //选中后触发的事件
        @strongify(returnCell);
        //block中不应该依赖
        returnCell.htmiDynamicTreeNode.isCheck = !returnCell.htmiDynamicTreeNode.isCheck;
        
        
        if (returnCell.htmiDynamicTreeNode.isCheck == YES) {
            
            //加入购物车动画
            CGRect parentRect = [returnCell convertRect:returnCell.checkImageView.frame toView:self.view];
            [self JoinCartAnimationWithRect:parentRect];
            
            //设置图片
            returnCell.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
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
            
            returnCell.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
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
- (void)dealDepartmentSingleSelectionCheck:(HTMIABCDynamicTreeCell *)returnCell{
    //如果已选数组中有那么就将已选数组中的移除，将这个添加进去，没有直接添加
    //wlq add
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        
    }
    else{
        
        HTMIABCDynamicTreeNode * node = [self.selectedDataSource lastObject];
        
        if (node) {
            node.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
            
            NSMutableDictionary * dicForUpdateiIsCheck = [NSMutableDictionary dictionary];
            [dicForUpdateiIsCheck setObject:[NSString stringWithFormat:@"%@",node.nodeId] forKey:@"nodeId"];
            [dicForUpdateiIsCheck setObject:@"0" forKey:@"checkState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil userInfo:dicForUpdateiIsCheck];
        }
        
        /*
         //可能存在当前已选中的是从搜索选中的，
         for (HTMIABCDynamicTreeNode *nodeInSycle in self.allDataSource) {
         if ([nodeInSycle.nodeId isEqualToString:node.nodeId]) {
         nodeInSycle.isCheck = NO;
         break;
         }
         }
         */
        
        /*
         if (_isSearch == YES) {
         
         //wlq add 当时选择的时候需要处理选择结果中选中多个的问题
         //检索出来的可能有部门也可能有用户
         for (HTMIABCDynamicTreeNode * nodeInSycle in self.searchDataSource) {
         if ([nodeInSycle.model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
         
         if ([nodeInSycle.nodeId isEqualToString:node.nodeId]) {
         nodeInSycle.isCheck = NO;
         break;
         }
         }
         }
         
         //如果搜索出来的在当前页面存在，进行node替换
         for (HTMIABCDynamicTreeNode *node in self.allDataSource) {
         
         if ([node.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
         returnCell.htmiDynamicTreeNode = node;
         returnCell.htmiDynamicTreeNode.isCheck = YES;
         
         break;
         }
         }
         }
         */
        
        [self.selectedDataSource removeAllObjects];//先移除再添加
        
        [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
        
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        
    }
}

#pragma mark --部门单选取消选中处理

- (void)dealDepartmentSingleSelectionUnCheck:(HTMIABCDynamicTreeCell *)returnCell{
    //wlq add
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        
    }
    else{
        
        HTMIABCDynamicTreeNode * node = [self.selectedDataSource lastObject];
        
        if (node) {
            node.isCheck = NO;
        }
        
        if (_isSearch == YES) {
            /*
             //将其他选中的设置为未选中
             for (HTMIABCDynamicTreeNode * nodeInSycle in self.searchDataSource) {
             if ([nodeInSycle.model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
             
             if ([nodeInSycle.nodeId isEqualToString:node.nodeId]) {
             nodeInSycle.isCheck = NO;
             }
             }
             }*/
        }
        
        [self.selectedDataSource removeAllObjects];
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];    }
}

#pragma mark --部门多选选中处理


- (void)dealDepartmentMultiSelectCheck:(HTMIABCDynamicTreeCell *)returnCell{
    
    //wlq add
    if (self.chooseType == ChooseTypeUserFromAll)
    {
        /*
         //用户多选时可以选择部门进行选择子部门的所有人员
         
         //1、从数据库中获取所有字部门的人员，添加到集合，并且去除重复的
         
         NSMutableArray * userArray = [[HTMIABCDBHelper sharedYMDBHelperTool]searchUsersBySearchString:@"" inDepartment:returnCell.htmiDynamicTreeNode.nodeId];
         
         //获取所有子部门
         NSMutableArray * arrayDepartArray = [[HTMIABCDBHelper sharedYMDBHelperTool]getDepartmentBySearchString:@"" inDepartment:returnCell.htmiDynamicTreeNode.nodeId];
         
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
        
        //判断是否在已选数组中存在如果存在那么不添加
        BOOL isExist = NO;
        
        for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
            if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
                isExist = YES;
            }
        }
        /*
         //如果是从搜索中获取的数据需要将搜索出来的的替换到页面上,并且设置选中状态
         if (_isSearch) {
         
         for (int i = 0; i < self.allDataSource.count ; i++) {
         HTMIABCDynamicTreeNode *nodeInCycle = self.allDataSource[i];
         
         if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
         nodeInCycle = returnCell.htmiDynamicTreeNode;
         nodeInCycle.isCheck = YES;
         }
         }
         
         }  */
        
        if (isExist == NO) {
            
            [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        }
    }
    else{
        
        //判断是否在已选数组中存在如果存在那么不添加
        BOOL isExist = NO;
        
        for (HTMIABCDynamicTreeNode *nodeInCyle in self.selectedDataSource) {
            if ([nodeInCyle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
                isExist = YES;
            }
        }
        
        if (isExist == NO) {
            
            [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
            [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        }
    }
}


#pragma mark --部门多选取消选中处理

- (void)dealDepartmentMultiSelectUnCheck:(HTMIABCDynamicTreeCell *)returnCell{
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
         //如果点击的是搜索的
         if (_isSearch) {
         //删除页面上已选中的
         for (HTMIABCDynamicTreeNode *nodeInCycle in self.allDataSource) {
         if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
         nodeInCycle.isCheck = NO;
         break;
         }
         }
         }*/
        
        for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
            
            if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
                nodeInCycle.isCheck = NO;
                
                [self.selectedDataSource removeObject:nodeInCycle];
                [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
                
                break;
            }
        }
    }
    else{
        /*
         //判断是否在已选数组中存在如果存在那么不添加
         for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
         
         if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
         
         [self.selectedDataSource removeObject:sysModel];
         [self.searchTableView reloadData];
         [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
         
         break;
         }
         }
         */
        
        for (HTMIABCDynamicTreeNode *nodeInCycle in self.selectedDataSource) {
            
            if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
                nodeInCycle.isCheck = NO;
                
                [self.selectedDataSource removeObject:nodeInCycle];
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
- (void)dealWithUser:(HTMIABCDynamicTreeNode *)node cell:(HTMIABCDynamicTreeCell *)returnCell{
    @weakify(returnCell);
    //处理选中事件
    returnCell.checkBlock = ^(HTMIABCDynamicTreeCell *cell){ //选中后触发的事件
        @strongify(returnCell);
        returnCell.htmiDynamicTreeNode.isCheck = !returnCell.htmiDynamicTreeNode.isCheck;
        
        if (returnCell.htmiDynamicTreeNode.isCheck == YES) {
            
            //加入购物车动画
            CGRect parentRect = [returnCell convertRect:returnCell.checkImageView.frame toView:self.view];
            [self JoinCartAnimationWithRect:parentRect];
            
            //设置图片
            returnCell.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
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
            
            returnCell.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.nodeId] forKey:@"nodeId"];
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
- (void)dealUserSingleSelectionCheck:(HTMIABCDynamicTreeCell *)returnCell{
    
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
        [dic setObject:[NSString stringWithFormat:@"%@",returnCell.htmiDynamicTreeNode.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
    }
    
    /*
     //可能存在当前已选中的是从搜索选中的，
     for (HTMIABCDynamicTreeNode *nodeInSycle in self.allDataSource) {
     if ([nodeInSycle.nodeId isEqualToString:node.nodeId]) {
     nodeInSycle.isCheck = NO;
     break;
     }
     }
     
     
     if (_isSearch == YES) {
     
     //wlq add 当时选择的时候需要处理选择结果中选中多个的问题
     //检索出来的可能有部门也可能有用户
     for (HTMIABCDynamicTreeNode * nodeInSycle in self.searchDataSource) {
     if ([nodeInSycle.model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
     
     if ([nodeInSycle.nodeId isEqualToString:node.nodeId]) {
     nodeInSycle.isCheck = NO;
     break;
     }
     }
     }
     
     //如果搜索出来的在当前页面存在，进行node替换
     for (HTMIABCDynamicTreeNode *node in self.allDataSource) {
     
     if ([node.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
     returnCell.htmiDynamicTreeNode = node;
     returnCell.htmiDynamicTreeNode.isCheck = YES;
     
     break;
     }
     }
     }
     */
    
    [self.selectedDataSource removeAllObjects];//先移除再添加
    
    [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
    
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
}

#pragma mark --用户单选取消选中处理

- (void)dealUserSingleSelectionUnCheck:(HTMIABCDynamicTreeCell *)returnCell{
    
    HTMIABCDynamicTreeNode * node = [self.selectedDataSource lastObject];
    
    if (node) {
        node.isCheck = NO; //这里处理了已选中的人员，在未选中的事件中不用再处理
        //设置其他节点的已选人数-1
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%@",node.fatherNodeId] forKey:@"departmentCode"];
        [dic setObject:@"0" forKey:@"checkState"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_CheckStateChange" object:nil userInfo:dic];
    }
    /*
     if (_isSearch == YES) {
     //将其他选中的设置为未选中
     for (HTMIABCDynamicTreeNode * nodeInSycle in self.searchDataSource) {
     if ([nodeInSycle.model isMemberOfClass:[HTMIABCSYS_UserModel class]]) {
     
     if ([nodeInSycle.nodeId isEqualToString:node.nodeId]) {
     nodeInSycle.isCheck = NO;
     }
     }
     }
     }
     */
    
    [self.selectedDataSource removeAllObjects];
    [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
}

#pragma mark --用户多选选中处理

- (void)dealUserMultiSelectCheck:(HTMIABCDynamicTreeCell *)returnCell{
    
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
    /*
     //如果是从搜索中获取的数据需要将搜索出来的的替换到页面上
     if (_isSearch) {
     for (int i = 0; i < self.allDataSource.count ; i++) {
     HTMIABCDynamicTreeNode *nodeInCycle = self.allDataSource[i];
     
     if ([nodeInCycle.nodeId isEqualToString:returnCell.htmiDynamicTreeNode.nodeId]) {
     nodeInCycle = returnCell.htmiDynamicTreeNode;
     }
     }
     }*/
    
    if (isExist == NO) {
        
        [self.selectedDataSource insertObject:returnCell.htmiDynamicTreeNode atIndex:0];
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
    }
    
    
}

#pragma mark --用户多选取消选中处理

- (void)dealUserMultiSelectUnCheck:(HTMIABCDynamicTreeCell *)returnCell{
    
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
         }
         */
    }
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
        
        /*
         //1、将当前页面上的重新设置一遍
         for (HTMIABCDynamicTreeNode *nodeInCycle in self.allDataSource) {
         
         nodeInCycle.isCheck = NO;
         for (HTMIABCDynamicTreeNode *node in self.selectedDataSource) {
         if ([nodeInCycle.nodeId isEqualToString:node.nodeId]) {
         nodeInCycle.isCheck = YES;
         }
         }
         }*/
        
        //刷新已选TableView
        [self.htmiAddressBookSelectedView.htmiReOrderTableView.tableView reloadData];
        
        //设置当前选中人数
        [self.htmiAddressBookSelectedView setSelectedCountWithCountNumber:self.selectedDataSource.count];
        // [self.htmiAddressBookSelectedView updateFrame:self.htmiAddressBookSelectedView.htmiReOrderTableView];
        
        self.htmiAddressBookSelectedView.badge.htmiBadgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectedDataSource.count];
        self.htmiAddressBookSelectedView.htmiReOrderTableView.objects = self.selectedDataSource;
        [self setCartImage];
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
#define kHSelectedViewHeight 50
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

#define kHSelectedViewHeight 50

- (HTMIABCAddressBookSelectedView *)htmiAddressBookSelectedView{
    if (!_htmiAddressBookSelectedView) {
        
        _htmiAddressBookSelectedView = [[HTMIABCAddressBookSelectedView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kHSelectedViewHeight - [[HTMIWFCSettingManager manager] choosePageTagHight] - 64, CGRectGetWidth(self.view.bounds), 50) inView:self.view withObjects:nil];
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
        _mainSearchBar.searchBarStyle = UISearchBarStyleDefault;
        
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

- (NSMutableArray *)selectedDepartmentArray{
    if (!_selectedDepartmentArray) {
        _selectedDepartmentArray = [NSMutableArray array];
    }
    return _selectedDepartmentArray;
}

- (NSMutableArray *)specificArray{
    if (!_specificArray) {
        _specificArray = [NSMutableArray array];
    }
    return _specificArray;
}

- (NSMutableArray *)allDataSource{
    if (!_allDataSource) {
        _allDataSource = [NSMutableArray array];
    }
    return _allDataSource;
}

- (NSMutableArray *)deleteIndexPathArray{
    if (!_deleteIndexPathArray) {
        
        _deleteIndexPathArray = [NSMutableArray array];
    }
    return _deleteIndexPathArray;
}

- (NSMutableIndexSet *)deleteIndexSet{
    if (!_deleteIndexSet) {
        self.deleteIndexSet = [[NSMutableIndexSet alloc]init];
    }
    return _deleteIndexSet;
}

- (NSMutableArray *)searchDataSource{
    if (!_searchDataSource) {
        _searchDataSource = [NSMutableArray array];
    }
    return _searchDataSource;
}

//缓存数据的字典
- (NSMutableDictionary *)cacheDic{
    if (!_cacheDic) {
        _cacheDic = [NSMutableDictionary dictionary];
    }
    return _cacheDic;
}

- (NSMutableArray *)selectedDataSource{
    if (!_selectedDataSource) {
        _selectedDataSource = [self.myParentViewController selectedDataSource];//[NSMutableArray array];
    }
    return _selectedDataSource;
}

@end
