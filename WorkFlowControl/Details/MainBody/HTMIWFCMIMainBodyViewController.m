//
//  HTMIWFCMIMainBodyViewController.m
//  MXClient
//
//  Created by chong on 16/7/28.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCMIMainBodyViewController.h"

#import "HTMIWFCMIBodyView.h"

#import "HTMIWFCBottomBodyView.h"

//#import "MXConfig.h"

#import "HTMIWFCAFNetworking.h"

#import "HTMIWFCZipArchive.h"

#import "HTMIWFCEMWebbodyViewController.h"

#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCEMBodyZip.h"
#import "HTMIWFCApi.h"
#import "UIImage+HTMIWFCWM.h"

#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
//#import "MXCircle.h"
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

@interface HTMIWFCMIMainBodyViewController ()<HTMIWFCMIBodyViewDelegate,HTMIWFCBottomBodyViewDelegate,
UIActionSheetDelegate>
//自定义预览内容的显示
@property (nonatomic, strong)HTMIWFCMIBodyView *myBodyView;

@property (nonatomic, strong)HTMIWFCBottomBodyView *myBottomView;

@property (nonatomic, strong)NSString *objSting;

@property (nonatomic, strong)UIButton *downloadBtn;

@property (nonatomic, strong)UIImageView *downloadImg;

@property (nonatomic, strong)UIButton *shareFriend;

@property (nonatomic, strong)NSString *pathURL;

@property (nonatomic)NSInteger ByteLength;

@property (nonatomic, strong)NSString *myFileName;

@property (nonatomic, strong)NSString *Pathh;

@property (nonatomic, strong)NSString *myType;

@property (nonatomic, strong)UILabel *myTime;

@property(nonatomic,strong)UILabel *titleLable;
@end

@implementation HTMIWFCMIMainBodyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.myBodyView];
    [self.view addSubview:self.myBottomView];
    //获取正文预览内容
    [self myPreView];
    
}
#pragma mark 自定义预览View
-(HTMIWFCMIBodyView *)myBodyView{
    if (!_myBodyView) {
        if (ISFormType == 1) {
            _myBodyView = [[HTMIWFCMIBodyView alloc]initWithFrame:CGRectMake(0, 65, kScreenWidth, kScreenHeight-154)];
        }else{
            _myBodyView = [[HTMIWFCMIBodyView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight-154)];
        }
        
        _myBodyView.delegate = self;
    }
    return _myBodyView;
}
#pragma mark HTMIWFCMIBodyView 回调事件
//暂时不是点击页面刷新请求
-(void)reloadRequestView{
    [self myPreView];
}

