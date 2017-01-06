//
//  HTMWFCIBottomActionView.m
//  MXClient
//
//  Created by chong on 16/7/21.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMWFCIBottomActionView.h"
//#import "MXConst.h"
#import "HTMIWFCOAOperationDataEntity.h"

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



@interface HTMWFCIBottomActionView ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong)NSMutableArray *myactionNameArray;

@end

@implementation HTMWFCIBottomActionView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        [self initExisting];
    }
    return self;
}

-(void)bottomActionView:(NSArray *)operationDataArray{
    
    UIScrollView *myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    myScrollView.userInteractionEnabled = YES;
    myScrollView.delegate = self;
    myScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:myScrollView];
    /**
     *  所有的字与图片的宽相加 是否大于appWidth
     */
    int myWidth = 0;
    for (int i = 0; i < operationDataArray.count; i++){
        HTMIWFCOAOperationDataEntity *data = operationDataArray[i];
        //        NSString *str = [NSString stringWithFormat:@"%@%@%@",data.actionName,data.actionName,data.actionName];
        CGSize textSize = [data.actionName sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }];
        myWidth = myWidth + textSize.width +40;
    }
    
    int mya = 0;
    
    if (myWidth < kScreenWidth) {
        mya = (kScreenWidth-myWidth)/operationDataArray.count;
    }
    
    int mywidthContentSizeInt = 0;
    
    self.myactionNameArray = [NSMutableArray array];
    for (int i = 0; i < operationDataArray.count; i++) {
        HTMIWFCOAOperationDataEntity *data = operationDataArray[i];
        //        NSString *str = [NSString stringWithFormat:@"%@%@%@",data.actionName,data.actionName,data.actionName];
        CGSize textSize = [data.actionName sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12] }];
        
        [self.myactionNameArray addObject:data.actionName];
        UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(mywidthContentSizeInt, 0, textSize.width+40+mya, 44)];
        myView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        myView.tag = i;
        myView.userInteractionEnabled = YES;
        [myScrollView addSubview:myView];
        UITapGestureRecognizer *myTapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myTapGesture:)];
        [myView addGestureRecognizer:myTapGest];
        
        
        UIImageView *myImg = [[UIImageView alloc]initWithFrame:CGRectMake(5+mya/2, 10, 20, 20)];
        [myView addSubview:myImg];
        UILabel *mylabel = [[UILabel alloc]initWithFrame:CGRectMake(35+mya/2, 0, textSize.width+10, 40)];
        mylabel.text = [NSString stringWithFormat:@"%@",data.actionName];
        mylabel.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1];
        mylabel.tag = i;
        mylabel.numberOfLines = 0;
        mylabel.font = [UIFont systemFontOfSize:12];
        [myView addSubview:mylabel];
        //        画线
        if (i != operationDataArray.count-1) {
            UIImageView *myImgLine = [[UIImageView alloc]initWithFrame:CGRectMake(myView.frame.size.width-1, 0, 1, 44)];
            myImgLine.backgroundColor = [UIColor lightGrayColor];
            [myView addSubview:myImgLine];
        }
        
        
        mywidthContentSizeInt = 30 + textSize.width + mywidthContentSizeInt+10+mya;
        
        if ([data.actionName isEqualToString:@"拿回"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_takeback_1"];
        }
        else if ([data.actionName isEqualToString:@"退回"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_return_1"];
        }
        else if ([data.actionName isEqualToString:@"已读"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_read_1"];
        }
        else if ([data.actionName isEqualToString:@"阅知"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_yuezhi_1"];
        }
        else if ([data.actionName isEqualToString:@"暂存"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_save_1"];
        }
        else if ([data.actionName isEqualToString:@"分享"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_share_1"];
        }
        else if ([data.actionName isEqualToString:@"添加关注"] ||
                 [data.actionName isEqualToString:@"取消关注"]) {
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_attention"];
        }
        else{
            myImg.image = [UIImage getPNGImageHTMIWFC:@"btn_action_submit_1"];
        }
    }
    myScrollView.contentSize = CGSizeMake(mywidthContentSizeInt, 40);
}

-(void)myTapGesture:(UITapGestureRecognizer *)tap{
    NSLog(@"%d",(int)tap.view.tag);
    [self.delegate myCountandIdentfier:(int)tap.view.tag andmyActionName:self.myactionNameArray];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
