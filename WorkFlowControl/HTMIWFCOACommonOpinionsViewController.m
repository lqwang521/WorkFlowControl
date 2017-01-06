//
//  HTMIWFCOACommonOpinionsViewController.m
//  MXClient
//
//  Created by 赵志国 on 15/12/14.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOACommonOpinionsViewController.h"
#import "HTMIWFCApi.h"
//#import "MXConfig.h"
#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCCommonOpinion.h"

#import "HTMIWFCOpinionTableViewCell.h"

#import "HTMIWFCEditOpinionViewController.h"

#import "HTMIWFCSVProgressHUD.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "HTMIWFCSettingManager.h"


//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]


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


//start 定义弱引用和强引用

#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif

//end


@interface HTMIWFCOACommonOpinionsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *mybackImg;//没有数据时显示背景图片
    UILabel *myLabelString; //没有数据时显示的文字提示
}
@property(nonatomic,strong)UITableView *opinoonTableView;

/**
 *  登陆信息
 */
@property (nonatomic, strong) NSDictionary *contextDic;

/**
 *  意见model数组
 */
@property (nonatomic, strong) NSMutableArray *opinionModelArray;

@end

@implementation HTMIWFCOACommonOpinionsViewController

#pragma mark --生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateNormal];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //wlq update 2016/05/11 适配风格
    [self customNavigationController:NO title:@""];
    
    self.title = @"常用意见";

    //底部  添加意见
    UIButton *addOpinion = [UIButton buttonWithType:UIButtonTypeSystem];
    addOpinion.frame = CGRectMake(0, self.opinoonTableView.frame.size.height, kScreenWidth, 50);
    addOpinion.backgroundColor = [[HTMIWFCSettingManager manager] navigationBarColor];
    addOpinion.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [addOpinion setTitle:@"新增常用意见" forState:UIControlStateNormal];
    [addOpinion setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addOpinion addTarget:self action:@selector(addOpinionClick:) forControlEvents:UIControlEventTouchUpInside];
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        [addOpinion setTitleColor:[[HTMIWFCSettingManager manager] blueColor] forState:UIControlStateNormal];
    }
    else{
        [addOpinion setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [self.view addSubview:addOpinion];
    
    [HTMIWFCSVProgressHUD show];
    [self getDataSource];
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------ 懒加载
- (UITableView *)opinoonTableView {
    if (!_opinoonTableView) {
        _opinoonTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-50)];
        _opinoonTableView.delegate = self;
        _opinoonTableView.dataSource = self;
        _opinoonTableView.tableFooterView = [[UITableView alloc]initWithFrame:CGRectZero];
        _opinoonTableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        [self.view addSubview:_opinoonTableView];
    }
    
    return _opinoonTableView;
}

- (NSMutableArray *)opinionModelArray {
    if (!_opinionModelArray) {
        _opinionModelArray = [NSMutableArray array];
    }
    
    return _opinionModelArray;
}