-(HTMIWFCBottomBodyView *)myBottomView{
    if (!_myBottomView) {
        if (ISFormType == 1) {
            _myBottomView = [[HTMIWFCBottomBodyView alloc]initWithFrame:CGRectMake(0, 15, kScreenWidth, 50)];
            _myBottomView.layer.cornerRadius = 4.0;
            _myBottomView.layer.masksToBounds = YES;
        }else{
            _myBottomView = [[HTMIWFCBottomBodyView alloc]initWithFrame:CGRectMake(0, kScreenHeight-154+20, kScreenWidth, 50)];
        }
        _myBottomView.delegate = self;
    }
    return _myBottomView;
}
#pragma mark HTMIWFCBottomBodyView 底部按钮事件
//@"读取正文"@"正文下载"@"打开文件"
-(void)myBottomBodyorbutton:(NSString *)nameString{
    if ([nameString isEqualToString:@"读取正文"]) {
        self.myBodyView.myImgView.image = [UIImage getPNGImageHTMIWFC:@"img_no_messages"];
        self.myBodyView.myLabelString.text = @"努力读取中，请稍后......";
        [self myPreView];
        [self.myBottomView startAnimation];
    }else if ([nameString isEqualToString:@"正文下载"]){
        [self mybuttontitleString:@"正文下载"];
    }else if ([nameString isEqualToString:@"打开文件"]){
        [self mybuttontitleString:@"打开文件"];
    }
}
#pragma mark HTMIWFCBottomBodyView 底部分享按钮 事件
//底部按钮  分享
-(void)myBottomBodyorSharebutton:(NSString *)nameString{
    if ([nameString isEqualToString:@"分享"]) {
        
        UIActionSheet *myAction = [[UIActionSheet alloc]initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给同事",@"分享到工作圈" ,nil];
        myAction.actionSheetStyle = UIBarStyleBlackTranslucent;
        [myAction showInView:self.view];
        
    }
}
#pragma mark 获取正文预览内容
- (void)myPreView{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    NSString *AttachmentID = self.AttachmentID;
    
    NSString *path = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetWord_Text",EMUrl,EMPORT,EMapiDir];
    
    NSDictionary *params = @{@"DocId":AttachmentID,@"context":context,@"DocType":self.docType,@"Kind":@"oa"};
    [HTMIWFCSVProgressHUD show];
    [HTMIWFCApi requestUserInfoPreViewWithPath:path andParams:params succeed:^(id data) {
        
        [HTMIWFCSVProgressHUD dismiss];
        
        self.objSting = [NSString stringWithFormat:@"%@",data];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *str = [user objectForKey:self.matterID];
        //str 是在userdefault里保存的，本地存储
        if (str){
            self.myBodyView.myTextView.hidden = NO;
            self.myBodyView.myTextView.text = str;
            self.myBodyView.myImgView.hidden = YES;
            [self.myBottomView endAnimation];
            if (![self.myBottomView.mylabel1.text isEqualToString:@"打开文件"]) {
                self.myBottomView.mylabel1.text = @"正文下载";
                self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_start"];
            }
            
        }else if (!str && self.objSting.length > 0 ) {
            if (data == [NSNull null]) {
                self.myBodyView.myImgView.image = [UIImage getPNGImageHTMIWFC:@"img_lost_internet"];
                self.myBodyView.myLabelString.text = @"正文读取失败，请重试 !";
                self.myBodyView.myImgView.hidden = NO;
                self.myBodyView.myTextView.hidden = YES;
                self.myBottomView.mylabel1.text = @"读取正文";
                self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_read"];
                [self.myBottomView endAnimation];
            }else{
                
                NSString *Newobj =[data stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                NSString *NewObj1 =[Newobj stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                [user setObject:NewObj1 forKey:self.matterID];
                self.myBodyView.myTextView.text = [NSString stringWithFormat:@"%@",NewObj1];
                self.myBodyView.myTextView.hidden = NO;
                self.myBodyView.myImgView.hidden = YES;
                [self.myBottomView endAnimation];
                if (![self.myBottomView.mylabel1.text isEqualToString:@"打开文件"]) {
                    self.myBottomView.mylabel1.text = @"正文下载";
                    self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_start"];
                }
            }
        }else{
            self.myBodyView.myImgView.hidden = NO;
            self.myBodyView.myImgView.image = [UIImage getPNGImageHTMIWFC:@"img_lost_internet"];
            self.myBodyView.myLabelString.text = @"正文读取失败，请重试 !";
            self.myBodyView.myTextView.hidden = YES;
            self.myBottomView.mylabel1.text = @"读取正文";
            self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_read"];
            [self.myBottomView endAnimation];
        }
        
    } failure:^(NSError *error) {
        
        
    }];
    
    //        -------------------------------------------------------------
    NSString *path1 = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/DownFileIsFinish_DocFile",EMUrl,EMPORT,EMapiDir];
    NSDictionary *paramss = @{@"DocId":AttachmentID,@"context":context,@"DocType":self.docType,@"Kind":@"oa"};
    [HTMIWFCApi requestUserInfoZipWithPath:path1 andParams:paramss succeed:^(id data) {
        HTMIWFCEMBodyZip *bodyZip = data;
        if (bodyZip.myFielName) {
            self.myFileName = bodyZip.myFielName;
        }else
        {
            self.myFileName = @"";
        }
        if (bodyZip.myType) {
            self.myType = bodyZip.myType;
        }else
        {
            self.myType = @"";
        }
        
        if (bodyZip.myModifiedTime) {
            self.myTime.text = [NSString stringWithFormat:@"%@",bodyZip.myModifiedTime];
        }else
        {
            self.myTime.text = @"";
        }
        if (bodyZip.myFielName) {
            self.titleLable.text = [NSString stringWithFormat:@"%@",bodyZip.myFielName];
        }else
        {
            self.titleLable.text = @"";
        }
        if (bodyZip.myByteLength) {
            self.ByteLength = bodyZip.myByteLength;
            HTLog(@"%d",bodyZip.myByteLength);
        }else
        {
            self.ByteLength = 0;
        }
        if (bodyZip.myDownloadURL) {
            self.pathURL = bodyZip.myDownloadURL;
        }else
        {
            self.pathURL = @"";
        }
        
        NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
        //如果self.pathURL 不是空  那就进方法  反之不进
        if (![self.pathURL isEqual:[NSNull null]]) {
            self.Pathh = [users objectForKey:self.pathURL];
            
            HTLog(@"%@",self.Pathh);
            
            if (self.Pathh) {
                if (![self.myBottomView.mylabel1.text isEqualToString:@"读取正文"]) {
                    [self.myBottomView endAnimation];
                    self.myBottomView.mylabel1.text = @"打开文件";
                    self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_look_file"];
                }
                
                [self.myBottomView.progressGradientView setProgress:1.0];
                //                    [self.downloadBtn setTitle:@"打开文件" forState:UIControlStateNormal];
            }else
            {
                if (![self.myBottomView.mylabel1.text isEqualToString:@"读取正文"]) {
                    [self.myBottomView endAnimation];
                    self.myBottomView.mylabel1.text = @"正文下载";
                    self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_start"];
                }
                //                    [self.downloadBtn setTitle:@"正文下载" forState:UIControlStateNormal];
            }
        }
    } failure:^(NSError *error) {
        
        
    }];
    
}


- (void)mybuttontitleString:(NSString *)nameString{
    
    if ([nameString isEqualToString:@"正文下载"]) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask,
                                                                      YES) firstObject];
        
        
        //文件保存路径
        NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/%d.zip",documentPath,self.ByteLength];
        HTLog(@"%@",documentsDirectoryPath);
        
        //创建存储目录,可以提前判断该路径是否存在下载文件！
        [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        //创建请求,下载文件
        NSString *urlStr = [NSString stringWithFormat:@"%@",self.pathURL];
        HTLog(@"%@",self.pathURL);
        NSURL *url = [[NSURL alloc]initWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        HTMIWFCAFHTTPRequestOperation *operation = [[HTMIWFCAFHTTPRequestOperation alloc]initWithRequest:request];
        
        [HTMIWFCApi downloadFileNeedShowProgress:operation url:url documentsDirectoryPath:documentsDirectoryPath succeed:^(id operation) {
            
            HTLog(@"下载成功");
            
            
            NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
            [users setObject:documentsDirectoryPath forKey:self.pathURL];
            [users synchronize];
            HTLog(@"%@",documentsDirectoryPath);
            self.myBottomView.mylabel1.text = @"打开文件";
            self.myBottomView.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_look_file"];
            
            //下载之后并且开始解压  有密码传入密码
            HTMIWFCZipArchive *htmiWFCZipArchive =  [[HTMIWFCZipArchive alloc]init];
            if ([htmiWFCZipArchive UnzipOpenFile:documentsDirectoryPath Password:@"password"]) {
                if ([htmiWFCZipArchive UnzipFileTo:documentPath overWrite:YES]) {
                    //self.pathPath = [HTMIWFCZipArchive.UnzipCloseFile fir]
                    HTLog(@"解压完成");
                }
            }
            // 下载成功后，如需添加操作，在此处进行
        } failure:^(NSError *error) {
            
        }];
        //    显示进度
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            HTLog(@"bytesRead = %ld, totalBytesRead = %lld, totalBytesExpectedToRead = %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
            double a = totalBytesRead;
            double b = totalBytesExpectedToRead;
            double c = a/b;
            [self.myBottomView.progressGradientView setProgress:c];
        }];
    }else if ([nameString isEqualToString:@"打开文件"]){
        //判断按钮文字是打开文件   并跳转页面
        HTMIWFCEMWebbodyViewController *webBody = [[HTMIWFCEMWebbodyViewController alloc]init];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:webBody];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask,
                                                                      YES) firstObject];
        NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/%@",documentPath,self.myFileName];
        
        HTLog(@"%@",documentsDirectoryPath);
        
        if (documentsDirectoryPath.length > 0) {
            webBody.documentPath = documentsDirectoryPath;
        }else
        {
            webBody.documentPath = self.Pathh;
        }
        
        HTLog(@"%@",webBody.documentPath);
        [self presentViewController:navi animated:YES completion:nil];
        
        HTLog(@"正在打开...");
    }
}
//
#pragma mark 分享正文
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    NSString *str1 = [context objectForKey:@"UserID"];
    NSString *str2 = [context objectForKey:@"OA_UserId"];
    NSString *str3 = [context objectForKey:@"OA_UserName"];
    NSString *str4 = [context objectForKey:@"ThirdDepartmentId"];
    NSString *str5 = [context objectForKey:@"ThirdDepartmentName"];
    NSString *str6 = [context objectForKey:@"attribute1"];
    NSString *str7 = [context objectForKey:@"OA_UnitId"];
    
    if (!self.urlPNG) {
        self.urlPNG = @"http://img1.gtimg.com/13/1301/130137/13013760_980x1200_0.jpg";
    }
    
    if (buttonIndex == 0){
        NSString *str = [NSString stringWithFormat:@"cc%@|%d|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",self.pathURL,self.ByteLength,self.myFileName,str1,str2,str3,self.matterID,self.kind,self.docType,str4,str5,str6,str7];
        
#ifdef WorkFlowControl_Enable_MX
//        [[MXChat sharedInstance]shareTitle:@"分享正文" withDescription:self.docTitle withURL:nil withNativeURL:str withThumbnailURL:self.urlPNG withViewController:self];
#endif
        
        
    }else if (buttonIndex == 1){
        NSString *str = [NSString stringWithFormat:@"dd%@|%d|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",self.pathURL,self.ByteLength,self.myFileName,str1,str2,str3,self.matterID,self.kind,self.docType,str4,str5,str6,str7];
        NSString *myTitle = [NSString stringWithFormat:@"分享正文:%@",self.docTitle];
        
#ifdef WorkFlowControl_Enable_MX
//        [[MXCircle sharedInstance]shareTitle:myTitle withDescription:@"" withURL:nil withNativeURL:str withThumbnailURL:self.urlPNG withViewController:self];
#endif
    }
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
