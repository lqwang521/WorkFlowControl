//
//  DemoCell.m
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//
//放大图片
#import "HTMIWFCTGRImageViewController.h"

//view
#import "HTMIABCAddressBookPersonTableViewCell.h"

//model
#import "HTMIABCSYS_UserModel.h"

//others
#import "HTMIABCCommonHelper.h"
#import "UIImageView+HTMIWFCWebCache.h"
#import "HTMIABCAddressBookManager.h"

#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
#endif

#import "HTMIWFCCustomAlertView.h"
#import "UIColor+HTMIWFCHex.h"

#import "HTMIABCPhoneNumberTableViewCell.h"
#import "HTMIABCHeaderImageType.h"

#import "HTMIWFCSettingManager.h"

#import "UIImage+HTMIWFCWM.h"
#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCEMIManager.h"

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

@interface HTMIABCAddressBookPersonTableViewCell ()<HTMIWFCCustomAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)HTMIWFCCustomAlertView *alertView;
@property(nonatomic,strong)UITableView *phoneTableView;

@property(nonatomic,strong)NSMutableArray *phoneNumberArray;

@end

@implementation HTMIABCAddressBookPersonTableViewCell

#pragma mark - 生命周期
- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapAddContactView= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeaderImage:)];
    tapAddContactView.numberOfTapsRequired = 1;
    self.leftImageView.userInteractionEnabled = YES;
    [self.leftImageView addGestureRecognizer:tapAddContactView];
    
    //    self.leftImageView.layer.cornerRadius = self.leftImageView.bounds.size.width / 2;
    //    self.leftImageView.layer.masksToBounds = YES; // 裁剪
    //    self.leftImageView.layer.shouldRasterize = YES; // 缓存
    //    self.leftImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"HTMIABCAddressBookPersonTableViewCell";
    HTMIABCAddressBookPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCAddressBookPersonTableViewCell" owner:nil options:nil][0];
    }
    
    return cell;
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
    //wlq update 2016/09/23 隐藏通讯录中的手机号
    NSString *originTel = self.phoneNumberArray[indexPath.row];
    
    if ([[HTMIWFCSettingManager manager] isNeedHideAddressBookPersonPhoneNumber]) {//是否需要隐藏手机号中间的几位
        if (originTel.length == 11) {
            originTel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
    }
    
    cell.phoneNumberLabel.text = originTel;
    
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
    
    NSString *honeNumberString =  self.phoneNumberArray[indexPath.row];
    
    NSString *strUrl = [NSString stringWithFormat:@"tel://%@",honeNumberString];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}


#pragma mark --事件

- (IBAction)clickMessageButton:(id)sender {
    
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
            UIViewController * vc = [self getCurrentVC];
            NSArray *userArr = [[NSArray alloc]initWithObjects:self.sys_UserModel.UserId, nil];
            
            if (userArr != nil) {
#ifdef WorkFlowControl_Enable_MX
                
                [HTMIWFCEMIManager mxChat:userArr withViewController:vc];
                
#endif
            }
        }
    }
    else{
        UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"此人不是EMI用户" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myalert show];
    }
}

