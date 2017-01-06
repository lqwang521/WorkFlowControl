//
//  HTMIWFCEditOpinionViewController.m
//  MXClient
//
//  Created by 赵志国 on 16/7/27.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCEditOpinionViewController.h"

//#import "MXConst.h"
#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "UIImage+HTMIWFCWM.h"
#import "HTMIWFCSettingManager.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

@interface HTMIWFCEditOpinionViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UITextView *textView;

@end

@implementation HTMIWFCEditOpinionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customNavigationController:NO title:@""];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    
    self.title = self.titleString;
    
    // 自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    self.borderView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Width-20, 110)];
    self.borderView.backgroundColor = [UIColor whiteColor];
    self.borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.borderView.layer.borderWidth = 1.0;
    self.borderView.layer.masksToBounds = YES;
    self.borderView.layer.cornerRadius = 2.0;
    [self.view addSubview:self.borderView];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(8, 8, Width-36, 100)];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:15.0];
    if (self.opinionString.length > 0) {
        self.textView.text = self.opinionString;
    } else {
        self.textView.text = @"请填写意见";
        self.textView.textColor = [UIColor lightGrayColor];
    }
    [self.borderView addSubview:self.textView];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.frame = CGRectMake(16, self.borderView.frame.size.height+30, Width-32, 50);
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    saveButton.backgroundColor = [[HTMIWFCSettingManager manager] navigationBarColor];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
    // Do any additional setup after loading the view.
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonClick:(UIButton *)btn {
    //    cc 判断文本内容是否为空
    if ([self.titleString isEqualToString:@"编辑常用意见"]) {
        if ([self.textView.text isEqualToString:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请编辑常用意见" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }else{
            BOOL myBool = [self isEmpty:self.textView.text];
            if (!myBool) {
                self.opinionBlock(self.textView.text);
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                self.textView.text = @"";
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"文本内容无效,请从新输入 !" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
            
        }
        
    } else {
        //添加常用意见
        //        cc 判断文本内容是否为空 或者 是否是“请填写常用意见”
        if ([self.textView.text isEqualToString:@"请填写意见"] || [self.textView.text isEqualToString:@""]) {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入文本内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
        }else{
            BOOL myBool = [self isEmpty:self.textView.text];
            if (!myBool) {
                self.opinionBlock(self.textView.text);
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                self.textView.text = @"";
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"文本内容无效,请从新输入 !" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    
    
}
-(Boolean) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}
- (void)PopViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请填写意见"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    } else {
        
    }
    
    self.borderView.layer.borderColor = [[HTMIWFCSettingManager manager] navigationBarColor].CGColor;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
