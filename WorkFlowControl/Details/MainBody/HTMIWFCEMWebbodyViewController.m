//
//  HTMIWFCEMWebbodyViewController.m
//  MXClient
//
//  Created by HTRF on 15/7/3.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//
//定义应用屏幕宽度
#define WIDTH [UIScreen mainScreen].bounds.size.width

//定义应用屏幕高度
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#import "HTMIWFCEMWebbodyViewController.h"
//#import "MXConst.h"
#import "HTMIWFCZipArchive.h"
#import "UIImage+HTMIWFCWM.h"

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


@interface HTMIWFCEMWebbodyViewController ()

@end

@implementation HTMIWFCEMWebbodyViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 私有方法

- (void)initUI{
    
    if (!self.sharePush) {
        
        //wlq update 2016/05/11 适配风格
        [self customNavigationController:NO title:@"文件内容"];
        
        UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnLeft.backgroundColor = [UIColor redColor];
        UIImageView * imgFanHui = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        imgFanHui.image = [UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone"];//ym_btn_back
        [btnLeft addSubview:imgFanHui];
        btnLeft.backgroundColor = [UIColor clearColor];
        btnLeft.frame = CGRectMake(0, 0, 44, 44);//CGRectMake(10, 10, 30, 30);
        [btnLeft addTarget:self action:@selector(myBtnn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:btnLeft];
        self.navigationItem.leftBarButtonItem = back;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(10, 10, 30, 30);
        
        NSString *str = [NSString stringWithFormat:@"%@",self.documentPath];
        HTLog(@"%@",self.documentPath);
        NSURL *fileURL = [NSURL fileURLWithPath:str];
        UIWebView *myBody = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [myBody loadRequest:[NSURLRequest requestWithURL:fileURL]];
        myBody.scalesPageToFit = YES;
        [self.view addSubview:myBody];
        
    }else{
        self.title = @"分享正文";
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        //文件保存路径
        NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/%@.zip",documentPath,self.fileNameZIP];
        HTLog(@"%@",documentsDirectoryPath);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isHave = [fileManager fileExistsAtPath:documentsDirectoryPath];
        
        if (!isHave) {
            //创建存储目录,可以提前判断该路径是否存在下载文件！
            [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
            //创建请求,下载文件
            
            NSURL *url = [[NSURL alloc]initWithString:self.downloadURL];
            HTLog(@"%@",self.downloadURL);
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            [HTMIWFCApi downloadFile:request url:url documentsDirectoryPath:documentsDirectoryPath succeed:^(id operation) {
                
                HTLog(@"下载成功");
                
                NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
                [users setObject:documentsDirectoryPath forKey:self.downloadURL];
                [users synchronize];
                HTLog(@"%@",documentsDirectoryPath);
                
                
                //下载之后并且开始解压  有密码传入密码
                HTMIWFCZipArchive *htmiwfcZipArchive = [[HTMIWFCZipArchive alloc]init];
                
                if ([htmiwfcZipArchive UnzipOpenFile:documentsDirectoryPath Password:@"password"]) {
                    if ([htmiwfcZipArchive UnzipFileTo:documentPath overWrite:YES]) {
                        //self.pathPath = [HTMIWFCZipArchive.UnzipCloseFile fir]
                        HTLog(@"解压完成");
                        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                      NSUserDomainMask,
                                                                                      YES) firstObject];
                        NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/%@",documentPath,self.fileName];
                        NSString *str = [NSString stringWithFormat:@"%@",documentsDirectoryPath];
                        NSURL *fileURL = [NSURL fileURLWithPath:str];
                        UIWebView *myBody = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
                        [myBody loadRequest:[NSURLRequest requestWithURL:fileURL]];
                        
                        myBody.scalesPageToFit = YES;
                        [self.view addSubview:myBody];
                        
                    }
                }
                
            } failure:^(NSError *error) {
//                HTLogDetail(@"%@%@",kErrorString,@"文件下载失败");
            }];
            
        }else
        {
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                          NSUserDomainMask,
                                                                          YES) firstObject];
            NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/%@",documentPath,self.fileName];
            NSString *str = [NSString stringWithFormat:@"%@",documentsDirectoryPath];
            NSURL *fileURL = [NSURL fileURLWithPath:str];
            UIWebView *myBody = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
            [myBody loadRequest:[NSURLRequest requestWithURL:fileURL]];
            
            myBody.scalesPageToFit = YES;
            [self.view addSubview:myBody]; 
            
        }
    }
}

- (void)myBtnn:(UIButton *)sender{
    HTLog(@"回去了");
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
