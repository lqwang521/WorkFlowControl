//
//  HTMIWFCDownloadTableViewCell.m
//  断电下载 demo
//
//  Created by 赵志国 on 16/6/24.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import "HTMIWFCDownloadTableViewCell.h"
#import "UIImage+HTMIWFCWM.h"
/** 十六进制字符串转颜色 */
#define kColorWithString(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

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


#ifdef DEBUG

#define HTLog(...) NSLog(__VA_ARGS__)

#define HTLogDetail(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define HTLog(...)

#define HTLogDetail(fmt, ...)

#endif

#define ISFormType 1

// 2.获得RGB颜色
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)



@interface HTMIWFCDownloadTableViewCell ()

/**
 *   图片
 */
@property (nonatomic, strong) UIImageView *headImageView;

/**
*  name
*/
@property (nonatomic, strong) UILabel *nameLabel;

/**
*  大小
*/
@property (nonatomic, strong) UILabel *lengthLabel;

@end

@implementation HTMIWFCDownloadTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)creatCellByType:(NSString *)type fileName:(NSString *)fileName fileLength:(NSString *)filelength cellIndex:(NSInteger)cellIndex {
    NSArray *typeArray = @[@"docx",@"doc",@"DOCX",@"DOC",
                           @"xlsx",@"xls",@"XLSX",@"XLS",
                           @"pptx",@"ppt",@"PPTX",@"PPT",
                           @"pdf",@"PDF"];
    NSDictionary *attachTypeDic = @{@"docx":@"icon_word",@"doc":@"icon_word",@"DOCX":@"icon_word",@"DOC":@"icon_word",
                                    @"xlsx":@"icon_excle",@"xls":@"icon_excle",@"XLSX":@"icon_excle",@"XLS":@"icon_excle",
                                    @"pptx":@"icon_ppt",@"ppt":@"icon_ppt",@"PPTX":@"icon_ppt",@"PPT":@"icon_ppt",
                                    @"pdf":@"icon_pdf",@"PDF":@"icon_pdf",
                                    @"none":@"icon_unkonw"};
    if (![typeArray containsObject: type]) {
        type = @"none";
    }
    self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kW6(12), kH6(14), 38, 38)];
    self.headImageView.image = [UIImage getPNGImageHTMIWFC:[attachTypeDic objectForKey:type]];
    [self.contentView addSubview:self.headImageView];
    
    CGFloat nameheight = [self labelSizeWithMaxWidth:kScreenWidth-kW6(117) content:fileName FontOfSize:15.0].height;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kW6(62), kH6(12), kScreenWidth-kW6(117), nameheight)];
    self.nameLabel.font = [UIFont systemFontOfSize:15.0];
    self.nameLabel.text = fileName;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.numberOfLines = 0;
    [self.contentView addSubview:self.nameLabel];
    
    self.lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(kW6(62), kH6(12)+nameheight, kScreenWidth-kW6(117), kH6(20))];
    self.lengthLabel.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:self.lengthLabel];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(kW6(62), kH6(12)+nameheight+kH6(20)+kH6(8), kScreenWidth-kW6(117), 2)];
    [self.contentView addSubview:self.progressView];
    [self.progressViewArray addObject:self.progressView];
    
    self.downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.downloadBtn.frame = CGRectMake(kScreenWidth-kW6(44), kH6(11), kW6(44), kH6(44));
    self.downloadBtn.tag = cellIndex;
    [self.downloadBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(downloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.downloadBtn];
}

- (void)refreshLengthLabel:(NSString *)string {
    self.lengthLabel.text = string;
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

- (NSMutableArray *)progressViewArray {
    if (!_progressViewArray) {
        _progressViewArray = [NSMutableArray array];
    }
    
    return _progressViewArray;
}

- (void)downloadButtonClick:(UIButton *)btn {
    self.downloadBtnBlock(btn);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
