//
//  HTMIWFCOAToDoViewController.m
//  MXClient
//
//  Created by 赵志国 on 16/3/8.
//  Copyright (c) 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOAToDoViewController.h"

//#import "AppDelegate+PrivateMethod.h"

#import "HTMIWFCApi.h"

//#import "MXConfig.h"
//#import "MXNavBarView.h"
//#import <MXKit/MXAppCenter.h>
#import "HTMIWFCOAMatterOperationViewController.h"
//#import "OAAddQuickViewController.h"
#import "HTMIWFCOAMatterInfo.h"
#import "HTMIWFCEGOImageButton.h"
#include "HTMIWFCSVProgressHUD.h"
#import "HTMIWFCOAToDoTableViewCell.h"
#import "HTMIWFCOADoneViewController.h"

#import "HTMIWFCSVPullToRefresh.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCSettingManager.h"
//气泡Badge
//#import "WZLBadgeImport.h"
#import "HTMIWFCSRRefreshView.h"//下拉刷新 水滴

//定义应用屏幕宽度
#define WIDTH [UIScreen mainScreen].bounds.size.width

//定义应用屏幕高度
#define HEIGHT [UIScreen mainScreen].bounds.size.height

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


#define searchHeight 42 //栏高度

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

@interface HTMIWFCOAToDoViewController ()<UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
UIAlertViewDelegate,
HTMIWFCOAMatterOperationViewControllerDelegate,
SRRefreshDelegate,
UISearchBarDelegate>
{
    HTMIWFCEGOImageButton *egoImageButton;
    UISearchBar *mySearchbar;
    
}

@property (nonatomic, strong) UIView *rootView; //最底层view  与已办切换时用到

@property (nonatomic, strong) UIView *btnView;//rootView上铺一层存放按钮的view

@property (nonatomic, strong) UIView *coverView;//存放todotableView及上滑下滑

@property (nonatomic, strong) HTMIWFCSRRefreshView *srRefreshView;//水滴效果下拉刷新

//@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, strong) UITableView *todoTableView;

@property (nonatomic, strong) NSMutableArray *toDoArray;

@property (nonatomic, assign) BOOL isDown;//判断是否下拉

@property (nonatomic, strong) NSArray *arr1;//插件数据相关
@property (nonatomic, strong) NSMutableArray *mutable1;
@property (nonatomic, strong) NSMutableArray *mutable2;
@property (nonatomic, strong) NSMutableArray *mutable3;
@property (nonatomic, strong) NSMutableArray *mutable4;
@property (nonatomic, strong) NSMutableArray *mutable5;

@property (nonatomic, assign) NSInteger cellHeight;

//下拉刷新上拉加载数据
@property (nonatomic, assign) NSInteger startNumber;
@property (nonatomic, assign) NSInteger endNumber;
@property (nonatomic, strong) NSArray *myNewTodoArray;
@property (nonatomic, strong) NSArray *myredrawArray;


//@property (nonatomic, strong)AppDelegate *mydelegate;

/**
 *  上拉加载是否到最后
 */
@property (nonatomic, assign) BOOL isHaveMoreDone;

/**
 *  最后一条数据提示
 */
@property (nonatomic, strong) UIView *footView;

@end

@implementation HTMIWFCOAToDoViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addItemsToTopview) name:@"HTMI_AppCenterChanged" object:nil];
    
    //    //wlq add 网络监听
    //    //------开启网络状况监听
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange:) name:kReachabilityChangedNotification object:nil];
    //    self.reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    //    [self.reachability startNotifier];
    
    self.isHaveMoreDone = NO;
    
    //初始化页面
    [self showMain];
    
    //准备数据
    [self prepareForDate];
    
    [self creatSearchController];
}

-(void)viewWillAppear:(BOOL)animated{
    //self.tabBarController.tabBar.hidden = NO;
}

