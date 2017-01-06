//
//  HTMIWFCDownloadTableViewCell.h
//  断电下载 demo
//
//  Created by 赵志国 on 16/6/24.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^downloadBtnBlock)(UIButton *btn);

@interface HTMIWFCDownloadTableViewCell : UITableViewCell

/**
 *  进度条数组
 */
@property (nonatomic, strong) NSMutableArray *progressViewArray;

@property (nonatomic, strong) UIProgressView *progressView;

/**
 *  下载按钮
 */
@property (nonatomic, strong) UIButton *downloadBtn;


@property (nonatomic, copy) downloadBtnBlock downloadBtnBlock;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)creatCellByType:(NSString *)type fileName:(NSString *)fileName fileLength:(NSString *)filelength cellIndex:(NSInteger)cellIndex;

- (void)refreshLengthLabel:(NSString *)string;

@end
