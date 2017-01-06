//
//  HTMIWFCOAMatterOperationViewController.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/31.
//  Copyright (c) 2015年 MXClient. All rights reserved.

//详情页面
#import "HTMIWFCOAMatterOperationViewController.h"
#import "HTMIWFCOAMatterFormTableViewController.h"
#import "HTMIWFCMIMainBodyViewController.h"
#import "HTMIWFCOAMatterAttachmentViewController.h"
#import "HTMIWFCOAMatterFlowListTableViewController.h"
#import "HTMIWFCOAMainBodyService.h"
#import "HTMIWFCOAAttachEntity.h"
#import "HTMIWFCDWBubbleMenuButton.h"
#import "HTMIWFCOAManageFollowViewController.h"
//#import "HTMIWFCOAQuickOpinionViewController.h"
#import "HTMIWFCOAOperationService.h"
#import "HTMIWFCSVProgressHUD.h"
#import "HTMIWFCOAOperationProtocol.h"
#import "HTMIWFCOAMatterFormFieldItem.h"
//#import "AppDelegate+PrivateMethod.h"
#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
//#import "MXCircle.h"
#endif
//#import "CustomIOSAlertView.h"
#import "HTMIWFCCustomAlertView.h"
//#import "MXConst.h"
#import "HTMIWFCOAOperationDataEntity.h"
//选择页面
//#import "HTMIABCChooseFormAddressBookViewController.h"
#import "HTMIABCChooseFormAddressBookViewController.h"
//#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_UserModel.h"
//#import "HTMIABCSYS_DepartmentModel.h"

#import "HTMIWFCSegmentedControl.h"

#import "HTMIWFCSettingManager.h"
#import "HTMIWFCApi.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCEmptyView.h"
//#import "Loading.h"
/**
 *  自定义底部选择按钮
 */
#import "HTMWFCIBottomActionView.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

//定义应用屏幕宽度
#define WIDTH  [UIScreen mainScreen].bounds.size.width
//定义应用屏幕高度
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
//蓝色
//#define navBarColor [UIColor colorWithRed:81.0/255.0 green:195.0/255.0 blue:39.0/255.0 alpha:1.0];
//有正文
#define hasBodyDoc  (self.matterBodyDocID && self.matterBodyDocID.length > 0)
//有附件
#define hasAttach  (self.matterAttachList && self.matterAttachList.count > 0)

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

//取view的坐标及长宽
#define W(view)    view.frame.size.width
#define H(view)    view.frame.size.height
#define X(view)    view.frame.origin.x
#define Y(view)    view.frame.origin.y


#ifdef DEBUG

#define HTLog(...) NSLog(__VA_ARGS__)

#define HTLogDetail(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define HTLog(...)

#define HTLogDetail(fmt, ...)

#endif

#define ISFormType 0

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



@interface HTMIWFCOAMatterOperationViewController ()<
OAManegerFollowViewControllerDelegate,
UIGestureRecognizerDelegate,
DWBubbleMenuViewDelegate,
OAOperationDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate,
HTMIWFCCustomAlertViewDelegate,
UIAlertViewDelegate,
HTMWFCIBottomActionViewDelegate>

//操作引导手势
@property (nonatomic, strong)UITapGestureRecognizer *tap;

@property (nonatomic, strong) HTMIWFCSegmentedControl *hmSegmentedControl;
/**
 *  segment 最后一个index
 */
@property(nonatomic,assign)NSInteger segmentLastIndex;
/**
 *  segmeng下边框
 */
//@property(nonatomic,strong)UILabel *segmentLabel;
@property(nonatomic,strong)UIView *myContentView;//内容视图
@property(nonatomic,strong)HTMIWFCDWBubbleMenuButton *upMenuView;
@property(nonatomic,strong)UITableView *routeTableView;//选择路由
@property(nonatomic,strong)HTMIWFCCustomAlertView *alertView;
@property(nonatomic,strong)UIView *popLabelView;

@property(nonatomic,strong)NSMutableArray *operationDataArray;//提交等事项
@property(nonatomic,strong)NSMutableArray *eidtFieldListDicArray;//储存用户在表单页面编辑的意见
@property(nonatomic,strong)NSDictionary *appendDictionary;//附加信息
@property(nonatomic,copy)NSString *eidtValue;//编辑的值

@property(nonatomic,strong)UILabel *homeLabel;//操作事项 top 按钮
@property(nonatomic,strong)NSMutableSet *mustEditFeildItems;//必须填写的意见
@property(nonatomic,copy)NSString *currentActionID;//纪录当前操作事项
@property(nonatomic,copy)NSString *comment;//保存用户的意见
@property(nonatomic,copy)NSString *currentNodeID;//请假参数
@property(nonatomic,copy)NSString *currentTrackId;//请假参数
@property(nonatomic,copy)NSString *flowName;

@property(nonatomic,strong)NSMutableArray *routeNameArray;
@property(nonatomic,strong)NSMutableArray *routeIDArray;
@property(nonatomic,assign)NSInteger selectedRow;
@property(nonatomic,strong)NSMutableArray *selectedRouteArray;

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)NSMutableArray *actionNamesArray;

@property(nonatomic,assign)NSInteger segmentIndex;
@property(nonatomic,strong)NSMutableArray *controllerArray;

/**
 *  正文等没有没有详细内容 会弹出提示
 */
@property(nonatomic,strong)UIAlertView *backAlertView;

/**
 * 底部按钮view
 */
@property (nonatomic, strong) UIView *bottombuttonView;

/**
 * 底部按钮自定义
 */
@property (nonatomic, strong) HTMWFCIBottomActionView *bottomActionView;



@end

@implementation HTMIWFCOAMatterOperationViewController

static BOOL isClick = YES;

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    // 自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //导航字体颜色
    //wlq update 2016/05/11 适配风格
    [self customNavigationController:NO title:@""];
    
    isClick = YES;
    self.selectedRow = 999;
    //初始化
    self.eidtFieldListDicArray = [[NSMutableArray alloc]init];
    self.mustEditFeildItems = [[NSMutableSet alloc] init];
    self.myContentView = [[UIView alloc]init];
    
    //第一次进入的引导页
    [self firstLogin];
    
    [self.view addSubview:self.myContentView];
    
    if (self.flowid.length > 0)
    {
        //处理请假的情况的逻辑
        [self leaveByFlowidExist];
    }
    else
    {
        //处理请假的情况的逻辑(包括正文、流程、等等)
        [self exceptLeaveCondition];
    }
    
    //将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    self.navigationController.navigationBarHidden = YES;
    //self.navigationController.navigationBar.tintColor = navBarColor;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 代理方法

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.backAlertView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - DWBubbleMwnuButtonDelegate

/**
 *  气泡菜单按钮点击事件的代理
 *
 *  @param name 设置图片（如果不设置就是圆形加号图片）
 */
