//
//  HTMIWFCOAMatterFormTableViewController.m
//  MXClient
//
//  Created by 赵志国 on 16/6/20.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterFormTableViewController.h"

#import "HTMIWFCSVProgressHUD.h"

#import "HTMIWFCOATableItemsEntity.h"

#import "HTMIWFCOAMainBodyService.h"

#import "HTMIWFCOAMatterFormTableViewController+EditType.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "UIImage+HTMIWFCWM.h"

#define LABELWIDTH 85
#define LABELHEIGHT 50
#define FLOATY 94

#define LineColor [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]

#define eidtColor [UIColor colorWithRed:251/255.0 green:250/255.0 blue:213/255.0 alpha:1.0]

//定义ViewController默认背景色
#define kDefaultBackgroundColor RGB(249,249,249)
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


@interface HTMIWFCOAMatterFormTableViewController ()

@property(nonatomic, copy)NSString *openTel;

/**
 *  记录子表收回的数据，再次点击展开时使用 总体 infoRegin
 */
@property (nonatomic, strong) NSMutableArray *infoReginChangedArray;

/**
 *  记录子表收回的数据，再次点击展开时使用 子表部分
 */
@property (nonatomic, strong) NSMutableArray *childFormChangeArray;

/** 缩放比例*/
@property (nonatomic, assign) float scale;

@property (nonatomic, strong) UIView *matterView;

@end

@implementation HTMIWFCOAMatterFormTableViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollIndex = -1;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *contextDic = [user objectForKey:@"kContextDictionary"];
    self.myUserName = [contextDic objectForKey:@"OA_UserName"];
    
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    self.navigationController.navigationBarHidden = NO;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults removeObjectForKey:@"AttachmentID"];
    
 
    [self customNavigationController:NO title:@""];
    
    if (self.contextMatter) {
        self.matterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
        [self.view addSubview:self.matterView];
        
        //分享表单，进这里
        [self shareMatterForm];
    } else {
        //正常表单,进这里
        HTMIWFCOATableItemsEntity *tableItems = self.detaileArray[self.segmentIndex];
        self.infoRegionArray = [NSMutableArray arrayWithArray:tableItems.regionsArray];
        
        [self.infoRegionArray removeObjectsInArray:tableItems.childFormRegionArray];
        
        for (HTMIWFCOATableItemsEntity *item in self.detaileArray) {
            NSArray *array = item.regionsArray;
            [self sendMustEditFeildItemsToOperationViewControllerByInfoRegionArray:array];
        }
        
        
        //        for (HTMIWFCOAInfoRegion *infoRegion in self.infoRegionArray) {
        //            for (HTMIWFCOAMatterFormFieldItem *fieldItem in infoRegion.feildItemList) {
        //                if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"]) && fieldItem.mustInput && fieldItem.value.length < 1) {
        //                    fieldItem.eidtMustColor = @"changeColor";
        //                }
        //            }
        //        }//不变必填颜色打开这里
        
        [self.matterFormTableView reloadData];
    }
    
    self.formLabelFont = IS_IPHONE_6P ? 17 : 15;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewPinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    
}