#pragma mark ------ 页面显示
- (void)showMain {
    
    //    if (!_mydelegate) {
    //        self.mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    }
    //    [self.mydelegate myEMIAndEMMunReadCount];
    
    [self setRootView:self.rootView];
    
    //    [self setBtnView:self.btnView];
    //
    //    [self  addItemsToTopview];
    //
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    [self.coverView addSubview:view];
    [self.coverView addSubview:self.todoTableView];
    //
    //    [self creatPulldownImage];
}

- (void)creatPulldownImage {
    UIImageView *pulldownImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    pulldownImage.image = [UIImage getPNGImageHTMIWFC:@"btn_gest"];
    [self.coverView addSubview:pulldownImage];
    pulldownImage.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *pull = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pullImageView:)];
    pull.delegate = self;
    pull.minimumNumberOfTouches = 1;
    [pulldownImage addGestureRecognizer:pull];
}

//懒加载
- (UIView *)rootView {
    if (!_rootView) {
        //暂时修改
        if (self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {// 有tabbar并且显示
            
            _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, searchHeight, kScreenWidth, kScreenHeight-64-49-searchHeight)];
        }
        else{
            _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, searchHeight, kScreenWidth, kScreenHeight-64-searchHeight)];
        }
        
        _rootView.backgroundColor = RGBA(253, 253, 253, 1);
        [self.view addSubview:_rootView];
    }
    
    return _rootView;
}

- (UIView *)coverView {
    if (!_coverView) {
        
        //暂时修改
        if (self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {// 有tabbar并且显示
            
            _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64-49-searchHeight)];
        }
        else{
            _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64-searchHeight)];
        }
        
        _coverView.backgroundColor = RGBA(248, 248, 248, 1);
        [self.rootView addSubview:_coverView];
    }
    
    return _coverView;
}
- (UITableView *)todoTableView {
    if (!_todoTableView) {
        //覆盖页面上加tableview
        //暂时修改
        if (self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {// 有tabbar并且显示
            
            _todoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-searchHeight-49-64)];
        }
        else{
            _todoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-searchHeight-64)];
        }
        _todoTableView.delegate = self;
        _todoTableView.dataSource = self;
        _todoTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _todoTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _todoTableView.backgroundColor = RGBA(248, 248, 248, 1);
        [_todoTableView addSubview:self.srRefreshView];
        [self.coverView addSubview:_todoTableView];
    }
    
    return _todoTableView;
}

