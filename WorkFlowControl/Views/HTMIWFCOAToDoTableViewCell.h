//
//  HTMIWFCOAToDoTableViewCell.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "HTMIWFCEGOImageButton.h"

#import "HTMIWFCOAMatterInfo.h"


@interface HTMIWFCOAToDoTableViewCell : UITableViewCell

typedef NS_ENUM(NSInteger, titleStyle) {
    oneLine = 0,
    twoLine,
};


/**
 *  未读提示
 */
@property (nonatomic,strong)UIImageView *unreadDoing;

/**
 *  给控件赋值
 *
 *  @param matterInfo 模型
 *  @param height     cell高度
 *  @param isLong     是否为长按
 */
- (void)creatToDoCellByToDoArray:(HTMIWFCOAMatterInfo *)matterInfo titleStyle:(titleStyle)titleStyle;

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleStyle:(titleStyle)titleStyle;

@end
