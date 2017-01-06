//
//  HTMIWFCEMWebbodyViewController.h
//  MXClient
//
//  Created by HTRF on 15/7/3.
//  Copyright (c) 2015年 MXClient. All rights reserved.


#import <UIKit/UIKit.h>
#import "HTMIWFCBaseViewController.h"

@interface HTMIWFCEMWebbodyViewController : HTMIWFCBaseViewController
//正常打开正文zip
@property (nonatomic, strong)NSString *documentPath;//路径查看

//分享过来的 下载链接打开
@property (nonatomic, strong)NSString *sharePush;   //判断是分享打开
@property (nonatomic, strong)NSString *downloadURL; //下载地址
@property (nonatomic, strong)NSString *fileNameZIP; //压缩包名字
@property (nonatomic, strong)NSString *fileName;    //解压缩包后文件名称

@end
