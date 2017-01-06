//
//  HTMIOtherPersonInfoViewController.m
//  AddressBook
//
//  Created by wlq on 16/4/10.
//  Copyright © 2016年 wlq. All rights reserved.
//

#import "HTMIABCContactPersonInfoViewController.h"

#import "HTMIWFCSettingManager.h"

//model
#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCTD_UserModel.h"

//others
#import "HTMIABCAddressBookManager.h"
#import <MessageUI/MessageUI.h>
#import "UIImageView+HTMIWFCWebCache.h"
#import "HTMIWFCMasonry.h"//代码自动布局
#import "HTMIWFCTGRImageViewController.h"//放大图片
#import "HTMIWFCAFNManager.h"
#import "HTMIABCUserdefault.h"

#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
#endif
//#import "UIViewController+Utility.h"

#import "HTMIABCSystemAddressBookHelper.h"

#import "HTMIABCPhoneNumberTableViewCell.h"

#import "HTMIWFCCustomAlertView.h"


#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "HTMIABCCommonHelper.h"

#import "HTMIWFCApi.h"

#import "UIImage+HTMIWFCWM.h"

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
//#import <MessageUI/MessageUI.h>
//
//#import "MFMailComposeViewControlleralloc.h"
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

@interface HTMIABCContactPersonInfoViewController ()<UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,HTMIWFCCustomAlertViewDelegate>
//单个view的图片
@property (weak, nonatomic) IBOutlet UIImageView *singleViewImageView;
//单个view的Label，用来显示文字
@property (weak, nonatomic) IBOutlet UILabel *singleViewLabel;

@property (weak, nonatomic) IBOutlet UIView *sendMessageSignalView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *normalBottomView;

@property(nonatomic,strong)HTMIWFCCustomAlertView *alertView;
@property(nonatomic,strong)NSMutableArray *phoneNumberArray;
@property(nonatomic,strong)UITableView *phoneTableView;
/**
 *  添加联系人View
 */
@property (weak, nonatomic) IBOutlet UIView *addContactView;

/**
 *  分割线
 */
@property (weak, nonatomic) IBOutlet UIView *splitView;
@property (weak, nonatomic) IBOutlet UIView *sendMessageView;
@property (copy,nonatomic)NSString * strPhoenNumber;
//@property (strong,nonatomic) NSMutableArray * phoneArray;
@property (strong,nonatomic)UIWebView * webView;
@property (weak,nonatomic)UIImageView * headerImageView;
//底部view的高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;

@end

@implementation HTMIABCContactPersonInfoViewController

-(instancetype)init{
    
    if (self = [super init]) {
        
        NSBundle * bundle = [UIImage getBundleHTMIWFC:@"WorkFlowControlResources"];
        
        self = [super initWithNibName:@"HTMIABCContactPersonInfoViewController" bundle:bundle];
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager]defaultBackgroundColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;// 这句代码的意思是不让它扩展布局
    self.automaticallyAdjustsScrollViewInsets = NO;//关键
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    [self customNavigationController:YES title:@"联系人信息"];
    
    UITapGestureRecognizer *tapAddContactView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAddContactView:)];
    tapAddContactView.numberOfTapsRequired = 1;
    [self.addContactView addGestureRecognizer:tapAddContactView];
    
    UITapGestureRecognizer *tapSendMessageView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSendMessageView:)];
    tapSendMessageView.numberOfTapsRequired = 1;
    [self.sendMessageView addGestureRecognizer:tapSendMessageView];
    
    UITapGestureRecognizer *tapSendMessageSignalView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSendMessageView:)];
    tapSendMessageSignalView.numberOfTapsRequired = 1;
    [self.sendMessageSignalView addGestureRecognizer:tapSendMessageSignalView];
    
    if ([self isContains]) {
        //如果存在，隐藏加为联系人view
        self.addContactView.hidden = YES;
        self.sendMessageView.hidden = YES;
        self.splitView.hidden = YES;
        
        
        //判断是否为EMI用户
        if (self.sys_UserModel.IsEMIUser) {
            self.sendMessageSignalView.hidden = NO;
        }
        else{
            //隐藏所有（）
            self.sendMessageSignalView.hidden = YES;
            
            //设置底部高度约束为0
            self.bottomHeightConstraint.constant = 0;
            self.normalBottomView.hidden = YES;
        }
        
    }
    else{
        //显示加为联系人view
        self.addContactView.hidden = NO;
        self.sendMessageView.hidden = NO;
        self.splitView.hidden = NO;
        
        
        //判断是否为EMI用户
        if (self.sys_UserModel.IsEMIUser) {
            self.sendMessageSignalView.hidden = YES;
        }
        else{
            self.addContactView.hidden = YES;
            self.sendMessageView.hidden = YES;
            self.splitView.hidden = YES;
            
            self.sendMessageSignalView.hidden = NO;
            //设置图片，以及文字
            [self.singleViewImageView setImage:[UIImage getPNGImageHTMIWFC:@"btn_add_friends"]];
            self.singleViewLabel.text = @"加为联系人";
        }
    }
    
    [self initUI];
}