#pragma mark －准备数据
- (void)prepareForDate {
    //  tableview显示数据源
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    
    NSString *start = @"0";
    NSString *end = @"14";
    
    [HTMIWFCApi requestMatterFormWithTodoFlag:@"0" andRecordStartIndex:start andRecordEndIndex:end andContext:context andModelName:self.myAppNameString title:@"" succeed:^(id data) {
        [HTMIWFCSVProgressHUD dismiss];
        
        self.toDoArray = data;
        [self.todoTableView reloadData];
        
        //        if (self.toDoArray.count == 0) {
        //            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //            [delegate setupUnYesandNo:YES];
        //        }
        //        else {
        //            self.toDoArray = data;
        //            [self.todoTableView reloadData];
        //
        //            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //            [delegate setupUnYesandNo:NO];
        //        }
        
        self.startNumber = [start integerValue];
        self.endNumber = [end integerValue];
        
        //下拉加载数据
        __weak HTMIWFCOAToDoViewController *myTodo = self;
        
        __weak UISearchBar *searchBar = mySearchbar;
        
        if (self.toDoArray.count > 14) {
            //上拉加载
            [self.todoTableView addInfiniteScrollingWithActionHandler:^{
                if (mySearchbar.text.length < 1) {
                    if (!myTodo.isHaveMoreDone) {
                        myTodo.startNumber+=15;
                        myTodo.endNumber+=15;
                        NSString *newStart = [NSString stringWithFormat:@"%d",(int)myTodo.startNumber];
                        NSString *newEnd = [NSString stringWithFormat:@"%d",(int)myTodo.endNumber];
                        
                        int64_t delayInSeconds = 0.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            [myTodo.todoTableView beginUpdates];
                            [HTMIWFCApi requestMatterFormWithTodoFlag:@"0" andRecordStartIndex:newStart andRecordEndIndex:newEnd andContext:context andModelName:myTodo.myAppNameString title:@"" succeed:^(id data) {
                                [HTMIWFCSVProgressHUD dismiss];
                                
                                myTodo.myNewTodoArray = data;
                                
                                if (myTodo.myNewTodoArray.count > 0) {
                                    [myTodo.toDoArray addObjectsFromArray:myTodo.myNewTodoArray];
                                    for (int i = 0; i < myTodo.myNewTodoArray.count; i++)
                                    {
                                        [myTodo.todoTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:myTodo.toDoArray.count-(i+1) inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                    }
                                    [myTodo.todoTableView endUpdates];
                                    
                                    [myTodo.todoTableView.infiniteScrollingView stopAnimating];
                                    
                                } else {
                                    [myTodo.todoTableView endUpdates];
                                    
                                    [myTodo.todoTableView.infiniteScrollingView stopAnimating];
                                    
                                    myTodo.isHaveMoreDone = YES;
                                    
                                    
                                    myTodo.footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kH6(60))];
                                    myTodo.footView.backgroundColor = RGBA(248, 248, 248, 1);
                                    
                                    UILabel *footLabel = [[UILabel alloc] initWithFrame:myTodo.footView.bounds];
                                    footLabel.text = @"已是最后一条数据......";
                                    footLabel.font = [UIFont systemFontOfSize:10.0];
                                    footLabel.textAlignment = NSTextAlignmentCenter;
                                    footLabel.textColor = [UIColor lightGrayColor];
                                    [myTodo.footView addSubview:footLabel];
                                    
                                    [myTodo.todoTableView.infiniteScrollingView addSubview:myTodo.footView];
                                }
                                
                                
                            } failure:^(NSError *error) {
                                [myTodo.todoTableView.infiniteScrollingView stopAnimating];
                                [HTMIWFCSVProgressHUD dismiss];
                                [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
                            }];
                        });
                    } else {
                        [myTodo.todoTableView.infiniteScrollingView stopAnimating];
                    }
                }
                
                if (searchBar.text.length > 0) {
                    [myTodo.todoTableView.infiniteScrollingView stopAnimating];
                }
            }];
        }
        
    } failure:^(NSError *error) {
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    }];
}

#pragma mark ------ 下拉刷新
// ------ slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(HTMIWFCSRRefreshView *)refreshView {
    [self xilashuaxin];
}

// ------ scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.srRefreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.srRefreshView scrollViewDidEndDraging];
}