- (void)changeViewImage:(NSString *)name{
    
    if (isClick)
    {
        [self.popLabelView removeFromSuperview];
        
        [self.homeLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage getPNGImageHTMIWFC:name]]];
        
        [self popLabelAnimation];
    }
    else
    {
        [self.homeLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage getPNGImageHTMIWFC:@"btn_operation_homelabel_off"]]];
        
        [self.popLabelView removeFromSuperview];
    }
    
    CGRect frame = CGRectMake(self.upMenuView.frame.origin.x,
                              self.upMenuView.frame.origin.y+self.upMenuView.frame.size.height-50,
                              50,
                              50);
    self.upMenuView.newFrame = frame;
    isClick = !isClick;
}

#pragma mark - UIActionSheet代理方法

/**
 *  表单分享
 *
 *  @param actionSheet UIActionSheet
 *  @param buttonIndex clickedButtonAtIndex
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    //    NSString *shareBody = [userdefaults objectForKey:@"bodyShare"];
    //    NSString *urlsave = [userdefaults objectForKey:@"URLsave"];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    NSString *str1 = [context objectForKey:@"UserID"];
    NSString *str2 = [context objectForKey:@"OA_UserId"];
    NSString *str3 = [context objectForKey:@"OA_UserName"];
    NSString *str4 = [context objectForKey:@"ThirdDepartmentId"];
    NSString *str5 = [context objectForKey:@"ThirdDepartmentName"];
    NSString *str6 = [context objectForKey:@"attribute1"];
    NSString *str7 = [context objectForKey:@"UserName"];
    //    注释部分如果打开：在表单页面点分享，分享表单，在正文页面点分享，分享正文。
    //    if (shareBody) {
    //
    //        if (buttonIndex == 0){
    //            NSString *str = [NSString stringWithFormat:@"cc%@",urlsave];
    //            [[MXChat sharedInstance]shareTitle:@"分享正文" withDescription:self.docTitle withURL:nil withNativeURL:str withThumbnailURL:self.urlPNG withViewController:self];
    //            HTLog(@"%@",str);
    //            HTLog(@"%@",self.urlPNG);
    //
    //        }else if (buttonIndex == 1){
    //            NSString *str = [NSString stringWithFormat:@"dd%@",urlsave];
    //            HTLog(@"%@",str);
    //            NSString *myTitle = [NSString stringWithFormat:@"分享正文:%@",self.docTitle];
    //            [[MXCircle sharedInstance]shareTitle:myTitle withDescription:@"" withURL:nil withNativeURL:str withThumbnailURL:self.urlPNG withViewController:self];
    //            HTLog(@"%@",str);
    //            HTLog(@"%@",self.urlPNG);
    //        }
    //
    //
    //    }else{
    if (!self.urlPNG) {
        self.urlPNG = @"http://img1.gtimg.com/13/1301/130137/13013760_980x1200_0.jpg";
    }
    if (buttonIndex == 0){
        NSString *str  = [NSString stringWithFormat:@"aa%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",str1,str2,str3,self.matterID,self.kind,self.docType,str4,str5,str6,str7];
#ifdef WorkFlowControl_Enable_MX
//        [[MXChat sharedInstance]shareTitle:@"分享表单" withDescription:self.docTitle withURL:nil withNativeURL:str withThumbnailURL:self.urlPNG withViewController:self];
#endif
        
    }else if (buttonIndex == 1){
        NSString *myTitle = [NSString stringWithFormat:@"分享表单:%@",self.docTitle];
        NSString *str  = [NSString stringWithFormat:@"bb%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",str1,str2,str3,self.matterID,self.kind,self.docType,str4,str5,str6,str7];
#ifdef WorkFlowControl_Enable_MX
//        [[MXCircle sharedInstance]shareTitle:myTitle withDescription:@"" withURL:nil withNativeURL:str withThumbnailURL:self.urlPNG withViewController:self];
#endif
    }
    
    //    }
}


-(void)quickOpinion:(NSString *)opinion{
    
}

#pragma mark - OAManagerFollowViewcontrollerDelegate

- (void)followDidSelected:(NSArray *)selected hasSelectedRoute:(NSArray *)hasSelectedRoute{
    [HTMIWFCSVProgressHUD show];
    
    [self operationMatterWithAction:self.currentActionID
                            comment:self.comment
                          routeList:hasSelectedRoute
                       employeeList:selected
                           matterID:self.matterID
                            docType:self.docType];
}

#pragma mark - OAMatterFormViewControllerDelegate

/**
 *  必填？
 *
 *  @param mustEditFeildItems 数组
 */
- (void)oaOperationDelegateMustEditFeildItems:(NSArray *)mustEditFeildItems{
    [self.mustEditFeildItems addObjectsFromArray:mustEditFeildItems];
}

/**
 *  保存用户在表单页面编辑的意见
 *
 *  @param key     键
 *  @param value   值
 *  @param mode    模式
 *  @param input   输入类型
 *  @param formkey 表单键
 */
