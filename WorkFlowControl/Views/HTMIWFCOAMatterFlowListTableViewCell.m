//
//  HTMIWFCOAMatterFlowListTableViewCell.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterFlowListTableViewCell.h"
//#import "MXConst.h"
#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
#endif
#import "HTMIWFCOAMatterFlowListTableViewController.h"
#import "HTMIWFCSettingManager.h"
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


@interface HTMIWFCOAMatterFlowListTableViewCell ()<UIAlertViewDelegate>

@end


@implementation HTMIWFCOAMatterFlowListTableViewCell


-(void)creatMatterFlowListCell:(HTMIWFCOAMatterFlowListEntity *)flowList andmyIdentfier:(int)identfierInt
{
    if (_flowList != flowList)
    {
        _flowList = flowList;
    }
    
    self.myUserID = flowList.userID;
    if (flowList.Comments == nil) {
        flowList.Comments = @"";
    }
    self.contentView.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    flowList.stepName = [NSString stringWithFormat:@"%@",flowList.stepName];
    flowList.OAUserName = [NSString stringWithFormat:@"%@",flowList.OAUserName];
    flowList.action = [NSString stringWithFormat:@"%@",flowList.action];
    
    UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, kScreenWidth-20, 30)];
    [self.contentView addSubview:myView];
    if (identfierInt == 0) {
        self.headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kW(19), kH(30), 1, kH(81))];
    }else{
        self.headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kW(19), -4, 1, kH(110))];
    }
    
    UIImage *image = [UIImage getPNGImageHTMIWFC:@"sing_oa_flow_line"];
    self.headImageView.image = image;
    [self.contentView addSubview:self.headImageView];
    
    UIImageView *myImg01 = [[UIImageView alloc]init];
    myImg01.frame = CGRectMake(kW(20) , kH(72), kW(kScreenWidth-40), 1);
    myImg01.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    //    [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    
    [myView addSubview:myImg01];
    
    
    
    self.circleImageHTMIWFCView = [[UIImageView alloc]initWithFrame:CGRectMake(kW(7), kW(15), kW(25), kW(25))];
    self.circleImageHTMIWFCView.image = [UIImage getPNGImageHTMIWFC:@"sign_oa_flow_line_previous"];
    [self.contentView addSubview:self.circleImageHTMIWFCView];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kW(24) , kH(46), kW(200), kH(20))];
    //self.timeLabel.backgroundColor = [UIColor grayColor];
    self.timeLabel.text = [flowList.actionTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    [myView addSubview:self.timeLabel];
    
    //    获取字符串的    CGSize
    CGSize textSize1 = [flowList.stepName sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
    //    Label的宽 起点坐标加CGSize.width
    //    第一个字段拼接   StepName
    self.myStepName = [[UILabel alloc]initWithFrame:CGRectMake(kW(20), kH(10), kW(20+textSize1.width), kH(30))];
    self.myStepName.text = [NSString stringWithFormat:@"%@",flowList.stepName];
    NSLog(@"%@",self.myStepName.text);
    NSLog(@"CGSize:%d,%d",(int)textSize1.width,(int)textSize1.height);
    self.myStepName.font = [UIFont systemFontOfSize:16.0];
    [myView addSubview:self.myStepName];
    //    第二个字段拼接   OAUserName
    CGSize textSize2 = [flowList.OAUserName sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
    self.myOAUserName = [UIButton buttonWithType:UIButtonTypeSystem];
    self.myOAUserName.frame = CGRectMake(kW(20+textSize1.width), kH(10), kW(textSize2.width+10), kH(30));
    [self.myOAUserName setTitle:flowList.OAUserName forState:UIControlStateNormal];
    [self.myOAUserName addTarget:self action:@selector(chatView:) forControlEvents:UIControlEventTouchUpInside];
    self.myOAUserName.tintColor = [[HTMIWFCSettingManager manager] navigationBarColor];
    NSLog(@"%d",(int)self.myOAUserName.frame.origin.x);
    [myView addSubview:self.myOAUserName];
    //    第三个字段拼接   Action
    CGSize textSize3 = [flowList.action sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
    int myA = textSize3.width / (kScreenWidth-40);
    int a =textSize3.height + myA*20;
    self.myAction = [[UILabel alloc]initWithFrame:CGRectMake(kW(20), kH(50), kW(textSize3.width+20), kH(a))];
    self.myAction.text = [NSString stringWithFormat:@"%@",flowList.action];
    NSLog(@"%@",self.myAction.text);
    NSLog(@"CGSize:%d,%d",(int)textSize1.width,(int)textSize1.height);
    self.myAction.font = [UIFont systemFontOfSize:16.0];
    [myView addSubview:self.myAction];
    //    }
    
    
    //   第四个字段拼接    Comments
    CGSize textSize4 = [flowList.Comments sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
    if (20+textSize3.width+textSize4.width < kScreenWidth-40) {
        int myA = textSize4.width / (kScreenWidth-40);
        int a =textSize4.height + myA*20;
        self.myComments = [[UILabel alloc]initWithFrame:CGRectMake(kW(20+textSize3.width+10), kH(50), kW(20+textSize4.width), kH(a))];
        myView.frame = CGRectMake(kW(20), 0, kW(kScreenWidth-20), kH(a+85));
        myImg01.frame = CGRectMake(kW(20), kH(a+86-1), kW(kScreenWidth-20), 1);
        self.timeLabel.frame = CGRectMake(kW(24) , kH(60+a), kW(200), kH(20));
    }else{
        self.myAction.frame = CGRectMake(kW(20), kH(41), kW(textSize3.width+20), kH(a));
        
        int myA = textSize4.width / (kScreenWidth-40);
        int a =textSize4.height + myA*22;
        self.myComments = [[UILabel alloc]initWithFrame:CGRectMake(kW(20), kH(65), kW(kScreenWidth-50), kH(a))];
        self.myComments.numberOfLines = 0;
        if (identfierInt == 0){
            self.headImageView.frame = CGRectMake(kW(19), kH(30), 1, kH(80+a));
        }else{
            self.headImageView.frame = CGRectMake(kW(19), kH(-4), 1, kH(110+a));
        }
        
        myView.frame = CGRectMake(kW(20), 0, kW(kScreenWidth-20), kH(a+93));
        myImg01.frame = CGRectMake(kW(20), kH(a+91-1), kW(kScreenWidth-20), 1);
        self.timeLabel.frame = CGRectMake(kW(24) , kH(65+a), kW(200), kH(20));
    }
    NSString*myComments1 =[flowList.Comments stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString*myComments2 =[myComments1 stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    self.myComments.text = [NSString stringWithFormat:@"%@",myComments2];
    NSLog(@"%@",self.myComments.text);
    NSLog(@"CGSize:%d,%d",(int)textSize1.width,(int)textSize1.height);
    self.myComments.font = [UIFont systemFontOfSize:16.0];
    self.myComments.textColor = [UIColor blackColor];
    [myView addSubview:self.myComments];
    
}

-(void)chatView:(UIButton *)sender
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    NSString *str = [context objectForKey:@"UserID"];
    NSLog(@"%@",str);
    NSLog(@"%@",self.myUserID);
    
    if ( [self.myUserID isEqual:[NSNull null]]) {
        NSLog(@"111");
    }else if ([self.myUserID isEqualToString:str]){
        
        UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"不能与自己聊天" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myalert show];
    }else
    {
        NSArray *userArr = [[NSArray alloc]initWithObjects:self.myUserID, nil];
        NSUserDefaults *defaule = [NSUserDefaults standardUserDefaults];
        [defaule setObject:userArr forKey:@"userID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myUserID"
                                                            object:nil];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
