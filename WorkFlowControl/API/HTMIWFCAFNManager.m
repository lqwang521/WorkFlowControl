
#import "HTMIWFCAFNManager.h"


#import "HTMIWFCAFNetworking.h"
#import <Availability.h>

//#import "MBProgressHUD+Add.h"


@interface HTMIWFCAFNManager()
{
    HTMIWFCAFHTTPRequestOperation *operation; //创建请求管理（用于上传和下载）
}
@end

static HTMIWFCAFNManager *manager = nil;

@implementation HTMIWFCAFNManager

- (HTMIWFCAFHTTPRequestOperationManager *)baseHtppRequest{
    // 开启转圈圈
    //[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // 创建请求管理者
    HTMIWFCAFHTTPRequestOperationManager *manager = [HTMIWFCAFHTTPRequestOperationManager manager];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 3;
    
    manager.requestSerializer = [HTMIWFCAFJSONRequestSerializer serializer];//声明请求的数据是json类型
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.0f;//设置请求超时时间
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    //[manager.requestSerializer setTimeoutInterval:5.0f];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"text/xml",
                                                         @"text/plain",
                                                         @"image/*",nil];//声明返回的结果是json类型
    
    return manager;
}

+ (HTMIWFCAFNManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            
            manager = [super allocWithZone:zone];
        }
    });
    return manager;
}

- (void)GET:(NSString *)URLString parameters:(id)parameters
{
    // 创建请求管理者
    HTMIWFCAFHTTPRequestOperationManager *mgr = [HTMIWFCAFHTTPRequestOperationManager manager];
    
    
    
    [mgr GET:URLString parameters:parameters success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidSuccess:)]) {
            
            [self.delegate AFNManagerDidSuccess:responseObject];
        }
        
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidFaild:)]) {
            
            [self.delegate AFNManagerDidFaild:error];
        }
    }];
}

- (void)Post:(NSString *)URLString parameters:(id)parameters
{
    // 创建请求管理者
    HTMIWFCAFHTTPRequestOperationManager *mgr = [HTMIWFCAFHTTPRequestOperationManager manager];
    
    [mgr POST:URLString parameters:parameters success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidSuccess:)]) {
            
            [self.delegate AFNManagerDidSuccess:responseObject];
        }
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidFaild:)]) {
            
            [self.delegate AFNManagerDidFaild:error];
        }
    }];
}

- (void)Upload:(NSString *)URLString parameters:(id)parameters uploadParam:(HTMIWFCUploadParam *)uploadParam
{
    // 创建请求管理者
    HTMIWFCAFHTTPRequestOperationManager *mgr = [HTMIWFCAFHTTPRequestOperationManager manager];
    
    [mgr POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { // 上传的文件全部拼接到formData
        
        /**
         *  FileData:要上传的文件的二进制数据
         *  name:上传参数名称
         *  fileName：上传到服务器的文件名称
         *  mimeType：文件类型
         */
        [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];
        
    } success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidSuccess:)]) {
            
            [self.delegate AFNManagerDidSuccess:responseObject];
        }
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidFaild:)]) {
            
            [self.delegate AFNManagerDidFaild:error];
        }
    }];
    
}

#pragma mark - block形式的请求方法

//wlq add 2016/04/14
/**
 *  Get请求（block形式）
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param succeed    成功
 *  @param failure    失败
 */
- (HTMIWFCAFHTTPRequestOperationManager *)Get:(NSString *)URLString parameters:(id)parameters succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure
{
    HTMIWFCAFHTTPRequestOperationManager * mgr = [self baseHtppRequest];
    //先检查网络再进行请求
    
    if([HTMIWFCAFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        
        //[MBProgressHUD showError:@"当前没有网络，请检查网络设置" toView:nil];
        
        return mgr;
    }
    
    
    [mgr GET:URLString parameters:parameters success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        
        succeed(responseObject);
        
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        
        //        if (error.code == -1001) {//请求超时
        //
        //        }
        //        else{
        //            [self handleError:error];
        //        }
        
        failure(error);
    }];
    
    return mgr;
}

