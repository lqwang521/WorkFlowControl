//
//  HTMIWFCOAAttachEntity.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/4.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAAttachEntity.h"


@implementation HTMIWFCOAAttachEntity

+ (NSMutableArray *)requestAttachByDic:(NSDictionary *)dic
{
    NSMutableArray *attachArr = [[NSMutableArray alloc]init];
    
    
    
    NSDictionary *resultDic = [dic objectForKey:@"Result"];
    NSArray *attachArray = [resultDic objectForKey:@"listAttInfo"];
    
    for (NSDictionary *attachDic in attachArray)
    {
        HTMIWFCOAAttachEntity *attach = [[HTMIWFCOAAttachEntity alloc]init];
        
        attach.attachID = [attachDic objectForKey:@"AttachmentID"];
        attach.attachTitle = [attachDic objectForKey:@"AttachmentTitle"];
        attach.attachType = [attachDic objectForKey:@"AttachmentType"];
        attach.attachSize = [[attachDic objectForKey:@"AttachmentSize"] integerValue];;
        attach.encrypt = [[attachDic objectForKey:@"Encrypt"] boolValue];
        
        [attachArr addObject:attach];
    }
    

    
    return attachArr;
}


@end
