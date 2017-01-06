//
//  HTMIWFCOADoneViewController.m
//  MXClient
//
//  Created by 赵志国 on 16/3/8.
//  Copyright (c) 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOADoneViewController.h"

//controller
#import "HTMIWFCOAMatterOperationViewController.h"
//view
#import "HTMIWFCOADoneTableViewCell.h"
//others
#import "HTMIWFCOADoneEntity.h"

#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCSVPullToRefresh.h"

#import "HTMIWFCSRRefreshView.h"

#import "HTMIWFCNetTipView.h"

#import "HTMIWFCEmptyView.h"

//TableView内容为空展示
#import "UIScrollView+HTMIWFCEmptyDataSet.h"

#import "HTMIWFCApi.h"

#import "HTMIWFCSettingManager.h"

#import "UIImage+HTMIWFCWM.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

#define searchHeight 42


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


@interface HTMIWFCOADoneViewController ()<HTMIWFCOAMatterOperationViewControllerDelegate,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate,
SRRefreshDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate>//搜索
{
    
}

@property (nonatomic,strong)HTMIWFCSRRefreshView *srRefreshView;
@property (nonatomic,strong)NSMutableArray *doneArray;
@property (nonatomic,strong)UITableView *doneTableView;
@property (nonatomic,assign)NSInteger startNumber;
@property (nonatomic,assign)NSInteger endNumber;
@property (nonatomic,strong)NSArray *myNewDoneArray;
@property (nonatomic,copy)NSString *startString;
@property (nonatomic,copy)NSString *endString;
@property (nonatomic,strong)UISearchBar *mySearchBar;

/**
 *  上拉加载是否到最后
 */
@property (nonatomic, assign) BOOL isHaveMoreDone;

/**
 *  最后一条数据提示
 */
@property (nonatomic, strong) UIView *footView;

@end

@implementation HTMIWFCOADoneViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.translucent = NO;
    
    self.isHaveMoreDone = NO;
    //    @weakify(self);
    //    [self.view showNetTipViewWithToDoBlock:^{
    //        @strongify(self);
    
    [self initUI];
    
    //    }];
}