- (IBAction)clickPhoneButton:(id)sender {
    
    [self.phoneNumberArray removeAllObjects];
    if (_sys_UserModel.Telephone.length > 0) {
        
        //这个可能里面有多个，号，如果有，进行拆分
        if ([_sys_UserModel.Telephone containsString:@","]) {//英文，
            
            NSArray *array = [_sys_UserModel.Telephone componentsSeparatedByString:@","];
            
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Telephone containsString:@"，"]){//中文，
            NSArray *array = [_sys_UserModel.Telephone componentsSeparatedByString:@"，"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Telephone containsString:@" "]){
            NSArray *array = [_sys_UserModel.Telephone componentsSeparatedByString:@" "];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Telephone containsString:@";"]){//英文;
            NSArray *array = [_sys_UserModel.Telephone componentsSeparatedByString:@";"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Telephone containsString:@"；"]){//中文；
            NSArray *array = [_sys_UserModel.Telephone componentsSeparatedByString:@"；"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else{
            
            NSString * strPhoneNumber = _sys_UserModel.Telephone;
            
            if ([HTMIABCCommonHelper isValidatePhone:strPhoneNumber]||strPhoneNumber.length > 0) {
                [self.phoneNumberArray addObject:strPhoneNumber];
            }
        }
    }
    
    if(_sys_UserModel.Mobile.length > 0){
        
        //这个可能里面有多个，号，如果有，进行拆分
        if ([_sys_UserModel.Mobile containsString:@","]) {//英文，
            
            NSArray *array = [_sys_UserModel.Mobile componentsSeparatedByString:@","];
            
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Mobile containsString:@"，"]){//中文，
            NSArray *array = [_sys_UserModel.Mobile componentsSeparatedByString:@"，"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Mobile containsString:@" "]){
            NSArray *array = [_sys_UserModel.Mobile componentsSeparatedByString:@" "];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Mobile containsString:@";"]){//英文;
            NSArray *array = [_sys_UserModel.Mobile componentsSeparatedByString:@";"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else if ([_sys_UserModel.Mobile containsString:@"；"]){//中文；
            NSArray *array = [_sys_UserModel.Mobile componentsSeparatedByString:@"；"];
            [self.phoneNumberArray addObjectsFromArray:array];
        }
        else{
            
            NSString * strPhoneNumber = _sys_UserModel.Mobile;
            
            if ([HTMIABCCommonHelper isValidatePhone:strPhoneNumber]|| strPhoneNumber.length > 0) {
                [self.phoneNumberArray addObject:strPhoneNumber];
            }
        }
    }
    
    
    //    NSOrderedSet *orderSet = [NSOrderedSet orderedSetWithArray:self.phoneNumberArray];
    //    NSArray *newArray = orderSet.array;
    //    self.phoneNumberArray = [NSMutableArray arrayWithArray:newArray];//去重
    
    NSMutableArray *listAry = [[NSMutableArray alloc]init];
    for (NSString *str in self.phoneNumberArray) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }
    
    self.phoneNumberArray = listAry;
    
    if (self.phoneNumberArray.count > 1) {
        
        for (int i = 0; i < self.phoneNumberArray.count; i++) {
            NSString * numberString = self.phoneNumberArray[i];
            if (numberString.length < 8 || numberString.length > 11) {//长度不是一个电话号
                
                [self.phoneNumberArray removeObjectAtIndex:i];
                i--;
            }
        }
        
        //删除不是电话号码的，可能就没有了
        if (self.phoneNumberArray.count <= 0) {
            return;
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
        
        NSString *honeNumberString =  self.phoneNumberArray[0];
        
        NSString *strUrl = [NSString stringWithFormat:@"tel://%@",honeNumberString];
        
        NSURL *url = [NSURL URLWithString:strUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //不要将webView添加到self.view，如果添加会遮挡原有的视图
        if (!self.webView) {
            self.webView = [[UIWebView alloc] init];
        }
        [self.webView loadRequest:request];
    }
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
    
    UILabel *routeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,width, 40)];
    routeLabel.text = @"请选择要拨打的电话";
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


- (void)tapHeaderImage:(UITapGestureRecognizer *)sender{
    
    HTMIWFCTGRImageViewController *viewController = [[HTMIWFCTGRImageViewController alloc] initWithImage:self.leftImageView.image];
    
    UIViewController * currentVC = [self getCurrentVC];
    [currentVC presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - 私有方法

/**
 *  获取当前屏幕显示的viewcontroller
 *
 *  @return 当前屏幕显示的viewcontroller
 */
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }
    
    else{
        result = window.rootViewController;
    }
    
    return result;
}


#pragma mark - Getters and Setters

