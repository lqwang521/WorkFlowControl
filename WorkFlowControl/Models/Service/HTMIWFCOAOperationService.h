//
//  HTMIWFCOAOperationService.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/7/1.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

// 操作完成的回调，返回一个列表（部门或员工）list，和是否可以多选 isMultiSelect
typedef void(^HTMIWFCOAOperationServiceBlock) (NSInteger retCode, NSArray *list, NSString *title, BOOL isMultiSelect,BOOL isFreeSelectUser,NSDictionary *hasSelectedRoute);


@interface HTMIWFCOAOperationService : NSObject

/**
 *  对事项操作：提交、暂存、回调等
 *
 *  @param actionName   操作
 *  @param comment      意见
 *  @param commentList  回传字段（可能）
 *  @param routList     后续需要办理的部分
 *  @param employeeList 后续需要办理的人员
 *  @param matterID     事项ID
 *  @param flowID       流程ID
 *  @param block        回调
 */
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
                            block:(HTMIWFCOAOperationServiceBlock)block;

@end
