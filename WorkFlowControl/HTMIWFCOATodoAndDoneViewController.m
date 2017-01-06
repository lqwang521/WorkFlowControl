//
//  HTMIWFCOATodoAndDoneViewController.m
//  MXClient
//
//  Created by 赵志国 on 16/3/8.
//  Copyright (c) 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOATodoAndDoneViewController.h"

//#import "AppDelegate+PrivateMethod.h"
#import "HTMIWFCApi.h"
//#import "MXConfig.h"
//#import "MXNavBarView.h"
#import "HTMIWFCOAMatterOperationViewController.h"
//#import "OAAddQuickViewController.h"
#import "HTMIWFCOAMatterInfo.h"
#import "HTMIWFCEGOImageButton.h"
#import "HTMIWFCSVProgressHUD.h"
#import "HTMIWFCOADoneViewController.h"
#import "HTMIWFCOAToDoViewController.h"
#import "HTMIWFCMineViewController.h"

#import "HTMIWFCSettingManager.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCOAUser.h"
//#import "MXNetworkListView.h"
//#import "MXPopupMenuView.h"
#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
//#import "MXAppCenter.h"
#endif

//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]



#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface HTMIWFCOATodoAndDoneViewController ()
<UIGestureRecognizerDelegate,
//MXNavBarViewDelegate,
UIScrollViewDelegate
//,
//MXPopupMenuViewDelegate
>
{
    UIView *navAddView;  //存放"+"小view
    UIView *rootView;    //最底层view与已办切换时用到
    UISegmentedControl *segmentControl;
    HTMIWFCOAToDoViewController *todoVC;
    HTMIWFCOADoneViewController *doneVC;
    HTMIWFCMineViewController *mineVC;
    //    MXNetworkListView *networkListView;
    UIView *myCoverView;
}
@property (atomic)BOOL pullDown;
@property(nonatomic,assign)BOOL isDone;

@property (nonatomic, strong) NSArray *viewControllArray;

@property (nonatomic, assign) NSInteger segmentIndex;

@end

@implementation HTMIWFCOATodoAndDoneViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TOdoDaiban"
                                                        object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(LayoutstartCancell)
    //                                                 name:@"startCancellstartCancell"
    //                                               object:nil];
    
    rootView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    [self.view addSubview:rootView];
    
    mineVC = [[HTMIWFCMineViewController alloc] init];
    [self addChildViewController:mineVC];
    doneVC = [[HTMIWFCOADoneViewController alloc]init];
    [self addChildViewController:doneVC];
    todoVC = [[HTMIWFCOAToDoViewController alloc]init];
    [self addChildViewController:todoVC];
    
    self.viewControllArray = @[todoVC,doneVC,mineVC];
    
    //重画导航
    [self myOwnNavigation];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeInToDoAndDone:)];
    swipe.delegate = self;
    swipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    //    [self.view addGestureRecognizer:swipe];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    //    self.tabBarController.tabBar.hidden = NO;
    
    [HTMIWFCSVProgressHUD dismiss];
    
}

