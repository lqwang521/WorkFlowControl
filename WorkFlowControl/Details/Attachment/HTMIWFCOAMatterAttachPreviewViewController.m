//
//  HTMIWFCOAMatterAttachPreviewViewController.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/4.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterAttachPreviewViewController.h"

#import "HTMIWFCSVProgressHUD.h"

#import "UIImage+HTMIWFCWM.h"

//定义应用屏幕宽度
#define WIDTH  [UIScreen mainScreen].bounds.size.width

//定义应用屏幕高度
#define HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface HTMIWFCOAMatterAttachPreviewViewController ()<UIWebViewDelegate>

@end

@implementation HTMIWFCOAMatterAttachPreviewViewController

#pragma mark - 生命周期

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [backBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"附件预览";
    
    
    [HTMIWFCSVProgressHUD show];
    UIWebView *attachPreview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64)];
    attachPreview.scalesPageToFit = YES;
    attachPreview.delegate = self;
    attachPreview.suppressesIncrementalRendering = YES;
    [self.view addSubview:attachPreview];

    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    [attachPreview loadRequest:[NSURLRequest requestWithURL:fileURL]];
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    // 服务器的响应对象,服务器接收到请求返回给客户端的
//    NSURLResponse *respnose = nil;
//    
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&respnose error:NULL];
//    
//    NSLog(@"%@", respnose.MIMEType);
    
    // 在iOS开发中,如果不是特殊要求,所有的文本编码都是用UTF8
    // 先用UTF8解释接收到的二进制数据流
//    [attachPreview loadData:data MIMEType:respnose.MIMEType textEncodingName:@"UTF8" baseURL:nil];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [HTMIWFCSVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [HTMIWFCSVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 事件

/**
 *  返回按钮点击事件
 */
- (void)backButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
    [HTMIWFCSVProgressHUD dismiss];
}



@end