- (void)oaOperationDelegateEditOperationForKey:(NSString *)key value:(NSString *)value mode:(NSString *)mode input:(NSString *)input formkey:(NSString *)formkey{
    if (!self.eidtFieldListDicArray) {
        self.eidtFieldListDicArray = [[NSMutableArray alloc]init];
    }
    
    //    if (self.flowid.length > 0)
    //    {
    //        //请假
    //        [self.eidtFieldListDicArray addObject:@{@"key":key,@"value":value,@"mode":mode,@"input":input,@"formKey":formkey}];
    //    }
    //    else
    //    {
    //去重
    for (int i = 0; i < self.eidtFieldListDicArray.count; i++) {
        NSDictionary *dic = self.eidtFieldListDicArray[i];
        if ([key isEqualToString:[dic objectForKey:@"key"]]) {
            [self.eidtFieldListDicArray removeObjectAtIndex:i];
        }
    }
    
    [self.eidtFieldListDicArray addObject:@{@"key":key,@"value":value,@"mode":mode,@"input":input,@"formKey":formkey}];
    
    if ([input isEqualToString:@"2001"]) {
        self.comment = value;//comment只能存意见
    }
    //去除两边的空格和回车
    self.comment = [self.comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //    }
}

#pragma mark - CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(HTMIWFCCustomAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
    self.selectedRouteArray = [[NSMutableArray alloc] init];
    switch ((int)buttonIndex) {
        case 0:
            //HTLog(@"确定%d",self.selectedRow);
            if (self.selectedRow != 999)
            {
                [HTMIWFCSVProgressHUD show];
                [self.selectedRouteArray addObject:self.routeIDArray[self.selectedRow]];
                [self operationMatterWithAction:self.currentActionID
                                        comment:self.comment
                                      routeList:self.selectedRouteArray
                                   employeeList:nil
                                       matterID:self.matterID
                                        docType:self.docType];
                self.selectedRow = 999;
            }
            else
            {
                
            }
            
            break;
        case 1:
            HTLog(@"取消");
            [alertView close];
            self.selectedRow = 999;
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate && UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.routeNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    
    cell.textLabel.text = self.routeNameArray[indexPath.row];
    //选中cell的颜色
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [[HTMIWFCSettingManager manager] navigationBarColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedRow = indexPath.row;
}

#pragma mark ------事件

#pragma mark - 操作按钮移动手势相应事件

- (void)homeLabelMove:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        HTLog(@"开始移动");
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        self.upMenuView.frame = CGRectMake([pan locationInView:self.view].x-25,
                                           [pan locationInView:self.view].y-self.upMenuView.frame.size.height+25,
                                           self.upMenuView.frame.size.width,
                                           self.upMenuView.frame.size.height);
    }
    else if (pan.state == UIGestureRecognizerStateEnded)
    {
        //防止按钮超出手机屏
        if ([pan locationInView:self.view].x > WIDTH-20) {
            self.upMenuView.center = CGPointMake(self.upMenuView.center.x-20, self.upMenuView.center.y);
        }
        if ([pan locationInView:self.view].x < 20) {
            self.upMenuView.center = CGPointMake(20, self.upMenuView.center.y);
        }
        if ([pan locationInView:self.view].y > HEIGHT-66-20) {
            self.upMenuView.center = CGPointMake(self.upMenuView.center.x, self.upMenuView.center.y-20);
        }
        if ([pan locationInView:self.view].y < 100) {
            self.upMenuView.center = CGPointMake(self.upMenuView.center.x-20, 100);
        }
        self.upMenuView.transform = CGAffineTransformIdentity;
    }
    
    self.popLabelView.frame = CGRectMake(self.upMenuView.frame.origin.x-100, self.upMenuView.frame.origin.y, 100, (40+18)*self.actionNamesArray.count);
}

#pragma mark - 操作事项点击事件
/**
 *  操作事项点击事件
 *
 *  @param sender UIButton
 */
- (void)doAction:(UIButton *)sender {
    
    [self allDoAction:sender.tag actionNameArray:self.actionNamesArray];
    
}

- (void)showMustInputAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您还有未填写的内容，请填写后再提交" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

- (void)allDoAction:(NSInteger)index actionNameArray:(NSArray *)actionNameArray {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    if ([actionNameArray[index] isEqualToString:@"分享以沟通"] ||
        [actionNameArray[index] isEqualToString:@"分享"]) {
        
        UIActionSheet *myAction = [[UIActionSheet alloc]initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给同事",@"分享到工作圈", nil];
        myAction.actionSheetStyle = UIBarStyleBlackTranslucent;
        [myAction showInView:self.view];
        
    } else if ([actionNameArray[index] isEqualToString:@"添加关注"]) {
        [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeClear];
        
        [HTMIWFCApi attentOrDisAttentWithContext:context docID:self.matterID attentionFlag:@"1" allowPush:@"1" docTitle:self.docTitle docType:self.docType sendFrom:self.sendFrom sendDate:self.sendDate iconID:self.iconID kind:self.kind succeed:^(id data) {
            [HTMIWFCSVProgressHUD dismiss];
            [HTMIWFCSVProgressHUD showSuccessWithStatus:@"添加关注成功" duration:1.0];
            
            for (HTMIWFCOAOperationDataEntity *oaod in self.operationDataArray) {
                if ([oaod.actionName isEqualToString:@"添加关注"]) {
                    oaod.actionName = @"取消关注";
                    break;
                }
            }
            if (ISFormType == 1) {
                [self myBottomClick];
            }else{
                [self creatActionI];
            }
            
            //发送通知刷新关注页面
            //创建一个消息对象
            NSNotification * notice = [NSNotification notificationWithName:@"refreshMyAttentionTableView" object:nil userInfo:nil];
            //发送消息
            [[NSNotificationCenter defaultCenter] postNotification:notice];
            
        } failure:^(NSError *error) {
            [HTMIWFCSVProgressHUD dismiss];
            [HTMIWFCSVProgressHUD showErrorWithStatus:@"添加关注失败" duration:1.0];
        }];
        
    } else if ([actionNameArray[index] isEqualToString:@"取消关注"]) {
        [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeClear];
        
        [HTMIWFCApi attentOrDisAttentWithContext:context docID:self.matterID attentionFlag:@"0" allowPush:@"1" docTitle:self.docTitle docType:self.docType sendFrom:self.sendFrom sendDate:self.sendDate iconID:self.iconID kind:self.kind succeed:^(id data) {
            [HTMIWFCSVProgressHUD dismiss];
            [HTMIWFCSVProgressHUD showSuccessWithStatus:@"取消关注成功" duration:1.0];
            
            for (HTMIWFCOAOperationDataEntity *oaod in self.operationDataArray) {
                if ([oaod.actionName isEqualToString:@"取消关注"]) {
                    oaod.actionName = @"添加关注";
                    break;
                }
            }
            if (ISFormType == 1) {
                [self myBottomClick];
            }else{
                [self creatActionI];
            }
            
            //发送通知刷新关注页面
            //创建一个消息对象
            NSNotification * notice = [NSNotification notificationWithName:@"refreshMyAttentionTableView" object:nil userInfo:nil];
            //发送消息
            [[NSNotificationCenter defaultCenter] postNotification:notice];
            
        } failure:^(NSError *error) {
            [HTMIWFCSVProgressHUD dismiss];
            [HTMIWFCSVProgressHUD showErrorWithStatus:@"取消关注失败" duration:1.0];
        }];
        
    } else {
        for (HTMIWFCOAMatterFormFieldItem *fieldItem in self.mustEditFeildItems) {
            if ([fieldItem.inputType isEqualToString:@"2001"] ||
                [fieldItem.inputType isEqualToString:@"2002"] ||
                [fieldItem.inputType isEqualToString:@"2003"]) {
                if (fieldItem.eidtValue.length < 1) {
                    [self checkMustAlert];
                    return;
                }
            } else {
                if (fieldItem.value.length < 1) {
                    [self checkMustAlert];
                    return;
                }
            }
        }
        NSLog(@"%@",self.actionNamesArray);
        [HTMIWFCSVProgressHUD show];
        NSString *actionID = [self getActionIDByButtonTitleName:actionNameArray[index]];
        self.currentActionID = actionID;
        [self operationMatterWithAction:self.currentActionID
                                comment:self.comment
                              routeList:nil
                           employeeList:nil
                               matterID:self.matterID
                                docType:self.docType];
    }
}

/**
 *  actionLabel点击事件
 *
 *  @param tap UITapGestureRecognizer
 */
- (void)actionLabelClick:(UITapGestureRecognizer *)tap{
    
    [self allDoAction:tap.view.tag actionNameArray:self.actionNamesArray];
    
}

- (void)checkMustAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您还有未填写的内容，请填写后再提交" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)myCountandIdentfier:(int)count andmyActionName:(NSArray *)myActionNameArray {
    [self allDoAction:count actionNameArray:myActionNameArray];
}

