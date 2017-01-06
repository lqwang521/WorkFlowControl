
#import <Foundation/Foundation.h>

#import "HTMIWFCAFNManagerDelegate.h"

#import "HTMIWFCUploadParam.h"

@class HTMIWFCAFHTTPRequestOperationManager;

@interface HTMIWFCAFNManager : NSObject

@property (nonatomic, weak) id<HTMIWFCAFNManagerDelegate> delegate;

/**
 *  AFNManager单利
 */
+(HTMIWFCAFNManager *)sharedManager;

#pragma mark --代理的方式传值
/**
 *  get
 */
- (void)GET:(NSString *)URLString parameters:(id)parameters;

/**
 *  post
 */
- (void)Post:(NSString *)URLString parameters:(id)parameters;

/**
 *  upload
 */
- (void)Upload:(NSString *)URLString parameters:(id)parameters uploadParam:(HTMIWFCUploadParam *)uploadParam;

#pragma mark --block的形式传值

/**
 *  get请求
 */
- (HTMIWFCAFHTTPRequestOperationManager *)Get:(NSString *)URLString parameters:(id)parameters succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

/**
 *  post请求
 */
- (HTMIWFCAFHTTPRequestOperationManager *)Post:(NSString *)URLString parameters:(id)parameters succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

/**
 *  upload
 */
- (void)Upload:(NSString *)URLString parameters:(id)parameters uploadParam:(HTMIWFCUploadParam *)uploadParam succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


#pragma mark --断点续传

/**
 *  开始下载  断点续传
 *
 *  @param URLString 请求接口
 */
- (void)downloadStartWithUrl:(NSString *)URLString fileName:(NSString *)fileName;

/**
 *  开始上传  断点续传
 *
 *  @param URLString 请求接口
 */
- (void)uploadStartWithUrl:(NSString *)URLString fileData:(NSData *)fileData;

/**
 *  暂停操作  断点续传
 */
- (void)operationPause;

/**
 *  继续操作  断点续传
 */
- (void)operationResume;

/**
 *  取消操作
 */
- (void)operationCancel;

//（用于检测网络是否可以链接。此方法最好放于AppDelegate中，可以使程序打开便开始检测网络）
/**
 *  网络监听
 */
- (void)reachabilityManager;

@end
