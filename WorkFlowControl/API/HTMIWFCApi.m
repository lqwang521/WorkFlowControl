//
//  EMApi.m
//  MXClient
//
//  Created by HTRF on 15/6/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCAFNManager.h"

#import "HTMIWFCApi.h"
//#import <MXConfig.h>
#import "HTMIWFCAFNetworking.h"
#import "HTMIWFCEMJsonParser.h"
//#import "HTMIWFCEGOImageButton.h"
//#import "HTMIWFCOADataBase.h"
#import "HTMIWFCOAUser.h"
#import "HTMIWFCOAMatterInfo.h"
#import "HTMIWFCOAInfoRegion.h"
#import "HTMIWFCOAMatterFormFieldItem.h"
#import "HTMIWFCOAAttachEntity.h"
#import "HTMIWFCOAMatterFlowListService.h"
#import "HTMIWFCOAMainBodyEntity.h"
#import "HTMIWFCOAMainBodyService.h"
#import "HTMIWFCOADoneEntity.h"
#import "HTMIWFCOADoneService.h"
#import "HTMIWFCOAAttachmentService.h"
#import "HTMIWFCOAAttachmentListEntity.h"
#import "HTMIWFCOAOperationDataEntity.h"

//#import "JSONKit.h"

//#import "Reachability.h"

#import "HTMIWFCSVProgressHUD.h"

//model
//#import "HTMIABCSYS_UserModel.h"

#ifdef DEBUG

#define HTLog(...) NSLog(__VA_ARGS__)

#define HTLogDetail(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define HTLog(...)

#define HTLogDetail(fmt, ...)

#endif

//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

@implementation HTMIWFCApi


#pragma mark - 朱冲冲负责的接口

