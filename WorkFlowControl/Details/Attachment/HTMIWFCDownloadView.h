//
//  HTMIWFCDownloadView.h
//  断电下载 demo
//
//  Created by 赵志国 on 16/6/24.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTMIWFCDownloadViewBlock)(NSString *pathString);


@interface HTMIWFCDownloadView : UIView

@property (nonatomic, strong) NSArray *nameArray;

@property (nonatomic, strong) NSArray *keyArray;

@property (nonatomic, copy) HTMIWFCDownloadViewBlock pathStringBlock;


- (instancetype)initWithFrame:(CGRect)frame url:(NSArray *)url fileName:(NSArray *)fileName fileLength:(NSArray *)fileLength type:(NSArray *)type;

- (void)downloadViewReloadData;

@end
