//
//  HTMIWFCMyAttentionViewController.m
//  MXClient
//
//  Created by 赵志国 on 2016/9/25.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCMyAttentionViewController.h"

#import "HTMIWFCApi.h"

#import "HTMIWFCOADoneEntity.h"//模型

#import "HTMIWFCSVProgressHUD.h"//加载中。。。

#import "HTMIWFCSVPullToRefresh.h"//上拉加载

#import "HTMIWFCSRRefreshView.h"//下拉刷新

#import "HTMIWFCOADoneTableViewCell.h"

#import "HTMIWFCOAMatterOperationViewController.h"

#import "HTMIWFCApi.h"

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

@interface HTMIWFCMyAttentionViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,SRRefreshDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

/**
 * 搜索框
 */
@property (nonatomic, strong) UISearchBar *searchBar;


@property (nonatomic, strong) UITableView *attentionTableView;

/**
 * 登录信息
 */
@property (nonatomic, strong) NSDictionary *context;

/**
 * 我的关注
 */
@property (nonatomic, strong) NSMutableArray *myAttentionArray;

/**
 * 下拉刷新
 */
@property (nonatomic, strong) HTMIWFCSRRefreshView *refreshView;

/**
 * 开始
 */
@property (nonatomic, assign) NSInteger startInteger;

/**
 * 结束
 */
@property (nonatomic, assign) NSInteger endInteger;

/**
 * 流程名称关键字
 */
@property (nonatomic, copy) NSString *modelNameString;

/**
 * 标题关键字
 */
@property (nonatomic, copy) NSString *titleString;

/**
 * 上拉加载底部最后一条提示
 */
@property (nonatomic, strong) UIView *loadFootView;

/**
 * 是否最后一条
 */
@property (nonatomic, assign) BOOL haveNoMoreAttention;


@end

@implementation HTMIWFCMyAttentionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [HTMIWFCSVProgressHUD show];
    
    [self setSearchBar:self.searchBar];
    
    [self setAttentionTableView:self.attentionTableView];
    
    [self myAttentionData];
    
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notice) name:@"refreshMyAttentionTableView" object:nil];
    // Do any additional setup after loading the view.
}

- (void)notice {
    self.startInteger = 1;
    self.endInteger = 15;
    
    [self noticeRefreshAttentionTableView];
}

