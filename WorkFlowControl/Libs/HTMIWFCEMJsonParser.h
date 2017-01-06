//
//  HTMIWFCEMJsonParser.h
//  MXClient
//
//  Created by HTRF on 15/6/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMIWFCEMBodyZip.h"
#import "HTMIWFCEMAppInfo.h"
#import "HTMIWFCOAlastFlow.h"
#import "HTMIWFCOAScrollpng.h"
#import "HTMIWFCOAAppInfo.h"
#import "HTMIWFCOADataBase.h"
#import "HTMIWFCOADataBaseFile.h"
#import "HTMIWFCOADataBaseContent.h"

@interface HTMIWFCEMJsonParser : NSObject

//正文Zip
+(HTMIWFCEMBodyZip *)paseZipByDictionart:(NSDictionary *)dic;

//应用信息
+(HTMIWFCEMAppInfo *)paseAppInfoDictionart:(NSDictionary *)dic;

//流程最后一条
+(HTMIWFCOAlastFlow *)paseFlowInfoDictionart:(NSDictionary *)dic;

//滚动视图解析
+(HTMIWFCOAScrollpng *)paseScrollpngDictionart:(NSDictionary *)dic;

//应用信息
+(HTMIWFCOAAppInfo *)paseHomePageDictionart:(NSDictionary *)dic;

//资料库
+(HTMIWFCOADataBase *)paseDataBaseByDictionart:(NSDictionary *)dic;

//子层文件
+(HTMIWFCOADataBaseFile *)paseDataBaseFileByDictionart:(NSDictionary *)dic;

//子层目录
+(HTMIWFCOADataBaseContent *)paseDataBaseContentByDictionart:(NSDictionary *)dic;

@end
