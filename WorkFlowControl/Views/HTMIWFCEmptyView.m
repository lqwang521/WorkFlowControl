//
//  HTMIWFCEmptyView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/4.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "HTMIWFCEmptyView.h"
#import "HTMIWFCMasonry.h"
#import "UIColor+HTMIWFCHex.h"

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



@interface HTMIWFCEmptyView ()

@property (nonatomic, copy) HTMIEmptyActionBlock actionBlock;

@property (nonatomic, copy) HTMIEmptyGoToCheckBlock goToCheckBlock;

@end

@implementation HTMIWFCEmptyView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)btnAction:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)showInView:(UIView *)view
{
    [self showInView:view padding:UIEdgeInsetsZero];
}

- (void)showInView:(UIView *)view padding:(UIEdgeInsets)padding
{
    [view addSubview:self];
    [self mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.edges.equalTo(view).insets(padding);
    }];
}

+ (BOOL)viewHasEmptyView:(UIView *)view
{
    BOOL result= NO;
    for (UIView *one in view.subviews) {
        if ([one isKindOfClass:[HTMIWFCEmptyView class]]) {
            result = YES;
            break;
        }
    }
    return result;
}

+ (void)removeFormView:(UIView *)view
{
    for (UIView *one in view.subviews) {
        if ([one isKindOfClass:[HTMIWFCEmptyView class]]) {
            [one removeFromSuperview];
            break;
        }
    }
}

+ (HTMIWFCEmptyView *)reloadErrorView:(HTMIEmptyActionBlock)action goToCheck:(HTMIEmptyGoToCheckBlock)goToCheck
{
    HTMIWFCEmptyView *view = [[HTMIWFCEmptyView alloc] init];
    view.actionBlock = action;
    view.goToCheckBlock = goToCheck;
    
    /* 顶部的跳转按钮
     UIImageView *imgtop = [[UIImageView alloc] initWithImage:[UIImage getPNGImageHTMIWFC:@"btn_operation_homelabel_off"]];
     [view addSubview:imgtop];
     
     [imgtop mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
     make.top.equalTo(view.mas_top).with.offset(0.0);
     make.left.equalTo(view.mas_left).with.offset(0.0);
     
     make.width.equalTo(view.mas_width);
     make.height.equalTo(@(40.0));
     }];
     */
    
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage getPNGImageHTMIWFC:@"img_lost_internet"]];
    [view addSubview:img];
    [img mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-80.0);
        make.width.equalTo(@(80.0));
        make.height.equalTo(@(80.0));
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.textColor = RGB(102, 102, 102);
    tipsLabel.text = @"网络不给力呀，刷新试试";
    tipsLabel.numberOfLines = 10;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(img.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reloadBtn addTarget:view action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [reloadBtn setBackgroundImage:[UIImage imageWithRenderColorHTMIWFC:RGBA(74, 120, 251, 1) renderSize:CGSizeMake(10., 10.)] forState:UIControlStateNormal];
    [reloadBtn setBackgroundImage:[UIImage imageWithRenderColorHTMIWFC:RGBA(91, 141, 223, 1) renderSize:CGSizeMake(10., 10.)] forState:UIControlStateSelected];
    [reloadBtn setTitle:@"刷新" forState:UIControlStateNormal];
    reloadBtn.layer.cornerRadius = 2.0;
    reloadBtn.layer.masksToBounds = YES;
    reloadBtn.layer.borderWidth = 1;
    reloadBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [view addSubview:reloadBtn];
    
    [reloadBtn mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(tipsLabel.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(50.0));
        make.width.equalTo(@(150.0));
    }];
    
    return view;
}