//正文预览内容
+ (void)requestUserInfoPreViewWithPath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Post:path parameters:params succeed:^(id data) {
        
        //返回来的直接就是json转好的对象
        NSDictionary *resultDic = data;//[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSString *str = [resultDic objectForKey:@"Result"];
        succeed(str);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)requestUserInfoZipWithPath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Post:path parameters:params succeed:^(id data) {
        
        NSDictionary *dic = data;
        NSDictionary *dic1 = [dic objectForKey:@"Result"];
        NSDictionary *dic2 = [dic1 objectForKey:@"DocFileInfoResult"];
        HTMIWFCEMBodyZip *myZip = [HTMIWFCEMJsonParser paseZipByDictionart:dic2];
        succeed(myZip);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//获取应用列表
+ (void)requestAccessToaApplications:(NSString *)path succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Get:path parameters:nil succeed:^(id data) {
        
        NSDictionary *dic = data;
        if ([dic objectForKey:@"Result"] && [dic objectForKey:@"Result"] != [NSNull null]) {
            HTLog(@"%@",[dic objectForKey:@"Result"]);
            NSData *originData = [[NSData alloc]initWithBase64EncodedString:[dic objectForKey:@"Result"] options:0];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:originData options:0 error:nil];
            
            NSString *str = [[NSString alloc]initWithData:originData encoding:NSUTF8StringEncoding];
            
            HTLog(@"%@",str);
            HTLog(@"%@",dic);
            //        HTLog(@"%@",originData);
            HTLog(@"%@",arr);
            succeed (arr);
        }else {
            succeed (nil);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//保存应用信息
+ (void)requestSaveAppInfoWithPath:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Post:path parameters:params succeed:^(id data) {
        
        NSString *str = @"保存成功";
        succeed(str);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//流程最后一条数据
+ (void)requestMyMatterLastFlowWithContext:(NSDictionary*)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDocInfo",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"DocId":matterID,@"DocType":docType,@"Kind":kind};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        //        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSDictionary *dic1 = [data objectForKey:@"Result"];
        
        succeed(dic1);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//获取首页资源
+ (void)requesttestHomepage:(NSString *)path succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Get:path parameters:nil succeed:^(id data) {
        
        
        NSDictionary *dic = data;//[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        HTLog(@"%@",dic);
        NSData *originData = [[NSData alloc]initWithBase64EncodedString:[dic objectForKey:@"Result"] options:0];
        //        NSString *str = [[NSString alloc]initWithData:originData encoding:NSUTF8StringEncoding];
        //        HTLog(@"%@",str);
        NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:originData options:0 error:nil];
        succeed(dic1);
        
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//检查版本信息
+ (void)startVersionCheck:(NSString *)path andParams:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Get:path parameters:params succeed:^(id data) {
        
        succeed(data);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)myrequestUserInfounReadCountWithPath:(NSString *)path andmyParameter:(NSDictionary *)params succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure{
    
    [[HTMIWFCAFNManager sharedManager] Post:path parameters:params succeed:^(id data) {
        
        NSDictionary *dic = data;//[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString *unreadCount = [dic objectForKey:@"Result"];
        
        succeed(unreadCount);
        
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma mark - 赵志国负责的接口

//提交
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
                        failure:(void (^)(NSError *error))failure
{
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/DoAction",EMUrl,EMPORT,EMapiDir];
    
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    
    NSDictionary *parameter = @{@"context":(context ? context : @""),@"DocId":(matterID ? matterID : @""),@"FlowId":(flowID ? flowID : @""),@"FlowName":(flowName ? flowName : @""),@"CurrentNodeid":(currentNodeID ? currentNodeID : @""),@"CurrentTrackid":(currentTrackID ? currentTrackID : @""),@"ActionName":operationType?operationType:@"",@"NextNodeId":(routIDs ? routIDs : @""),@"SelectAuthorID":(employeeIDs ? employeeIDs : @""),@"Comments":(comment ? comment : @""),@"CommentFieldName":@"",@"EditFields":(eidtFieldList ? eidtFieldList : @""),@"DocType":(docType ? docType : @""),@"Kind":kind};
    
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        succeed(data);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//登录
+ (void)loginWithUserID:(NSString *)userID andPassword:(NSString *)password  succeed:(void (^)(id data))succeed
                failure:(void (^)(NSError *error))failure
{
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/AppPortLogin/login",EMUrl,EMPORT,EMapiDir];
    HTLog(@"登录接口地址%@",urlPath);
    
    NSDictionary *parameter = @{@"LoginName":userID,@"PassWord":password,@"DeviceId":@"12345679989",@"DeviceType":@3,@"SoftWareCode":EMSoftWare,@"Tel":@"13146542574",@"Email":@"ycm@htmitech.com",@"DepartmentCode":@"100138001001",@"DepartmentName":@"OA",@"ChildAccount":@"1",@"ChildPassword":@"1"};
    HTLog(@"登录接口参数%@",parameter);
    
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        succeed(data);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}


#pragma mark - 待办

+ (void)requestMatterFormWithTodoFlag:(NSString *)todo andRecordStartIndex:(NSString *)recordStartIndex andRecordEndIndex:(NSString *)recordEndIndex andContext:(NSDictionary *)context andModelName:(NSString *)modelName title:title succeed:(void (^)(id data))succeed
                              failure:(void (^)(NSError *error))failure//搜索
{
    //接口地址
  
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDbYbList",EMUrl,EMPORT,EMapiDir];
    if (modelName == nil) {
        modelName = @"";
    }
 
    NSDictionary *parameter = @{@"recordStartIndex":recordStartIndex,@"recordEndIndex":recordEndIndex,@"todoFlag":todo,@"context":context,@"ModelName":modelName,@"Title":title};//搜索
    HTLog(@"%@",parameter);
    
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        NSDictionary *message = [data objectForKey:@"Message"];
        NSInteger status = [[data objectForKey:@"Status"] integerValue];
        if (status == 1 && [[message objectForKey:@"StatusCode"] integerValue] == 200) {
            NSArray *toDoArr = [data objectForKey:@"Result"];
            NSMutableArray *toDoArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in toDoArr)
            {
               HTMIWFCOAMatterInfo *matterInfo = [HTMIWFCOAMatterInfo parserMyMatterInfoByResultDic:dic];
                [toDoArray addObject:matterInfo];
            }
            succeed(toDoArray);
        }
        else {
            
            NSString *errorString = [message objectForKey:@"StatusMessage"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            succeed(nil);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma mark - 已办
+ (void)requestDoneWithDoneFlag:(NSString *)done andRecordStartIndex:(NSString *)recordStartIndex andRecordEndIndex:(NSString *)recordEndIndex andContext:(NSDictionary *)context succeed:(void (^)(id data))succeed
                        failure:(void (^)(NSError *error))failure{
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDbYbList",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"recordStartIndex":recordStartIndex,@"recordEndIndex":recordEndIndex,@"todoFlag":done,@"context":context};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        NSArray *doneArr = [data objectForKey:@"Result"];
        NSMutableArray *doneArray = [[NSMutableArray alloc]init];
        for (NSDictionary *dic in doneArr)
        {
            HTMIWFCOADoneEntity *done = [HTMIWFCOADoneService parserMyDoneBydictionary:dic];
            [doneArray addObject:done];
        }
        succeed(doneArray);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 我的发起
+ (void)requestMyStartWithContext:(NSDictionary *)context startIndex:(NSString *)startIndex endIndex:(NSString *)endIndex modelName:(NSString *)modelName title:(NSString *)title succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure {
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetMySendFlowList",EMUrl,EMPORT,EMapiDir];
    if (modelName == nil) {
        modelName = @"";
    }
    
    NSDictionary *parameter = @{@"recordStartIndex":startIndex,
                                @"recordEndIndex":endIndex,
                                @"context":context,
                                @"ModelName":modelName,
                                @"Title":title};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        NSDictionary *message = [data objectForKey:@"Message"];
        NSInteger status = [[data objectForKey:@"Status"] integerValue];
        if (status == 1 && [[message objectForKey:@"StatusCode"] integerValue] == 200) {
            NSArray *toDoArr = [data objectForKey:@"Result"];
            NSMutableArray *toDoArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in toDoArr)
            {
               HTMIWFCOAMatterInfo *matterInfo = [HTMIWFCOAMatterInfo parserMyMatterInfoByResultDic:dic];
                [toDoArray addObject:matterInfo];
            }
            succeed(toDoArray);
        }
        else {
            
            NSString *errorString = [message objectForKey:@"StatusMessage"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            succeed(nil);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 我的关注
+ (void)requestMyAttentionWithContext:(NSDictionary *)context startIndex:(NSString *)startIndex endIndex:(NSString *)endIndex modelName:(NSString *)modelName title:(NSString *)title succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure {
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetMyAttentionFlowList",EMUrl,EMPORT,EMapiDir];
    if (modelName == nil) {
        modelName = @"";
    }
    
    NSDictionary *parameter = @{@"recordStartIndex":startIndex,
                                @"recordEndIndex":endIndex,
                                @"context":context,
                                @"ModelName":modelName,
                                @"Title":title};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        NSDictionary *message = [data objectForKey:@"Message"];
        NSInteger status = [[data objectForKey:@"Status"] integerValue];
        if (status == 1 && [[message objectForKey:@"StatusCode"] integerValue] == 200) {
            NSArray *toDoArr = [data objectForKey:@"Result"];
            NSMutableArray *toDoArray = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in toDoArr)
            {
                HTMIWFCAttentEntity *matterInfo = [HTMIWFCOAMatterInfo parserMyAttentionByResultDic:dic];
                [toDoArray addObject:matterInfo];
            }
            succeed(toDoArray);
        }
        else {
            
            NSString *errorString = [message objectForKey:@"StatusMessage"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            succeed(nil);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)attentOrDisAttentWithContext:(NSDictionary *)context docID:(NSString *)docID attentionFlag:(NSString *)attentionFlag allowPush:(NSString *)allowPush docTitle:(NSString *)docTitle docType:(NSString *)docType sendFrom:(NSString *)sendFrom sendDate:(NSString *)sendDate iconID:(NSString *)iconID kind:(NSString *)kind succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure {
    
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    
    if (iconID == nil || [iconID isEqual:[NSNull null]]) {
        iconID = @"";
    }
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/SetAttentionYesOrNo",EMUrl,EMPORT,EMapiDir];
    
    NSDictionary *parameter = @{@"DocId":docID,
                                @"AttentionFlag":attentionFlag,
                                @"AllowPush":allowPush,
                                @"context":context,
                                @"DocTitle":docTitle,
                                @"DocType":docType,
                                @"SendFrom":sendFrom,
                                @"SendDate":sendDate,
                                @"iconId":iconID,
                                @"Kind":kind};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        NSDictionary *message = [data objectForKey:@"Message"];
        NSInteger status = [[data objectForKey:@"Status"] integerValue];
        if (status == 1 && [[message objectForKey:@"StatusCode"] integerValue] == 200) {
            
            succeed(@"关注成功");
        }
        else {
            NSString *errorString = [message objectForKey:@"StatusMessage"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            succeed(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 正文
+ (void)requestMyMatterFormWithContext:(NSDictionary*)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed
                               failure:(void (^)(NSError *error))failure{
    
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDocInfo",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"DocId":matterID,@"DocType":docType,@"Kind":kind};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        NSDictionary *dic = [data objectForKey:@"Result"];
        HTLog(@"成功");
        succeed(dic);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 附件
+ (void)requestMatterAttachWithContext:(NSDictionary*)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed
                               failure:(void (^)(NSError *error))failure{
    
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDocInfo",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"DocId":matterID,@"DocType":docType,@"Kind":kind};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        NSDictionary *resultDic = [data objectForKey:@"Result"];
        NSArray *attachDic = [resultDic objectForKey:@"listAttInfo"];
        NSString *string1;
        for (NSDictionary *dic in attachDic) {
            string1 = [dic objectForKey:@"AttachmentID"];
        }
        
        if (string1.length > 1)
        {
            NSArray *attach = [HTMIWFCOAAttachEntity requestAttachByDic:data];
            succeed(attach);
        }
        else
        {
            succeed(nil);
        }
        
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 流程
+ (void)requestMatterFlowListWithContext:(NSDictionary *)context andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKInd:(NSString *)kind succeed:(void (^)(id data))succeed
                                 failure:(void (^)(NSError *error))failure{
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDocFlow",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"DocId":matterID,@"DocType":docType,@"Kind":kind};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        NSArray *actionArr = [HTMIWFCOAMatterFlowListService parserMatterFlowListByDictionary:data];
        succeed(actionArr);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - 表单详情
+ (void)requestMainBodyWithContext:(NSDictionary *)context isFlowid:(BOOL)isFlowid andMatterID:(NSString *)matterID andDocType:(NSString *)docType andKind:(NSString *)kind succeed:(void (^)(id data))succeed
                           failure:(void (^)(NSError *error))failure{
    
    //wlq update 追加一层判断，请假会进入
    if (isFlowid) {
        
        NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/StartDocFlow",EMUrl,EMPORT,EMapiDir];
        NSDictionary *parameter = @{@"context":context,@"flowid":matterID};//这里的matterID就是flowid
        
        [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
            
            succeed(data);
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    else{
        
        NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetDocInfo",EMUrl,EMPORT,EMapiDir];
        NSDictionary *parameter = @{@"context":context,@"DocId":matterID};
        
        [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
            
            succeed(data);
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

#pragma mark - 下载附件
+ (void)downloadFileWithAttachID:(NSString *)attachID
                   andAttachName:(NSString *)attachName
                      andContext:(NSDictionary *)context andKind:(NSString *)kind
                         succeed:(void (^)(id data))succeed
                         failure:(void (^)(NSError *error))failure{
    // 添加会导致乱码
    //NSString *attachmentName = [attachName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (kind == nil || [kind isEqual:[NSNull null]]) {
        kind = @"";
    }
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/DownFileIsFinish_Attachment",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"FileID":attachID,@"ParafileName":attachName,@"Kind":kind};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        
        HTMIWFCOAAttachmentEntity *attachment = [HTMIWFCOAAttachmentService parserAttachmentByDictionary:data];
        succeed(attachment);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (NSURLSessionDownloadTask *)downloadZipFilePathWithDownloadURL:(NSString *)downloadUrl andSavePath:(NSString *)savePath  progress:(NSProgress **)progress succeed:(void (^)(id data))succeed
                                                         failure:(void (^)(NSError *error))failure{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    HTMIWFCAFURLSessionManager *sessionManager = [[HTMIWFCAFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *attachFileRemoteURL = [NSURL URLWithString:downloadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:attachFileRemoteURL];
    
    // 保存文件
    //返回url     块对象           参数              参数
    NSURL * (^DestinationBlock)(NSURL *__strong, NSURLResponse *__strong) =
    //              参数名                      参数名
    ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //复制给block
        NSURL *attachFileLocalURL = [NSURL fileURLWithPath:savePath];
        return [attachFileLocalURL URLByAppendingPathComponent:[response suggestedFilename]];
    };
    
    
    // 下载完成
    void (^completionHandlerBlock)(NSURLResponse *__strong, NSURL *__strong, NSError *__strong) =
    ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            failure(error);
        }
        else {
            succeed([filePath absoluteString]);
        }
    };
    
    
    // 开始下载
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request
                                                                            progress:progress
                                                                         destination:DestinationBlock
                                                                   completionHandler:completionHandlerBlock];
    
    //不管用哪种方法最后一定要执行 task 的 resume方法 因为默认下载操作是挂起的，必须先手动恢复下载
    [downloadTask resume];
    return downloadTask;
}

//请假
+ (void)requestMyLeaveMatterFormWithContext:(NSDictionary*)context andFlowID:(NSString *)FlowID succeed:(void (^)(id data))succeed
                                    failure:(void (^)(NSError *error))failure{
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/StartDocFlow",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"flowid":FlowID};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        NSArray *array = [HTMIWFCOAInfoRegion parserInforRegionBydic:data];
        succeed(array);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//请假其他
+ (void)requestMyLeaveWithContext:(NSDictionary *)context andFlowID:(NSString *)FlowID succeed:(void (^)(id data))succeed
                          failure:(void (^)(NSError *error))failure{
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/StartDocFlow",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"flowid":FlowID};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        succeed(data);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/*
 //自由选择所有人员
 + (void)getAllUsersAndBlock:(NSDictionary *)param succeed:(void (^)(id data))succeed
 failure:(void (^)(NSError *error))failure{
 NSString *urlPath;
 //判断数据库是否存在
 NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
 NSString *path=[paths objectAtIndex:0];
 NSString *filepath=[path stringByAppendingPathComponent:@"personinfo.sqlite"];
 NSFileManager *fileManager = [NSFileManager defaultManager];
 BOOL isHave = [fileManager fileExistsAtPath:filepath];
 
 NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
 NSString *userName = [userDefault objectForKey:@"kOA_userIDString"];
 
 //    if (isHave)
 //    {
 //        //获取上次时间
 //        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
 //
 //        urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/SyncUsers?LastSyncTime=%@&userloginName=%@",EMUrl,EMPORT,EMapiDir,[userDefault objectForKey:@"kLastSysncTime"],userName];
 //    }
 //    else
 //    {
 //        urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/SyncUsers?LastSyncTime=1999-08-06 13:37:09&userloginName=%@",EMUrl,EMPORT,EMapiDir,userName];
 //    }
 //获取上次时间
 
 NSString * kLastSysncTimeString = [userDefault objectForKey:@"kLastSysncTime"];
 
 if (isHave && kLastSysncTimeString && kLastSysncTimeString.length > 0)
 {
 urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/SyncUsers?LastSyncTime=%@&userloginName=%@",EMUrl,EMPORT,EMapiDir,kLastSysncTimeString,userName];
 }
 else
 {
 urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/SyncUsers?LastSyncTime=1999-08-06 13:37:09&userloginName=%@",EMUrl,EMPORT,EMapiDir,userName];
 }
 
 
 NSString *myURLPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 
 //    HTMIWFCAFHTTPRequestOperationManager *manager = [HTMIWFCAFHTTPRequestOperationManager manager];
 //    [manager GET:myURLPath parameters:nil success:^(HTMIWFCAFHTTPRequestOperation *operation, id responseObject) {
 
 [[HTMIWFCAFNManager sharedManager] Get:myURLPath parameters:nil succeed:^(id data) {
 succeed(data);
 } failure:^(NSError *error) {
 failure(error);
 }];
 }
 */


+ (void)getCommonOpinionsByUserName:(NSString *)userName succeed:(void (^)(id data))succeed
                            failure:(void (^)(NSError *error))failure{
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetUserOptions?userloginName=%@",EMUrl,EMPORT,EMapiDir,userName];
    
    [[HTMIWFCAFNManager sharedManager] Get:urlPath parameters:nil succeed:^(id data) {
        succeed(data);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//新增常用意见
+(void)addCommonOpinionWithContext:(NSDictionary *)context idString:(NSString *)idString valueString:(NSString *)valueString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure {
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/NewUserOptions",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"option":@{@"value":valueString}};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        succeed(data);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


//修改常用意见
+(void)changeCommonOpinionWithContext:(NSDictionary *)context idString:(NSString *)idString valueString:(NSString *)valueString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure {
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/EditUserOptions",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"option":@{@"value":valueString,@"id":idString}};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        succeed(data);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


//删除常用意见
+(void)removeCommonOpinionWithContext:(NSDictionary *)context idString:(NSString *)idString valueString:(NSString *)valueString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure {
    
    NSString *urlPath = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/DelUserOptions",EMUrl,EMPORT,EMapiDir];
    NSDictionary *parameter = @{@"context":context,@"option":@{@"value":valueString,@"id":idString}};
    
    [[HTMIWFCAFNManager sharedManager] Post:urlPath parameters:parameter succeed:^(id data) {
        succeed(data);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/*
 #pragma mark - 操作时无网络提示框
 
 + (void)showAlertInOneSecond:(NSString *)message{//时间
 UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
 
 [NSTimer scheduledTimerWithTimeInterval:0.5f
 target:self
 selector:@selector(timerFireMethod:)
 userInfo:promptAlert
 repeats:NO];
 [promptAlert show];
 }
 
 + (void)timerFireMethod:(NSTimer*)theTimer//弹出框
 {
 UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
 [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
 promptAlert = NULL;
 theTimer = nil;
 }
 */

#pragma mark - 显示错误信息
+ (void)showErrorStringWithError:(NSString *)string error:(NSError *)error onView:(UIView *)view{
    if (string && string.length > 0) {
        
        if (error.code == -1001) {
            [HTMIWFCSVProgressHUD showErrorWithStatus:string duration:1];
        }
        else{
            [HTMIWFCSVProgressHUD showErrorWithStatus:string duration:1];
        }
        
    }
    else{
        if (error.code == -1001) {
            [HTMIWFCSVProgressHUD showErrorWithStatus:@"请求超时" duration:1];
        }
        else{
            [HTMIWFCSVProgressHUD showErrorWithStatus:error.localizedDescription duration:1];//@"请求失败，请检查您的网络"
            
        }
    }
}

@end