#pragma mark - 事件
//手势  实现代办／已办左右滑动切换
- (void)swipeInToDoAndDone:(UISwipeGestureRecognizer *)swipe{
    if (self.isDone) {
        self.isDone = NO;
        segmentControl.selectedSegmentIndex = 0;
        todoVC.view.frame = self.view.bounds;
        [self transitionFromViewController:doneVC toViewController:todoVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
    }
    else{
        segmentControl.selectedSegmentIndex = 1;
        self.isDone = YES;
        doneVC.view.frame = self.view.frame;
        [self transitionFromViewController:todoVC toViewController:doneVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - segment点击事件
//实现代办／已办左右滑动切换
- (void)segmentPress:(UISegmentedControl *)seg{
    
    NSInteger index = seg.selectedSegmentIndex;
    
    switch (index) {
        case 0:
            todoVC.view.frame = self.view.bounds;
            [self transitionFromViewController:self.viewControllArray[self.segmentIndex] toViewController:todoVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
            }];
            break;
            
        case 1:
            doneVC.view.frame = self.view.bounds;
            [self transitionFromViewController:self.viewControllArray[self.segmentIndex] toViewController:doneVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
            }];
            break;
        case 2:
            mineVC.view.frame = self.view.bounds;
            [self transitionFromViewController:self.viewControllArray[self.segmentIndex] toViewController:mineVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
            }];
            break;
            
        default:
            break;
    }
    
    self.segmentIndex = index;
}

#pragma mark - 重画导航栏

- (void)myOwnNavigation{
    
    UIView * customNavigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    customNavigationView.userInteractionEnabled = YES;
    [self.view addSubview:customNavigationView];
    UIImageView *myImg = [[UIImageView alloc]initWithFrame:customNavigationView.frame];
    myImg.userInteractionEnabled = YES;
    //wlq update 2016/05/11 适配风格
    myImg.image = [UIImage imageWithRenderColorHTMIWFC:[[HTMIWFCSettingManager manager] navigationBarColor] renderSize:CGSizeMake(10., 10.)];
    [customNavigationView addSubview:myImg];
    
    //    if (![self.homePageString isEqualToString:@"OA_AllToDo"] && ![self.homePageString isEqualToString:@"OA_AllHasDone"]) {
    //        //        //    侧边栏按钮添加
    //        //        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    //        //        [btn addTarget:self action:@selector(myBtn:) forControlEvents:UIControlEventTouchUpInside];
    //        //        [btn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_community_list_phone" ] forState:UIControlStateNormal];
    //        //        [btn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_community_list_phone" ] forState:UIControlStateHighlighted];
    //        //
    //        //        [customNavigationView addSubview:btn];
    
    //
    //    }else{
    
    //    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 20, 44, 44);
    
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        //蓝色
        btn.tintColor = [[HTMIWFCSettingManager manager] blueColor];
    }
    else{
        btn.tintColor = [UIColor whiteColor];
    }
    
    [btn addTarget:self action:@selector(PopViewController) forControlEvents:UIControlEventTouchUpInside];
    [customNavigationView addSubview:btn];
    
    
    //我的
    NSArray *segmentArr = @[@"待办",@"已办",@"关注"];
    segmentControl = [[UISegmentedControl alloc]initWithItems:segmentArr];
    segmentControl.frame = CGRectMake(WIDTH/2-90, 27, 180, 30);
    
    //wlq add 只能单独修改，因为敏行也用到了
    
    [segmentControl setBackgroundColor:[[HTMIWFCSettingManager manager] segmentedControlBackgroundColor]];//kSegmentedControlBackgroundColor
    [segmentControl setTintColor:[[HTMIWFCSettingManager manager] segmentedControlTintColor]];//kSegmentedControlTintColor
    
    if ([self.homePageString isEqualToString:@"OA_AllHasDone"]) {
        segmentControl.selectedSegmentIndex = 1;
        
        doneVC.myAppNameString = @"";
        doneVC.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height+93);
        [rootView addSubview:doneVC.view];
        
    }else {
        segmentControl.selectedSegmentIndex = 0;
        todoVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+93);
        
        [rootView addSubview:todoVC.view];
    }
    
    [segmentControl addTarget:self action:@selector(segmentPress:) forControlEvents:UIControlEventValueChanged];
    [customNavigationView addSubview:segmentControl];
    
    
    navAddView = [[UIView alloc]initWithFrame:CGRectMake(WIDTH-44, 20, 44, 44)];
    [customNavigationView addSubview:navAddView];
    //    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    //    //[rightBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_add_phone"] forState:UIControlStateNormal];
    //    [rightBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_add_phone"] forState:UIControlStateNormal];
    //    [rightBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_add_phone"] forState:UIControlStateHighlighted];
    //    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    //    //适配风格 应该删除，要不然图片颜色会被修改
    //    //wlq update 2016/05/11 适配风格
    //    if ([kApplicationHue isEqualToString:@"_white"]) {
    //
    //        rightBtn.tintColor = kApplicationHueBlueColor;
    //    }
    //    else{
    //
    //        rightBtn.tintColor = [UIColor whiteColor];
    //    }
    //
    //    [rightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [navAddView addSubview:rightBtn];
}

- (void)PopViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

//右上角按钮点击事件
- (void)rightBtn:(UIButton *)button{

    //wlq 暂时注释
//    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
//    NSMutableArray *imgList = [NSMutableArray arrayWithObjects:
//                               @"mx_icon_menu_appCenter_phone",
//                               @"mx_icon_menu_sns_phone",
//                               @"mx_icon_menu_qrCode_phone",
//                               nil];
//    NSMutableArray *remoteArr = [NSMutableArray arrayWithObjects:@"",@"",@"", nil];
//    NSArray *nameArray = [NSArray arrayWithObjects:@"appCenter",@"share",@"qrCode",  nil];
//    NSMutableDictionary *nameDic = [[NSMutableDictionary alloc] initWithObjects:imgList forKeys:nameArray] ;
//    NSArray *textArray = [NSArray arrayWithObjects:GetLocalResStr(@"mx_qr_appCenter"),GetLocalResStr(@"mx_work_jobsharing"),GetLocalResStr(@"mx_qr_code"),  nil];
//    for(int i = 0; i< textArray.count; i++)
//    {
//        MXAppsVO *appVo = [[MXAppsVO alloc] init] ;
//        appVo.text = [textArray objectAtIndex:i];
//        appVo.name = [nameArray objectAtIndex:i];
//        [menuItems addObject:appVo];
//    }
//    MXPopupMenuView *pop = [MXPopupMenuView popupMenuWithItems:menuItems
//                                                        images:nameDic];
//    pop.imageSize = 24;
//    pop.y = 10;
//    pop.remoteUrlArray = remoteArr;
//    [pop showAtPoint:CGPointMake(20, 44) inView:navAddView animated:NO];
//    pop.popupMenuDelegate = self;
}