- (void)imageViewPinch:(UIPinchGestureRecognizer *)recognizer {
    
    NSInteger fontSize = 0;
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        
        self.scale = recognizer.scale;
        /*
         if (recognizer.scale > 1) {
         
         fontSize = self.formLabelFont + 2;
         
         
         } else if (recognizer.scale < 1){
         
         fontSize = self.formLabelFont - 2;
         }
         else{
         return;
         }
         
         //6p:15.17.19     6/5:13.15.17
         if (IS_IPHONE_6P) {
         if (fontSize > 19 || fontSize < 15) {
         
         recognizer.scale = 1;
         
         return;
         }
         }
         else {
         if (fontSize < 13 || fontSize > 17) {
         
         recognizer.scale = 1;
         
         return;
         }
         }
         */
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        
        /*
         if (recognizer.scale > 1) {
         
         fontSize = self.formLabelFont + 2;
         
         
         } else if (recognizer.scale < 1){
         
         fontSize = self.formLabelFont - 2;
         }
         else{
         return;
         }
         */
        
        if (self.scale > 1) {
            
            fontSize = self.formLabelFont + 2;
            
        } else if (self.scale < 1){
            
            fontSize = self.formLabelFont - 2;
        }
        else{
            return;
        }
        
        //6p:15.17.19     6/5:13.15.17
        if (IS_IPHONE_6P) {
            if (fontSize > 19 || fontSize < 15) {
                
                recognizer.scale = 1;
                
                return;
            }
        }
        else {
            if (fontSize < 13 || fontSize > 17) {
                
                recognizer.scale = 1;
                
                return;
            }
        }
        
        if (fontSize != 0) {
            self.formLabelFont = fontSize;
            recognizer.scale = 1;
            [self.matterFormTableView reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark ------ 懒加载
- (NSMutableArray *)opinionIdArray {
    if (!_opinionIdArray) {
        _opinionIdArray = [NSMutableArray array];
    }
    
    return _opinionIdArray;
}

- (NSMutableArray *)autographNameArray {
    if (!_autographNameArray) {
        _autographNameArray = [NSMutableArray array];
    }
    
    return _autographNameArray;
}

- (UITableView *)matterFormTableView {
    if (!_matterFormTableView) {
        if (self.contextMatter) {
            _matterFormTableView = [[UITableView alloc] initWithFrame:self.matterView.bounds];
        } else {
            if (self.flowID.length > 0) {
                _matterFormTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
            } else {
                _matterFormTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-44)];
            }
        }
        
        //处理键盘遮挡问题
        UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [self addChildViewController:tvc];
        _matterFormTableView = tvc.tableView;
        
        _matterFormTableView.delegate = self;
        _matterFormTableView.dataSource = self;
        _matterFormTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _matterFormTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        if (self.contextMatter) {
            tvc.view.frame = self.view.bounds;
            [self.matterView addSubview:_matterFormTableView];
        } else {
            [self.view addSubview:_matterFormTableView];
        }
    }
    
    return _matterFormTableView;
}

- (NSMutableArray *)listBoxArray {
    if (!_listBoxArray) {
        _listBoxArray = [NSMutableArray array];
    }
    
    return _listBoxArray;
}

- (NSMutableArray *)infoReginChangedArray {
    if (!_infoReginChangedArray) {
        _infoReginChangedArray = [NSMutableArray array];
    }
    
    return _infoReginChangedArray;
}

- (NSMutableArray *)childFormChangeArray {
    if (!_childFormChangeArray) {
        _childFormChangeArray = [NSMutableArray array];
    }
    
    return _childFormChangeArray;
}

- (NSMutableArray *)scrollViewArray {
    if (!_scrollViewArray) {
        _scrollViewArray = [NSMutableArray array];
    }
    
    return _scrollViewArray;
}

- (NSMutableDictionary *)contentOffSetDic {
    if (!_contentOffSetDic) {
        _contentOffSetDic = [NSMutableDictionary dictionary];
    }
    
    return _contentOffSetDic;
}

- (NSMutableArray *)rankArray {
    if (!_rankArray) {
        _rankArray = [NSMutableArray array];
    }
    
    return _rankArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 代理

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoRegionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    //    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    for (id any in cell.contentView.subviews) {
        [any removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //显示内容
    [self configureCell:cell atIndexPath:indexPath tableView:tableView];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self mytableView:tableView heightForRowAtIndexPath:indexPath];
}

//主要实现子表功能
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *downImage = nil;
    
    for (id view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            downImage = view;
        }
    }
    
    
    HTMIWFCOATableItemsEntity *tableItems = self.detaileArray[self.segmentIndex];
    
    HTMIWFCOAInfoRegion *infoRegin = self.infoRegionArray[indexPath.row];
    
    if (infoRegin.isOpen) {
        downImage.image = [UIImage getPNGImageHTMIWFC:@"btn_angle_up_circle"];
    } else {
        downImage.image = [UIImage getPNGImageHTMIWFC:@"btn_angle_down_circle"];
    }
    
    if (!infoRegin.isOpen) {
        //展开
        NSMutableArray *changInfoReginArray = [NSMutableArray array];
        
        for (int i = 0; i < tableItems.childFormRegionArray.count; i++) {
            HTMIWFCOAInfoRegion *regin = tableItems.childFormRegionArray[i];
            
            if ([regin.ParentRegionID isEqualToString:infoRegin.regionID]) {
                [changInfoReginArray addObject:regin];
                
            }
            
            [self.infoReginChangedArray addObject:@[infoRegin.regionID,changInfoReginArray]];
        }
        
        NSRange range = NSMakeRange(indexPath.row+1, changInfoReginArray.count);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.infoRegionArray insertObjects:changInfoReginArray atIndexes:indexSet];
        
        NSMutableArray *indexPathArray = [NSMutableArray array];
        for (int i = 0; i < changInfoReginArray.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+i+1) inSection:0];
            [indexPathArray addObject:path];
        }
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
        
    } else {
        //收回
        //点击的indexPath.row时dedao其
        NSInteger count = 0;
        NSArray *reginArray = nil;
        
        for (int i = 0; i < self.infoReginChangedArray.count; i++) {
            NSArray *array = self.infoReginChangedArray[i];
            
            NSString *reginID = array[0];
            
            if ([reginID isEqualToString:infoRegin.regionID]) {
                reginArray = array[1];
                
                [self.infoReginChangedArray removeObject:array];
                count += reginArray.count;
                
                [self.infoRegionArray removeObjectsInArray:reginArray];
                
            } else {
                for (int j = 0; j < reginArray.count; j++) {
                    HTMIWFCOAInfoRegion *info = reginArray[j];
                    
                    if ([reginID isEqualToString:info.regionID]) {
                        NSArray *array1 = array[1];
                        
                        [self.infoReginChangedArray removeObject:array];
                        count += array1.count;
                        
                        [self.infoRegionArray removeObjectsInArray:array1];
                        
                        info.isOpen = !info.isOpen;
                    }
                }
            }
            
        }
        
        NSMutableArray *indexPathArray = [NSMutableArray array];
        
        for (int i = 0; i < count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+i+1) inSection:0];
            [indexPathArray addObject:path];
        }
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:indexPathArray  withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }
    
    infoRegin.isOpen = !infoRegin.isOpen;
    
}