#pragma mark - segment点击事件

/**
 *  segment点击事件
 *
 *  @param segment UISegmentedControl
 */
- (void)segmentPress:(HTMIWFCSegmentedControl *)segment{
    
    //    float w = WIDTH/self.controllerArray.count;
    //    self.segmentLabel.frame = CGRectMake(segment.selectedSegmentIndex*w, 40, w, 2);
    
    if ([[segment sectionTitles][segment.selectedSegmentIndex] isEqualToString:@"正文"]) {
        //正文
        HTMIWFCMIMainBodyViewController *mainBody = self.controllerArray[segment.selectedSegmentIndex];
        mainBody.view.frame = CGRectMake(0, 0, W(self.myContentView), H(self.myContentView));
        
        [self transitionFromViewController:self.controllerArray[self.segmentLastIndex] toViewController:self.controllerArray[segment.selectedSegmentIndex] duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
        
    }
    if ([[segment sectionTitles][segment.selectedSegmentIndex]  isEqualToString:@"附件"]) {
        //附件
        HTMIWFCOAMatterAttachmentViewController *mainBody = self.controllerArray[segment.selectedSegmentIndex];
        mainBody.view.frame = self.myContentView.bounds;
        mainBody.view.frame = CGRectMake(0, 0, W(self.myContentView), H(self.myContentView));
        
        
        [self transitionFromViewController:self.controllerArray[self.segmentLastIndex] toViewController:self.controllerArray[segment.selectedSegmentIndex] duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
        
    }
    if ([[segment sectionTitles][segment.selectedSegmentIndex]  isEqualToString:@"流程"]) {
        //流程
        HTMIWFCOAMatterFlowListTableViewController *mainBody = self.controllerArray[segment.selectedSegmentIndex];
        mainBody.view.frame = self.myContentView.bounds;
        mainBody.view.frame = CGRectMake(0, 0, W(self.myContentView), H(self.myContentView));
        
        [self transitionFromViewController:self.controllerArray[self.segmentLastIndex] toViewController:self.controllerArray[segment.selectedSegmentIndex] duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
        
        [self firstMatterFlow];
        
    }
    else {
        //表单
        HTMIWFCOAMatterFormTableViewController *mainBody = self.controllerArray[segment.selectedSegmentIndex];
        mainBody.view.frame = self.myContentView.bounds;
        mainBody.view.frame = CGRectMake(0, -20, W(self.myContentView), H(self.myContentView)+20);
        
        [self transitionFromViewController:self.controllerArray[self.segmentLastIndex] toViewController:self.controllerArray[segment.selectedSegmentIndex] duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
        
    }
    
    self.segmentLastIndex = segment.selectedSegmentIndex;
}

/**
 *  跳过按钮点击事件
 */
- (void)btnClick{
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
}

/**
 *  手势响应事件(第一次进入当前页面的引导页手势点击)
 *
 *  @param tap UITapGestureRecognizer
 */
- (void)tap:(UITapGestureRecognizer *)tap{
    
    tap.enabled = NO;
    
    if(self.scrollView)
    {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x+WIDTH, 0) animated:YES];
    }
    
    
}

#pragma mark - scrollView代理方法
/**
 *  会在视图滚动完成时执行
 *
 *  @param scrollView UIScrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        if (self.scrollView) {
            
            self.tap.enabled = YES;
            
            if (self.scrollView.contentOffset.x >= WIDTH*2 && self.scrollView.contentSize.width == WIDTH*2)
            {
                [self.scrollView removeFromSuperview];
                self.scrollView = nil;
            }
        }
        
    });
}

/**
 *  返回
 */
- (void)backButtonClick{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shareChat" object:self];
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    //    self.tabBarController.tabBar.hidden = NO;
}

/**
 *  手势点击事件（第一次进入流程页面）
 *
 *  @param tap UITapGestureRecognizer
 */
- (void)tapClick:(UITapGestureRecognizer *)tap{
    tap.enabled = NO;
    UIImageView *imageView;
    if ([tap isKindOfClass:[UIButton class]]) {
        if ([((UIButton *)tap).superview isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)((UIButton *)tap).superview;
        }
    }
    else{
        imageView = (UIImageView *)tap.view;//[self.view viewWithTag:101];
    }
    
    [imageView removeFromSuperview];
    imageView = nil;
    tap.enabled = YES;
}

#pragma mark  - 私有方法

#pragma mark  - 第一次进入流程页面

- (void)firstMatterFlow{
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"matterFlowFirstStart"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"matterFlowFirstStart"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        imageView.image = [UIImage getPNGImageHTMIWFC:@"img_oa_flow01"];
        imageView.userInteractionEnabled = YES;
        imageView.tag = 101;
        [self.navigationController.view.window addSubview:imageView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"跳过" forState:UIControlStateNormal];
        btn.tintColor = [UIColor whiteColor];
        btn.frame = CGRectMake(WIDTH-70, 20, 60, 40);
        btn.backgroundColor = [UIColor clearColor];
        btn.showsTouchWhenHighlighted = YES;//按钮发光
        [btn addTarget:self action:@selector(tapClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        tap.delegate = self;
        [tap setNumberOfTapsRequired:1];
        self.tap = tap;
        [imageView addGestureRecognizer:tap];
    }
}

#pragma mark - 第一次进入的引导页

- (void)firstLogin{
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"matterFormFirstStart"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"matterFormFirstStart"];
        HTLog(@"------------第一次启动－－－－－－－－－");
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        //设置滚动范围
        self.scrollView.contentSize = CGSizeMake(WIDTH*2, HEIGHT);
        //设置是否开启分页显示
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        //设置拖拽的弹簧效果
        self.scrollView.bounces =YES;
        //是否允许滚动
        self.scrollView.scrollEnabled = NO;
        self.navigationController.view.window.userInteractionEnabled = YES;
        
        [self.navigationController.view.window addSubview:self.scrollView];
        
        for (int i = 0; i < 2; i ++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH*i, 0, WIDTH, HEIGHT)];
            imageView.image = [UIImage getPNGImageHTMIWFC:[NSString stringWithFormat:@"img_oa_matterform0%d.png",i+1]];
            imageView.userInteractionEnabled = YES;
            [self.scrollView addSubview:imageView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"跳过" forState:UIControlStateNormal];
            btn.tintColor = [UIColor whiteColor];
            btn.frame = CGRectMake(WIDTH*(i+1)-70, 20, 60, 40);
            btn.backgroundColor = [UIColor clearColor];
            btn.showsTouchWhenHighlighted = YES;//按钮发光
            [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:btn];
        }
        
        //点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.delegate = self;
        [tap setNumberOfTapsRequired:1];
        [self.scrollView addGestureRecognizer:tap];
        self.tap = tap;
        
        [HTMIWFCSVProgressHUD dismiss];
    }
}

