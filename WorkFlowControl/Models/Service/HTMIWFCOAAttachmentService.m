//
//  HTMIWFCOAAttachmentService.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/17.
//  Copyright (c) 2015年 MXClient. All rights reserved.


#import "HTMIWFCOAAttachmentService.h"

#import "HTMIWFCOAAttachmentListEntity.h"


@implementation HTMIWFCOAAttachmentService

+ (HTMIWFCOAAttachmentEntity *)parserAttachmentByDictionary:(NSDictionary *)dic
{
    HTMIWFCOAAttachmentEntity *attachment = [[HTMIWFCOAAttachmentEntity alloc]init];
    
    NSDictionary *resultDic = [dic objectForKey:@"Result"];
    
    attachment.isFinished = [resultDic objectForKey:@"IsFinished"];
    
    //attachment.DocFileInfoResult = [resultDic objectForKey:@"DocFileInfoResult"];
    NSDictionary *docDic = [resultDic objectForKey:@"DocFileInfoResult"];
    
    HTMIWFCOAAttachmentListEntity *list = [[HTMIWFCOAAttachmentListEntity alloc]init];
    list.type = [docDic objectForKey:@"Type"];
    list.byteLength = [[docDic objectForKey:@"ByteLength"] integerValue];
    list.fielName = [docDic objectForKey:@"FielName"];
    list.modifiedTime = [docDic objectForKey:@"ModifiedTime"];
    list.downloadURL = [docDic objectForKey:@"DownloadURL"];
    
//    attachment.DocFileInfoResult = list;
    attachment.attachList = list;
    return attachment;
}

@end
