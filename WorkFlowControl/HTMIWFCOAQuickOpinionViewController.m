//
//  HTMIWFCOAQuickOpinionViewController.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/28.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAQuickOpinionViewController.h"
#import "HTMIWFCOACommonOpinionsViewController.h"

#import "HTMIWFCEditOpinionViewController.h"

#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCApi.h"

#import "HTMIWFCCommonOpinion.h"

#import "HTMIWFCOpinionTableViewCell.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

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



@interface HTMIWFCOAQuickOpinionViewController ()<UITextViewDelegate,OACommonOpinionTableViewController,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
/**
 *  多行文本框
 */
@property(nonatomic,strong)UITextView *textView;

/**
 *  文本框边框
 */
@property (nonatomic, strong) UIView *borderView;

/**
 *  登陆信息
 */
@property (nonatomic, strong) NSDictionary *contextDic;

/**
 *  意见model数组
 */
@property (nonatomic, strong) NSMutableArray *opinionModelArray;

@property(nonatomic,strong)UITableView *opinoonTableView;

@end

@implementation HTMIWFCOAQuickOpinionViewController

#pragma mark - 生命周期

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
    
    [self initUI];
    
    [self getDataSource];
    
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUI {
    self.title = @"审批意见";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatMakeSurebutton];
    
    [self setTextView:self.textView];
    
    [self addCommonOpinionButton];
}

#pragma mark ------ UI
- (void)creatMakeSurebutton {
    UIButton *makeSureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [makeSureBtn setTitle:@"确定" forState:UIControlStateNormal];
    makeSureBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [makeSureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [makeSureBtn addTarget:self action:@selector(myDo) forControlEvents:UIControlEventTouchUpInside];
    makeSureBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -31);
    UIBarButtonItem *makeSureItem = [[UIBarButtonItem alloc] initWithCustomView:makeSureBtn];
    
    self.navigationItem.rightBarButtonItem = makeSureItem;
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        makeSureBtn.tintColor = [[HTMIWFCSettingManager manager] blueColor];
    }
    else{
        makeSureBtn.tintColor = [UIColor whiteColor];
    }
}

- (void)addCommonOpinionButton {
    //底部  添加意见
    UIButton *addOpinion = [UIButton buttonWithType:UIButtonTypeSystem];
    addOpinion.frame = CGRectMake(0, kScreenHeight-50-64, kScreenWidth, 50);
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
}

- (void)creatCommonOpinionView {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    headView.userInteractionEnabled = YES;
    headView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    [self.view addSubview:headView];
    
    UITapGestureRecognizer *selectCommonOpinionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commonOpinionTap:)];
    selectCommonOpinionTap.delegate = self;
    [headView addGestureRecognizer:selectCommonOpinionTap];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 50)];
    label.text = @"选择常用意见";
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1.0];
    [headView addSubview:label];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-30, 10, 28, 30)];
    rightImageView.image = [UIImage getPNGImageHTMIWFC:@"ht_commonOpinion_right"];
    [headView addSubview:rightImageView];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
    lineImageView.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:lineImageView];
}

-(void)commonOpinionTap:(UITapGestureRecognizer *)tap
{
    HTMIWFCOACommonOpinionsViewController *cvc = [[HTMIWFCOACommonOpinionsViewController alloc]init];
    cvc.delegate = self;
    cvc.isFormGo = @"表单进入";
    [self.navigationController pushViewController:cvc animated:YES];
}

#pragma mark ------ 懒加载
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(8, 8, kScreenWidth-34, 100)];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15.0];
        if (self.opinionString.length > 0) {
            _textView.text = self.opinionString;
            _textView.textColor = [UIColor blackColor];
        } else {
            _textView.text = @" 请填写意见 ";
            _textView.textColor = [UIColor lightGrayColor];
        }
        
        [self.borderView addSubview:_textView];
    }
    
    return _textView;
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(3, 5, kScreenWidth-6, 110)];
        _borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _borderView.layer.borderWidth = 1.0;
        _borderView.layer.masksToBounds = YES;
        _borderView.layer.cornerRadius = 2.0;
        [self.view addSubview:_borderView];
    }
    
    return _borderView;
}

- (UITableView *)opinoonTableView {
    if (!_opinoonTableView) {
        _opinoonTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, kScreenWidth, kScreenHeight-64-50-120)];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - OACommonOpinionTableViewControllerDelegate
- (void)addCommonOpinion:(NSString *)opinion{
    self.textView.textColor = [UIColor blackColor];
    self.textView.text = opinion;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}

#pragma mark - 事件
/**
 *  确定
 */
- (void)myDo{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.textView.text isEqualToString:@" 请填写意见 "]) {
        [self.delegate quickOpinion:@""];
    } else {
        [self.delegate quickOpinion:self.textView.text];
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@" 请填写意见 "]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    } else {
        
    }
    
    self.borderView.layer.borderColor = [[HTMIWFCSettingManager manager] navigationBarColor].CGColor;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}


#pragma mark - 私有方法
- (void)addOpinionClick:(UIButton *)btn {
    HTMIWFCEditOpinionViewController *eovc = [[HTMIWFCEditOpinionViewController alloc] init];
    eovc.titleString = @"新增常用意见";
    eovc.opinionString = @"";
    [self.navigationController pushViewController:eovc animated:YES];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.contextDic = [user objectForKey:@"kContextDictionary"];
    
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
        
        [HTMIWFCSVProgressHUD dismiss];
        [self.opinoonTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
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
    
    cell.isFormGo = @"表单进入";
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
                
                [HTMIWFCApi changeCommonOpinionWithContext:self.contextDic idString:opinionModel.idString valueString:opinionModel.valueString succeed:^(id data) {
                    
                    
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
            [self.delegate quickOpinion:opinionModel.valueString];
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

- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize
{
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