/**
 *  创建路由选择提示框内容视图
 *
 *  @return 内容视图
 */
- (UIView *)createDemoView{
    
    //wlq update 适配屏幕
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth * 0.8, 200)];//290
    UILabel *routeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth * 0.8, 60)];//290
    routeLabel.text = @"请选择路由";
    routeLabel.font = [UIFont systemFontOfSize:22];
    routeLabel.textAlignment = NSTextAlignmentCenter;
    
    [demoView addSubview:routeLabel];
    [demoView addSubview:self.routeTableView];
    
    return demoView;
}

/**
 *  通过操作事项获得 操作ID
 *
 *  @param name ButtonTitleName
 *
 *  @return 操作ID
 */
- (NSString *)getActionIDByButtonTitleName:(NSString *)name{
    
    for (HTMIWFCOAOperationDataEntity *operationData in self.operationDataArray) {
        if ([operationData.actionName isEqualToString:name]) {
            return operationData.actionID;
        }
    }
    return nil;
}

/**
 *  提交对事项的操作
 *
 *  @param actionID     事项ID
 *  @param comment      编辑的意见
 *  @param routList     路由
 *  @param employeeList 人员
 *  @param matterID     事件id
 *  @param docType      docType
 */
- (void)operationMatterWithAction:(NSString *)actionID
                          comment:(NSString *)comment
                        routeList:(NSArray *)routList
                     employeeList:(NSArray *)employeeList
                         matterID:(NSString *)matterID
                          docType:(NSString *)docType{
    //请求参数
    NSString *flowName;
    NSString *flowID;
    NSString *currentNodeID;
    NSString *currentTrackID;
    if (self.flowid.length > 0)
    {
        flowID = self.flowid;
        currentNodeID = self.currentNodeID;
        currentTrackID = self.currentTrackId;
        flowName = self.flowName;
    }
    else
    {
        flowName = self.appendDictionary[@"flowName"];
        flowID = self.appendDictionary[@"flowID"];
        currentNodeID = self.appendDictionary[@"currentNodeID"];
        currentTrackID = self.appendDictionary[@"currentTrackID"];
    }
    
    NSString *commentList = @"";
    
    //将用户的「意见」和「意见正文」提交
    [[HTMIWFCOAOperationService alloc] operationMatterWithAction:actionID comment:comment commentList:commentList routeList:routList employeeList:employeeList matterID:matterID docType:docType kind:self.kind flowID:flowID flowName:flowName currentNodeID:currentNodeID currentTrackID:currentTrackID eidtFieldList:self.eidtFieldListDicArray block:^(NSInteger retCode, NSArray *list, NSString *title, BOOL isMultiSelect, BOOL isFreeSelectUser, NSDictionary *hasSelectedRoute) {
        [HTMIWFCSVProgressHUD dismiss];
        
        if (retCode == 0)
        {
            [HTMIWFCSVProgressHUD dismiss];
            [self.alertView close];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            //暂时注释
            //self.tabBarController.tabBar.hidden = NO;
            if (self.delegate != nil)
                [self.delegate tableViewReloadData];
        }
        else if (retCode == 2)//路由
        {
            self.routeNameArray = [[NSMutableArray alloc] init];
            self.routeIDArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dic in list) {
                NSString *routeName = [dic objectForKey:@"routeName"];
                NSString *routeID = [dic objectForKey:@"routeID"];
                
                [self.routeNameArray addObject:routeName];
                [self.routeIDArray addObject:routeID];
            }
            
            self.routeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth * 0.8, 140)];
            self.routeTableView.dataSource = self;
            self.routeTableView.delegate = self;
            self.routeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            [self.view setBackgroundColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
            
            
            self.alertView = [[HTMIWFCCustomAlertView alloc] init];
            [self.alertView setContainerView:[self createDemoView]];
            [self.alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", @"取消", nil]];
            [self.alertView setDelegate:self];
            
            [self.alertView setOnButtonTouchUpInside:^(HTMIWFCCustomAlertView *alertView, int buttonIndex) {
                
            }];
            
            [self.alertView setUseMotionEffects:true];
            
            [self.alertView show];
            
            
            /*
             //从组织结构所有部门中进行单选
             HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:ChooseTypeDepartmentFromSpecific isSingleSelection:!isMultiSelect specificArray:list isTree:YES];
             
             @weakify(self);
             vc.resultBlock = ^(NSArray *resultArray){
             @strongify(self);
             //选择完成后，点击完成按钮会跳转回当前调用页面，执行这个回调方法
             //在这里对返回结果数组进行处理(如果选择的是人员返回的就是人员UserId字符串数组，如果是部门返回的就是DepartmentCode字符串数组)
             
             [HTMIWFCSVProgressHUD show];
             
             [self operationMatterWithAction:self.currentActionID
             comment:self.comment
             routeList:resultArray
             employeeList:nil
             matterID:self.matterID
             docType:self.docType];
             
             };
             [self.navigationController pushViewController:vc animated:YES];
             */
        }
        else if (retCode == 4)//人员
        {
            /*
             //IsFreeSelectUser
             HTMIWFCOAManageFollowViewController *mvc = [[HTMIWFCOAManageFollowViewController alloc]init];
             mvc.resultInfo = title;
             mvc.IsMultiSelectResult = isMultiSelect;
             mvc.resultList = list;
             mvc.retCode = retCode;
             mvc.IsFreeSelectUser = isFreeSelectUser;
             mvc.hasSelectedRoute = hasSelectedRoute;
             mvc.delegate = self;
             
             
             [self.alertView close];
             [HTMIWFCSVProgressHUD dismiss];
             
             UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:mvc];
             [self presentViewController:nvc animated:YES completion:nil];
             */
            
            [self.alertView close];
            [HTMIWFCSVProgressHUD dismiss];
            
            
            ChooseType chooseType;
            if (isFreeSelectUser) {
                chooseType = ChooseTypeUserFromSpecific;
            }
            else{
                chooseType = ChooseTypeUserFromSpecificOnly;
            }
            
            //从组织结构所有部门中进行单选
            HTMIABCChooseFormAddressBookViewController * vc = [[HTMIABCChooseFormAddressBookViewController alloc]initWithChooseType:chooseType isSingleSelection:!isMultiSelect specificArray:list isTree:YES];
            
            if (hasSelectedRoute.count > 0) {
                NSString *string = [hasSelectedRoute objectForKey:@"RouteID"];
                vc.selectedRouteArray = [string componentsSeparatedByString:@""];
            }
            
            
            
            //title 设置标题
            [vc setTitleString:title];
            
            @weakify(self);
            vc.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray){
                @strongify(self);
                //选择完成后，点击完成按钮会跳转回当前调用页面，执行这个回调方法
                //在这里对返回结果数组进行处理(如果选择的是人员返回的就是人员UserId字符串数组，如果是部门返回的就是DepartmentCode字符串数组)
                
                NSMutableArray * resultIdArray = [NSMutableArray array];
                for (NSObject * object in resultArray) {
                    
                    NSString * userId = ((HTMIABCSYS_UserModel *)object).UserId;
                    [resultIdArray addObject:userId];
                }
                
                [HTMIWFCSVProgressHUD show];
                [self operationMatterWithAction:self.currentActionID
                                        comment:self.comment
                                      routeList:selectedRouteArray
                                   employeeList:resultIdArray
                                       matterID:self.matterID
                                        docType:self.docType];
                
            };
            
            [self.navigationController pushViewController:vc animated:YES];
            
            
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:title delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

/**
 *  气泡菜单按钮动画设置
 */
- (void)popLabelAnimation{
    [self.popLabelView removeFromSuperview];
    
    self.popLabelView = [[UIView alloc] initWithFrame:CGRectMake(self.upMenuView.frame.origin.x-100, self.upMenuView.frame.origin.y, 100, (40+18)*self.actionNamesArray.count)];
    [self.view addSubview:self.popLabelView];
    
    for (int i = 0; i < self.actionNamesArray.count; i++) {
        UILabel *actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*60, 100, 40)];
        actionLabel.backgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.7];
        actionLabel.textColor = [UIColor whiteColor];
        actionLabel.layer.masksToBounds = YES;
        actionLabel.layer.cornerRadius = 5.0;
        actionLabel.textAlignment = NSTextAlignmentCenter;
        actionLabel.adjustsFontSizeToFitWidth = YES;
        actionLabel.numberOfLines = 0;
        actionLabel.font = [UIFont systemFontOfSize:14.0];
        actionLabel.userInteractionEnabled = YES;
        actionLabel.tag = i;
        actionLabel.text = self.actionNamesArray[i];
        [self.popLabelView addSubview:actionLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionLabelClick:)];
        tap.delegate = self;
        [actionLabel addGestureRecognizer:tap];
    }
}

