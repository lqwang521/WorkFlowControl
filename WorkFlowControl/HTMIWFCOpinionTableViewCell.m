//
//  HTMIWFCOpinionTableViewCell.m
//  MXClient
//
//  Created by 赵志国 on 16/7/27.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOpinionTableViewCell.h"

#import "UIImage+HTMIWFCWM.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

@interface HTMIWFCOpinionTableViewCell ()

@property (nonatomic, strong) UILabel *opinionlabel;

@end

@implementation HTMIWFCOpinionTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)creatCellByOpinionmodel:(HTMIWFCCommonOpinion *)opinionModel index:(NSInteger)index {
    CGFloat opinionStringHeight = [self labelSizeWithMaxWidth:Width-24 content:opinionModel.valueString FontOfSize:15.0].height+24;
    CGFloat opinionheight = MAX(opinionStringHeight, 55);
    
    self.opinionlabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, Width-24, opinionheight)];
    self.opinionlabel.text = opinionModel.valueString;
    self.opinionlabel.font = [UIFont systemFontOfSize:15.0];
    self.opinionlabel.adjustsFontSizeToFitWidth = YES;
    self.opinionlabel.numberOfLines = 0;
    [self.contentView addSubview:self.opinionlabel];
    
    [self lineImageView];
    
    //编辑、删除按钮
    UIButton *eidtBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    eidtBtn.frame = CGRectMake(Width-164, opinionheight+10, 70, 30);
    eidtBtn.layer.borderWidth = 1.0;
    eidtBtn.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [eidtBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [eidtBtn setTitleColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1.0] forState:UIControlStateNormal];
    eidtBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    eidtBtn.tag = index;
    [eidtBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:eidtBtn];
    
    //编辑、删除按钮
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    removeBtn.frame = CGRectMake(Width-82, opinionheight+10, 70, 30);
    removeBtn.layer.borderWidth = 1.0;
    removeBtn.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [removeBtn setTitle:@"删除" forState:UIControlStateNormal];
    [removeBtn setTitleColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1.0] forState:UIControlStateNormal];
    removeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    removeBtn.tag = index;
    [removeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:removeBtn];
    
    if ([self.isFormGo isEqualToString:@"表单进入"]) {
        //图片按钮
        UIButton *makeSure = [UIButton buttonWithType:UIButtonTypeSystem];
        [makeSure setTitle:@"确定" forState:UIControlStateNormal];
        [makeSure setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        makeSure.frame = CGRectMake(10, opinionheight+10, 30, 30);
        [makeSure setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_check_normal"] forState:UIControlStateNormal];
        makeSure.tag = index;
        [makeSure addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:makeSure];
    }
}

- (void)buttonClick:(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:@"确定"]) {
        [btn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_check_selected"] forState:UIControlStateNormal];
    }
    
    self.buttonBlock(btn.titleLabel.text, btn.tag);
    
}


#pragma mark ------ 私有方法
//绘制虚线
- (void)lineImageView {
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.opinionlabel.frame.size.height, Width, 1)];
    
    UIGraphicsBeginImageContext(imageView.frame.size);   //开始画线
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    CGFloat lineLength[] = {10,5};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor);
    
    CGContextSetLineDash(line, 0, lineLength, 1);  //画虚线
    CGContextMoveToPoint(line, 0.0, 0.0);    //开始画线
    CGContextAddLineToPoint(line, Width, 0.0);
    CGContextStrokePath(line);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    [self.contentView addSubview:imageView];
}



- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize
{
    if (content.length < 1) {
        return CGSizeMake(0, 0);
    }
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