#pragma mark - MXPopupMenuViewDelegate   popupView的点击事件

- (void)selectedMenuItemIndex:(NSInteger)index url:(NSString*)url title:(NSString*)title;{
    
}
        //wlq 暂时注释
//- (void)selectedMenuItemAppVo:(MXAppsVO *)appVo{

//    if([appVo.name isEqualToString:@"multiChat"])
//    {
//        [MobClick event:@"createMultiChat"];
//        [[MXChat sharedInstance] startChat];
//    }
//    else if([appVo.name isEqualToString:@"addPeople"])
//    {
//        [[MXChat sharedInstance] addContact];
//    }
//    else if([appVo.name isEqualToString:@"share"])
//    {
//        [MobClick event:@"shareJob"];
//        [[MXChat sharedInstance] shareJob];
//    } else if([appVo.name isEqualToString:@"qrCode"]) {
//        UIViewController *qrVC = [[MXKit shareMXKit] getQRScanViewController];
//        qrVC.hidesBottomBarWhenPushed = YES;
// 
//        [self.navigationController pushViewController:qrVC animated:YES];
//    }else if([appVo.name isEqualToString:@"appCenter"]) {
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [delegate appCenter];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSegmentControlSelecteIndex:(NSString *)selectIndex{
    if (segmentControl) {
        
        if ([selectIndex isEqualToString:@"0"]) {
            segmentControl.selectedSegmentIndex = 0;
            todoVC.view.frame = self.view.bounds;
            if (self.segmentIndex != [selectIndex integerValue]) {
                [self transitionFromViewController:self.viewControllArray[self.segmentIndex] toViewController:todoVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
                }];
            }
            
        }
        else if ([selectIndex isEqualToString:@"1"]){
            segmentControl.selectedSegmentIndex = 1;
            doneVC.view.frame = self.view.frame;
            if (self.segmentIndex != [selectIndex integerValue]) {
                [self transitionFromViewController:self.viewControllArray[self.segmentIndex] toViewController:doneVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
                }];
            }
            
        }
        else if ([selectIndex isEqualToString:@"2"]) {
            segmentControl.selectedSegmentIndex = 2;
            mineVC.view.frame = self.view.bounds;
            if (self.segmentIndex != [selectIndex integerValue]) {
                [self transitionFromViewController:self.viewControllArray[self.segmentIndex] toViewController:mineVC duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
                }];
            }
            
        }
        
        self.segmentIndex = [selectIndex integerValue];
    }
    
    
    
}


+ (void)loginEMM:(NSString *)name password:(NSString *)password succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure{
    [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeBlack];
    //登录OA
    [HTMIWFCApi loginWithUserID:name andPassword:password succeed:^(id data) {
        [HTMIWFCSVProgressHUD dismiss];
        
        if (data)
        {
            NSDictionary *resultDic = [data objectForKey:@"Result"];
            
            NSDictionary *MessageDic = [data objectForKey:@"Message"];
            
            NSInteger status = [[data objectForKey:@"Status"] integerValue];
            
            NSLog(@"登录打印%ld%@",(long)status,[MessageDic objectForKey:@"StatusMessage"]);
            
            if (status == 1 && [[MessageDic objectForKey:@"StatusCode"] integerValue] == 200) {
                //保存用户信息
                HTMIWFCOAUser *user = [HTMIWFCOAUser parserMyUserByDic:data];
                
                succeed(@"Success");
            }
        }
    } failure:^(NSError *error) {
        
        failure(error);
        
        [HTMIWFCSVProgressHUD dismiss];
        
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    }];
}
#pragma mark - 单例

/*
 static id _instance = nil;
 
 + (id)allocWithZone:(struct _NSZone *)zone
 {
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 _instance = [super allocWithZone:zone];
 });
 return _instance;
 }
 
 + (instancetype)sharedHTMIWFCOATodoAndDoneViewController
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
 */

@end