- (void)addViewsToOneView:(UIView *)oneView td_UserModel:(HTMIABCTD_UserModel *)td_UserModel value:(NSString *)value{
    
    UILabel * fieldNameLabel = [UILabel new];
    fieldNameLabel.text = [NSString stringWithFormat:@"%@:",td_UserModel.DisLabel];
    fieldNameLabel.font = [UIFont systemFontOfSize:14];
    fieldNameLabel.textAlignment = NSTextAlignmentLeft;
    [oneView addSubview:fieldNameLabel];
    
    UILabel * valueLabel = [UILabel new];
    valueLabel.text = [NSString stringWithFormat:@"%@",value];
    valueLabel.font = [UIFont systemFontOfSize:14];
    valueLabel.textAlignment = NSTextAlignmentRight;
    [oneView addSubview:valueLabel];
    
    [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        
        make.left.equalTo(oneView.mas_left).with.offset(5);
        make.width.mas_equalTo(@100);
        make.centerY.equalTo(oneView);
    }];
    
    [valueLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        
        make.right.equalTo(oneView.mas_right).with.offset(-10);
        
        make.centerY.equalTo(oneView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:^{//关键的一句   不能为YES
        
    }];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            //[self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            
            break;
        default:
            break;
    }
}

#pragma mark - TableViewDelegate相关
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.phoneNumberArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HTMIABCPhoneNumberTableViewCell * cell = [HTMIABCPhoneNumberTableViewCell cellWithTableView:tableView];
    cell.phoneNumberLabel.text = self.phoneNumberArray[indexPath.row];
    
    if (indexPath.row == (self.phoneNumberArray.count - 1)) {
        cell.splitView.hidden = YES;
    }
    else{
        cell.splitView.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.alertView close];
    
    self.strPhoenNumber = self.phoneNumberArray[indexPath.row];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:[NSString stringWithFormat:@"拨打 %@",self.phoneNumberArray[indexPath.row]]
                                  otherButtonTitles:@"发送短信",@"保存到手机通讯录", @"复制",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [actionSheet showInView:self.view];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}

#pragma mark - CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(HTMIWFCCustomAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
    
    
    switch ((int)buttonIndex) {
        case 0:
            [alertView close];
            break;
            
        default:
            break;
    }
}

/**
 *  创建路由选择提示框内容视图
 *
 *  @return 内容视图
 */
- (UIView *)createDemoView{
    
    //wlq update 适配屏幕
    
    int count;
    if (self.phoneNumberArray.count > 3) {
        count = 3;//最多显示三行
    }
    else{
        count = self.phoneNumberArray.count;
    }
    
    float width = kScreenWidth * 0.8;
    
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, (count * 60) + 40)];
    demoView.backgroundColor = [UIColor whiteColor];
    
    UILabel *routeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    routeLabel.text = @"请选择要操作的电话号";
    routeLabel.font = [UIFont systemFontOfSize:18];
    routeLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(routeLabel.frame) -  1, width, 1)];
    splitView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f];
    
    self.phoneTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(routeLabel.frame), width,count * 60) style:UITableViewStylePlain];
    self.phoneTableView.backgroundColor = [UIColor whiteColor];
    self.phoneTableView.tableFooterView = [[UIView alloc] init];
    self.phoneTableView.delegate = self;
    self.phoneTableView.dataSource = self;
    self.phoneTableView.bounces = NO;
    self.phoneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [demoView addSubview:routeLabel];
    [demoView addSubview:splitView];
    [demoView addSubview:self.phoneTableView];
    
    return demoView;
}

#pragma mark --事件