/**
 *  设置操作事项按钮
 *
 *  @return 按钮数组
 */
- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    [self.actionNamesArray removeAllObjects];
    
    for (int i = 0; i < self.operationDataArray.count; i++) {
        HTMIWFCOAOperationDataEntity *data = self.operationDataArray[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.actionNamesArray addObject:data.actionName];
        
        button.frame = CGRectMake(0.f, 0.f, 40, 40);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        
        if ([data.actionName isEqualToString:@"拿回"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_takeback"] forState:UIControlStateNormal];
        }
        else if ([data.actionName isEqualToString:@"退回"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_return"] forState:UIControlStateNormal];
        }
        else if ([data.actionName isEqualToString:@"已读"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_read"] forState:UIControlStateNormal];
        }
        else if ([data.actionName isEqualToString:@"阅知"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_yuezhi"] forState:UIControlStateNormal];
        }
        else if ([data.actionName isEqualToString:@"暂存"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_save"] forState:UIControlStateNormal];
        }
        else if ([data.actionName isEqualToString:@"分享"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_share"] forState:UIControlStateNormal];
        }
        else if ([data.actionName isEqualToString:@"添加关注"] ||
                 [data.actionName isEqualToString:@"取消关注"]) {
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_attention"] forState:UIControlStateNormal];
        }
        else{
            [button setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_action_submit"] forState:UIControlStateNormal];
        }
        
        button.clipsToBounds = YES;
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonsMutable addObject:button];
    }
    
    return [buttonsMutable copy];
}

/**
 *  默认表单
 */
- (void)formVCShow{
    //默认显示表单
    HTMIWFCOAMatterFormTableViewController *matterForm = (HTMIWFCOAMatterFormTableViewController *)self.controllerArray[0];
    
    //    matterForm.view.frame = self.myContentView.bounds;
    matterForm.view.frame = CGRectMake(0, -20, W(self.myContentView), H(self.myContentView)+20);
    
    [self transitionFromViewController:matterForm toViewController:matterForm duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
    }];
    [self.myContentView addSubview:matterForm.view];
}

#pragma mark 操作项  I(右下角的圆按钮)

- (void)creatActionI{
    
    if (self.operationDataArray.count == 0) {
        HTLog(@"没有 操作项");
    }
    else {
        HTLog(@"有 操作项");
        //添加设置操作事项按钮
        [self.upMenuView removeFromSuperview];
        
        self.homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 50.f)];
        self.homeLabel.textColor = [UIColor whiteColor];
        self.homeLabel.textAlignment = NSTextAlignmentCenter;
        self.homeLabel.layer.cornerRadius = self.homeLabel.frame.size.height / 2.f;
        [self.homeLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage getPNGImageHTMIWFC:@"btn_operation_homelabel_off"]]];
        self.homeLabel.clipsToBounds = YES;
        
        
        if (self.flowid.length > 0) {
            self.upMenuView = [[HTMIWFCDWBubbleMenuButton alloc] initWithFrame:CGRectMake
                               (self.view.frame.size.width - self.homeLabel.frame.size.width - 20.f,
                                self.view.frame.size.height - self.homeLabel.frame.size.height - 45.f,
                                self.homeLabel.frame.size.width,
                                self.homeLabel.frame.size.height)
                                                            expansionDirection:DirectionUp];
        }
        else {
            self.upMenuView = [[HTMIWFCDWBubbleMenuButton alloc] initWithFrame:CGRectMake
                               (self.view.frame.size.width - self.homeLabel.frame.size.width - 20.f,
                                self.view.frame.size.height - self.homeLabel.frame.size.height - 45.f,
                                self.homeLabel.frame.size.width,
                                self.homeLabel.frame.size.height)
                                                            expansionDirection:DirectionUp];
        }
        
        self.upMenuView.delegate = self;
        self.upMenuView.homeButtonView = self.homeLabel;
        
        //添加手势
        self.upMenuView.homeButtonView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(homeLabelMove:)];
        pan.delegate = self;
        pan.minimumNumberOfTouches = 1;
        [self.upMenuView.homeButtonView addGestureRecognizer:pan];
        
        [self.upMenuView addButtons:[self createDemoButtonArray]];
        [self.view addSubview:self.upMenuView];
        
    }
}

#pragma mark - 处理请假相关的逻辑以及接口调用
/**
 *  请假
 */