- (void)xilashuaxin {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    //    [self.mydelegate myEMIAndEMMunReadCount];
    
    //__weak HTMIWFCOAToDoViewController *weakSelf = self;
    @weakify(self);
    [HTMIWFCApi requestMatterFormWithTodoFlag:@"0" andRecordStartIndex:@"0" andRecordEndIndex:@"14" andContext:context andModelName:self.myAppNameString title:@"" succeed:^(id data) {
        @strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        //        [HTMIWFCEmptyView removeFormView:self.view];
        
        [self.srRefreshView performSelector:@selector(endRefresh)
                                 withObject:nil afterDelay:0.0
                                    inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        
        self.myredrawArray = data;
        if (self.myredrawArray.count != 0) {
            [self.toDoArray removeAllObjects];
            [self.toDoArray addObjectsFromArray:self.myredrawArray];
            [self.todoTableView reloadData];
            //            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //            [delegate setupUnYesandNo:NO];
            
        } else {
            //            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //            [delegate setupUnYesandNo:YES];
        }
        
        self.startNumber = 0;
        self.endNumber = 14;
        
        mySearchbar.text = @"";
        
    } failure:^(NSError *error) {
        //@strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        //wlq add 应该显示空页面
        //        [HTMIWFCEmptyView removeFormView:self.view];
        
        if (error.code == -1001) {//请求超时
            //            [self showTimeoutReloadView:^{
            //                [HTMIWFCSVProgressHUD show];
            //                //下拉刷新
            //                [self xilashuaxin];
            //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        else{//断网
            //            [self showErrorReloadView:^{
            //                [HTMIWFCSVProgressHUD show];
            //                //下拉刷新
            //                [self xilashuaxin];
            //            } goToCheck:^{
            //
            //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
    }];
    
    self.isHaveMoreDone = NO;
    [self.footView removeFromSuperview];
}

// ------ Getters and Setters
- (HTMIWFCSRRefreshView *)srRefreshView {
    if (!_srRefreshView) {
        _srRefreshView = [[HTMIWFCSRRefreshView alloc] init];
        _srRefreshView.delegate = self;
        _srRefreshView.upInset = 0;
        _srRefreshView.slimeMissWhenGoingBack = YES;
        _srRefreshView.slime.skinColor = [UIColor whiteColor];
        _srRefreshView.slime.lineWith = 1;
        _srRefreshView.slime.shadowBlur = 4;
        
        
        if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
            //蓝色
            _srRefreshView.slime.shadowColor = [[HTMIWFCSettingManager manager] blueColor];
            _srRefreshView.slime.bodyColor = [[HTMIWFCSettingManager manager] blueColor];
        } else {
            _srRefreshView.slime.shadowColor = [[HTMIWFCSettingManager manager] navigationBarColor];
            _srRefreshView.slime.bodyColor = [[HTMIWFCSettingManager manager] navigationBarColor];
        }
    }
    
    return _srRefreshView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 设置tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toDoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HTMIWFCOAMatterInfo *matterInfo = self.toDoArray[indexPath.row];
    float width = [self labelSizeWithMaxHeight:30 content:matterInfo.DocTitle FontOfSize:15].width;
    
    static NSString *myCell = @"cell";
    HTMIWFCOAToDoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (!cell) {
        
        cell = [[HTMIWFCOAToDoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
        
    }
    
    for (id any in cell.contentView.subviews) {
        [any removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = RGBA(248, 248, 248, 1);
    
    if (width > WIDTH-44) {
        [cell creatToDoCellByToDoArray:matterInfo titleStyle:twoLine];
    } else {
        [cell creatToDoCellByToDoArray:matterInfo titleStyle:oneLine];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HTMIWFCOAMatterInfo *matterInfo = self.toDoArray[indexPath.row];
    float width = [self labelSizeWithMaxHeight:30 content:matterInfo.DocTitle FontOfSize:15].width;
    
    if (width > WIDTH-44) {
        return 130;
    } else {
        return 104;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HTMIWFCOAMatterInfo *matterInfo = self.toDoArray[indexPath.row];
    HTMIWFCOAToDoTableViewCell *cell = [[HTMIWFCOAToDoTableViewCell alloc]init];
    [cell.unreadDoing removeFromSuperview];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    HTMIWFCOAMatterOperationViewController *mvc = [[HTMIWFCOAMatterOperationViewController alloc]init];
    mvc.delegate = self;
    mvc.matterID = matterInfo.DocID;
    mvc.docTitle = matterInfo.DocTitle;
    mvc.docType = matterInfo.DocType;
    mvc.kind = matterInfo.kind;
    mvc.sendFrom = matterInfo.SendFrom;
    mvc.sendDate = matterInfo.SendDate;
    mvc.iconID = matterInfo.iconId;
    
    mvc.hidesBottomBarWhenPushed = YES;
    mvc.urlPNG = matterInfo.iconId;
    [HTMIWFCSVProgressHUD show];
    [self.navigationController pushViewController:mvc animated:YES];
}

#pragma mark ------搜索功能
- (void)creatSearchController {
    mySearchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, searchHeight)];
    mySearchbar.placeholder = @"请输入标题或流程关键字搜索";
    mySearchbar.delegate = self;
    //下面三行改变颜色
    UIView *segmentView = [mySearchbar.subviews objectAtIndex:0];
    [[segmentView.subviews objectAtIndex:0] removeFromSuperview];
    mySearchbar.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:244/255.0 alpha:1.0];
    [self.view addSubview:mySearchbar];
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithImage:[UIImage getPNGImageHTMIWFC:@"btn_packup_keyboard"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyBoard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    [mySearchbar setInputAccessoryView:topView];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //    if (searchText.length == 0) {
    //        [self prepareForDate];
    //    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self.footView removeFromSuperview];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    [HTMIWFCSVProgressHUD show];
    [HTMIWFCApi requestMatterFormWithTodoFlag:@"0" andRecordStartIndex:@"0" andRecordEndIndex:@"99" andContext:context andModelName:self.myAppNameString title:mySearchbar.text succeed:^(id data) {
        [HTMIWFCSVProgressHUD dismiss];
        
        self.toDoArray = data;
        [self.todoTableView reloadData];
        
        self.startNumber = 0;
        self.endNumber = 14;
        
    } failure:^(NSError *error) {
        
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    }];
}



#pragma mark - 下拉手势

- (void)pullImageView:(UIPanGestureRecognizer *)pull {
    CGPoint p = [pull locationInView:self.view];
    float height = HEIGHT-WIDTH/4-64-searchHeight;
    
    if (pull.state == UIGestureRecognizerStateBegan) {
        
    }
    if (pull.state == UIGestureRecognizerStateChanged) {
        self.coverView.frame = CGRectMake(0, p.y-64, WIDTH, height);
    }
    if (pull.state == UIGestureRecognizerStateEnded) {
        if (!self.isDown) {
            if (p.y > HEIGHT - height - 49 + 80) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.coverView.frame = CGRectMake(0, HEIGHT-WIDTH/4-64-searchHeight, WIDTH, height);
                }];
                self.isDown = !self.isDown;
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.coverView.frame = CGRectMake(0, WIDTH/4, WIDTH, height);
                }];
            }
        } else {
            if(p.y < HEIGHT - 49 - 80) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.coverView.frame = CGRectMake(0, WIDTH/4, WIDTH, height);
                }];
                self.isDown = !self.isDown;
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.coverView.frame = CGRectMake(0, HEIGHT-WIDTH/4-64-searchHeight, WIDTH, height);
                }];
            }
        }
    }
}

