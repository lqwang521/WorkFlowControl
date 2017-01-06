//
//  HTMIWFCOAToDoTableViewCell.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAToDoTableViewCell.h"
#import "HTMIWFCOAMatterInfo.h"
#import "HTMIWFCEGOImageButton.h"
//#import "MXConfig.h"
//#import "MXConst.h"
#import "UIImage+HTMIWFCWM.h"

//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]


#define cellWidth [UIScreen mainScreen].bounds.size.width


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


//取view的坐标及长宽
#define W(view)    view.frame.size.width
#define H(view)    view.frame.size.height
#define X(view)    view.frame.origin.x
#define Y(view)    view.frame.origin.y


@interface HTMIWFCOAToDoTableViewCell()

@property (nonatomic, strong)HTMIWFCOAMatterInfo *matterInfo;

@property (nonatomic, strong) HTMIWFCEGOImageButton *imgButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sendFromLabel;
@property (nonatomic, strong) UILabel *checkLabel;

@property (nonatomic, strong) UIView *totalView;

@property (nonatomic, assign) titleStyle titleStyle;

@end

@implementation HTMIWFCOAToDoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleStyle:(titleStyle)titleStyle {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.titleStyle = titleStyle;
        
        [self.totalView addSubview:self.unreadDoing];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
    }
    
    return self;
}

- (void)creatToDoCellByToDoArray:(HTMIWFCOAMatterInfo *)matterInfo titleStyle:(titleStyle)titleStyle{
    if(_matterInfo != matterInfo)
    {
        //更新数据
        _matterInfo = matterInfo;
    }
    self.titleStyle = titleStyle;
    
    //白色部分
    self.totalView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, cellWidth-24, 94+self.titleStyle*26)];
    self.totalView.backgroundColor = RGBA(255, 255, 255, 1);
    [self.contentView addSubview:self.totalView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, W(self.totalView)-20, 21+24*self.titleStyle)];
    self.titleLabel.numberOfLines = self.titleStyle+1;
    self.titleLabel.font = [UIFont systemFontOfSize:15];//[UIFont fontWithName:@"PingFangSC-Regular" size:15];
    self.titleLabel.textColor = RGBA(60, 60, 60, 1);
    self.titleLabel.text = matterInfo.DocTitle;//标题
    [self.totalView addSubview:self.titleLabel];
    
    
    self.imgButton = [[HTMIWFCEGOImageButton alloc] initWithPlaceholderImage:[UIImage getPNGImageHTMIWFC:@"file_default_icon_phone"]];
    self.imgButton.frame = CGRectMake(10, self.totalView.frame.size.height-6-50, 50, 50);
    self.imgButton.layer.masksToBounds = YES;
    self.imgButton.layer.cornerRadius = 5;
    self.imgButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.imgButton.backgroundColor=[UIColor clearColor];
    self.imgButton.placeholderImage = [UIImage getPNGImageHTMIWFC:@"icon_email"];
    [self.imgButton setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", matterInfo.iconId]]];
    [self.totalView addSubview:self.imgButton];
    
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.5, 46+self.titleStyle*25, 96, 14)];
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    self.nameLabel.text = [NSString stringWithFormat:@"提交人:%@",matterInfo.SendFrom];//类型
    self.nameLabel.textColor = RGBA(115, 115, 115, 1);
    [self.totalView addSubview:self.nameLabel];
    
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth/2, 46+self.titleStyle*25, cellWidth/2-34, 14)];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = RGBA(115, 115, 115, 1);
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = matterInfo.SendDate;//时间
    [self.totalView addSubview:self.timeLabel];
    
    
    self.sendFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.5, 65+self.titleStyle*25, 150, 14)];
    self.sendFromLabel.font = [UIFont systemFontOfSize:12];
    self.sendFromLabel.textColor = RGBA(115, 115, 115, 1);
    self.sendFromLabel.text = matterInfo.DocType;
    [self.totalView addSubview:self.sendFromLabel];
    
    
    self.checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth/2, 65+self.titleStyle*25, cellWidth/2-34, 14)];
    self.checkLabel.font = [UIFont systemFontOfSize:12];
    self.checkLabel.textColor = RGBA(115, 115, 115, 1);
    self.checkLabel.textAlignment = NSTextAlignmentRight;
    self.checkLabel.text = @"查看全文 >";
    [self.totalView addSubview:self.checkLabel];
    
    
    
    [self.totalView addSubview:self.unreadDoing];
}