- (void)clickEmail:(UIButton *)sender{
    
    if (sender.titleLabel.text.length <= 0) {
        return;
    }
    /*
     [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@",sender.titleLabel.text]]];
     */
    
    // 不能发邮件
    if (![MFMailComposeViewController canSendMail]){
        
        return;
    }
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    
    UIColor * myTintColor;
    
    
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        
        myTintColor= [[HTMIWFCSettingManager manager] blueColor];
        
    }
    else{
        
        myTintColor= [UIColor whiteColor];
        
    }
    
    vc.navigationBar.tintColor = myTintColor;
    
    // ************************ 设置邮件内容 ************************
    // 设置邮件主题
    [vc setSubject:@""];//主题
    // 设置邮件内容
    [vc setMessageBody:@"" isHTML:NO];//邮件内容
    
    if (sender.titleLabel.text.length > 0) {
        // 设置收件人列表
        [vc setToRecipients:@[sender.titleLabel.text]];
    }
    
    /*
     // 设置抄送人列表
     [vc setCcRecipients:@[@"抄送人@qq.com"]];
     // 设置密送人列表
     [vc setBccRecipients:@[@"密送人@qq.com"]];
     */
    
    /*
     // 添加附件（例如：一张图片）
     UIImage *image = [UIImage getPNGImageHTMIWFC:@"图片.jpeg"];
     NSData *data = UIImageJPEGRepresentation(image, 0.5);
     [vc addAttachmentData:datamimeType:@"image/jepg" fileName:@"lufy.jpeg"];
     */
    
    // 设置代理
    vc.mailComposeDelegate = self;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[HTMIWFCSettingManager manager] navigationBarTitleFontColor],NSForegroundColorAttributeName,
                         [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0],
                         NSFontAttributeName,nil];
    
    [vc.navigationBar setTitleTextAttributes:dic];
    
    // 显示控制器
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // 关闭邮件界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if(result == MFMailComposeResultCancelled) {
        NSLog(@"取消发送");
    } else if(result == MFMailComposeResultSent) {
        NSLog(@"已经发出");
    } else {
        NSLog(@"发送失败");
    }
}

