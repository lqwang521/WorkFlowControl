//
//  HTMIWFCOAAttachmentListEntity.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/17.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIWFCOAAttachmentListEntity : NSObject
/*"Result": {
    "IsFinished": true,
    "ErroMsg": "",
    "DocFileInfoResult": {
        "Type": "doc",
        "ByteLength": 308353,
        "FielName": "中国光大集团综合办公信息系统-驻场维护手册.doc",
        "ModifiedTime": "0001-01-01T00:00:00",
        "DownloadURL": "http://114.112.89.94:8081/CloudAPI/Files/HZ286f024cf9144b014d22af645c4965.zip"
    }
},*/
@property(nonatomic,strong)NSString *type;
@property(nonatomic,assign)NSInteger byteLength;
@property(nonatomic,strong)NSString *fielName;
@property(nonatomic,strong)NSString *modifiedTime;
@property(nonatomic,strong)NSString *downloadURL;

@end
