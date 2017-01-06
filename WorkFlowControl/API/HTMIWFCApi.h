//
//  EMApi.h
//  MXClient
//
//  Created by HTRF on 15/6/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class HTMIABCSYS_UserModel;

@class HTMIWFCAFHTTPRequestOperation;

//志国的

//typedef void(^OAAttachDownloadBlock) (NSString *zipLocalPath);

@interface HTMIWFCApi : NSObject

#pragma mark - 朱冲冲负责的接口

//正文预览内容
+ (void)requestUserInfoPreViewWithPath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//正文下载Zip
//+ (void)requestUserInfoZipWithDocID:(NSDictionary *)docID andContext:(NSDictionary *)context andCallback:(SucceedBlock)callback;
+ (void)requestUserInfoZipWithPath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//获取应用列表
+ (void)requestAccessToaApplications:(NSString *)path succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//保存应用信息
+ (void)requestSaveAppInfoWithPath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//流程最后一条数据
+ (void)requestMyMatterLastFlowWithContext:(NSDictionary*)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//获取首页资源
+ (void)requesttestHomepage:(NSString *)path succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//资料库
+ (void)requestFilePath:(NSString *)path succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//子层目录
+ (void)requestDataBasePath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//子层文件
+ (void)requestDataBaseFilePath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//检查版本信息
+ (void)startVersionCheck:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


//待办请求数量
+ (void)myrequestUserInfounReadCountWithPath:(NSString *)path andmyParameter:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

#pragma mark - 王立权负责的接口

/**
 *  同步数据库
 *
 *  @param path     路径
 *  @param params   参数
 */
+ (void)syncAddressBook:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;
/**
 *  添加常用联系人
 *
 *  @param params 参数
 */
+ (void)AddTopContact:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

/**
 *  删除常用联系人
 *
 *  @param params 参数
 */
+ (void)RemoveTopContact:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


/**
 *  更新用户信息
 *
 *  @param params 参数
 */
+ (void)updateUserInfo:(HTMIABCSYS_UserModel *)sys_UserModel succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


+ (void)downloadFile:(NSURLRequest *)request url:(NSURL *)url documentsDirectoryPath:(NSString *)documentsDirectoryPath succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

+ (void)downloadFileNeedShowProgress:(HTMIWFCAFHTTPRequestOperation *)operation url:(NSURL *)url documentsDirectoryPath:(NSString *)documentsDirectoryPath succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

#pragma mark - 赵志国负责的接口

+ (void)submitMatterWithContext:(NSDictionary *)context
                       matterID:(NSString *)matterID
                        docType:(NSString *)docType
                           kind:(NSString *)kind
                         flowID:(NSString *)flowID
                       flowName:(NSString *)flowName
                      operation:(NSString *)operationType
                        Comment:(NSString *)comment
                    commentList:(NSString *)commentList
                      routeList:(NSString *)routIDs
                   employeeList:(NSString *)employeeIDs
                  currentNodeID:(NSString *)currentNodeID
                 currentTrackID:(NSString *)currentTrackID
                  eidtFieldList:(NSArray *)eidtFieldList
                        succeed:(void (^)(id data))succeed
                        failure:(void (^)(NSError *error))failure;

+ (void)loginWithUserID:(NSString *)userID andPassword:(NSString *)password succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;




//待办
+ (void)requestMatterFormWithTodoFlag:(NSString *)todo andRecordStartIndex:(NSString *)recordStartIndex andRecordEndIndex:(NSString *)recordEndIndex andContext:(NSDictionary *)context andModelName:(NSString *)modelName title:title succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


//已办
+ (void)requestDoneWithDoneFlag:(NSString *)done andRecordStartIndex:(NSString *)recordStartIndex andRecordEndIndex:(NSString *)recordEndIndex andContext:(NSDictionary *)context succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//wlq delete
//表单
//+ (void)requestMyMatterFormWithDocID:(NSString *)docID andContext:(NSDictionary*)context andblock:(OAMatterFormHTTPLogic)block;
+ (void)requestMyMatterFormWithContext:(NSDictionary*)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//附件
+ (void)requestMatterAttachWithContext:(NSDictionary*)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//流程
+ (void)requestMatterFlowListWithContext:(NSDictionary *)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKInd:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//正文
+ (void)requestMainBodyWithContext:(NSDictionary *)context isFlowid:(BOOL)isFlowid andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//我的发起
+ (void)requestMyStartWithContext:(NSDictionary *)context startIndex:(NSString *)startIndex endIndex:(NSString *)endIndex modelName:(NSString *)modelName title:(NSString *)title succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//我的关注
+ (void)requestMyAttentionWithContext:(NSDictionary *)context startIndex:(NSString *)startIndex endIndex:(NSString *)endIndex modelName:(NSString *)modelName title:(NSString *)title succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//关注/取消关注
+ (void)attentOrDisAttentWithContext:(NSDictionary *)context docID:(NSString *)docID attentionFlag:(NSString *)attentionFlag allowPush:(NSString *)allowPush docTitle:(NSString *)docTitle docType:(NSString *)docType sendFrom:(NSString *)sendFrom sendDate:(NSString *)sendDate iconID:(NSString *)iconID kind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//wlq delete
////下载附件
+ (void)downloadFileWithAttachID:(NSString *)attachID
                   andAttachName:(NSString *)attachName
                      andContext:(NSDictionary *)context andKind:(NSString *)kind
                           succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//下载zip
+ (NSURLSessionDownloadTask *)downloadZipFilePathWithDownloadURL:(NSString *)downloadUrl andSavePath:(NSString *)savePath  progress:(NSProgress **)progress succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//wlq delete
//请假
+ (void)requestMyLeaveMatterFormWithContext:(NSDictionary*)context andFlowID:(NSString *)FlowID succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//请假其他
+ (void)requestMyLeaveWithContext:(NSDictionary *)context andFlowID:(NSString *)FlowID succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//+ (void)getAllUsersAndBlock:(NSDictionary *)param succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//修改密码
+ (void)changePasswordByUserName:(NSString *)userName oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//获取常用意见
+ (void)getCommonOpinionsByUserName:(NSString *)userName succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

//新增常用意见
+(void)addCommonOpinionWithContext:(NSDictionary *)context idString:(NSString *)idString valueString:(NSString *)valueString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


//修改常用意见
+(void)changeCommonOpinionWithContext:(NSDictionary *)context idString:(NSString *)idString valueString:(NSString *)valueString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;


//删除常用意见
+(void)removeCommonOpinionWithContext:(NSDictionary *)context idString:(NSString *)idString valueString:(NSString *)valueString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;

#pragma mark - 显示错误信息
+ (void)showErrorStringWithError:(NSString *)string error:(NSError *)error onView:(UIView *)view;

@end