/**
 *  Post请求（block形式）
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param succeed    成功
 *  @param failure    失败
 */
- (HTMIWFCAFHTTPRequestOperationManager *)Post:(NSString *)URLString parameters:(id)parameters succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure
{
    HTMIWFCAFHTTPRequestOperationManager * mgr = [self baseHtppRequest];
    
    //先检查网络再进行请求
    if([HTMIWFCAFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        
        //[MBProgressHUD showError:@"当前没有网络，请检查网络设置" toView:nil];
        
        return mgr;
    }
    
    [mgr POST:URLString parameters:parameters success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        
        succeed(responseObject);
        //HTLogDetail(@"response:%@",responseObject);
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        
        
        //        if (error.code == -1001) {//请求超时
        //
        //        }
        //        else{
        //            [self handleError:error];
        //        }
        
        failure(error);
    }];
    
    return mgr;
}

#pragma mark - 文件上传

//文件上传
- (void)Upload:(NSString *)URLString parameters:(id)parameters uploadParam:(HTMIWFCUploadParam *)uploadParam succeed:(void (^)(id))succeed failure:(void (^)(NSError *))failure
{
    /*
     // 创建请求管理者
     HTMIWFCAFHTTPRequestOperationManager *mgr = [HTMIWFCAFHTTPRequestOperationManager manager];
     
     [mgr POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { // 上传的文件全部拼接到formData
     
     
     *  FileData:要上传的文件的二进制数据
     *  name:上传参数名称
     *  fileName：上传到服务器的文件名称
     *  mimeType：文件类型
     
     [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];
     
     
     } success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
     if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidSuccess:)]) {
     
     succeed(responseObject);
     }
     
     } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
     if (self.delegate && [self.delegate respondsToSelector:@selector(AFNManagerDidFaild:)]) {
     
     failure(error);
     }
     }];
     */
    
    HTMIWFCAFHTTPRequestOperationManager *mgr = [HTMIWFCAFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                     @"text/html",
                                                     @"text/json",
                                                     @"text/javascript",
                                                     @"text/plain",@"application/xml", nil];
    
    NSString * strImageUploadpath = [NSString stringWithFormat:@"%@uploadFile",URLString];
    [mgr POST:strImageUploadpath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        //name 的参数是@"file"
        [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];//@"image/jpeg"
        
    } success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        succeed(responseObject);
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error];
        failure(error);
    }];
    
}

- (void)downloadStartWithUrl:(NSString *)URLString fileName:(NSString *)fileName
{
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(), fileName];
    
    operation = [[HTMIWFCAFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    //    可以在此设置进度条
    //    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    //
    //    }];
    __weak typeof(self) weakself = self;
    [operation setCompletionBlockWithSuccess:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        //        请求成功做出提示
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(AFNManagerDidSuccess:)]) {
            
            [weakself.delegate AFNManagerDidSuccess:responseObject];
        }
        
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        //        请求失败做出提示
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(AFNManagerDidFaild:)]) {
            
            [weakself.delegate AFNManagerDidFaild:error];
        }
    }];
    
    [operation start];
}

- (void)uploadStartWithUrl:(NSString *)URLString fileData:(NSData *)fileData
{
    operation = [[HTMIWFCAFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
    
    operation.inputStream = [[NSInputStream alloc] initWithData:fileData];
    
    //    设置进度条
    //    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    //
    //    }];
    __weak typeof(self) weakself = self;
    [operation setCompletionBlockWithSuccess:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
        //        请求成功做出提示
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(AFNManagerDidSuccess:)]) {
            
            [weakself.delegate AFNManagerDidSuccess:responseObject];
        }
        
        
    } failure:^(HTMIWFCAFHTTPRequestOperation *operation, NSError *error) {
        //        请求失败做出提示
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(AFNManagerDidFaild:)]) {
            
            [weakself.delegate AFNManagerDidFaild:error];
        }
    }];
    
    [operation start];
}

- (void)operationPause
{
    [operation pause];
}

- (void)operationResume
{
    [operation resume];
}