//通过reginID获得 infoRegin
- (HTMIWFCOAInfoRegion *)findInfoReginByReginID:(NSString *)reginid {
    HTMIWFCOAInfoRegion *inforegin = nil;
    
    for (HTMIWFCOAInfoRegion *info in self.infoRegionArray) {
        if ([info.regionID isEqualToString:reginid]) {
            inforegin = info;
            return info;
        }
    }
    
    return inforegin;
}

#pragma mark - UIActionSheet代理方法

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSString *telString = [NSString stringWithFormat:@"tel://%@",self.openTel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telString]];
    }else if (buttonIndex == 1){
        NSString *telString = [NSString stringWithFormat:@"sms://%@",self.openTel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telString]];
    }
}

#pragma mark - HTMIWFCOAQuickOpinionViewControllerDelegate
/**
 *  填写完意见执行的方法
 *
 *  @param opinion 意见内容
 */
- (void)quickOpinion:(NSString *)opinion{
    //去除两边的空格和回车 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
    opinion = [opinion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"%d",opinion.length);
//    if (opinion.length > 0) {
        HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[self.currentEidtRegionIndex];
        HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[self.currentEidtFieldItemIndex];
        
        fieldItem.eidtValue = [NSString stringWithFormat:@"%@",opinion];
        fieldItem.aOrO = @"意见";
        
        [self.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:opinion mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        
        [self.matterFormTableView reloadData];
//    }
    
}


#pragma mark - 事件
/**
 *  返回按钮点击事件
 *
 *  @param sender UIButton
 */
- (void)myBtn:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  ViewTouch事件
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    [self removeChoiceView];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}



#pragma mark - 私有方法

/**
 *  校验电话号码
 *
 *  @param mobileNum 电话号码字符串
 *
 *  @return 是否为电话号
 */
- (BOOL)isMobileNumber:(NSString *)mobileNum{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
 *  将必填的 feildItem 项发送给 BLMatterOperationViewController，它将在用户办理事宜时判断用户是否已填写
 */
- (void)sendMustEditFeildItemsToOperationViewControllerByInfoRegionArray:(NSArray *)inforeginArray {
    
    HTLog(@"-------------------------找出所有的必填项----------------------");
    
    NSMutableArray *mustEditFeildItems = [[NSMutableArray alloc] init];
    for (HTMIWFCOAInfoRegion *infoRegion in inforeginArray) {
        for (HTMIWFCOAMatterFormFieldItem *fieldItem in infoRegion.feildItemList) {
            if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"]) && fieldItem.mustInput) {
                if ([fieldItem.inputType isEqualToString:@"2001"]) {
                    if (fieldItem.eidtValue.length < 1) {
                        [mustEditFeildItems addObject:fieldItem];
                    }
                    
                } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                    NSArray *autographArray = [fieldItem.value componentsSeparatedByString:@"\r\n"];
                    if ([[autographArray lastObject] rangeOfString:self.myUserName].location == NSNotFound) {
                        [mustEditFeildItems addObject:fieldItem];
                    }
                    
                } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                    if (fieldItem.eidtValue.length < 1) {
                        [mustEditFeildItems addObject:fieldItem];
                    }
                    
                } else {
//                    if (fieldItem.value.length < 1) {
                        [mustEditFeildItems addObject:fieldItem];
//                    }
                }
            }
        }
    }
    [self.operationDelegate oaOperationDelegateMustEditFeildItems:mustEditFeildItems];
}

/**
 *  获取View所属的TableViewCell
 *
 *  @param view 当前视图
 *
 *  @return UITableViewCell
 */
