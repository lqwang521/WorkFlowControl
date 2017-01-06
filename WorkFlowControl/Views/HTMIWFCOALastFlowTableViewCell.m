//
//  HTMIWFCOALastFlowTableViewCell.m
//  MXClient
//
//  Created by 朱冲 on 16/2/16.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOALastFlowTableViewCell.h"
#import "HTMIWFCOAlastFlow.h"
#import "HTMIWFCSettingManager.h"
#import "UIImage+HTMIWFCWM.h"
/** 十六进制字符串转颜色 */
#define kColorWithString(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define appWidth [UIScreen mainScreen].bounds.size.width

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



//#import "MXConst.h"
@implementation HTMIWFCOALastFlowTableViewCell

//判断当前节点是不是结束，以  Username 是否有值来判断  没有值就是结束了。。。
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andmyCurrentUsername:(NSString *)UserName andmyCurrentNodename:(NSString *)nodeName{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
        self.headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kW(19), -4, 1, kW(30))];
        UIImage *image = [UIImage getPNGImageHTMIWFC:@"sing_oa_flow_line"];
        self.headImageView.image = image;
        [self.contentView addSubview:self.headImageView];
        UIImageView *circleImageHTMIWFCView = [[UIImageView alloc]initWithFrame:CGRectMake(kW(6), kH(16), kW(27), kH(27))];
        if (UserName.length > 0 || nodeName.length > 0) {
            circleImageHTMIWFCView.image = [UIImage getPNGImageHTMIWFC:@"sing_oa_flow_line_current"];
            [self.contentView addSubview:circleImageHTMIWFCView];
            UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(kW(20), 0, kW(appWidth-20), kH(20))];
            myView.tag = 1101;
            [self.contentView addSubview:myView];
            self.myLabel = [[UILabel alloc]initWithFrame:CGRectMake(kW(20) , kH(16), kW(40), kH(20))];
            self.myLabel.text = @"当前:";
            self.myLabel.font = [UIFont systemFontOfSize:16];
            [myView addSubview:self.myLabel];
            
            self.CurrentNodeName = [[UILabel alloc]init];
            [myView addSubview:self.CurrentNodeName];
            
            NSArray *myCurrentName = [UserName componentsSeparatedByString:@";"];
            for (int i = 0; i < myCurrentName.count; i++) {
                UIButton *currentUsernameButton = [UIButton buttonWithType:UIButtonTypeSystem];
                [currentUsernameButton addTarget:self action:@selector(chatView:) forControlEvents:UIControlEventTouchUpInside];
                currentUsernameButton.tintColor = [[HTMIWFCSettingManager manager] navigationBarColor];
                currentUsernameButton.tag = i+100;
                //            currentUsernameButton.backgroundColor = [UIColor orangeColor];
                [myView addSubview:currentUsernameButton];
            }
        }else{
            circleImageHTMIWFCView.image = [UIImage getPNGImageHTMIWFC:@"sign_oa_flow_line_end"];
            [self.contentView addSubview:circleImageHTMIWFCView];
            UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(kW(20), 0, kW(appWidth-20), kH(30))];
            [self.contentView addSubview:myView];
            self.myLabel = [[UILabel alloc]initWithFrame:CGRectMake(kW(20) , kH(20), kW(40), kH(20))];
            self.myLabel.text = @"结束";
            self.myLabel.font = [UIFont systemFontOfSize:16];
            [myView addSubview:self.myLabel];
        }
        
        
        
    }
    return self;
}
//CurrentNodeName = "\U5355\U4e00\U7b7e\U6838";
//CurrentUserId = "";
//CurrentUserName = "";
- (void)updateMatterFlowListCell:(HTMIWFCOAlastFlow *)flowList andmyHeight:(int)heightInt{
    
    if (_flowList != flowList)
    {
        _flowList = flowList;
    }
    
    self.CurrentUserId = flowList.CurrentUserId;
    if (flowList.CurrentUsername > 0 || flowList.CurrentNodeName > 0) {
        //获取字符串的    CGSize
        CGSize textSize1 = [flowList.CurrentNodeName sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0] }];
        self.CurrentNodeName.frame = CGRectMake(kW(60), kH(16), kW(25+textSize1.width), kH(20));
        self.CurrentNodeName.text = [NSString stringWithFormat:@"%@:",flowList.CurrentNodeName];
        self.CurrentNodeName.font = [UIFont systemFontOfSize:16.0];
        
        //    第二个字段拼接   OAUserName
        NSArray *myCurrentNamearray = [flowList.CurrentUsername componentsSeparatedByString:@";"];
        int myInts = textSize1.width;
        int identfier = 0;
        int ccmyFold = 16;
        for (int i = 0; i < myCurrentNamearray.count; i++) {
            for (UIView *myView1 in self.contentView.subviews) {
                if ([myView1 isKindOfClass:[UIView class]]) {
                    if (myView1.tag == 1101) {
                        myView1.frame = CGRectMake(20, 0, appWidth-20, heightInt);
                    }
                    for (UIButton *myButton1 in myView1.subviews) {
                        NSLog(@"%@",myView1.subviews);
                        if ([myButton1 isKindOfClass:[UIButton class]]) {
                            if (myButton1.tag == 100+i) {
                                CGSize textSize2 = [myCurrentNamearray[i] sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16] }];
                                int ccwidth = myInts + textSize2.width;
                                if (ccwidth < appWidth-88 && identfier == 0) {
                                    myButton1.frame = CGRectMake(kW(68+myInts), kH(16), kW(textSize2.width+14), kH(20));
                                }else{
                                    if (ccwidth > appWidth-88) {
                                        myInts = 0;
                                        ccmyFold = ccmyFold+30;
                                    }
                                    myButton1.frame = CGRectMake(kW(myInts+20), kH(ccmyFold), kW(textSize2.width+14), kH(20));
                                    identfier = 1;
                                }
                                myInts = myInts + myButton1.frame.size.width;
                                
                                NSString *currentUser = [NSString stringWithFormat:@"%@",myCurrentNamearray[i]];
                                [myButton1 setTitle:currentUser forState:UIControlStateNormal];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)chatView:(UIButton *)sender{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    NSString *str = [context objectForKey:@"UserID"];
    
    NSArray *myCurrentUserId = [self.CurrentUserId componentsSeparatedByString:@";"];
    
    if ( [myCurrentUserId[sender.tag-100] isEqual:[NSNull null]]) {
 
    }else if ([myCurrentUserId[sender.tag-100] isEqualToString:str]){
        
        UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"不能与自己聊天" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [myalert show];
    }else
    {
        
        
        NSArray *userArr = [[NSArray alloc]initWithObjects:myCurrentUserId[sender.tag-100], nil];
        NSUserDefaults *defaule = [NSUserDefaults standardUserDefaults];
        [defaule setObject:userArr forKey:@"userID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myUserID"
                                                            object:nil];
    }
}

@end