- (void)clickPhone:(UIButton *)sender{
    
    [self.phoneNumberArray removeAllObjects];
    
    NSString * phoneNumnerOrigion = @"";
    if (sender.tag == 10001) {
        phoneNumnerOrigion = self.sys_UserModel.Telephone;
    }
    else if(sender.tag == 10002)
    {
        phoneNumnerOrigion = self.sys_UserModel.Mobile;
    }
    
    if(phoneNumnerOrigion > 0){
        
        NSString * numberString = phoneNumnerOrigion;
        //这个可能里面有多个，号，如果有，进行拆分
        if ([numberString containsString:@","]) {//英文，
            
            NSArray *array = [phoneNumnerOrigion componentsSeparatedByString:@","];
            
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([numberString containsString:@"，"]){//中文，
            NSArray *array = [numberString componentsSeparatedByString:@"，"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([numberString containsString:@" "]){
            NSArray *array = [numberString componentsSeparatedByString:@" "];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([numberString containsString:@";"]){//英文;
            NSArray *array = [numberString componentsSeparatedByString:@";"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([numberString containsString:@"；"]){//中文；
            NSArray *array = [numberString componentsSeparatedByString:@"；"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else{
            
            NSString * strPhoneNumber = numberString;
            
            if ([HTMIABCCommonHelper isValidatePhone:strPhoneNumber]|| strPhoneNumber.length > 0) {
                [self.phoneNumberArray addObject:strPhoneNumber];
            }
        }
    }
    
    if (self.phoneNumberArray.count > 1) {
        
        for (int i = 0; i < self.phoneNumberArray.count; i++) {
            NSString * numberString = self.phoneNumberArray[i];
            if (numberString.length < 8) {
                
                [self.phoneNumberArray removeObjectAtIndex:i];
                i--;
            }
        }
        
        //不要将webView添加到self.view，如果添加会遮挡原有的视图
        if (!self.webView) {
            self.webView = [[UIWebView alloc] init];
        }
        
        self.alertView = [[HTMIWFCCustomAlertView alloc] init];
        [self.alertView setContainerView:[self createDemoView]];
        [self.alertView setButtonTitles:[NSMutableArray arrayWithObjects: @"取消", nil]];
        [self.alertView setDelegate:self];
        [self.alertView setOnButtonTouchUpInside:^(HTMIWFCCustomAlertView *alertView, int buttonIndex) {
            
        }];
        
        [self.alertView setUseMotionEffects:true];
        
        [self.alertView show];
        [self.phoneTableView reloadData];
    }
    else{
        
        [self.alertView close];
        
        if (self.phoneNumberArray.count <= 0) {
            return;
        }
        
        self.strPhoenNumber = self.phoneNumberArray[0];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:[NSString stringWithFormat:@"拨打 %@",self.strPhoenNumber]
                                      otherButtonTitles:@"发送短信",@"保存到手机通讯录", @"复制",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        
        [actionSheet showInView:self.view];
    }
}

//手势响应事件 添加为常用联系人
- (void)tapAddContactView:(UITapGestureRecognizer *)sender{
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *UserID = [userdefaults objectForKey:@"UserID"] ==  nil ? @"":[userdefaults objectForKey:@"UserID"];
    NSString *UserName = [userdefaults objectForKey:@"UserName"]==  nil ? @"":[userdefaults objectForKey:@"UserName"];
    NSString *OA_UserId = [userdefaults objectForKey:@"OA_UserId"]==  nil ? @"":[userdefaults objectForKey:@"OA_UserId"];
    NSString *OA_UserName = [userdefaults objectForKey:@"OA_UserName"]==  nil ? @"":[userdefaults objectForKey:@"OA_UserName"];
    NSString *ThirdDepartmentId = [userdefaults objectForKey:@"ThirdDepartmentId"]==  nil ? @"":[userdefaults objectForKey:@"ThirdDepartmentId"];
    NSString *ThirdDepartmentName = [userdefaults objectForKey:@"ThirdDepartmentName"]==  nil ? @"":[userdefaults objectForKey:@"ThirdDepartmentName"];
    NSString *attribute1 = [userdefaults objectForKey:@"attribute1"]==  nil ? @"":[userdefaults objectForKey:@"attribute1"];
    NSString *OA_UnitId = [userdefaults objectForKey:@"OA_UnitId"]==  nil ? @"":[userdefaults objectForKey:@"OA_UnitId"];
    NSString *MRS_UserId = [userdefaults objectForKey:@"MRS_UserId"]==  nil ? @"":[userdefaults objectForKey:@"MRS_UserId"];
    
    //比以前多的
    NSString *IsEMIUser = [userdefaults objectForKey:@"IsEMIUser"]==  nil ? @"":[userdefaults objectForKey:@"IsEMIUser"];
    NSString *NetworkName = [userdefaults objectForKey:@"NetworkName"]==  nil ? @"":[userdefaults objectForKey:@"NetworkName"];
    
    NSMutableDictionary *myDic1 = [NSMutableDictionary dictionary];
    
    [myDic1 setObject:UserID forKey:@"UserID"];
    [myDic1 setObject:UserName forKey:@"UserName"];
    [myDic1 setObject:OA_UserId forKey:@"OA_UserId"];
    [myDic1 setObject:OA_UnitId forKey:@"OA_UnitId"];
    [myDic1 setObject:OA_UserName forKey:@"OA_UserName"];
    [myDic1 setObject:MRS_UserId forKey:@"MRS_UserId"];
    [myDic1 setObject:ThirdDepartmentId forKey:@"ThirdDepartmentId"];
    [myDic1 setObject:ThirdDepartmentName forKey:@"ThirdDepartmentName"];
    [myDic1 setObject:attribute1 forKey:@"attribute1"];
    
    [myDic1 setObject:IsEMIUser forKey:@"IsEMIUser"];
    [myDic1 setObject:NetworkName forKey:@"NetworkName"];
    
    NSMutableDictionary *myDic2 = [NSMutableDictionary dictionary];
    [myDic2 setObject:myDic1 forKey:@"context"];
    
    [myDic2 setObject:UserID forKey:@"UserId"];
    [myDic2 setObject:self.sys_UserModel.UserId forKey:@"CUserId"];
    
    
    //    [Loading showLoadingWithView:self.view];
    [HTMIWFCSVProgressHUD showWithMaskType:HTMIWFCSVProgressHUDMaskTypeNone];
    [HTMIWFCApi AddTopContact:myDic2 succeed:^(id data) {
        [HTMIWFCSVProgressHUD dismiss];
        //        [Loading hiddonLoadingWithView:self.view];
        NSDictionary * dicResult = data;
        
        if ([dicResult isKindOfClass:[NSDictionary class]]) {
            
            
            NSDictionary  * dicMessage = [dicResult objectForKey:@"Message"];
            
            if ([dicMessage isKindOfClass:[NSDictionary class]]) {
                NSString * statusCode = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusCode"]];
                
                if ([statusCode isEqualToString:@"200"]) {
                    
                    HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
                    [addressBookSingletonClass.topContactsArray addObject:self.sys_UserModel];
                    
                    if (self.sys_UserModel.IsEMIUser) {
                        //如果存在，隐藏加为联系人view
                        self.addContactView.hidden = YES;
                        self.sendMessageView.hidden = YES;
                        self.splitView.hidden = YES;
                        self.sendMessageSignalView.hidden = NO;
                        self.normalBottomView.hidden = NO;
                    }
                    else{
                        self.bottomHeightConstraint.constant = 0;
                        self.normalBottomView.hidden = YES;
                    }
                }
                else{
                    //[self showAlertInOneSecond:@"添加常用联系人失败"];
                    [HTMIWFCSVProgressHUD showErrorWithStatus:@"添加常用联系人失败" duration:2.0];
                }
            }
        }
        
    } failure:^(NSError *error) {
        //        [Loading hiddonLoadingWithView:self.view];
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    }];
}

//手势响应事件 发送消息，不是短信
- (void)tapSendMessageView:(UITapGestureRecognizer *)sender{
    
    //需要对用户的信息进行验证，如果不是EMI用户不能发送消息
    if (self.sys_UserModel.IsEMIUser) {
        //可以发消息
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
        NSString *str = [context objectForKey:@"UserID"];
        
        //[HTMIABCAddressBookManager sharedInstance].currentUserModel.UserId
        if ([self.sys_UserModel.UserId isEqual:[NSNull null]]) {
            
        }else if ([self.sys_UserModel.UserId isEqualToString:str]){
            
            UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"不能与自己聊天" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [myalert show];
        }else
        {
            
            NSArray *userArr = [[NSArray alloc]initWithObjects:self.sys_UserModel.UserId, nil];
            
            if (userArr != nil) {
                
#ifdef WorkFlowControl_Enable_MX
//                [[MXChat sharedInstance]chat:userArr withViewController:self withFailCallback:^(id object, MXError *error) {
//                    [HTMIWFCSVProgressHUD showErrorWithStatus:error.description duration:2.0];
//                }];
#endif
            }
        }
    }
    else{
        //        UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该联系人没有聊天权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        //        [myalert show];
        //添加常用联系人
        [self tapAddContactView:nil];
    }
    
}

/**
 *  查看大图图像
 *
 *  @param sender UITapGestureRecognizer
 */
- (void)tapHeaderImage:(UITapGestureRecognizer *)sender{
    
    HTMIWFCTGRImageViewController *viewController = [[HTMIWFCTGRImageViewController alloc] initWithImage:self.headerImageView.image];
    
    
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark --私有方法

- (void)initUI{
    
    HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
    //wlq update 保密字段判断
    NSMutableArray * arrayAll = [addressBookSingletonClass.tdUserModelArray mutableCopy];
    
    for (int i=0; i<arrayAll.count; i++) {
        HTMIABCTD_UserModel * model = arrayAll[i];
        
        if (!model.IsActive) {
            
            [arrayAll removeObject:model];
            i--;
        }
        
        //根据敏感程度确定是否需要显示
        if (![[HTMIABCAddressBookManager sharedInstance] canShowBySecretFlag:model.SecretFlag
                                                       someOneDepartmentCode:self.sys_UserModel.departmentCode]) {
            [arrayAll removeObject:model];
            i--;
        }
    }
    
    NSSortDescriptor *disOrderAscend = [NSSortDescriptor sortDescriptorWithKey:@"DisOrder" ascending:YES];
    
    // 按顺序添加排序描述器
    NSArray *arrayDesc = [arrayAll sortedArrayUsingDescriptors:@[disOrderAscend]];
    
    float height = 10;
    for (HTMIABCTD_UserModel *model in arrayDesc) {
        
        if ([model.FieldName isEqualToString:@"Photosurl"]) {//1
            
            UIView * headerView = [self addViewToScrollerView];
            
            headerView.frame = CGRectMake(10, height, kScreenWidth -20, 70);
            
            UILabel * fieldNameLabel = [UILabel new];
            fieldNameLabel.text = [NSString stringWithFormat:@"%@:",model.DisLabel];
            fieldNameLabel.font = [UIFont systemFontOfSize:14];
            fieldNameLabel.textAlignment = NSTextAlignmentLeft;
            [headerView addSubview:fieldNameLabel];
            
            UIImageView * headerImageView = [UIImageView new];
            self.headerImageView =headerImageView;
            UITapGestureRecognizer *tapAddContactView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImage:)];
            tapAddContactView.numberOfTapsRequired = 1;
            headerImageView.userInteractionEnabled = YES;
            [headerImageView addGestureRecognizer:tapAddContactView];
            [headerView addSubview:headerImageView];
            
            headerImageView.layer.cornerRadius = headerImageView.bounds.size.width / 2;
            headerImageView.layer.masksToBounds = YES; // 裁剪
            headerImageView.layer.shouldRasterize = YES; // 缓存
            headerImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            
            if (!_sys_UserModel.headerBackGroundColor) {
                _sys_UserModel.headerBackGroundColor = [[HTMIWFCSettingManager manager] randomColor];
            }
            
            //控制显示
            [headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,_sys_UserModel.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:_sys_UserModel.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType]  withColor:_sys_UserModel.headerBackGroundColor]];
            
            [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.left.equalTo(headerView.mas_left).with.offset(5);
                make.width.mas_equalTo(@100);
                make.centerY.equalTo(headerView);
            }];
            
            [headerImageView mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.right.equalTo(headerView.mas_right).with.offset(-10);
                make.width.mas_equalTo(@50);
                make.height.mas_equalTo(@50);
                make.centerY.equalTo(headerView);
            }];
            
            height += CGRectGetHeight(headerView.frame) + 5;
        }
        else if ([model.FieldName isEqualToString:@"FullName"]){//2
            
            UIView * nameView = [self addViewToScrollerView];
            nameView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:nameView td_UserModel:model value:self.sys_UserModel.FullName];
            
            height += CGRectGetHeight(nameView.frame) + 5;
            
        }
        else if ([model.FieldName isEqualToString:@"Gender"]){//3
            
            UIView * genderView = [self addViewToScrollerView];
            
            genderView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            UILabel * fieldNameLabel = [UILabel new];
            fieldNameLabel.text = [NSString stringWithFormat:@"%@:",model.DisLabel];
            fieldNameLabel.font = [UIFont systemFontOfSize:14];
            fieldNameLabel.textAlignment = NSTextAlignmentLeft;
            [genderView addSubview:fieldNameLabel];
            
            UILabel * nameLabel = [UILabel new];
            
            NSString *strGender;
            if (self.sys_UserModel.Gender == 0) {
                strGender = @"女";
            }
            else if(self.sys_UserModel.Gender == 1){
                strGender = @"男";
            }
            nameLabel.text = [NSString stringWithFormat:@"%@",strGender];
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.textAlignment = NSTextAlignmentRight;
            [genderView addSubview:nameLabel];
            
            [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.left.equalTo(genderView.mas_left).with.offset(5);
                make.width.mas_equalTo(@100);
                make.centerY.equalTo(genderView);
            }];
            
            [nameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.right.equalTo(genderView.mas_right).with.offset(-10);
                
                make.centerY.equalTo(genderView);
            }];
            
            height += CGRectGetHeight(genderView.frame) + 5;
        }
        else if ([model.FieldName isEqualToString:@"Email"]){//4
            
            UIView * emailView = [self addViewToScrollerView];
            
            emailView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            UILabel * fieldNameLabel = [UILabel new];
            fieldNameLabel.text = [NSString stringWithFormat:@"%@:",model.DisLabel];
            fieldNameLabel.font = [UIFont systemFontOfSize:14];
            fieldNameLabel.textAlignment = NSTextAlignmentLeft;
            [emailView addSubview:fieldNameLabel];
            
            UIButton * emailButton = [UIButton new];
            [emailButton setTitle:self.sys_UserModel.Email forState:UIControlStateNormal];
            [emailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
            emailButton.titleLabel.font = [UIFont systemFontOfSize:14];
            emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            
            [emailButton addTarget:self action:@selector(clickEmail:) forControlEvents:UIControlEventTouchUpInside];
            [emailView addSubview:emailButton];
            
            [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.left.equalTo(emailView.mas_left).with.offset(5);
                make.width.mas_equalTo(@100);
                make.centerY.equalTo(emailView);
            }];
            
            [emailButton mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.right.equalTo(emailView.mas_right).with.offset(-10);
                make.centerY.equalTo(emailView);
            }];
            
            height += CGRectGetHeight(emailView.frame)+5;
            
        }
        else if ([model.FieldName isEqualToString:@"Telephone"]){//5
            
            UIView * telephoneView = [self addViewToScrollerView];
            telephoneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            UILabel * fieldNameLabel = [UILabel new];
            fieldNameLabel.text = [NSString stringWithFormat:@"%@:",model.DisLabel];
            fieldNameLabel.font = [UIFont systemFontOfSize:14];
            fieldNameLabel.textAlignment = NSTextAlignmentLeft;
            [telephoneView addSubview:fieldNameLabel];
            
            UIButton * telephoneButton = [UIButton new];
            //wlq update 2016/09/23 隐藏通讯录中的手机号
            NSString *originTel = self.sys_UserModel.Telephone;
            [telephoneButton setTitle:[self getPhoneNumberByDeal:originTel] forState:UIControlStateNormal];
            telephoneButton.tag = 10001;
            [telephoneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
            telephoneButton.titleLabel.font = [UIFont systemFontOfSize:14];
            telephoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            
            [telephoneButton addTarget:self action:@selector(clickPhone:) forControlEvents:UIControlEventTouchUpInside];
            [telephoneView addSubview:telephoneButton];
            
            [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.left.equalTo(telephoneView.mas_left).with.offset(5);
                make.width.mas_equalTo(@100);
                make.centerY.equalTo(telephoneView);
            }];
            
            [telephoneButton mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.right.equalTo(telephoneView.mas_right).with.offset(-10);
                make.centerY.equalTo(telephoneView);
            }];
            
            height += CGRectGetHeight(telephoneView.frame)+5;
        }
        else if ([model.FieldName isEqualToString:@"Office"]){//6
            
            UIView * officeView = [self addViewToScrollerView];
            
            officeView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            UILabel * fieldNameLabel = [UILabel new];
            fieldNameLabel.text = [NSString stringWithFormat:@"%@:",model.DisLabel];
            fieldNameLabel.font = [UIFont systemFontOfSize:14];
            fieldNameLabel.textAlignment = NSTextAlignmentLeft;
            [officeView addSubview:fieldNameLabel];
            
            UILabel * nameLabel = [UILabel new];
            nameLabel.text = [NSString stringWithFormat:@"%@",self.sys_UserModel.Office];
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.textAlignment = NSTextAlignmentRight;
            [officeView addSubview:nameLabel];
            
            [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.left.equalTo(officeView.mas_left).with.offset(5);
                make.width.mas_equalTo(@100);
                make.centerY.equalTo(officeView);
            }];
            
            [nameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.right.equalTo(officeView.mas_right).with.offset(-10);
                
                make.centerY.equalTo(officeView);
            }];
            
            height += CGRectGetHeight(officeView.frame)+5;
            
        }
        else if ([model.FieldName isEqualToString:@"Mobile"]){//7
            UIView * mobileView = [self addViewToScrollerView];
            
            mobileView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            UILabel * fieldNameLabel = [UILabel new];
            fieldNameLabel.text = [NSString stringWithFormat:@"%@:",model.DisLabel];
            fieldNameLabel.font = [UIFont systemFontOfSize:14];
            fieldNameLabel.textAlignment = NSTextAlignmentLeft;
            [mobileView addSubview:fieldNameLabel];
            
            UIButton * telephoneButton = [UIButton new];
            //wlq update 2016/09/23 隐藏通讯录中的手机号
            NSString *originTel = self.sys_UserModel.Mobile;
            [telephoneButton setTitle:[self getPhoneNumberByDeal:originTel] forState:UIControlStateNormal];
            [telephoneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            telephoneButton.tag = 10002;
            telephoneButton.titleLabel.font = [UIFont systemFontOfSize:14];
            telephoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            
            [telephoneButton addTarget:self action:@selector(clickPhone:) forControlEvents:UIControlEventTouchUpInside];
            [mobileView addSubview:telephoneButton];
            
            [fieldNameLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.left.equalTo(mobileView.mas_left).with.offset(5);
                make.width.mas_equalTo(@100);
                make.centerY.equalTo(mobileView);
            }];
            
            [telephoneButton mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
                
                make.right.equalTo(mobileView.mas_right).with.offset(-10);
                make.centerY.equalTo(mobileView);
            }];
            
            height += CGRectGetHeight(mobileView.frame)+5;
            
        }
        else if ([model.FieldName isEqualToString:@"Fax"]){//8
            UIView * faxView = [self addViewToScrollerView];
            
            faxView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:faxView td_UserModel:model value:self.sys_UserModel.Fax];
            
            height += CGRectGetHeight(faxView.frame)+5;
            
        }
        else if ([model.FieldName isEqualToString:@"Position"]){//9
            
            UIView * positionView = [self addViewToScrollerView];
            
            positionView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:positionView td_UserModel:model value:self.sys_UserModel.Position];
            
            height += CGRectGetHeight(positionView.frame) +5;
        }
        
