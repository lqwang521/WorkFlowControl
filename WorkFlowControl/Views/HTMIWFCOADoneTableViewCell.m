//
//  HTMIWFCOADoneTableViewCell.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/9.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOADoneTableViewCell.h"

#import "UIImage+HTMIWFCWM.h"

//#import "MXConst.h"

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//等比布局使用
#define kW(R)  ((R)*(kScreenWidth)/320)
#define kH(R)  ((R)*(kScreenHeight)/568)

//表单部分zzg    处理方法：5\6一样，6p为他们的1.1倍
#define kW6(R) (IS_IPHONE_6P ? R*1.1 : R)
#define kH6(R) (IS_IPHONE_6P ? R*1.1 : R)

#define formLineWidth kW6(1.5)
#define formLineColor [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]
#define sidesPlace kW6(5)//label字体距两边的距离



@interface HTMIWFCOADoneTableViewCell()

@property(nonatomic,strong)HTMIWFCOADoneEntity *done;
@property(nonatomic,strong)HTMIWFCEGOImageButton *imgButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UILabel *nameLabel;

@end

@implementation HTMIWFCOADoneTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    
    return self;
}

- (void)updateDoneCellContentValue:(HTMIWFCOADoneEntity *)done {
    self.imgButton = [[HTMIWFCEGOImageButton alloc] initWithPlaceholderImage:[UIImage getPNGImageHTMIWFC:@"file_default_icon_phone"]];
    self.imgButton.layer.masksToBounds = YES;
    self.imgButton.layer.cornerRadius = 5;
    self.imgButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.imgButton.backgroundColor=[UIColor clearColor];
    self.imgButton.placeholderImage = [UIImage getPNGImageHTMIWFC:@"icon_email_taken"];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    
    
    [self.contentView addSubview:self.imgButton];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.nameLabel];
    
    CGFloat titleHeight = [self labelSizeWithMaxWidth:kScreenWidth-kW6(84) content:done.DocTitle FontOfSize:15].height+kH6(20);
    
    CGFloat cellHeight = MAX((titleHeight+kH6(30)), kH6(70));
    
    [self.imgButton setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", done.iconId]]];
    self.imgButton.frame=CGRectMake(kW6(10), cellHeight/2-25, kW6(50), kH6(50));
    
    self.titleLabel.frame = CGRectMake(kW6(72), 0, kScreenWidth-kW6(84), titleHeight);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = done.DocTitle;
    
    self.nameLabel.frame = CGRectMake(kW6(72), titleHeight, kW6(110), kH6(20));
    self.nameLabel.text = done.DocType;
    
    self.timeLabel.frame = CGRectMake(kW6(180), titleHeight, kScreenWidth-kW6(180)-kW6(12), kH6(20));
    self.timeLabel.text = done.SendDate;
}


//计算字符串长度
- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize {
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}


@end
