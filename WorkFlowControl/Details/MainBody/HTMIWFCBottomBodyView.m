//
//  HTMIWFCBottomBodyView.m
//  MXClient
//
//  Created by chong on 16/7/28.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCBottomBodyView.h"
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


@interface HTMIWFCBottomBodyView ()
{
    int angle;
}
@end

@implementation HTMIWFCBottomBodyView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        if (ISFormType == 1) {
            self.backgroundColor = [UIColor whiteColor];
        }else{
            self.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        }
        
        
        [self showmain];
    }
    return self;
}

-(void)showmain{
    
    self.progressGradientView = [[HTMIWFCProgressGradientView alloc] initWithFrame:CGRectMake(1, 0, kScreenWidth, 3)];
//    self.progressGradientView.hidden = YES;
    [self addSubview:self.progressGradientView];
    if (ISFormType == 1) {
        self.progressGradientView = [[HTMIWFCProgressGradientView alloc] initWithFrame:CGRectMake(1, 0, kScreenWidth, 3)];
        //    self.progressGradientView.hidden = YES;
        [self addSubview:self.progressGradientView];
        
        self.myImg1 = [[UIImageView alloc]initWithFrame:CGRectMake(kW(20), kW(6), kW(30), kW(30))];
        self.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_read"];
        [self addSubview:self.myImg1];
        [self startAnimation];
        self.mylabel1 = [[UILabel alloc]initWithFrame:CGRectMake(kW(60), 2, kW(100), kH(40))];
        UIImageView *myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(179, 2, 1, 50)];
        myImageView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        //    [self addSubview:myImageView];
        self.mylabel1.text = @"正文读取中";
        self.mylabel1.font = [UIFont systemFontOfSize:14];
        self.mylabel1.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1];
        [self addSubview:self.mylabel1];
        self.myBtn1 = [UIButton buttonWithType:UIButtonTypeSystem];
        self.myBtn1.frame = CGRectMake(0, 0, kW(320), kH(45));
        self.myBtn1.tag = 101;
        [self.myBtn1 addTarget:self action:@selector(myButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.myBtn1];
        //    -----------------------------------------------------
        self.myImg2 = [[UIImageView alloc]initWithFrame:CGRectMake(kW(200), kH(10), kW(30), kH(30))];
        self.myImg2.image = [UIImage getPNGImageHTMIWFC:@"btn_action_share1"];
        [self addSubview:self.myImg2];
        self.mylabel2 = [[UILabel alloc]initWithFrame:CGRectMake(kW(250), kW(5), kW(100), kW(40))];
        self.mylabel2.text = @"分享";
        self.mylabel2.font = [UIFont systemFontOfSize:14];
        self.mylabel2.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1];
        [self addSubview:self.mylabel2];
        self.myBtn2 = [UIButton buttonWithType:UIButtonTypeSystem];
        self.myBtn2.frame = CGRectMake(kW(190), 0, kW(kScreenWidth/3), kH(50));
        self.myBtn2.tag = 101;
        [self.myBtn2 addTarget:self action:@selector(myButtonClick1:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.myBtn2];
        
        self.myImg2.hidden = YES;
        self.mylabel2.hidden = YES;
        self.myBtn2.hidden = YES;
    }else{
        self.myImg1 = [[UIImageView alloc]initWithFrame:CGRectMake(kW(30+80), kW(10), kW(30), kW(30))];
        self.myImg1.image = [UIImage getPNGImageHTMIWFC:@"btn_time_read"];
        [self addSubview:self.myImg1];
        [self startAnimation];
        self.mylabel1 = [[UILabel alloc]initWithFrame:CGRectMake(kW(80+80), 5, kW(100), kW(40))];
        UIImageView *myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(179, 2, 1, 50)];
        myImageView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        [self addSubview:myImageView];
        self.mylabel1.text = @"正文读取中";
        self.mylabel1.font = [UIFont systemFontOfSize:14];
        self.mylabel1.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1];
        [self addSubview:self.mylabel1];
        self.myBtn1 = [UIButton buttonWithType:UIButtonTypeSystem];
        self.myBtn1.frame = CGRectMake(0, 0, kW(320), kW(50));
        self.myBtn1.tag = 101;
        [self.myBtn1 addTarget:self action:@selector(myButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.myBtn1];
        //    -----------------------------------------------------
        self.myImg2 = [[UIImageView alloc]initWithFrame:CGRectMake(kW(200), kW(10), kW(30), kW(30))];
        self.myImg2.image = [UIImage getPNGImageHTMIWFC:@"btn_action_share1"];
        [self addSubview:self.myImg2];
        self.mylabel2 = [[UILabel alloc]initWithFrame:CGRectMake(kW(250), kW(5), kW(100), kW(40))];
        self.mylabel2.text = @"分享";
        self.mylabel2.font = [UIFont systemFontOfSize:14];
        self.mylabel2.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1];
        [self addSubview:self.mylabel2];
        self.myBtn2 = [UIButton buttonWithType:UIButtonTypeSystem];
        self.myBtn2.frame = CGRectMake(kW(190), 0, kW(kScreenWidth/3), kW(50));
        self.myBtn2.tag = 101;
        [self.myBtn2 addTarget:self action:@selector(myButtonClick1:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.myBtn2];
        
        self.myImg2.hidden = YES;
        self.mylabel2.hidden = YES;
        self.myBtn2.hidden = YES;
    }
    
}

-(void)myButtonClick:(UIButton *)sender{
    
    if ([self.mylabel1.text isEqualToString:@"正文读取中"]) {
        
    }else if ([self.mylabel1.text isEqualToString:@"读取正文"]){
        [self.delegate myBottomBodyorbutton:@"读取正文"];
    }else if ([self.mylabel1.text isEqualToString:@"正文下载"]){
        [self.delegate myBottomBodyorbutton:@"正文下载"];
    }else if ([self.mylabel1.text isEqualToString:@"打开文件"]){
        [self.delegate myBottomBodyorbutton:@"打开文件"];
    }
}

-(void)myButtonClick1:(UIButton *)sender{
    [self.delegate myBottomBodyorSharebutton:@"分享"];
}

-(void)startAnimation
{
    [self.myImg1 rotate360DegreeWithImageView];
}

-(void)endAnimation
{
    [self.myImg1 stopRotate];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
