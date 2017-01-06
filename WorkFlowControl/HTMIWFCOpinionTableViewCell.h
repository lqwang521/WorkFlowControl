//
//  HTMIWFCOpinionTableViewCell.h
//  MXClient
//
//  Created by 赵志国 on 16/7/27.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTMIWFCCommonOpinion.h"

typedef void(^HTMIWFCOpinionTableViewCellBlock)(NSString *string, NSInteger index);

@interface HTMIWFCOpinionTableViewCell : UITableViewCell

@property (nonatomic, copy) HTMIWFCOpinionTableViewCellBlock buttonBlock;

@property (nonatomic ,copy) NSString *isFormGo;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)creatCellByOpinionmodel:(HTMIWFCCommonOpinion *)opinionModel index:(NSInteger)index;

@end
