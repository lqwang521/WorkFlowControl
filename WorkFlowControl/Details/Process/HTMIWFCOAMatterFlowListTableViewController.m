//
//  HTMIWFCOAMatterFlowListTableViewController.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/1.
//  Copyright (c) 2015年 MXClient. All rights reserved.

//流程
#import "HTMIWFCOAMatterFlowListTableViewController.h"
#import "HTMIWFCOAMatterFlowListEntity.h"
#import "HTMIWFCOAMatterFlowListTableViewCell.h"
#import "HTMIWFCOALastFlowTableViewCell.h"
#import "HTMIWFCSVProgressHUD.h"
#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
#endif
#import "HTMIWFCOAInfoRegion.h"
#import "HTMIWFCEMJsonParser.h"
#import "HTMIWFCApi.h"

#import "HTMIWFCSettingManager.h"

#import "HTMIWFCEmptyView.h"

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

@interface HTMIWFCOAMatterFlowListTableViewController ()
{
    int myHeightInt;
}

@property(nonatomic,strong)NSArray* actions;
@property (nonatomic, strong)NSArray *matterFormInfoList;
@property (nonatomic, strong)NSMutableArray *matterFormInfoListForiPhone;
@property (nonatomic, strong)NSDictionary *lastFlows;
@property (nonatomic, strong)NSArray *arrLastFlow;
@property (nonatomic, strong)NSString *lastone;

@end

@implementation HTMIWFCOAMatterFlowListTableViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    
    [HTMIWFCSVProgressHUD show];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myUserID)
                                                 name:@"myUserID"
                                               object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initDataAndUI];
}

- (void)initDataAndUI{
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    [HTMIWFCSVProgressHUD show];
    @weakify(self);
    //流程
    //wlq update form -OAMatterInfoHTTPLogic to -HTMIWFCApi
    [HTMIWFCApi requestMatterFlowListWithContext:context andMatterID:self.matterID andDocType:self.docType andKInd:self.kind succeed:^(id data) {
        
        @strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCEmptyView removeFormView:self.view];
        
        self.actions = data;
        //        把最后一个放在这个请求里面加载，否则一进来就显示当前节点，然后刷新，体验不好
        if (!_arrLastFlow) {
            HTMIWFCOAlastFlow *lastFlow = [HTMIWFCEMJsonParser paseFlowInfoDictionart:self.lastFlowDic];
            _arrLastFlow = @[lastFlow];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        //wlq add 应该显示空页面
        @strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCEmptyView removeFormView:self.view];
        
        if (error.code == -1001) {//请求超时
            //            [self showTimeoutReloadView:^{
            //                [HTMIWFCSVProgressHUD show];
            //
            //                [self initDataAndUI];
            //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        else{//断网
            
            //            [self showErrorReloadView:^{
            //                [HTMIWFCSVProgressHUD show];
            //
            //                [self initDataAndUI];
            //            } goToCheck:^{
            //
            //            } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        
    }];
    
    
}

#pragma mark ------ 懒加载最后一条数据
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.actions.count+self.arrLastFlow.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.row < self.actions.count) {
        
        static NSString *myCell = @"cell";
        
        HTMIWFCOAMatterFlowListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
        for (UIView *myView in cell.contentView.subviews) {
            [myView removeFromSuperview];
        }
        if (!cell)
        {
            cell = [[HTMIWFCOAMatterFlowListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        HTMIWFCOAMatterFlowListEntity *flowList = self.actions[indexPath.row];
        int aIdent = (int)indexPath.row;
        [cell creatMatterFlowListCell:flowList andmyIdentfier:aIdent];
        return cell;
    }else{
        //显示的是动作以外的
        static NSString *myCell = @"myCell";
        HTMIWFCOAlastFlow *last = self.arrLastFlow[indexPath.row-self.actions.count];
        HTMIWFCOALastFlowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
        if (!cell) {
            cell = [[HTMIWFCOALastFlowTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell andmyCurrentUsername:last.CurrentUsername andmyCurrentNodename:last.CurrentNodeName];
        }
        
        
        [cell updateMatterFlowListCell:last andmyHeight:myHeightInt];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.actions.count) {
        HTMIWFCOAMatterFlowListEntity *flowList = self.actions[indexPath.row];
        CGSize textSize3 = [flowList.action sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
        CGSize textSize4 = [flowList.Comments sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
        if (textSize3.width+textSize4.width < kScreenWidth-30) {
            return kW(104.0);
        }else{
            if (20+textSize4.width < kScreenWidth-50) {
                int myA = textSize4.width / (kScreenWidth-40);
                int a = 80 + textSize4.height + myA*22;
                return a;
            }else{
                int myA = textSize4.width / (kScreenWidth-50);
                int a = 90 + textSize4.height + myA*22;
                return a;
            }
            
            
        }
    }else{
        NSString *myCurrentUserName = [self.lastFlowDic objectForKey:@"CurrentUserName"];
        NSString *myCurrentNodeName = [self.lastFlowDic objectForKey:@"CurrentNodeName"];
        NSArray *myCurrentNamearray = [myCurrentUserName componentsSeparatedByString:@";"];
        
        if (myCurrentUserName) {
            int myNameHeightLine = 0;
            //        85
            CGSize textSize1 = [myCurrentNodeName sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
            int myWidthFold = 85 + textSize1.width;
            for (int i = 0; i< myCurrentNamearray.count; i++) {
                CGSize textSize2 = [myCurrentNamearray[i] sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
                myWidthFold = myWidthFold + textSize2.width+20;
                if (myWidthFold > kScreenWidth-20) {
                    myNameHeightLine = myNameHeightLine+1;
                    myWidthFold = 0;
                }
                
            }
            myHeightInt = 104+myNameHeightLine*25;
            return myHeightInt;
        }else{
            myHeightInt = 104;
            return myHeightInt;
        }
        
    }
    
    
}

#pragma mark - 通知监听方法

- (void)myUserID{
    
    NSUserDefaults *defaule = [NSUserDefaults standardUserDefaults];
    NSArray *userArr = [defaule objectForKey:@"userID"];
    if (userArr != nil) {
        
#ifdef WorkFlowControl_Enable_MX
//        [[MXChat sharedInstance]chat:userArr withViewController:self withFailCallback:^(id object, MXError *error) {
//            [HTMIWFCSVProgressHUD showErrorWithStatus:error.description duration:2.0];
//        }];
#endif
    }
}



@end