+ (HTMIWFCEmptyView *)reloadTimeOutView:(HTMIEmptyActionBlock)action
{
    HTMIWFCEmptyView *view = [[HTMIWFCEmptyView alloc] init];
    view.actionBlock = action;
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage getPNGImageHTMIWFC:@"img_lost_internet"]];
    [view addSubview:img];
    [img mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-120.0);
        make.width.equalTo(@(80.0));
        make.height.equalTo(@(80.0));
        
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.textColor =  RGB(102, 102, 102);//[UIColor colorWithHex:@"#999999"];
    tipsLabel.text = @"网络不给力呀，刷新试试";
    tipsLabel.numberOfLines = 10;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(img.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reloadBtn addTarget:view action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
 
    [reloadBtn setBackgroundImage:[UIImage imageWithRenderColorHTMIWFC:RGBA(74, 120, 251, 1) renderSize:CGSizeMake(10., 10.)] forState:UIControlStateNormal];
    [reloadBtn setBackgroundImage:[UIImage imageWithRenderColorHTMIWFC:RGBA(91, 141, 223, 1) renderSize:CGSizeMake(10., 10.)] forState:UIControlStateSelected];
    
    [reloadBtn setTitle:@"刷新" forState:UIControlStateNormal];
    reloadBtn.layer.cornerRadius = 2.0;
    reloadBtn.layer.masksToBounds = YES;
    reloadBtn.layer.borderWidth = 1;
    reloadBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [view addSubview:reloadBtn];
    
    [reloadBtn mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(tipsLabel.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(50.0));
        make.width.equalTo(@(150.0));
    }];
    
    return view;
}

+ (HTMIWFCEmptyView *)emptyViewWithImage:(UIImage *)image andTips:(NSString *)tips
{
    HTMIWFCEmptyView *view = [[HTMIWFCEmptyView alloc] init];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imgView];
    [imgView mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-120.0);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.text = tips;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 10;
    tipsLabel.textColor =  RGB(102, 102, 102);
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(imgView.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    return view;
}

+ (HTMIWFCEmptyView *)commonEmptyView
{
    return [HTMIWFCEmptyView emptyViewWithImage:[UIImage getPNGImageHTMIWFC:@"blankpage_image_Sleep"] andTips:@"这里怎么空空的\n发个讨论让它热闹点吧"];
}

+ (HTMIWFCEmptyView *)emptyViewForProject
{
    return [HTMIWFCEmptyView emptyViewWithImage:[UIImage getPNGImageHTMIWFC:@"blankpage_image_Sleep"] andTips:@"这个人很懒\n一个项目都木有~"];
}

+ (HTMIWFCEmptyView *)emptyViewForTask
{
    return [HTMIWFCEmptyView emptyViewWithImage:[UIImage getPNGImageHTMIWFC:@"blankpage_image_Sleep"] andTips:@"这里还没有任务\n赶快起来为团队做点贡献吧"];
}

+ (HTMIWFCEmptyView *)emptyViewForJoinedProject
{
    return [HTMIWFCEmptyView emptyViewWithImage:[UIImage getPNGImageHTMIWFC:@"blankpage_image_Sleep"] andTips:@"还没有参与项目\n赶快去参与一个项目吧~"];
}

+ (HTMIWFCEmptyView *)emptyViewForCreateProject:(HTMIEmptyActionBlock)action
{
    HTMIWFCEmptyView *view = [[HTMIWFCEmptyView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.actionBlock = action;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage getPNGImageHTMIWFC:@"blankpage_image_Sleep"]];
    [view addSubview:imgView];
    [imgView mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-180.0);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.text = @"这里还没有任务\n赶快起来为团队做点贡献吧";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 10;
    tipsLabel.textColor = [UIColor colorWithHex:@"#999999"];
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(imgView.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createBtn addTarget:view action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [createBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"icon_add_project"] forState:UIControlStateNormal];
    [view addSubview:createBtn];
    
    [createBtn mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-30.0);
        make.height.equalTo(@(40.0));
        make.width.equalTo(@(120.0));
    }];
    
    if (action == nil) {
        createBtn.hidden = YES;
    }
    
    return view;
}

@end