#pragma mark --暂未使用，保留字段
        else if ([model.FieldName isEqualToString:@"Ext1"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext1];
            
            height += CGRectGetHeight(oneView.frame) + 5;
        }
        else if ([model.FieldName isEqualToString:@"Ext2"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext2];
            
            height += CGRectGetHeight(oneView.frame) + 5;
        }
        else if ([model.FieldName isEqualToString:@"Ext3"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext3];
            
            height += CGRectGetHeight(oneView.frame) + 5;
        }
        else if ([model.FieldName isEqualToString:@"Ext4"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext4];
            
            height += CGRectGetHeight(oneView.frame) + 5;
            
        }
        else if ([model.FieldName isEqualToString:@"Ext5"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext5];
            
            height += CGRectGetHeight(oneView.frame) + 5;
            
        }else if ([model.FieldName isEqualToString:@"Ext6"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext6];
            
            height += CGRectGetHeight(oneView.frame) + 5;
            
        }else if ([model.FieldName isEqualToString:@"Ext7"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext7];
            
            height += CGRectGetHeight(oneView.frame) + 5;
            
        }
        else if ([model.FieldName isEqualToString:@"Ext8"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext8];
            
            height += CGRectGetHeight(oneView.frame) + 5;
            
        }
        else if ([model.FieldName isEqualToString:@"Ext9"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext9];
            
            height += CGRectGetHeight(oneView.frame) + 5;
        }
        else if ([model.FieldName isEqualToString:@"Ext10"]){
            
            UIView * oneView = [self addViewToScrollerView];
            oneView.frame =  CGRectMake(10, height, kScreenWidth -20, 50);
            
            [self addViewsToOneView:oneView td_UserModel:model value:self.sys_UserModel.ext10];
            
            height += CGRectGetHeight(oneView.frame) + 5;
        }
    }
    
    
    [self.scrollView setContentSize:CGSizeMake(kScreenWidth, height)];
}

