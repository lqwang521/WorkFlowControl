//
//  HTMIWFCEMBodyZip.h
//  MXClient
//
//  Created by HTRF on 15/6/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIWFCEMBodyZip : NSObject

@property (nonatomic, copy)NSString *myType;  //样式
@property (nonatomic,assign)NSInteger myByteLength;    //大小
@property (nonatomic, copy)NSString *myFielName;  //压缩包名字
@property (nonatomic, copy)NSString *myModifiedTime;  //修改时间
@property (nonatomic, copy)NSString *myDownloadURL;   //下载地址 URL

@end