- (void)leaveByFlowidExist{
    //请假
    //wlq update 将请假的TableView上移
    //self.myContentView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
    self.myContentView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    self.tabBarController.tabBar.hidden = YES;
    self.title = @"请假申请";
    [HTMIWFCSVProgressHUD show];
    @weakify(self);
    [[HTMIWFCOAMainBodyService alloc] myLeaveWithFlowID:self.flowid block:^(id obj, id detaile, id attachment, NSArray *segmentTitleArray, NSDictionary *maxWidthDic, NSError *error) {
        @strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCEmptyView removeFormView:self.view];
        if (error) {
            //wlq add 应该显示空页面
            if (error.code == -1001) {//请求超时
                //                [self showTimeoutReloadView:^{
                //                    [HTMIWFCSVProgressHUD show];
                //
                //                    [self leaveByFlowidExist];
                //                } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            }
            else{//断网
                
                //                [self showErrorReloadView:^{
                //                    [HTMIWFCSVProgressHUD show];
                //
                //                    [self leaveByFlowidExist];
                //                } goToCheck:^{
                //
                //                } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            }
        }
        else{
            
            if (ISFormType == 1) {
                //底部实现修改他的高度坐标
                self.myContentView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-108);
                self.myContentView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
            }else{
                //+
                self.myContentView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-108 + 44);
            }
            
            NSDictionary *modic = obj;
            
            NSString * docID = [modic objectForKey:@"kDocID"];
            
            self.matterID = docID;
            self.currentTrackId = [modic objectForKey:@"kCurrentTrackId"];
            self.currentNodeID = [modic objectForKey:@"kCurrentNodeID"];
            self.flowid = [modic objectForKey:@"kFlowID"];
            self.flowName = [modic objectForKey:@"kFlowName"];
            
            self.title = @"请假申请";
            
            self.controllerArray = [NSMutableArray array];
            //详情
            NSArray *tableItemsArray = detaile;
            
            NSMutableArray *segmentArray = [NSMutableArray array];//segment标题
            for (int i = 0; i < tableItemsArray.count; i++) {
                HTMIWFCOATableItemsEntity *tableItemEntity = tableItemsArray[i];
                [segmentArray addObject:tableItemEntity.tableName];
                
                HTMIWFCOAMatterFormTableViewController *matterForm = [[HTMIWFCOAMatterFormTableViewController alloc] init];
                matterForm.detaileArray = detaile;
                matterForm.operationDelegate = self;
                matterForm.flowID = self.flowid;
                
                matterForm.segmentIndex = i;
                [self.controllerArray addObject:matterForm];
                [self addChildViewController:matterForm];
                
                matterForm.view.frame = self.myContentView.bounds;
                [self.myContentView addSubview:matterForm.view];
            }
            
            
            self.appendDictionary = [obj objectForKey:@"appendData"];
            self.operationDataArray = [obj objectForKey:@"operationData"];
            
            
            if (ISFormType == 1) {
                //字母 I 下面的两种方式实现  底部实现修改他的高度坐标
                [self myBottomClick];
            }else{
                //字母 I.
                [self creatActionI];
            }
        }
    }];
}

#pragma mark - 处理除了请假相关的逻辑以及接口调用（正文、附件、流程等等）

/**0
 *  除了请假
 */
