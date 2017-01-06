//
//  HTMIABCPersonalInfoEditViewController.m
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCPersonalInfoEditViewController.h"

//model
#import "HTMIABCTD_UserModel.h"
#import "HTMIABCSYS_UserModel.h"

//ohers
//#import "MBProgressHUD+Add.h"
#import "HTMIABCDBHelper.h"
#import "HTMIABCCommonHelper.h"
#import "HTMIABCUserdefault.h"
#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCSettingManager.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "HTMIWFCApi.h"

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



@interface HTMIABCPersonalInfoEditViewController ()<UITextFieldDelegate>

@property (nonatomic,strong)UITextField * oneTextField;

@end

@implementation HTMIABCPersonalInfoEditViewController

#pragma mark --生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    
    [self customNavigationController:YES title:@""];
    
    [self initUI];
    
    //给textfield 赋值
    [self initData];
    
    //监听输入改变事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.oneTextField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark --事件

/**
 *  确定按钮点击事件
 */
- (void)clickRightBarButtonItem{
    [HTMIABCCommonHelper hideKeyBoard];
    
    if([self.td_UserModel.FieldName isEqualToString:@"Email"]){//4电子邮件
        if (![HTMIABCCommonHelper isValidateEmail:self.oneTextField.text]) {
            //            [HTMIWFCSVProgressHUD showError:@"您的邮箱输入格式有误" toView:nil];
            [HTMIWFCSVProgressHUD showErrorWithStatus:@"您的邮箱输入格式有误"];
            return;
        }
    }
    /*  可以输入多个手机号，以分号隔开
     else if([_td_UserModel.FieldName isEqualToString:@"Mobile"] || [_td_UserModel.FieldName isEqualToString:@"Telephone"]){//7手机号码
     
     if (![HTMIABCCommonHelper isValidatePhone:self.oneTextField.text]) {
     [MBProgressHUD showError:@"您的手机号输入格式有误" toView:nil];
     
     return;
     }
     }
     */
    
    //获取模型的所有属性
    NSArray * tempArray = [self.sys_UserModel allPropertyNames];
    
    //给特定的属性添加set方法进行赋值
    for (NSString *propertyString in tempArray) {
        if ([[self.td_UserModel.FieldName lowercaseString] isEqualToString:[propertyString lowercaseString]]) {
            [self.sys_UserModel assginToPropertyWithDictionary:propertyString value:self.oneTextField.text];
        }
    }
    
    //1调用接口上传服务器
    
    [HTMIWFCSVProgressHUD show];
    [HTMIWFCApi updateUserInfo:self.sys_UserModel succeed:^(id dicResult) {
        [HTMIWFCSVProgressHUD dismiss];
        if (dicResult && [dicResult isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary  * dicMessage = [dicResult objectForKey:@"Message"];
            
            if (dicMessage && [dicMessage isKindOfClass:[NSDictionary class]]) {
                
                NSString * statusCode = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusCode"]];
                
                if ([statusCode isEqualToString:@"200"]) {
                    
                    NSString * result = [NSString stringWithFormat:@"%@",[dicResult objectForKey:@"Result"]];
                    
                    //成功了
                    if ([result isEqualToString:@"1"]) {//可能不是1
                        
                        //2如果操作成功那么存入本地数据库
                        NSString *UserIDString = [HTMIABCUserdefault defaultLoadUserID];
                        //3成功后跳转回到上以页面
                        [[HTMIABCDBHelper sharedYMDBHelperTool]UpdateCurrentUserInfoByUserId:UserIDString fieldNameLower:[self.td_UserModel.FieldName lowercaseString] value:self.oneTextField.text];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    else{
                        [HTMIWFCApi showErrorStringWithError:@"修改个人信息失败" error:nil onView:nil];
                    }
                }
                else{
                    NSString * statusMessage = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusMessage"]];
                    [HTMIWFCApi showErrorStringWithError:statusMessage error:nil onView:nil];
                }
            }
        }
    } failure:^(NSError *error) {
        [HTMIWFCSVProgressHUD dismiss];
        [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
    }];
}

#pragma mark --textField代理方法

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([_td_UserModel.FieldName isEqualToString:@"Mobile"] || [_td_UserModel.FieldName isEqualToString:@"Telephone"]){//7手机号码
        
        NSScanner      *scanner    = [NSScanner scannerWithString:string];
        NSCharacterSet *numbers;
        
        
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789;"];
        
        if ( [textField.text isEqualToString:@""] && [string isEqualToString:@";"] ){
            return NO;
        }
        
        NSString *buffer;
        if (![scanner scanCharactersFromSet:numbers intoString:&buffer] && ([string length] != 0) ){
            //只能输入数字和
            return NO;
        }else{
            return YES;
        }
    }
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return YES;
}

#pragma mark --私有方法

- (void)initUI{
    
    self.navigationItem.title = self.td_UserModel.DisLabel;
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    btnRight.frame = CGRectMake(0, 0, 35, 20);
    
    //wlq update 2016/05/11 适配风格
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        
        //蓝色
        btnRight.tintColor = [[HTMIWFCSettingManager manager] blueColor];
        [btnRight setTitleColor:[[HTMIWFCSettingManager manager] blueColor] forState:UIControlStateNormal];
    }
    else{
        
        btnRight.tintColor = [UIColor whiteColor];
        [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [btnRight setTitle:@"保存" forState:UIControlStateNormal];
    btnRight.backgroundColor = [UIColor clearColor];
    [btnRight addTarget:self action:@selector(clickRightBarButtonItem) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = right;
    
    self.oneTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, 44)];
    self.oneTextField.delegate = self;
    [self.view addSubview:self.oneTextField];
    self.oneTextField.font = [UIFont systemFontOfSize:14];
    self.oneTextField.placeholder = @"请您在此输入";
    self.oneTextField.backgroundColor = [UIColor whiteColor];
    //self.oneTextField.textColor = RGB(153, 153, 153);
    self.oneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.oneTextField.layer.borderWidth = 1;
    self.oneTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    UIView * leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 44)];
    self.oneTextField.leftView = leftView;
    self.oneTextField.leftViewMode = UITextFieldViewModeAlways;
    //wlq add 根据判断控制控件的输入键盘
    if([self.td_UserModel.FieldName isEqualToString:@"Email"]){//4电子邮件
        self.oneTextField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if([_td_UserModel.FieldName isEqualToString:@"Mobile"] || [_td_UserModel.FieldName isEqualToString:@"Telephone"]){//7手机号码
        self.oneTextField.keyboardType = UIKeyboardTypeDefault;
    }
}

- (void)initData{
    
    NSString * LowerString = [self.td_UserModel.FieldName lowercaseString];
    
    if (LowerString && LowerString.length > 0) {
        
        NSString * valueString = [self.sys_UserModel.userInfoDic objectForKey:LowerString];
        self.oneTextField.text = valueString;
    }
    else{
        self.oneTextField.text = @"";
    }
}

//监听textField的输入长度
//wlq 追加 2015/07/08 限定登录输入栏只能输入十一个字符
- (void)textFiledEditChanged:(NSNotification *)obj{
    /*
     int kMaxLength = 11;
     
     UITextField *textField = (UITextField *)obj.object;
     NSString *toBeString = textField.text;
     //    NSString *lang = [textField.textInputMode primaryLanguage]; // 键盘输入模式
     
     if (textField == self.oneTextField) {
     
     //手机号需要限制长度
     
     if (toBeString.length > kMaxLength) {
     textField.text = [toBeString substringToIndex:kMaxLength];
     }
     }
     }*/
    if ([self.td_UserModel.FieldName isEqualToString:@"Mobile"] || [self.td_UserModel.FieldName isEqualToString:@"Telephone"]) {
        //联想输入不走代理方法
        UITextField *textField = (UITextField *)obj.object;
        
        NSString * tempString = [textField.text stringByReplacingOccurrencesOfString:@";" withString:@""];
        
        if (textField.text.length > 0) {
            
            NSString *regEx = @"^[0-9]*$";
            NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
            BOOL isMatch            = [pred evaluateWithObject:tempString];
            if (!isMatch) {
                
                [HTMIWFCSVProgressHUD showErrorWithStatus:@"不能输入数字和分号以外的字符"] ;
                textField.text = @"";
            }
        }
    }
}

@end
