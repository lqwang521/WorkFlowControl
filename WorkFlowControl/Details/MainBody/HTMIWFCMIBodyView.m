//
//  HTMIWFCMIBodyView.m
//  MXClient
//
//  Created by chong on 16/7/28.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCMIBodyView.h"
#import "UIImage+HTMIWFCWM.h"
//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

//等比布局使用
#define kW(R)  ((R)*(kScreenWidth)/320)
#define kH(R)  ((R)*(kScreenHeight)/568)


@interface HTMIWFCMIBodyView ()<UIGestureRecognizerDelegate>

@end

@implementation HTMIWFCMIBodyView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //imageView  加载时显示
        [self showImageView];
        //textView  请求到数据后  textview取消隐藏
        [self showTextView];
    }
    return self;
}

-(void)showImageView{
    self.myImgView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2-kW(kScreenWidth-250)/2, kH(100), kW(kScreenWidth-250), kW(kScreenWidth-250))];
//    self.myImgView.image = [UIImage getPNGImageHTMIWFC:@"ImgBackone"];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myTapGesture:)];
    self.myImgView.image = [UIImage getPNGImageHTMIWFC:@"img_no_messages"];
    [self.myImgView addGestureRecognizer:tapGest];
    [self addSubview:self.myImgView];
    self.myLabelString = [[UILabel alloc]initWithFrame:CGRectMake(0, kW(120+kScreenWidth-250), kScreenWidth, 30)];
    self.myLabelString.font = [UIFont systemFontOfSize:15];
    self.myLabelString.text = @"努力读取中，请稍后......";
    self.myLabelString.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.myLabelString];
}

-(void)showTextView{
    self.myTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
    self.myTextView.editable = NO;
    self.myTextView.font = [UIFont systemFontOfSize:18];
    self.myTextView.hidden = YES;
    [self addSubview:self.myTextView];
}

//重新加载页面 本打算刷新时，点击页面，现在是点击底部“读取正文”刷新了
-(void)myTapGesture:(UITapGestureRecognizer *)tap{
    
//    [self.delegate reloadRequestView];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