- (void)exceptLeaveCondition{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    self.title = self.docTitle;
    //    //字母 I 下面的两种方式实现  底部实现修改他的高度坐标
    //    self.myContentView.frame = CGRectMake(0, 44, WIDTH, HEIGHT-108-40);
    self.navigationController.navigationBarHidden = NO;
    [HTMIWFCSVProgressHUD show];
    @weakify(self);
    [[HTMIWFCOAMainBodyService alloc] mainBodyWithContext:context MatterID:self.matterID isFlowid:NO andDocType:self.docType andKind:self.kind block:^(id obj, id detaile, id attachment, NSArray *segmentTitleArray, NSDictionary *maxWidthDic, NSError *error) {
        
        @strongify(self);
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCEmptyView removeFormView:self.view];
        
        if (error)
        {
            if (error.code == -1001) {//请求超时
                //                [self showTimeoutReloadView:^{
                //                    [HTMIWFCSVProgressHUD show];
                //
                //                    [self exceptLeaveCondition];
                //                } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            }
            else{//断网
                
                //                [self showErrorReloadView:^{
                //                    [HTMIWFCSVProgressHUD show];
                //
                //                    [self exceptLeaveCondition];
                //                } goToCheck:^{
                //
                //                } padding:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            }
            
        }
        else {
            if (detaile) {
                //                ISFormType
                if (ISFormType == 1) {
                    //底部实现修改他的高度坐标
                    self.myContentView.frame = CGRectMake(0, 44, WIDTH, HEIGHT-108-44);
                    self.myContentView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
                }else{
                    //+
                    self.myContentView.frame = CGRectMake(0, 44, WIDTH, HEIGHT-108);
                }
                
                NSArray *segmengs = segmentTitleArray;
                
                self.controllerArray = [NSMutableArray array];
                //详情
                NSArray *tableItemsArray = detaile;
                
                NSMutableArray *segmentArray = [NSMutableArray array];//segment标题
                for (int i = 0; i < tableItemsArray.count; i++) {
                    HTMIWFCOATableItemsEntity *tableItemEntity = tableItemsArray[i];
                    
                    [segmentArray addObject:tableItemEntity.tableName];
                    
                    if ([segmentTitleArray[i] isEqualToString:@"正文"]) {
                        HTMIWFCMIMainBodyViewController *mainBody = [[HTMIWFCMIMainBodyViewController alloc] init];
                        [self.controllerArray addObject:mainBody];
                        mainBody.matterID = self.matterID;
                        mainBody.docType = self.docType;
                        mainBody.kind = self.kind;
                        mainBody.urlPNG = self.urlPNG;
                        mainBody.docTitle = self.docTitle;
                        
                        HTMIWFCOAMainBodyEntity *mainBodyEntity = [obj objectForKey:@"mainBody"];
                        mainBody.AttachmentID = mainBodyEntity.docAttachmentID;
                        
                        [self addChildViewController:mainBody];
                    }
                    
                    else if ([segmentTitleArray[i] isEqualToString:@"附件"]) {
                        HTMIWFCOAMatterAttachmentViewController *matterAttach = [[HTMIWFCOAMatterAttachmentViewController alloc] init];
                        [self.controllerArray addObject:matterAttach];
                        matterAttach.kind = self.kind;
                        matterAttach.attachArray = attachment;
                        
                        [self addChildViewController:matterAttach];
                    }
                    
                    else if ([segmentTitleArray[i] isEqualToString:@"流程"]) {
                        HTMIWFCOAMatterFlowListTableViewController *matterFlow = [[HTMIWFCOAMatterFlowListTableViewController alloc] init];
                        [self.controllerArray addObject:matterFlow];
                        matterFlow.matterID = self.matterID;
                        matterFlow.docType = self.docType;
                        matterFlow.kind = self.kind;
                        
                        NSDictionary *dic = [obj objectForKey:@"appendData"];
                        matterFlow.lastFlowDic = @{@"CurrentUserName":[dic objectForKey:@"currentUserName"],
                                                   @"CurrentUserId":[dic objectForKey:@"currentUserID"],
                                                   @"CurrentNodeName":[dic objectForKey:@"currentNodeName"]};
                        
                        
                        [self addChildViewController:matterFlow];
                    }
                    
                    else {
                        HTMIWFCOAMatterFormTableViewController *matterForm = [[HTMIWFCOAMatterFormTableViewController alloc] init];
                        matterForm.detaileArray = detaile;
                        matterForm.operationDelegate = self;
                        matterForm.segmentIndex = i;
                        matterForm.maxWidthDic = maxWidthDic;
                        [self.controllerArray addObject:matterForm];
                        
                        
                        [self addChildViewController:matterForm];
                    }
                }
                
                if (![segmengs containsObject:@"正文"]) {
                    HTMIWFCOAMainBodyEntity *mainBodyEntity = [obj objectForKey:@"mainBody"];
                    if (mainBodyEntity.docAttachmentID.length > 0) {
                        //有正文
                        [segmentArray addObject:@"正文"];
                        
                        HTMIWFCMIMainBodyViewController *mainBody = [[HTMIWFCMIMainBodyViewController alloc] init];
                        [self.controllerArray addObject:mainBody];
                        mainBody.matterID = self.matterID;
                        mainBody.docType = self.docType;
                        mainBody.kind = self.kind;
                        mainBody.urlPNG = self.urlPNG;
                        mainBody.docTitle = self.docTitle;
                        mainBody.AttachmentID = mainBodyEntity.docAttachmentID;
                        
                        [self addChildViewController:mainBody];
                    }
                }
                
                if (![segmengs containsObject:@"附件"]) {
                    NSArray *attachmenArray = attachment;
                    if (attachmenArray.count > 0) {
                        //有附件
                        [segmentArray addObject:@"附件"];
                        
                        HTMIWFCOAMatterAttachmentViewController *matterAttach = [[HTMIWFCOAMatterAttachmentViewController alloc] init];
                        [self.controllerArray addObject:matterAttach];
                        matterAttach.kind = self.kind;
                        matterAttach.attachArray = attachment;
                        
                        [self addChildViewController:matterAttach];
                    }
                }
                
                if (![segmengs containsObject:@"流程"]) {
                    [segmentArray addObject:@"流程"];
                    HTMIWFCOAMatterFlowListTableViewController *matterFlow = [[HTMIWFCOAMatterFlowListTableViewController alloc] init];
                    [self.controllerArray addObject:matterFlow];
                    matterFlow.matterID = self.matterID;
                    matterFlow.docType = self.docType;
                    matterFlow.kind = self.kind;
                    
                    NSDictionary *dic = [obj objectForKey:@"appendData"];
                    matterFlow.lastFlowDic = @{@"CurrentUserName":[dic objectForKey:@"currentUserName"],
                                               @"CurrentUserId":[dic objectForKey:@"currentUserID"],
                                               @"CurrentNodeName":[dic objectForKey:@"currentNodeName"]};
                    
                    
                    [self addChildViewController:matterFlow];
                }
                
                //创建segment
                self.hmSegmentedControl = [[HTMIWFCSegmentedControl alloc] initWithSectionTitles:segmentArray];
                self.hmSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
                self.hmSegmentedControl.frame = CGRectMake(0, 0, WIDTH, 40);
                self.hmSegmentedControl.selectedSegmentIndex = 0;
                self.hmSegmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
                self.hmSegmentedControl.selectionStyle = HTMIWFCSegmentedControlSelectionStyleFullWidthStripe;
                self.hmSegmentedControl.selectionIndicatorLocation = HTMIWFCSegmentedControlSelectionIndicatorLocationDown;
                
                
                if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {//如果是白色色调
                    self.hmSegmentedControl.selectionIndicatorColor = [[HTMIWFCSettingManager manager] blueColor];
                    
                    self.hmSegmentedControl.titleTextAttributes =@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
                    self.hmSegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [[HTMIWFCSettingManager manager] blueColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
                }
                else{
                    self.hmSegmentedControl.selectionIndicatorColor = [[HTMIWFCSettingManager manager] navigationBarColor];
                    
                    self.hmSegmentedControl.titleTextAttributes =@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
                    self.hmSegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [[HTMIWFCSettingManager manager] navigationBarColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
                }
                
                self.hmSegmentedControl.selectionIndicatorHeight = 2.0;
                [self.hmSegmentedControl addTarget:self action:@selector(segmentPress:) forControlEvents:UIControlEventValueChanged];
                self.hmSegmentedControl.backgroundColor = [UIColor whiteColor];
                [self.view addSubview: self.hmSegmentedControl];
                
                /*
                 //segment 下边的下划线
                 self.segmentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, WIDTH/segmentArray.count, 2)];
                 self.segmentLabel.backgroundColor = navBarColor;
                 [segment addSubview:self.segmentLabel];
                 */
                
                self.appendDictionary = [obj objectForKey:@"appendData"];
                self.operationDataArray = [obj objectForKey:@"operationData"];
                
                //默认表单
                [self formVCShow];
                if (ISFormType == 1) {
                    //字母 I 下面的两种方式实现  底部实现修改他的高度坐标
                    [self myBottomClick];
                }else{
                    //字母 I.
                    [self creatActionI];
                }
                
            }
            else {
                NSString *message = attachment;
                self.backAlertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
                [self.backAlertView show];
            }
        }
    }];
    
}

-(void)myBottomClick {
    self.bottomActionView = [[HTMWFCIBottomActionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    self.bottomActionView.delegate = self;
    [self.bottomActionView bottomActionView:self.operationDataArray];
    [self.bottombuttonView addSubview:self.bottomActionView];
}

- (NSMutableArray *)actionNamesArray {
    if (!_actionNamesArray) {
        _actionNamesArray = [NSMutableArray array];
    }
    return _actionNamesArray;
}

- (NSMutableArray *)operationDataArray {
    if (!_operationDataArray) {
        _operationDataArray = [NSMutableArray array];
    }
    return _operationDataArray;
}

- (UIView *)bottombuttonView {
    if (!_bottombuttonView) {
        _bottombuttonView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-104, kScreenWidth, 44)];
        _bottombuttonView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        [self.view addSubview:_bottombuttonView];
    }
    return _bottombuttonView;
}




@end