- (void)operationCancel
{
    [operation cancel];
}

//（用于检测网络是否可以链接。此方法最好放于AppDelegate中，可以使程序打开便开始检测网络）
/**
 *  网络监听
 */
- (void)reachabilityManager
{
    HTMIWFCAFHTTPRequestOperationManager *mgr = [HTMIWFCAFHTTPRequestOperationManager manager];
    //打开网络监听
    [mgr.reachabilityManager startMonitoring];
    
    //监听网络变化
    [mgr.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                
                //当网络不可用（无网络或请求延时）
            case AFNetworkReachabilityStatusNotReachable:
                
                //[MBProgressHUD showError:@"当前没有网络，请检查网络设置" toView:nil];
                
                break;
                
                //当为手机WiFi时
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                //发出网络变化通知
                break;
                
                //当为手机蜂窝数据网
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //发出网络变化通知
                
                break;
                
                //其它情况
            default:
                break;
        }
    }];
    
    //    //停止网络监听（若需要一直检测网络状态，可以不停止，使其一直运行）
    //    [mgr.reachabilityManager stopMonitoring];
}

#pragma mark Error

- (void)handleError:(NSError *)error
{
    
    NSString *urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    
    if (([error.domain isEqualToString:@"WebKitErrorDomain"] && 101 == error.code) ||
        ([error.domain isEqualToString:NSURLErrorDomain] && (NSURLErrorBadURL == error.code || NSURLErrorUnsupportedURL == error.code))) {
        
        [self showAlertInOneSecond:@"网址无效"];
        
    }else if ([error.domain isEqualToString:NSURLErrorDomain] && (NSURLErrorTimedOut == error.code ||
                                                                  NSURLErrorCannotFindHost == error.code ||
                                                                  NSURLErrorCannotConnectToHost == error.code ||
                                                                  NSURLErrorNetworkConnectionLost == error.code ||
                                                                  NSURLErrorDNSLookupFailed == error.code ||
                                                                  NSURLErrorNotConnectedToInternet == error.code)) {
        
        [NSTimer scheduledTimerWithTimeInterval:0.5f
                                         target:self
                                       selector:@selector(delayShowErrorInfo:)
                                       userInfo:@"网络连接异常，请检查网络设置"
                                        repeats:NO];
        
        
    }else if ([error.domain isEqualToString:@"WebKitErrorDomain"] && 102 == error.code){
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            
            //            [self showAlert:@"无法打开连接" message:urlString];
            //            [MBProgressHUD showError:urlString toView:nil];
            
            [self showAlertInOneSecond:urlString];
            
        }
    }else if (error.code == -999){
        
        [NSTimer scheduledTimerWithTimeInterval:0.5f
                                         target:self
                                       selector:@selector(delayShowErrorInfo:)
                                       userInfo:@"加载中断"
                                        repeats:NO];
    }else{
        
        if([HTMIWFCAFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            
            //#ifdef DEBUG
            //
            //            [self showAlert:@"当前没有网络，请检查网络设置" message:urlString];
            //
            //
            //#else
            
            //            [MBProgressHUD showError:@"当前没有网络，请检查网络设置" toView:nil];
            [self showAlertInOneSecond:@"当前没有网络，请检查网络设置"];
            
            //#endif
        }
        else{
            
            NSString *tips = [NSString stringWithFormat:@"%@\n%@", urlString, [error.userInfo objectForKey:@"NSLocalizedDescription"]? [error.userInfo objectForKey:@"NSLocalizedDescription"]: error.description];
            
            //            [MBProgressHUD showError:tips toView:nil];
            
            [self showAlertInOneSecond:tips];
        }
    }
}

- (void)showAlertInOneSecond:(NSString *)message{//时间
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:NO];
    [promptAlert show];
}

- (void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert = NULL;
    theTimer = nil;
}

- (void)delayShowErrorInfo:(NSTimer*)theTimer{
    
    NSString *errorString = (NSString*)[theTimer userInfo];
    
    //[MBProgressHUD showError:errorString toView:nil];
    theTimer = nil;
}



@end