- (void)setSys_UserModel:(HTMIABCSYS_UserModel *)sys_UserModel{
    
    _sys_UserModel = sys_UserModel;
    
    if (_sys_UserModel) {
        
        if (!_sys_UserModel.headerBackGroundColor) {
            _sys_UserModel.headerBackGroundColor = [[HTMIWFCSettingManager manager] randomColor];;
        }
        
        //控制显示
        [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,_sys_UserModel.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:_sys_UserModel.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType]  withColor:_sys_UserModel.headerBackGroundColor]];
        
        self.nameLabel.text = _sys_UserModel.FullName;
        
        if (_sys_UserModel.Mobile.length > 0 || _sys_UserModel.Telephone.length > 0) {
            
            
            NSMutableArray * arrayAll = [[HTMIABCAddressBookManager sharedInstance].tdUserModelArray mutableCopy];
            
            //默认是公开的
            int flagTelephone = 0;
            int flagMobile = 0;
            
            for (int i=0; i<arrayAll.count; i++) {
                HTMIABCTD_UserModel * model = arrayAll[i];
                
                if ([model.FieldName isEqualToString:@"Telephone"]) {//电话字段需要先进行flag判断
                    
                    flagTelephone = model.SecretFlag;
                }
                
                if ([model.FieldName isEqualToString:@"Mobile"]) {//电话字段需要先进行flag判断
                    
                    flagMobile = model.SecretFlag;
                }
            }
            
            self.phoneButton.enabled = YES;
            
            if (_sys_UserModel.Telephone.length > 0) {
                
                //判断是否需要保密
                if (![[HTMIABCAddressBookManager sharedInstance] canShowBySecretFlag:flagTelephone
                                                               someOneDepartmentCode:_sys_UserModel.departmentCode]) {
                    self.phoneButton.enabled = NO;
                    self.phoneOrDepartmentLabel.text = @"";
                }
                else{
                    
                    //这个可能里面有多个，号，如果有，进行拆分
                    if ([_sys_UserModel.Telephone containsString:@","]) {
                        
                        NSArray *array = [_sys_UserModel.Telephone componentsSeparatedByString:@","];
                        
                        
                        //wlq update 2016/09/23 隐藏通讯录中的手机号
                        NSString *originTel = array[0];
                        
                        if ([[HTMIWFCSettingManager manager] isNeedHideAddressBookPersonPhoneNumber]) {//是否需要隐藏手机号中间的几位
                            if (originTel.length == 11) {
                                originTel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                            }
                        }
                        
                        self.phoneOrDepartmentLabel.text = originTel;
                    }
                    else{
                        //wlq update 2016/09/23 隐藏通讯录中的手机号
                        NSString *originTel = _sys_UserModel.Telephone;
                        
                        if ([[HTMIWFCSettingManager manager] isNeedHideAddressBookPersonPhoneNumber]) {//是否需要隐藏手机号中间的几位
                            if (originTel.length == 11) {
                                originTel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                            }
                        }
                        self.phoneOrDepartmentLabel.text = originTel;
                    }
                }
            }
            else{
                
                //判断是否需要保密
                if (![[HTMIABCAddressBookManager sharedInstance] canShowBySecretFlag:flagMobile
                                                               someOneDepartmentCode:_sys_UserModel.departmentCode]) {
                    self.phoneButton.enabled = NO;
                    self.phoneOrDepartmentLabel.text = @"";
                }
                else{
                    //这个可能里面有多个，号，如果有，进行拆分
                    if ([_sys_UserModel.Mobile containsString:@","]) {
                        
                        NSArray *array = [_sys_UserModel.Mobile componentsSeparatedByString:@","];
                        
                        
                        //wlq update 2016/09/23 隐藏通讯录中的手机号
                        NSString *originTel = array[0];
                        
                        if ([[HTMIWFCSettingManager manager] isNeedHideAddressBookPersonPhoneNumber]) {//是否需要隐藏手机号中间的几位
                            if (originTel.length == 11) {
                                originTel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                            }
                        }
                        
                        self.phoneOrDepartmentLabel.text = originTel;
                    }
                    else{
                        //wlq update 2016/09/23 隐藏通讯录中的手机号
                        NSString *originTel = _sys_UserModel.Mobile;
                        
                        if ([[HTMIWFCSettingManager manager] isNeedHideAddressBookPersonPhoneNumber]) {//是否需要隐藏手机号中间的几位
                            if (originTel.length == 11) {
                                originTel = [originTel stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                            }
                        }
                        self.phoneOrDepartmentLabel.text = originTel;
                    }
                }
            }
        }
        else{
            self.phoneButton.enabled = NO;
            self.phoneOrDepartmentLabel.text = @"";
        }
        
        if (_sys_UserModel.IsEMIUser) {
            self.messageButton.enabled = YES;
        }
        else{
            self.messageButton.enabled = NO;
        }
        
        //如果没有电话号码
        if (self.phoneOrDepartmentLabel.text.length <= 0) {
            self.phoneOrDepartmentLabel.hidden = YES;
            self.phoneLabelTopConstraint.constant = 20;
        }
        else{
            self.phoneOrDepartmentLabel.hidden = NO;
            
            self.phoneLabelTopConstraint.constant = 10;
        }
    }
}

- (NSMutableArray *)phoneNumberArray{
    if (!_phoneNumberArray) {
        _phoneNumberArray = [NSMutableArray array];
    }
    return _phoneNumberArray;
}


@end