//#pragma mark ----- 懒加载
//- (UIView *)totalView {
//    if (!_totalView) {
//        _totalView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, cellWidth-24, 94+self.titleStyle*26)];
//        _totalView.backgroundColor = RGBA(255, 255, 255, 1);
//        [self.contentView addSubview:_totalView];
//    }
//    
//    return _totalView;
//}
//
//- (UILabel *)titleLabel {
//    if (!_titleLabel) {
//        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, W(self.totalView)-20, 21+24*self.titleStyle)];
//        _titleLabel.numberOfLines = self.titleStyle+1;
//        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
//        _titleLabel.textColor = RGBA(60, 60, 60, 1);
//        [self.totalView addSubview:_titleLabel];
//    }
//    
//    return _titleLabel;
//}
//
//- (UILabel *)nameLabel {
//    if (!_nameLabel) {
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.5, 46+self.titleStyle*25, 180, 14)];
//        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
//        _nameLabel.textColor = RGBA(115, 115, 115, 1);
//        [self.totalView addSubview:_nameLabel];
//    }
//    
//    return _nameLabel;
//}
//
//- (UILabel *)timeLabel {
//    if (!_timeLabel) {
//        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth/2, 46+self.titleStyle*25, cellWidth/2-34, 14)];
//        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
//        _timeLabel.textColor = RGBA(115, 115, 115, 1);
//        _timeLabel.textAlignment = NSTextAlignmentRight;
//        [self.totalView addSubview:_timeLabel];
//    }
//    
//    return _timeLabel;
//}
//
//- (UILabel *)sendFromLabel {
//    if (!_sendFromLabel) {
//        _sendFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.5, 65+self.titleStyle*25, 180, 14)];
//        _sendFromLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
//        _sendFromLabel.textColor = RGBA(115, 115, 115, 1);
//        [self.totalView addSubview:_sendFromLabel];
//    }
//    
//    return _sendFromLabel;
//}
//
//- (HTMIWFCEGOImageButton *)imgButton {
//    if (!_imgButton) {
//        _imgButton = [[HTMIWFCEGOImageButton alloc] initWithPlaceholderImage:[UIImage getPNGImageHTMIWFC:@"file_default_icon_phone"]];
//        _imgButton.frame = CGRectMake(10, self.totalView.frame.size.height-6-50, 50, 50);
//        _imgButton.layer.masksToBounds = YES;
//        _imgButton.layer.cornerRadius = 5;
//        _imgButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        _imgButton.backgroundColor=[UIColor clearColor];
//        _imgButton.placeholderImage = [UIImage getPNGImageHTMIWFC:@"icon_email"];
//        [self.totalView addSubview:_imgButton];
//    }
//    
//    return _imgButton;
//}
//
//- (UILabel *)checkLabel {
//    if (!_checkLabel) {
//        _checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth/2, 65+self.titleStyle*25, cellWidth/2-34, 14)];
//        _checkLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
//        _checkLabel.textColor = RGBA(115, 115, 115, 1);
//        _checkLabel.textAlignment = NSTextAlignmentRight;
//        [self.totalView addSubview:_checkLabel];
//    }
//    
//    return _checkLabel;
//}

//- (UILabel *)sendFromLabel {
//    if (_sendFromLabel) {
//        _sendFromLabel = [[UILabel alloc] initWithFrame:<#(CGRect)#>]
//    }
//}


@end