#pragma mark - 收文等按钮点击事件

- (void)btnPress:(UIButton *)sender {
    NSString *appID = [NSString stringWithFormat:@"%@",self.mutable1[sender.tag - 1110]];
    if ([appID isEqualToString: @"showalltodo"]) {
        
        self.myAppNameString = @"";//一定要设置
        
        [HTMIWFCSVProgressHUD show];
        [self prepareForDate];
    }
    else if (sender.tag != 1110)
    {
        NSString *appID = [NSString stringWithFormat:@"%@",self.mutable1[sender.tag - 1110]];
        
        if ([appID hasPrefix:@"OA_Select"] || [appID hasPrefix:@"OA_todo"]) {
            
            NSString *modelNameString =  [NSString stringWithFormat:@"%@",self.mutable4[sender.tag - 1110]];
            
            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
            
            [HTMIWFCSVProgressHUD show];
            [HTMIWFCApi requestMatterFormWithTodoFlag:@"0" andRecordStartIndex:@"0" andRecordEndIndex:@"1000" andContext:context andModelName:modelNameString title:@"" succeed:^(id data) {
                [HTMIWFCSVProgressHUD dismiss];
                
                self.toDoArray = data;
                [self.todoTableView reloadData];
                
                self.startNumber = 0;
                self.endNumber = 14;
                
            } failure:^(NSError *error) {
                
                [HTMIWFCSVProgressHUD dismiss];
                [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
            }];
        }
        else{
            //[[MXAppCenter sharedInstance]appClick:appID WithExtParam:nil withViewController:self];
        }
    }
}

- (void)addQuickkkk {
    
    //    OAAddQuickViewController *add = [[OAAddQuickViewController alloc]init];
    //    add.delegate = self;
    //    add.mutableArr = [NSMutableArray array];
    //    for (NSDictionary *dic in self.arr1) {
    //        [add.mutableArr addObject:dic];
    //    }
    //    [self.navigationController pushViewController:add animated:YES];
}


#pragma mark - 网络改变监听事件

- (void)networkStateChange:(NSNotification *)notification{
    
    //    NetworkStatus status = [self.reachability currentReachabilityStatus];
    //
    //    if (status == NotReachable) {
    //
    //    }else{
    //
    //        if (status == ReachableViaWiFi || status == ReachableViaWWAN) {
    //
    //            //通知页面刷新
    //            //[self addItemsToTopview];
    //            //[self showMain];
    //        }
    //    }
}

#pragma mark - 私有方法

//计算字符串长度
- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize {
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}

//计算字符串长度
- (CGSize)labelSizeWithMaxHeight:(CGFloat)height content:(NSString *)content FontOfSize:(CGFloat)FontOfSize {
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(0, height)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}

- (void)dismissKeyBoard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //    if (mySearchbar.text.length < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self xilashuaxin];
    //    }
}

