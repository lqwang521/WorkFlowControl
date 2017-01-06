//
//  HTMIWFCOpinionAutographView.m
//  HTMIWFCOpinionAutographView
//
//  Created by 赵志国 on 16/6/28.
//  Copyright © 2016年 htmitech.com. All rights reserved.
//

#import "HTMIWFCOpinionAutographView.h"

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



@interface HTMIWFCOpinionAutographView ()

@property (nonatomic, strong) UIButton *autographBtn;

@property (nonatomic, strong) UIButton *opinionBtn;

@end


@implementation HTMIWFCOpinionAutographView

- (instancetype)initWithFrame:(CGRect)frame selectType:(SelectType)selectType aOro:(NSString *)aOrO {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *opinionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kW6(57), 0, kW6(30), kH6(50))];
        opinionLabel.text = @"签名";
        opinionLabel.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:opinionLabel];
        
        UILabel *autographLabel = [[UILabel alloc] init];
        autographLabel.text = @"意见";
        autographLabel.font = [UIFont systemFontOfSize:15.0];
        if (selectType == HorizontalType) {
            autographLabel.frame = CGRectMake(kW6(144), 0, kW6(30), kH6(50));
            
        } else if (selectType == VerticalType) {
            autographLabel.frame = CGRectMake(kW6(57), kH6(50), kW6(30), kH6(50));
        }
        [self addSubview:autographLabel];
        
        
        self.autographBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.autographBtn.frame = CGRectMake(kW6(20), kH6(12.5), kW6(25), kH6(25));
        if ([aOrO isEqualToString:@"签名"]) {
            [self.autographBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_selected"] forState:UIControlStateNormal];
        } else {
            [self.autographBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_normal"] forState:UIControlStateNormal];
        }
        self.autographBtn.tag = 0;
        [self.autographBtn addTarget:self action:@selector(opinionOrAutoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.autographBtn];
        
        
        self.opinionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        if (selectType == HorizontalType) {
            self.opinionBtn.frame = CGRectMake(kW6(107), kH6(12.5), kW6(25), kH6(25));
            
        } else if (selectType == VerticalType) {
            self.opinionBtn.frame = CGRectMake(kW6(20), kH6(62.5), kW6(25), kH6(25));
        }
        if ([aOrO isEqualToString:@"意见"]) {
            [self.opinionBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_selected"] forState:UIControlStateNormal];
        } else {
            [self.opinionBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_normal"] forState:UIControlStateNormal];
        }
        
        self.opinionBtn.tag = 1;
        [self.opinionBtn addTarget:self action:@selector(opinionOrAutoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.opinionBtn];
    }
    
    return self;
}

- (void)opinionOrAutoBtnClick:(UIButton *)btn {
    if (btn.tag == 0) {
//        [self.autographBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_selected"] forState:UIControlStateNormal];
//        
//        [self.opinionBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_normal"] forState:UIControlStateNormal];
        
        self.buttonClickBlock(@"签名");
        
    } else if (btn.tag == 1) {
//        [self.opinionBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_selected"] forState:UIControlStateNormal];
//        
//        [self.autographBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_normal"] forState:UIControlStateNormal];
        
        self.buttonClickBlock(@"意见");
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