- (void)initUI {
    
    //wlq add
    
    //    if ([HTMINetWorkStatusManager manager].isReachable) {
    //        [self.view hideNetTipView];
    
    [self.view addSubview:[UIView new]];
    self.doneTableView = [[UITableView alloc] init];
    if (self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {// 有tabbar并且显示
        
        self.doneTableView.frame = CGRectMake(0, searchHeight, Width, Height-64-49-searchHeight);
    }
    else{
        self.doneTableView.frame = CGRectMake(0, searchHeight, Width, Height-64-searchHeight);
    }
    
    self.doneTableView.delegate = self;
    self.doneTableView.dataSource = self;
    self.doneTableView.emptyDataSetSource = self;
    self.doneTableView.emptyDataSetDelegate = self;
    self.doneTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.doneTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.doneTableView];
    
    [self.doneTableView addSubview:self.srRefreshView];
    
    self.doneArray = [[NSMutableArray alloc]init];
    
    if (self.startString.length<1) {
        self.startString = @"0";
        self.endString = @"14";
    }
    
    //tableview显示数据源
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    if (self.myAppNameString == nil && self.myAppNameString.length == 0) {
        self.myAppNameString = [NSString stringWithFormat:@""];
    }
    
    __weak HTMIWFCOADoneViewController *weakself = self;
    @weakify(self);
    [HTMIWFCSVProgressHUD show];
    [HTMIWFCApi requestMatterFormWithTodoFlag:@"1" andRecordStartIndex:self.startString andRecordEndIndex:self.endString andContext:context andModelName:self.myAppNameString title:@"" succeed:^(id data) {
        @strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        //        [self.view hideNetTipView];
        //        [HTMIWFCEmptyView removeFormView:weakself.view];
        
        self.doneArray = data;
        [self.doneTableView reloadData];
        
        
        self.startNumber = [self.startString integerValue];
        self.endNumber = [self.endString integerValue];
        
        if (self.doneArray.count > 14) {
            //上拉加载
            [self.doneTableView addInfiniteScrollingWithActionHandler:^{
                
                NSLog(@"上拉加载");
                
                //需要抽取成方法
                [weakself loadMoreData:weakself context:context];
                
            }];
            
        }
        
        
    } failure:^(NSError *error) {
        @strongify(self);
        //        [HTMIWFCEmptyView removeFormView:self.view];
        [HTMIWFCSVProgressHUD dismiss];
        
        //        [self.view showNetTipViewWithToDoBlock:^{
        //            //下拉刷新
        //            [weakself reloadxialashuju];
        //        }];
        
        if (error.code == -1001) {//请求超时
            //            [self showTimeoutReloadView:^{
            //                [HTMIWFCSVProgressHUD show];
            //
            //                [self reloadxialashuju];
            //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        else{//断网
            
            //            [self showErrorReloadView:^{
            //                [HTMIWFCSVProgressHUD show];
            //
            //                [self reloadxialashuju];
            //            } goToCheck:^{
            //
            //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
    }];
    
    
    self.mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, Width, 42)];
    self.mySearchBar.delegate = self;
    self.mySearchBar.placeholder = @"请输入标题或流程关键字搜索";
    //下面三行改变颜色
    UIView *segmentView = [self.mySearchBar.subviews objectAtIndex:0];
    [[segmentView.subviews objectAtIndex:0] removeFromSuperview];
    self.mySearchBar.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:244/255.0 alpha:1.0];
    [self.view addSubview:self.mySearchBar];
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithImage:[UIImage getPNGImageHTMIWFC:@"btn_packup_keyboard"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    [self.mySearchBar setInputAccessoryView:topView];
    
    //    }else{
    //
    //        @weakify(self);
    //        [self.view showNetTipViewWithToDoBlock:^{
    //            @strongify(self);
    //
    //            [self initUI];
    //
    //        }];
    //    }
}

/**
 *  加载更多
 */
- (void)loadMoreData:(HTMIWFCOADoneViewController *)weakself context:(NSDictionary *)context{
    
    if (weakself.mySearchBar.text.length < 1) {
        if (!weakself.isHaveMoreDone) {
            weakself.startNumber+=15;
            weakself.endNumber+=15;
            NSString *newStart = [NSString stringWithFormat:@"%ld",(long)weakself.startNumber];
            NSString *newEnd = [NSString stringWithFormat:@"%ld",(long)weakself.endNumber];
            
            
            int64_t delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakself.doneTableView beginUpdates];
                
                [HTMIWFCApi requestMatterFormWithTodoFlag:@"1" andRecordStartIndex:newStart andRecordEndIndex:newEnd andContext:context andModelName:@"" title:@"" succeed:^(id data) {
                    
                    weakself.myNewDoneArray = data;
                    
                    if (weakself.myNewDoneArray.count > 0) {
                        [weakself.doneArray addObjectsFromArray:weakself.myNewDoneArray];
                        
                        for (int i = 0; i < weakself.myNewDoneArray.count; i++) {
                            [weakself.doneTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakself.doneArray.count-(i+1) inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                        }
                        
                        [weakself.doneTableView endUpdates];
                        
                        [weakself.doneTableView.infiniteScrollingView stopAnimating];
                        
                    } else {
                        
                        [weakself.doneTableView endUpdates];
                        
                        [weakself.doneTableView.infiniteScrollingView stopAnimating];
                        
                        weakself.isHaveMoreDone = YES;
                        
                        
                        weakself.footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kH6(60))];
                        weakself.footView.backgroundColor = [UIColor whiteColor];
                        
                        UILabel *footLabel = [[UILabel alloc] initWithFrame:weakself.footView.bounds];
                        footLabel.text = @"已是最后一条数据......";
                        footLabel.font = [UIFont systemFontOfSize:10.0];
                        footLabel.textAlignment = NSTextAlignmentCenter;
                        footLabel.textColor = [UIColor lightGrayColor];
                        [weakself.footView addSubview:footLabel];
                        
                        [weakself.doneTableView.infiniteScrollingView addSubview:weakself.footView];
                        
                    }
                    
                    
                } failure:^(NSError *error) {
                    
                    [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
                    
                    [weakself.doneTableView.infiniteScrollingView stopAnimating];
                }];
                //
                
            });
        } else {
            [weakself.doneTableView.infiniteScrollingView stopAnimating];
        }
        
    }
    if (weakself.mySearchBar.text.length > 0) {
        [weakself.doneTableView.infiniteScrollingView stopAnimating];
    }
}

