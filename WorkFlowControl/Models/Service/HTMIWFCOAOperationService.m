//
//  HTMIWFCOAOperationService.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/7/1.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAOperationService.h"
#import "HTMIWFCApi.h"

//#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_UserModel.h"

@implementation HTMIWFCOAOperationService


- (void)operationMatterWithAction:(NSString *)actionID
                          comment:(NSString *)comment
                      commentList:(NSString *)commentList
                        routeList:(NSArray *)routList
                     employeeList:(NSArray *)employeeList
                         matterID:(NSString *)matterID
                          docType:(NSString *)docType
                             kind:(NSString *)kind
                           flowID:(NSString *)flowID
                         flowName:(NSString *)flowName
                    currentNodeID:(NSString *)currentNodeID
                   currentTrackID:(NSString *)currentTrackID
                    eidtFieldList:(NSArray *)eidtFieldList
                            block:(HTMIWFCOAOperationServiceBlock)block{
    //后续需要办理的事项
    NSMutableString *routIDStr = nil;
    if (routList && [routList count] > 0)
    {
        routIDStr = [[NSMutableString alloc] init];
        for (NSString *routeID in routList)
        {
            [routIDStr appendFormat:@"%@|", routeID];
        }
    }
    
    //后续需要办理的人员
    NSMutableString *employeeIDStr = nil;
    
    if (employeeList && [employeeList count] > 0)
    {
        employeeIDStr = [[NSMutableString alloc] init];
        for (NSString *employyeID in employeeList)
        {
            if (employeeIDStr.length > 0) {
                [employeeIDStr appendFormat:@"%@", @"|"];
            }
            
            [employeeIDStr appendFormat:@"%@", employyeID];//去掉  U_
        }
    }
    NSString *routeIdString = [routIDStr substringToIndex:[routIDStr length] - 1];
    NSString *employeeIdString = [employeeIDStr substringToIndex:employeeIDStr.length];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    [HTMIWFCApi submitMatterWithContext:context
                            matterID:matterID
                             docType:docType
                                kind:kind
                              flowID:flowID
                            flowName:flowName
                           operation:actionID
                             Comment:comment
                         commentList:commentList
                           routeList:routeIdString
                        employeeList:employeeIdString
                       currentNodeID:currentNodeID
                      currentTrackID:currentTrackID
                       eidtFieldList:eidtFieldList
                             succeed:^(id data) {
                                 
                                 NSDictionary *resultDic = [data objectForKey:@"Result"];
                                 
                                 BOOL isMultiSelectUser = [[resultDic objectForKey:@"IsMultiSelectUser"] boolValue];
                                 BOOL isMultiSelectRoute = [[resultDic objectForKey:@"IsMultiSelectRoute"] boolValue];
                                 BOOL isFreeSelectUser = [[resultDic objectForKey:@"IsFreeSelectUser"] boolValue];
                                 NSInteger resultCode = [[resultDic objectForKey:@"ResultCode"] integerValue];
                                 NSString *resultInfo = [resultDic objectForKey:@"ResultInfo"];
                                 NSDictionary *hasSelectedRoute = [resultDic objectForKey:@"HasSelectedRoute"];
                                 
                                 
                                 if (resultCode == 2)
                                 {
                                     //请选择路由
                                     NSMutableArray *routeArray = [[NSMutableArray alloc]init];
                                     
                                     NSArray *arr = [resultDic objectForKey:@"ListRouteInfo"];
                                     for (NSDictionary *dic in arr)
                                     {
                                         
                                         NSString *  routeID = [dic objectForKey:@"RouteID"];
                                         NSString * routeName = [dic objectForKey:@"RouteName"];
                                         NSDictionary *routeDic = @{@"routeID":routeID,@"routeName":routeName};
                                         [routeArray addObject:routeDic];
                                     }
                                     
                                     block(resultCode,routeArray,resultInfo,isMultiSelectRoute,isFreeSelectUser,nil);
                                 }
                                 else if (resultCode == 4)
                                 {
                                     
                                     //请选择人员
                                     NSMutableArray *authorArray = [[NSMutableArray alloc]init];
                                     
                                     NSArray *arr = [resultDic objectForKey:@"ListAuthorInfo"];
                                     
                                     for (NSDictionary *dic in arr)
                                     {
                                         HTMIABCSYS_UserModel *sys_UserModel= [HTMIABCSYS_UserModel new];
                                         
                                         sys_UserModel.UserId = [dic objectForKey:@"UserID"];
                                         sys_UserModel.FullName = [dic objectForKey:@"UserName"];
                                         [authorArray addObject:sys_UserModel];
                                     }
                                     block(resultCode,authorArray,resultInfo,isMultiSelectUser,isFreeSelectUser,hasSelectedRoute);
                                     
                                 }
                                 else if (resultCode == 0)
                                 {
                                     block(resultCode,nil,resultInfo,NO,isFreeSelectUser,nil);
                                 }
                                 else
                                 {
                                     block(resultCode,nil,resultInfo,NO,isFreeSelectUser,nil);
                                 }
                                 
                             } failure:^(NSError *error) {
                                 //                                 [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
                             }];
}

@end
