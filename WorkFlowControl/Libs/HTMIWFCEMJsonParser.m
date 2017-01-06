//
//  HTMIWFCEMJsonParser.m
//  MXClient
//
//  Created by HTRF on 15/6/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCEMJsonParser.h"

@implementation HTMIWFCEMJsonParser

+ (HTMIWFCEMBodyZip *)paseZipByDictionart:(NSDictionary *)dic{
    
    HTMIWFCEMBodyZip *zip = [[HTMIWFCEMBodyZip alloc]init];
    zip.myType = [dic objectForKey:@"Type"];
    zip.myByteLength = [[dic objectForKey:@"ByteLength"]integerValue];
 
    zip.myFielName = [dic objectForKey:@"FielName"];
    zip.myModifiedTime = [dic objectForKey:@"ModifiedTime"];
    zip.myDownloadURL= [dic objectForKey:@"DownloadURL"];
    
    return zip;
}

//应用信息
+ (HTMIWFCEMAppInfo *)paseAppInfoDictionart:(NSDictionary *)dic{
    HTMIWFCEMAppInfo *info = [[HTMIWFCEMAppInfo alloc]init];
    info.myAppID = [dic objectForKey:@"appID"];
    info.myAvatarUrl = [dic objectForKey:@"avatarUrl"];
    info.myID = [dic objectForKey:@"id"];
    info.myName = [dic objectForKey:@"name"];
    
    return info;
}

//流程最后一条
+ (HTMIWFCOAlastFlow *)paseFlowInfoDictionart:(NSDictionary *)dic{
    HTMIWFCOAlastFlow *last = [[HTMIWFCOAlastFlow alloc]init];
    last.CurrentUsername = [dic objectForKey:@"CurrentUserName"];
    last.CurrentUserId = [dic objectForKey:@"CurrentUserId"];
    last.CurrentNodeName = [dic objectForKey:@"CurrentNodeName"];
    return last;
}

//滚动视图解析
+ (HTMIWFCOAScrollpng *)paseScrollpngDictionart:(NSDictionary *)dic{
    HTMIWFCOAScrollpng *scroll = [[HTMIWFCOAScrollpng alloc]init];
    scroll.BackGroundImageURL = [dic objectForKey:@"BackGroundImageURL"];
    scroll.myText = [dic objectForKey:@"Text"];
    scroll.TextAlign = [dic objectForKey:@"TextAlign"];
    scroll.AppDescObject = [dic objectForKey:@"AppDescObject"];
    return scroll;
}

//应用信息
+ (HTMIWFCOAAppInfo *)paseHomePageDictionart:(NSDictionary *)dic{
    HTMIWFCOAAppInfo *info = [[HTMIWFCOAAppInfo alloc]init];
    info.myText = [dic objectForKey:@"text"];
    info.BackGroundImageURL = [dic objectForKey:@"BackGroundImageURL"];
    info.BackColor = [dic objectForKey:@"BackColor"];
    info.TextAlign = [dic objectForKey:@"TextAlign"];
    info.AppDescObject = [dic objectForKey:@"AppDescObject"];
    return info;
}

//资料库
+ (HTMIWFCOADataBase *)paseDataBaseByDictionart:(NSDictionary *)dic{
    HTMIWFCOADataBase *data = [[HTMIWFCOADataBase alloc]init];
    data.DocNodeID = [dic objectForKey:@"DocNodeID"];
    data.ParentDocNodeID = [dic objectForKey:@"ParentDocNodeID"];
    data.NodeName = [dic objectForKey:@"NodeName"];
    data.NodeIconURL = [dic objectForKey:@"NodeIconURL"];
    data.Remark = [dic objectForKey:@"Remark"];
    data.NodeIconDownloadURL = [dic objectForKey:@"NodeIconDownloadURL"];
    
    return data;
}

//子层文件
+ (HTMIWFCOADataBaseFile *)paseDataBaseFileByDictionart:(NSDictionary *)dic{
    HTMIWFCOADataBaseFile *ddFile = [[HTMIWFCOADataBaseFile alloc]init];
    
    ddFile.DocID = [dic objectForKey:@"DocID"];
    ddFile.DocNodeID = [dic objectForKey:@"DocNodeID"];
    ddFile.DocName = [dic objectForKey:@"DocName"];
    ddFile.DocURL = [dic objectForKey:@"DocURL"];
    ddFile.DocExtName = [dic objectForKey:@"DocExtName"];
    ddFile.CreateUserID = [dic objectForKey:@"CreateUserID"];
    ddFile.CreatedOn = [dic objectForKey:@"CreatedOn"];
    ddFile.DocDownloadURL = [dic objectForKey:@"DocDownloadURL"];
    ddFile.taggggg = @"2";
    return ddFile;
}

//子层目录
+ (HTMIWFCOADataBaseContent *)paseDataBaseContentByDictionart:(NSDictionary *)dic{
    HTMIWFCOADataBaseContent *content = [[HTMIWFCOADataBaseContent alloc]init];
    content.DocNodeID = [dic objectForKey:@"DocNodeID"];
    content.ParentDocNodeID = [dic objectForKey:@"ParentDocNodeID"];
    content.NodeName = [dic objectForKey:@"NodeName"];
    content.NodeIconURL = [dic objectForKey:@"NodeIconURL"];
    content.DocDownloadURL = [dic objectForKey:@"NodeIconDownloadURL"];
    content.taggggg = @"1";
    return content;
}

@end
