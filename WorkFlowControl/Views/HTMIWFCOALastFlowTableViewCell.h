//
//  HTMIWFCOALastFlowTableViewCell.h
//  MXClient
//
//  Created by 朱冲 on 16/2/16.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTMIWFCOAlastFlow;

@interface HTMIWFCOALastFlowTableViewCell : UITableViewCell

@property (nonatomic, strong)HTMIWFCOAlastFlow *flowList;
@property (nonatomic, strong)UILabel *CurrentNodeName;   //名称前面
@property (nonatomic, strong)NSString *CurrentUserId;    //id   跳转标示
@property (nonatomic, strong)UIButton *CurrentUsername;   //名称
@property(nonatomic,strong)UILabel *myLabel;   //当前
@property(nonatomic,strong)UIImageView *headImageView;    //左边的图片


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andmyCurrentUsername:(NSString *)UserName andmyCurrentNodename:(NSString *)nodeName;
/**
 *  更新Cell数据
 *
 *  @param flowList 模型
 */
- (void)updateMatterFlowListCell:(HTMIWFCOAlastFlow *)flowList andmyHeight:(int)heightInt;

@end