#pragma mark - 事件

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //    [self.view endEditing:YES];
    //
    //    if (mySearchbar.text.length < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self xilashuaxin];
    //    }
    
    //    if (self.toDoArray.count < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self xilashuaxin];
    //    }
}


#pragma mark - OAaddquickviewcontrollerdelegate

// 回调刷新
- (void)reloadview{
    
    [self addItemsToTopview];
}

//向顶部视图添加操作项
- (void)addItemsToTopview{
    /*
     
     for (int i = 0; i < self.btnView.subviews.count; i++) {
     if (self.btnView.subviews[i].tag == 10001) {
     continue;
     }
     [self.btnView.subviews[i] removeFromSuperview];
     i--;
     }
     //tableview显示数据源
     NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
     NSString *userID = [userdefaults objectForKey:@"kOA_userIDString"];
     
     self.homePageString = @"";
     [[MXAppCenter sharedInstance]getAppsMessageWithFinshCallback:^(id object, MXError *error) {
     
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:(NSDictionary *)object options:NSJSONWritingPrettyPrinted error:nil];
     NSArray *arr12 = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
     NSMutableArray *MXmutable1 = [NSMutableArray array];
     for (NSDictionary *dic in arr12) {
     if ([[dic allKeys]containsObject:@"appID"] && [[dic allKeys]containsObject:@"avatarUrl"] && [[dic allKeys]containsObject:@"id"] && [[dic allKeys]containsObject:@"name"])
     {
     NSString *str1 = [dic objectForKey:@"appID"];
     [MXmutable1 addObject:str1];
     }
     }
     //——————————————————————————————————————————————————————————————
     //应用
     @weakify(self);
     NSString *path = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetUserShortcuts?userId=%@",EMUrl,EMPORT,EMapiDir,userID];
     [HTMIWFCApi requestAccessToaApplications:path succeed:^(id data) {
     @strongify(self);
     [HTMIWFCSVProgressHUD dismiss];
     [HTMIWFCEmptyView removeFormView:self.view];
     
     self.arr1 = data;
     self.mutable1 = [NSMutableArray array];
     self.mutable2 = [NSMutableArray array];
     self.mutable3 = [NSMutableArray array];
     self.mutable4 = [NSMutableArray array];
     
     for (NSDictionary *dic in self.arr1) {
     
     if ([[dic allKeys]containsObject:@"appID"] && [[dic allKeys]containsObject:@"avatarUrl"] && [[dic allKeys]containsObject:@"id"] && [[dic allKeys]containsObject:@"name"])
     {
     NSString *str1 = [dic objectForKey:@"appID"];
     NSString *str2 = [dic objectForKey:@"avatarUrl"];
     NSString *str3 = [dic objectForKey:@"id"];
     NSString *str4 = [dic objectForKey:@"name"];
     [self.mutable1 addObject:str1];
     [self.mutable2 addObject:str2];
     [self.mutable3 addObject:str3];
     [self.mutable4 addObject:str4];
     
     }else
     {
     UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"一个错的数据源 !  !  !" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
     [alertView show];
     }
     }
     
     for (int i = 0; i < self.mutable1.count; i++) {
     if (![MXmutable1 containsObject:self.mutable1[i]]) {
     [self.mutable1 removeObjectAtIndex:i];
     [self.mutable2 removeObjectAtIndex:i];
     [self.mutable3 removeObjectAtIndex:i];
     [self.mutable4 removeObjectAtIndex:i];
     }
     }
     
     [self.mutable1 insertObject:@"showalltodo" atIndex:0];
     [self.mutable2 insertObject:@"icon_oa_todo" atIndex:0];
     [self.mutable3 insertObject:@"AllTodo" atIndex:0];
     [self.mutable4 insertObject:@"所有待办" atIndex:0];
     int btnWH = WIDTH/4;
     for (int i = 0; i < self.mutable1.count+1; i++)
     {
     egoImageButton = [[HTMIWFCEGOImageButton alloc] initWithPlaceholderImage:[UIImage getPNGImageHTMIWFC:@"file_default_icon_phone"]];
     egoImageButton.frame = CGRectMake(i%4*btnWH+btnWH/4, i/4*btnWH+btnWH/4-10, btnWH/2, btnWH/2);
     egoImageButton.layer.masksToBounds = YES;
     egoImageButton.layer.cornerRadius = 10;
     egoImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
     
     egoImageButton.tag = 1110 + i;
     egoImageButton.backgroundColor=[UIColor clearColor];
     
     if (i < self.mutable1.count) {
     
     egoImageButton.placeholderImage = [UIImage getPNGImageHTMIWFC:@"icon_oa_todo_style4"];
     [egoImageButton addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
     [egoImageButton setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.mutable2[i]]]];
     
     [self.btnView addSubview:egoImageButton];
     
     [egoImageButton layoutIfNeeded];
     
     [self.view layoutIfNeeded];
     
     //遍历下面的字
     UILabel *label = [[UILabel alloc]init];
     label.frame = CGRectMake(i%4*btnWH, (i/4)*btnWH+btnWH/4*3-6, btnWH, 20);
     label.textAlignment = NSTextAlignmentCenter;
     label.text = self.mutable4[i];
     label.font = [UIFont systemFontOfSize:13];
     label.textColor = [UIColor grayColor];
     [self.btnView addSubview:label];
     }else if (i == self.mutable1.count)
     {
     UILabel *label = [[UILabel alloc]init];
     label.frame = CGRectMake(i%4*btnWH, (i/4)*btnWH+btnWH/4*3-6, btnWH, 20);
     label.textAlignment = NSTextAlignmentCenter;
     label.text = @"添加";
     label.font = [UIFont systemFontOfSize:13];
     label.textColor = [UIColor grayColor];
     [self.btnView addSubview:label];
     [egoImageButton setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_add"] forState:UIControlStateNormal];
     [egoImageButton addTarget:self action:@selector(addQuickkkk) forControlEvents:UIControlEventTouchUpInside];
     [self.btnView addSubview:egoImageButton];
     }
     }
     
     //找出需要获取待办数量的插件，请求接口获取待办个数
     for (int i = 0; i < self.mutable1.count; i++){
     NSString * tempString = self.mutable1[i];
     if (tempString.length > 0) {
     if ([tempString isEqualToString:@"showalltodo"]) {//待办
     
     NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
     NSString *myPath = [NSString stringWithFormat:@"%@GetMobileData/GetDbYbCount",BaseURL];
     
     NSDictionary *context = [user objectForKey:@"kContextDictionary"];
     NSDictionary *parameter = @{@"recordStartIndex":@"0",@"recordEndIndex":@"14",@"todoFlag":@"0",@"context":context,@"ModelName":@"",@"Title":@""};
     
     [HTMIWFCApi myrequestUserInfounReadCountWithPath:myPath andmyParameter:parameter succeed:^(id data) {
     
     NSString * countString = [NSString stringWithFormat:@"%@",data];
     
     if (countString.length > 0) {
     UIView * view = [self.btnView viewWithTag:1110 + i];
     
     
     if ([view isKindOfClass:[HTMIWFCEGOImageButton class]]) {
     
     HTMIWFCEGOImageButton * eImageButton =(HTMIWFCEGOImageButton *)view;
     
     [eImageButton showBadge:countString];
     }
     }
     
     } failure:^(NSError *error) {
     NSLog(@"Error:GetDbYbCount");
     }];
     }
     
     if ([tempString hasPrefix:@"OA_Select"]) {//OA_Select
     
     NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
     NSString *myPath = [NSString stringWithFormat:@"%@GetMobileData/GetDbYbCount",BaseURL];
     
     NSDictionary *context = [user objectForKey:@"kContextDictionary"];
     NSDictionary *parameter = @{@"recordStartIndex":@"0",@"recordEndIndex":@"14",@"todoFlag":@"0",@"context":context,@"ModelName":self.mutable4[i],@"Title":@""};
     
     [HTMIWFCApi myrequestUserInfounReadCountWithPath:myPath andmyParameter:parameter succeed:^(id data) {
     
     NSString * countString = [NSString stringWithFormat:@"%@",data];
     if (countString.length > 0) {
     UIView * view = [self.btnView viewWithTag:1110 + i];
     if ([view isKindOfClass:[HTMIWFCEGOImageButton class]]) {
     
     HTMIWFCEGOImageButton * eImageButton =(HTMIWFCEGOImageButton *)view;
     
     [eImageButton showBadge:countString];
     
     }
     }
     
     } failure:^(NSError *error) {
     NSLog(@"Error:GetDbYbCount");
     }];
     }
     }
     }
     
     } failure:^(NSError *error) {
     @strongify(self);
     [HTMIWFCSVProgressHUD dismiss];
     [HTMIWFCEmptyView removeFormView:self.view];
     
     if (error.code == -1001) {//请求超时
     [self showTimeoutReloadView:^{
     [HTMIWFCSVProgressHUD show];
     //下拉刷新
     [self addItemsToTopview];
     } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
     }
     else{//断网
     
     [self showErrorReloadView:^{
     [HTMIWFCSVProgressHUD show];
     
     [self addItemsToTopview];
     } goToCheck:^{
     
     } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
     }
     }];
     }];
     */
}

- (NSMutableArray *)toDoArray{
    if (!_toDoArray) {
        _toDoArray = [NSMutableArray array];
    }
    return _toDoArray;
}

- (UIView *)btnView{
    //  添加按钮
    if (!_btnView) {
        _btnView = [[UIView alloc] initWithFrame:self.rootView.bounds];
        _btnView.backgroundColor = RGBA(253, 253, 253, 1);
        [self.rootView addSubview:_btnView];
        UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64)];
        myView.alpha = 0;
        myView.userInteractionEnabled = YES;
        myView.tag = 10001;
        [_btnView addSubview:myView];
    }
    return _btnView;
}

#pragma mark ------ 操作成功返回刷新待办
- (void)tableViewReloadData{
    [self prepareForDate];
    [self showMain];
}

@end