/**
 *  提示框
 */
- (void)alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];
}

/**
 *  打电话
 *
 *  @param strPhoneNumber 电话号码
 */
- (void)callByPhone:(NSString *)strPhoneNumber{
    //不要将webView添加到self.view，如果添加会遮挡原有的视图
    
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"tel://%@",strPhoneNumber];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
}

/**
 *  发送短信
 *
 *  @param arrPhoneNumber 电话号码数组
 */
- (void)showMessageView:(NSArray *)arrPhoneNumber{
    @try {
        if( [MFMessageComposeViewController canSendText] ){
            
            MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init];
            
            controller.recipients = arrPhoneNumber;
            controller.body = @"";
            controller.messageComposeDelegate = self;
            
            UIColor * myTintColor;
            
            //wlq update 2016/05/11 适配风格
            if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
                
                myTintColor= [[HTMIWFCSettingManager manager] blueColor];
            }
            else{
                
                myTintColor= [UIColor whiteColor];
            }
            
            controller.navigationBar.tintColor = myTintColor;
            
            [self presentViewController:controller animated:YES completion:^{
                
            }];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[HTMIWFCSettingManager manager] navigationBarTitleFontColor],NSForegroundColorAttributeName,
                                 [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0],
                                 NSFontAttributeName,nil];
            
            [controller.navigationBar setTitleTextAttributes:dic];
            
            //[[[[controller viewControllers] lastObject] navigationItem] setTitle:@"短信"];//修改短信界面标题
        }else{
            
            [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
        }
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark UIActionSheetDelegate Method

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self callByPhone:self.strPhoenNumber];
    }else if (buttonIndex == 1) {
        [self showMessageView:@[self.strPhoenNumber]];
    }else if(buttonIndex == 2) {
        [self saveTeleToAddBook];
    }else if(buttonIndex == 3) {
        [self copyTelephone];
    }
    else{
        
    }
}