- (void)noticeRefreshAttentionTableView {
    @weakify(self);
    [HTMIWFCApi requestMyAttentionWithContext:self.context startIndex:[NSString stringWithFormat:@"%ld",(long)self.startInteger] endIndex:[NSString stringWithFormat:@"%ld",(long)self.endInteger] modelName:self.modelNameString title:self.titleString succeed:^(id data) {
        
        @strongify(self);
        //下拉刷新时或者第一次进入
        self.myAttentionArray = data;
        [self.attentionTableView reloadData];
        
        if (self.myAttentionArray.count > 14) {
            @weakify(self);
            [self.attentionTableView addInfiniteScrollingWithActionHandler:^{
                @strongify(self);
                //需要抽取成方法
                [self loadMoreData];
                
            }];
        }
        
    } failure:^(NSError *error) {
        [self.attentionTableView.infiniteScrollingView stopAnimating];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------ 获取数据
- (void)myAttentionData {
    @weakify(self);
    [HTMIWFCApi requestMyAttentionWithContext:self.context startIndex:[NSString stringWithFormat:@"%ld",(long)self.startInteger] endIndex:[NSString stringWithFormat:@"%ld",(long)self.endInteger] modelName:self.modelNameString title:self.titleString succeed:^(id data) {
        
        [self loadingDismiss];
        //        __weak HTMIWFCMyAttentionViewController *weakself = self;
        
        @strongify(self);
        if (self.startInteger != 1) {//上拉加载
            
            [self.attentionTableView beginUpdates];
            
            if (((NSArray *)data).count > 0) {//有数据时
                [self.myAttentionArray addObjectsFromArray:data];
                
                for (int i = 0; i < ((NSArray *)data).count; i++) {
                    [self.attentionTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.myAttentionArray.count-(i+1) inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                }
                [self.attentionTableView endUpdates];
                [self.attentionTableView.infiniteScrollingView stopAnimating];
                
            } else {//无数据时提示最后一条
                [self.attentionTableView endUpdates];
                [self.attentionTableView.infiniteScrollingView stopAnimating];
                
                self.haveNoMoreAttention = YES;
                
                [self.attentionTableView.infiniteScrollingView addSubview:self.loadFootView];
            }
            
        } else {//下拉刷新时或者第一次进入
            self.myAttentionArray = data;
            [self.attentionTableView reloadData];
        }
        
        if (self.myAttentionArray.count > 14) {
            @weakify(self);
            [self.attentionTableView addInfiniteScrollingWithActionHandler:^{
                @strongify(self);
                //需要抽取成方法
                [self loadMoreData];
                
            }];
        }
        
    } failure:^(NSError *error) {
        [self loadingDismiss];
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
        [self.attentionTableView.infiniteScrollingView stopAnimating];
    }];
    
}

#pragma mark ------ 下拉刷新
// ------ slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(HTMIWFCSRRefreshView *)refreshView {
    //开始刷新
    [self refreshing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshView scrollViewDidEndDraging];
}

- (void)refreshing {
    //还原部分内容
    self.startInteger = 1;
    self.endInteger = 15;
    self.haveNoMoreAttention = NO;
    self.searchBar.text = @"";
    self.titleString = @"";
    self.modelNameString = @"";
    [self.loadFootView removeFromSuperview];
    
    [self myAttentionData];
}

- (void)loadingDismiss {
    [HTMIWFCSVProgressHUD dismiss];
    [self.refreshView performSelector:@selector(endRefresh) withObject:nil afterDelay:0.0 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

#pragma mark ------上拉加载
- (void)loadMoreData {
    //    __weak HTMIWFCMyAttentionViewController *weakself = self;
    
    if (self.titleString.length > 0) {
        [self.attentionTableView.infiniteScrollingView stopAnimating];
    } else{
        if (self.haveNoMoreAttention) {
            [self.attentionTableView.infiniteScrollingView stopAnimating];
        } else {
            self.startInteger+=15;
            self.endInteger+=15;
            
            [self myAttentionData];
        }
    }
}
#pragma mark ------ 懒加载
- (UITableView *)attentionTableView {
    if (!_attentionTableView) {
        _attentionTableView = [[UITableView alloc] init];
        if (self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {// 有tabbar并且显示
            
            _attentionTableView.frame = CGRectMake(0, 42, kScreenWidth, kScreenHeight-64-50-49-42);
        }
        else{
            _attentionTableView.frame = CGRectMake(0, 42, kScreenWidth, kScreenHeight-64-50-42);
        }
        
        
        _attentionTableView.delegate = self;
        _attentionTableView.dataSource = self;
        _attentionTableView.emptyDataSetSource = self;
        _attentionTableView.emptyDataSetDelegate = self;
        _attentionTableView.tableFooterView = [[UIView alloc] init];
        [_attentionTableView addSubview:self.refreshView];
        [self.view addSubview:_attentionTableView];
    }
    
    return _attentionTableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 42)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"请输入标题或流程关键字搜索";
        //下面三行改变颜色
        UIView *segmentView = [_searchBar.subviews objectAtIndex:0];
        [[segmentView.subviews objectAtIndex:0] removeFromSuperview];
        _searchBar.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:244/255.0 alpha:1.0];
        [self.view addSubview:_searchBar];
        
        //收键盘的按钮
        UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        [topView setBarStyle:UIBarStyleDefault];
        UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithImage:[UIImage getPNGImageHTMIWFC:@"btn_packup_keyboard"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
        
        NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
        [topView setItems:buttonsArray];
        [_searchBar setInputAccessoryView:topView];
    }
    
    return _searchBar;
}

- (HTMIWFCSRRefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[HTMIWFCSRRefreshView alloc] init];
        _refreshView.delegate = self;
        _refreshView.upInset = 0;
        _refreshView.slimeMissWhenGoingBack = YES;
        _refreshView.slime.skinColor = [UIColor whiteColor];
        _refreshView.slime.lineWith = 1;
        _refreshView.slime.shadowBlur = 4;
        
        if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
            //蓝色
            _refreshView.slime.shadowColor = [[HTMIWFCSettingManager manager] blueColor];
            _refreshView.slime.bodyColor = [[HTMIWFCSettingManager manager] blueColor];
        }else{
            _refreshView.slime.shadowColor = [[HTMIWFCSettingManager manager] navigationBarColor];
            _refreshView.slime.bodyColor = [[HTMIWFCSettingManager manager] navigationBarColor];
        }
    }
    
    return _refreshView;
}

- (UIView *)loadFootView {
    if (!_loadFootView) {
        _loadFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kH6(60))];
        _loadFootView.backgroundColor = [UIColor whiteColor];
        
        UILabel *footLabel = [[UILabel alloc] initWithFrame:_loadFootView.bounds];
        footLabel.text = @"已是最后一条数据......";
        footLabel.font = [UIFont systemFontOfSize:10.0];
        footLabel.textAlignment = NSTextAlignmentCenter;
        footLabel.textColor = [UIColor lightGrayColor];
        [_loadFootView addSubview:footLabel];
    }
    return _loadFootView;
}