- (UITableViewCell *)getCellBy:(id)view {
    
    
    UITableViewCell *cell = nil;
    if ([[[view superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)[[view superview] superview];
    }
    else if ([[[[view superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)[[[view superview] superview] superview];
    }
    else if ([[[[[view superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)[[[[view superview] superview] superview] superview];
    }
    else if ([[[[[[view superview] superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)[[[[[view superview] superview] superview] superview] superview];
    }
    else if ([[[[[[[view superview] superview] superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)[[[[[[view superview] superview] superview] superview] superview] superview];
    }
    else if ([[[[[[[[view superview] superview] superview] superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (UITableViewCell *)[[[[[[[view superview] superview] superview] superview] superview] superview] superview];
    }
    
    //    [self findTableViewCellFromView:view];
    //
    //    return self.findFromViewTableViewCell;
    return cell;
}

/**
 *  递归查找当前view所在的Cell
 *
 *  @param view View
 */
- (void)findTableViewCellFromView:(id)view{
    
    if ([[view superview] isKindOfClass:[UITableViewCell class]]) {
        
        self.findFromViewTableViewCell = (UITableViewCell *)[view superview];
        
        return;
    } else {
        
    }
    
    [self findTableViewCellFromView:[view superview]];
}

/**
 *  计算键盘的高度
 */
- (CGFloat)keyboardEndingFrameHeight:(NSDictionary *)userInfo{
    //方法一：
    //    CGRect keyboardEndingUncorrectedFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //    CGRect keyboardEndingFrame = [self.tableView convertRect:keyboardEndingUncorrectedFrame fromView:nil];
    //    return keyboardEndingFrame.size.height;
    //方法二：
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    return height;
}

#pragma mark ------ 分享表单，只读
- (void)shareMatterForm {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn addTarget:self action:@selector(myBtn:) forControlEvents:UIControlEventTouchUpInside];

    [btn setImage:[UIImage imageNavigationWithViewHueHTMIWFC:@"mx_btn_back_phone" ] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -31, 0, 0);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    NSLog(@"%@",self.contextMatter);
    NSString *bbb = [self.contextMatter objectForKey:@"DocId"];
    NSString *ccc = [self.contextMatter objectForKey:@"Kind"];
    NSString *ddd = [self.contextMatter objectForKey:@"DocType"];
    
    NSDictionary *dic = [self.contextMatter objectForKey:@"context"];
    
    [HTMIWFCSVProgressHUD show];
    [[HTMIWFCOAMainBodyService alloc] mainBodyWithContext:dic MatterID:bbb isFlowid:NO andDocType:ddd andKind:ccc block:^(id obj, id detaile, id attachment,NSArray *segmentArray, NSDictionary *maxWidthDic, NSError *error) {
        
        [HTMIWFCSVProgressHUD dismiss];
        //详情
        self.detaileArray = detaile;
        self.maxWidthDic = maxWidthDic;
        
        HTMIWFCOATableItemsEntity *tableItems = self.detaileArray[0];
        self.infoRegionArray = [NSMutableArray arrayWithArray:tableItems.regionsArray];
        [self.infoRegionArray removeObjectsInArray:tableItems.childFormRegionArray];
        for (HTMIWFCOATableItemsEntity *item in self.detaileArray) {
            NSArray *array = item.regionsArray;
            [self sendMustEditFeildItemsToOperationViewControllerByInfoRegionArray:array];
        }
//        NSMutableArray *feildItems = [NSMutableArray array];
//        for (HTMIWFCOAInfoRegion *infoRegion in self.infoRegionArray) {
//            [feildItems addObjectsFromArray:infoRegion.feildItemList];
//        }
        
        //        for (HTMIWFCOAInfoRegion *infoRegion in self.infoRegionArray) {
        //            for (HTMIWFCOAMatterFormFieldItem *fieldItem in infoRegion.feildItemList) {
        //                if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"]) && fieldItem.mustInput && fieldItem.value.length < 1) {
        //                    fieldItem.eidtMustColor = @"changeColor";
        //
        //                }
        //            }
        //        }//不变必填颜色打开这里
        
        [self.matterFormTableView reloadData];
        self.title = @"分享表单";
    }];
}

#pragma mark ------ UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    BOOL isScroll = NO;
    
    for (NSArray *array in self.scrollViewArray) {
        UIScrollView *scroll = array[1];
        if (scrollView == scroll) {
            //
            isScroll = YES;
        }
    }
    
    for (NSArray *array in self.scrollViewArray) {
        UIScrollView *scroll = array[1];
        
        if (isScroll) {
            [scroll setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) ];
            
            NSLog(@"%@",scrollView.superview);
            
            UITableViewCell *cell = [self getCellBy:scrollView];
            HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[[self.matterFormTableView indexPathForCell:cell].row];
            
            [self.contentOffSetDic setValue:[NSString stringWithFormat:@"%f",scrollView.contentOffset.x] forKey:infoRegion.ParentRegionID];
        }
        
    }
    
}

@end
