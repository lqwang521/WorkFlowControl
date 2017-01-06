//
//  HTMIWFCOAMatterFlowListService.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterFlowListService.h"

@implementation HTMIWFCOAMatterFlowListService


+ (NSMutableArray *)parserMatterFlowListByDictionary:(NSDictionary *)dic
{
    NSMutableArray *stepdesArr = [NSMutableArray array];
    
    NSDictionary *resultDic = [dic objectForKey:@"Result"];
    NSArray *stepdes = [resultDic objectForKey:@"stepdes"];
    
    for (NSDictionary *steDic in stepdes)
    {
        HTMIWFCOAMatterFlowListEntity *action = [[HTMIWFCOAMatterFlowListEntity alloc]init];
        
        NSString *str3= [steDic objectForKey:@"Action"];
        action.action = [NSString stringWithFormat:@"%@:",str3];
        action.actionTime = [steDic objectForKey:@"Actiontime"];
        NSString *str1= [steDic objectForKey:@"StepName"];
        if (![str1 isEqualToString:@""]) {
            action.stepName = [NSString stringWithFormat:@"%@:",str1];
        }else{
            action.stepName = [NSString stringWithFormat:@"%@",str1];
        }
        action.stepOrder = [[steDic objectForKey:@"StepOrder"] integerValue];
        action.oaUserID = [steDic objectForKey:@"OAUserID"];
        action.userID = [steDic objectForKey:@"UserID"];
        NSString *str2= [steDic objectForKey:@"OAUserName"];
        action.OAUserName = [NSString stringWithFormat:@"%@",str2];
        action.Comments = [steDic objectForKey:@"Comments"];
        [stepdesArr addObject:action];
    }
    
    return stepdesArr;
}

@end