- (NSDictionary *)context {
    if (!_context) {
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        _context = [userdefaults objectForKey:@"kContextDictionary"];
    }
    
    return _context;
}

- (NSMutableArray *)myAttentionArray {
    if (!_myAttentionArray) {
        _myAttentionArray = [NSMutableArray array];
    }
    
    return _myAttentionArray;
}

- (NSInteger)startInteger {
    if (!_startInteger) {
        _startInteger = 1;
    }
    
    return _startInteger;
}

- (NSInteger)endInteger {
    if (!_endInteger) {
        _endInteger = 15;
    }
    
    return _endInteger;
}

- (NSString *)modelNameString {
    if (!_modelNameString) {
        _modelNameString = @"";
    }
    return _modelNameString;
}

- (NSString *)titleString {
    if (!_titleString) {
        _titleString = @"";
    }
    return _titleString;
}

#pragma mark ------ 私有方法
- (void)dismissKeyBoard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //    if (self.searchBar.text.length < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self refreshing];
    //    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //    [self.view endEditing:YES];
    //
    //    if (self.searchBar.text.length < 1 && self.myAttentionArray.count > 0) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self refreshing];
    //    }
    
    //    if (self.myAttentionArray.count < 1) {
    //        [HTMIWFCSVProgressHUD show];
    //        [self refreshing];
    //    }
}

#pragma mark ------ UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myAttentionArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *attentionCell = @"attentionCell";
    HTMIWFCOADoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:attentionCell];
    if (!cell) {
        cell = [[HTMIWFCOADoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:attentionCell];
    }
    for (id any in cell.contentView.subviews) {
        [any removeFromSuperview];
    }
    HTMIWFCOADoneEntity *done = self.myAttentionArray[indexPath.row];
    
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
    
    HTMIWFCOADoneEntity *done = self.myAttentionArray[indexPath.row];
    
    CGFloat titleHeight = [self labelSizeWithMaxWidth:kScreenWidth-kW6(84) content:done.DocTitle FontOfSize:15].height+kH6(20);
    
    CGFloat cellHeight = titleHeight+kH6(30);
    
    return MAX(cellHeight, kH6(70));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [HTMIWFCSVProgressHUD dismiss];
    
    HTMIWFCOADoneEntity *done = self.myAttentionArray[indexPath.row];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 设置删除按钮
    UITableViewRowAction *noDeleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"取消关注" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //事件
        [HTMIWFCSVProgressHUD show];
        HTMIWFCOADoneEntity *done = self.myAttentionArray[indexPath.row];
        
        [HTMIWFCApi attentOrDisAttentWithContext:self.context docID:done.DocID attentionFlag:@"0" allowPush:@"1" docTitle:done.DocTitle docType:done.DocType sendFrom:done.SendFrom sendDate:done.SendDate iconID:done.iconId kind:done.kind succeed:^(id data) {
            
            [HTMIWFCSVProgressHUD dismiss];
            [HTMIWFCSVProgressHUD showSuccessWithStatus:@"取消关注成功" duration:1.0];
            
            [self.myAttentionArray removeObjectAtIndex:indexPath.row];
            
            [self.attentionTableView reloadData];
            
        } failure:^(NSError *error) {
            [HTMIWFCSVProgressHUD showErrorWithStatus:@"取消关注失败" duration:1.0];
            [HTMIWFCSVProgressHUD dismiss];
            
        }];
    }];
    
    
    noDeleAction.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    
    return @[noDeleAction];
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
        NSString *text = @"暂无记录";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.searchBar.text.length > 0) {
        return [UIImage getPNGImageHTMIWFC:@"img_search_fruitless"];
    }
    else{
        return [UIImage getPNGImageHTMIWFC:@"img_no_messages"];
    }
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view;
{
    //刷新
    [self refreshing];
}

#pragma mark ------ 搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    
    self.startInteger = 1;
    self.endInteger = 999;
    self.titleString = self.searchBar.text;
    self.modelNameString = self.searchBar.text;
    [self.loadFootView removeFromSuperview];
    
    [self myAttentionData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