-(void)reloadxialashuju{
    
    //tableview显示数据源
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    __weak HTMIWFCOADoneViewController *weakself = self;
    [HTMIWFCApi requestMatterFormWithTodoFlag:@"1" andRecordStartIndex:@"0" andRecordEndIndex:@"14" andContext:context andModelName:weakself.myAppNameString title:@"" succeed:^(id data) {
        
        [HTMIWFCEmptyView removeFormView:weakself.view];
        
        [self.srRefreshView performSelector:@selector(endRefresh)
                                 withObject:nil afterDelay:0
                                    inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        [weakself.doneArray removeAllObjects];
        [weakself.doneArray addObjectsFromArray:data];
        [weakself.doneTableView reloadData];
        
        self.mySearchBar.text = @"";
        weakself.startNumber = 0;
        weakself.endNumber = 14;
        
        [HTMIWFCSVProgressHUD dismiss];
        
    } failure:^(NSError *error) {
        
        [HTMIWFCEmptyView removeFormView:weakself.view];
        [HTMIWFCSVProgressHUD dismiss];
        
        //        if (error.code == -1001) {//请求超时
        //            [weakself showTimeoutReloadView:^{
        //                [HTMIWFCSVProgressHUD show];
        //                //下拉刷新
        //                [weakself reloadxialashuju];
        //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        //        }
        //        else{//断网
        //            [weakself showErrorReloadView:^{
        //                [HTMIWFCSVProgressHUD show];
        //                //下拉刷新
        //                [weakself reloadxialashuju];
        //            } goToCheck:^{
        //
        //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        //        }
    }];
    
    self.isHaveMoreDone = NO;
    [self.footView removeFromSuperview];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.srRefreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.srRefreshView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//可在下面方法里面添加发刷新请求方法
- (void)slimeRefreshStartRefresh:(HTMIWFCSRRefreshView *)refreshView
{
    [self reloadxialashuju];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doneArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myCell = @"cell";
    
    HTMIWFCOADoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    
    if (!cell) {
        cell = [[HTMIWFCOADoneTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    
    for (id any in cell.contentView.subviews) {
        [any removeFromSuperview];
    }
    HTMIWFCOADoneEntity *done = self.doneArray[indexPath.row];
    
    [cell updateDoneCellContentValue:done];
    
    CGFloat titleHeight = [self labelSizeWithMaxWidth:kScreenWidth-kW6(84) content:done.DocTitle FontOfSize:15].height+kH6(20);
    CGFloat cellHeight = titleHeight+kH6(30);
    
    UIView *myView = [[UIView alloc]init];
    myView.frame = CGRectMake(0, cellHeight-1, kScreenWidth, 1);
    myView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:myView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HTMIWFCOADoneEntity *done = self.doneArray[indexPath.row];
    
    CGFloat titleHeight = [self labelSizeWithMaxWidth:kScreenWidth-kW6(84) content:done.DocTitle FontOfSize:15].height+kH6(20);
    
    CGFloat cellHeight = titleHeight+kH6(30);
    
    return MAX(cellHeight, kH6(70));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [HTMIWFCSVProgressHUD dismiss];
    
    //    //wlq add
    //    if(!HTMIAPPDELEGATE.reachability.isReachable) {
    //
    //        [HTMIWFCApi showAlertInOneSecond:@"此操作需要连接网络"];
    //
    //        return;
    //    }
    
    HTMIWFCOADoneEntity *done = self.doneArray[indexPath.row];
    HTMIWFCOAMatterOperationViewController *vc = [[HTMIWFCOAMatterOperationViewController alloc]init];
    vc.matterID = done.DocID;
    vc.docTitle = done.DocTitle;
    vc.docType = done.DocType;
    vc.kind = done.kind;
    vc.urlPNG = done.iconId;
    vc.sendFrom = done.SendFrom;
    vc.sendDate = done.SendDate;
    vc.iconID = done.iconId;
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    [HTMIWFCSVProgressHUD show];
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    UIFont *font = [UIFont boldSystemFontOfSize:14.0];
    UIColor *textColor = RGBA(102, 102, 102, 1);
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    if (self.mySearchBar.text.length > 0) {
        NSString *text = @"暂无搜索结果，请重试";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    else{
        NSString *text = @"暂无记录";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.mySearchBar.text.length > 0) {
        return [UIImage getPNGImageHTMIWFC:@"img_search_fruitless"];
    }
    else{
        return [UIImage getPNGImageHTMIWFC:@"img_no_messages"];
    }
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view;
{
    //刷新
    [self reloadxialashuju];
}

/*
 - (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
 {
 NSString *text = nil;
 UIFont *font = nil;
 UIColor *textColor = nil;
 
 NSMutableDictionary *attributes = [NSMutableDictionary new];
 
 NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
 paragraph.lineBreakMode = NSLineBreakByWordWrapping;
 paragraph.alignment = NSTextAlignmentCenter;
 
 
 text = @"描述";
 font = [UIFont boldSystemFontOfSize:15.0];
 textColor = [UIColor lightGrayColor];
 
 if (!text) {
 return nil;
 }
 
 if (font) [attributes setObject:font forKey:NSFontAttributeName];
 if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
 if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
 
 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
 
 return attributedString;
 }
 */



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //self.tabBarController.tabBar.hidden = NO;
}

- (void)tableViewReloadData{
    [self viewDidLoad];
}

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

//手键盘
- (void)dismissKeyBoard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //    if (self.mySearchBar.text.length < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self reloadxialashuju];
    //    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //    [self.view endEditing:YES];
    //
    //    if (self.mySearchBar.text.length < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self reloadxialashuju];
    //    }
    
    //    if (self.doneArray.count < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self reloadxialashuju];
    //    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self.footView removeFromSuperview];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    [HTMIWFCSVProgressHUD show];
    [HTMIWFCApi requestMatterFormWithTodoFlag:@"1" andRecordStartIndex:@"0" andRecordEndIndex:@"99" andContext:context andModelName:self.myAppNameString title:self.mySearchBar.text succeed:^(id data) {
        
        
        self.doneArray = data;
        [self.doneTableView reloadData];
        
        self.startString = @"0";
        self.endString = @"14";
        
        [HTMIWFCSVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //    if (searchBar.text.length == 0) {
    //        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    //        NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    //        [HTMIWFCSVProgressHUD show];
    //
    //        [HTMIWFCApi requestMatterFormWithTodoFlag:@"1" andRecordStartIndex:@"0" andRecordEndIndex:@"14" andContext:context andModelName:self.myAppNameString title:@"" succeed:^(id data) {
    //
    //            self.startString = @"0";
    //            self.endString = @"14";
    //
    //            self.doneArray = data;
    //            [self.doneTableView reloadData];
    //
    //            [HTMIWFCSVProgressHUD dismiss];
    //        } failure:^(NSError *error) {
    //            [HTMIWFCSVProgressHUD dismiss];
    //            [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    //        }];
    //    }
}



#pragma mark - Getter And Setter

- (HTMIWFCSRRefreshView *)srRefreshView{
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
        }else{
            _srRefreshView.slime.shadowColor = [[HTMIWFCSettingManager manager] navigationBarColor];
            _srRefreshView.slime.bodyColor = [[HTMIWFCSettingManager manager] navigationBarColor];
        }
    }
    
    return _srRefreshView;
}


@end