- (UIView *)addViewToScrollerView{
    UIView * commonView = [UIView new];
    commonView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:commonView];
    
    UIView * splitView = [UIView new];
    splitView.backgroundColor = RGB(239, 240, 240);
    [self.scrollView addSubview:splitView];
    
    //添加底部边线
    [splitView mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.left.equalTo(commonView.mas_left).with.offset(0);
        make.right.equalTo(commonView.mas_right).with.offset(0);
        make.bottom.equalTo(commonView.mas_bottom).with.offset(0);
        make.height.mas_equalTo(@0.5);
        
    }];
    return commonView;
}

- (BOOL)isContains{
    
    HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
    
    for (HTMIABCSYS_UserModel *sys_UserModel in addressBookSingletonClass.topContactsArray) {
        if ([self.sys_UserModel.UserId isEqualToString:sys_UserModel.UserId]) {
            return YES;
        }
    }
    
    return NO;
}

//将电话保存到通讯录
- (void)saveTeleToAddBook
{
    NSString *phone = self.strPhoenNumber;
    
    if ([HTMIABCSystemAddressBookHelper existPhone:phone] == ABHelperExistSpecificContact)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息提示" message:[NSString stringWithFormat:@"手机号码：%@已存在通讯录",phone] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        if ([HTMIABCSystemAddressBookHelper addContactName:self.sys_UserModel.FullName phoneNum:phone withLabel:@"电话"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息提示" message:@"添加到通讯录成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        };
    }
    
}