//获取数据
- (void)getDataSource {
    [self.opinionModelArray removeAllObjects];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.contextDic = [user objectForKey:@"kContextDictionary"];
    
    NSString *userID = [self.contextDic objectForKey:@"UserID"];
    
    [HTMIWFCApi getCommonOpinionsByUserName:userID succeed:^(id data) {
        
        NSDictionary *resultDic = [data objectForKey:@"Result"];
        NSArray *opinions = [resultDic objectForKey:@"items"];
        
        for (int i = 0; i < opinions.count; i++) {
            NSDictionary *dic = opinions[i];
            HTMIWFCCommonOpinion *opinionModel = [[HTMIWFCCommonOpinion alloc] init];
            
            opinionModel.idString = [dic objectForKey:@"id"];
            opinionModel.valueString = [dic objectForKey:@"value"];
            
            [self.opinionModelArray addObject:opinionModel];
        }
        
        for (HTMIWFCCommonOpinion *model in self.opinionModelArray) {
            NSLog(@"%@,%@",model.valueString,model.idString);
        }
        //        zc 没有常用意见显示图片
        if (self.opinionModelArray.count < 1) {
            self.opinoonTableView.hidden = YES;
            if (!mybackImg) {
                mybackImg = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, kScreenWidth-200, kScreenWidth-200)];
                myLabelString = [[UILabel alloc]initWithFrame:CGRectMake(0, 120+kScreenWidth-200, kScreenWidth, 30)];
            }
            mybackImg.hidden = NO;
            mybackImg.image = [UIImage getPNGImageHTMIWFC:@"img_no_messages"];
            [self.view addSubview:mybackImg];
            
            myLabelString.text = @"当前没有常用意见,快去新增一条吧 !";
            myLabelString.textAlignment = NSTextAlignmentCenter;
            myLabelString.font = [UIFont systemFontOfSize:13.0];
            myLabelString.hidden = NO;
            [self.view addSubview:myLabelString];
        }else{
            self.opinoonTableView.hidden = NO;
            myLabelString.hidden = YES;
            mybackImg.hidden = YES;
            [self.opinoonTableView reloadData];
        }
        [HTMIWFCSVProgressHUD dismiss];
        [self.opinoonTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.opinionModelArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *opinionCell = @"opinionCell";
    HTMIWFCOpinionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:opinionCell];
    if (!cell) {
        cell = [[HTMIWFCOpinionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:opinionCell];
    }
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (id any in cell.contentView.subviews) {
        [any removeFromSuperview];
    }
    
    cell.isFormGo = self.isFormGo;
    [cell creatCellByOpinionmodel:self.opinionModelArray[indexPath.section] index:indexPath.section];
    
    typeof(self) __weakSelf = self;
    
    cell.buttonBlock = ^(NSString *string, NSInteger index) {
        HTMIWFCCommonOpinion *opinionModel = __weakSelf.opinionModelArray[index];
        
        if ([string isEqualToString:@"编辑"]) {
            
            HTMIWFCEditOpinionViewController *eovc = [[HTMIWFCEditOpinionViewController alloc] init];
            eovc.titleString = @"编辑常用意见";
            eovc.opinionString = opinionModel.valueString;
            [self.navigationController pushViewController:eovc animated:YES];
            
            eovc.opinionBlock = ^(NSString *string) {
                [HTMIWFCSVProgressHUD show];
                
                [HTMIWFCApi changeCommonOpinionWithContext:self.contextDic idString:opinionModel.idString valueString:string succeed:^(id data) {
                    
                    
                    NSInteger status = [[data objectForKey:@"Status"] integerValue];
                    
                    NSDictionary *messageDic = [data objectForKey:@"Message"];
                    
                    NSInteger statusCode = [[messageDic objectForKey:@"StatusCode"] integerValue];
                    
                    if (status == 1 && statusCode == 200) {
                        //
                        [self getDataSource];
                        
                    } else {
                        //编辑失败
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"编辑失败，请稍候再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                        [HTMIWFCSVProgressHUD dismiss];
                    }
                } failure:^(NSError *error) {
                    
                }];
            };
            
            
            
        } else if ([string isEqualToString:@"删除"]) {
            [HTMIWFCSVProgressHUD show];
            
            [HTMIWFCApi removeCommonOpinionWithContext:self.contextDic idString:opinionModel.idString valueString:opinionModel.valueString succeed:^(id data) {
                
                NSInteger status = [[data objectForKey:@"Status"] integerValue];
                
                NSDictionary *messageDic = [data objectForKey:@"Message"];
                
                NSInteger statusCode = [[messageDic objectForKey:@"StatusCode"] integerValue];
                
                if (status == 1 && statusCode == 200) {
                    //删除成功
                    [self getDataSource];
                    
                } else {
                    //删除失败
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除失败，请稍候再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    [HTMIWFCSVProgressHUD dismiss];
                }
                
                
            } failure:^(NSError *error) {
                
            }];
            
        }
        //wlq 删除，改成点击cell选择
        else if ([string isEqualToString:@"确定"]) {
            [self.delegate addCommonOpinion:opinionModel.valueString];
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    
    return cell;
}

//wlq add
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    HTMIWFCCommonOpinion *opinionModel = self.opinionModelArray[indexPath.section];
//    
//    [self.delegate addCommonOpinion:opinionModel.valueString];
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HTMIWFCCommonOpinion *opinionModel = self.opinionModelArray[indexPath.section];
    CGFloat opinionStringHeight = [self labelSizeWithMaxWidth:kScreenHeight-24 content:opinionModel.valueString FontOfSize:15.0].height+24;
    
    CGFloat opinionHeight = MAX(opinionStringHeight, 55);
    
    return opinionHeight+50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

#pragma mark - 私有方法
- (void)addOpinionClick:(UIButton *)btn {
    HTMIWFCEditOpinionViewController *eovc = [[HTMIWFCEditOpinionViewController alloc] init];
    eovc.titleString = @"新增常用意见";
    eovc.opinionString = @"";
    [self.navigationController pushViewController:eovc animated:YES];
    
    eovc.opinionBlock = ^(NSString *string) {
        
        [HTMIWFCSVProgressHUD show];
        
        [HTMIWFCApi addCommonOpinionWithContext:self.contextDic idString:@"" valueString:string succeed:^(id data) {
            NSInteger status = [[data objectForKey:@"Status"] integerValue];
            
            NSDictionary *messageDic = [data objectForKey:@"Message"];
            
            NSInteger statusCode = [[messageDic objectForKey:@"StatusCode"] integerValue];
            
            if (status == 1 && statusCode == 200) {
                //
                [self getDataSource];
                
            } else {
                //新增失败
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"新增常用意见失败，请稍候再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [HTMIWFCSVProgressHUD dismiss];
            }
        } failure:^(NSError *error) {
            
        }];
    };
}


- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize {
    if (content.length < 1) {
        return CGSizeMake(0, 0);
    }
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}


@end