//点击复制按钮
- (void)copyTelephone
{
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.strPhoenNumber];
}

//获取处理过的电话号码
- (NSString *)getPhoneNumberByDeal:(NSString *)originTel{
    
    NSMutableString * stringPhoneNumberDone = [[NSMutableString alloc]initWithString:@""];
    
    if ([[HTMIWFCSettingManager manager] isNeedHideAddressBookPersonPhoneNumber]) {//是否需要隐藏手机号中间的几位
        if ([originTel containsString:@";"]) {
            NSArray * tempArray = [originTel componentsSeparatedByString:@";"];
            for (NSString *strTemp in tempArray) {
                
                NSString * strDone = @"";
                
                if (strTemp.length == 11) {
                    strDone = [strTemp stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    
                    [stringPhoneNumberDone appendString:strDone];
                }
                else if (strTemp.length > 0)
                {
                    [stringPhoneNumberDone appendString:strTemp];
                }
            }
        }
        else if ([originTel containsString:@"；"]) {
            
            NSArray * tempArray = [originTel componentsSeparatedByString:@"；"];
            for (NSString *strTemp in tempArray) {
                
                NSString * strDone = @"";
                
                if (strTemp.length == 11) {
                    strDone = [strTemp stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    
                    [stringPhoneNumberDone appendString:strDone];
                }
                else if (strTemp.length > 0)
                {
                    [stringPhoneNumberDone appendString:strTemp];
                }
            }
        }
        else{
            
            
            if (originTel.length == 11) {
                originTel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            }
            
            [stringPhoneNumberDone appendString:originTel];
            
        }
    }
    else{
        [stringPhoneNumberDone appendString:self.sys_UserModel.Mobile];
    }
    
    return stringPhoneNumberDone;
}

#pragma mark --Getter

//- (NSMutableArray *)phoneArray{
//    if (!_phoneArray) {
//        _phoneArray = [NSMutableArray array];
//
//    }
//    return _phoneArray;
//}

- (NSMutableArray *)phoneNumberArray{
    if (!_phoneNumberArray) {
        _phoneNumberArray = [NSMutableArray array];
    }
    return _phoneNumberArray;
}


@end
