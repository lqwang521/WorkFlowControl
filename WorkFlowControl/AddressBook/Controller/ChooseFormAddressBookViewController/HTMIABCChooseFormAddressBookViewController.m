//
//  HTMIABCChooseFormAddressBookViewController.m
//  MXClient
//
//  Created by wlq on 16/4/19.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCChooseFormAddressBookViewController.h"

#import "HTMIABCDYSegmentControllerView.h"
#import "HTMIABCDYSegmentContainerlView.h"

//controller
#import "HTMIABCChooseFromOrganizationViewController.h"
#import "HTMIABCChooseFromContactViewController.h"
#import "HTMIABCChooseFromCustomViewController.h"
//tree
#import "HTMIABCChooseFromOrganizationTreeViewController.h"

#import "UIColor+HTMIWFCHex.h"
#import "HTMIABCDynamicTreeNode.h"
#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_DepartmentModel.h"

#import "HTMIWFCSettingManager.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "HTMIWFCMasonry.h"


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

@interface HTMIABCChooseFormAddressBookViewController ()<UIGestureRecognizerDelegate>
{
    
}

@property (nonatomic, copy) NSArray *titleArr;
@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@property (nonatomic, strong) HTMIABCDYSegmentControllerView *segmentView;
@property (nonatomic, strong) HTMIABCDYSegmentContainerlView *containerView;

@property (nonatomic, assign) NSInteger oldSeletedPageNumber;

/**
 *  已选择的数组
 */
@property (strong, nonatomic) NSMutableArray *selectedDataSource;

/** 是不是树形展现形式 */
@property (nonatomic, assign) BOOL isTree;
/** 当前的控制器index */
@property (nonatomic, assign) NSInteger index;

@end

@implementation HTMIABCChooseFormAddressBookViewController

//默认初始化方法
- (instancetype)init{
    self = [super init];
    //默认单选用户
    if (self) {
        //不允许直接调用init进行初始化，如果这样调用程序就会崩溃
        //HTMI_Assert(YES);
        NSAssert(NO, @"不能直接使用莫用初始化方法进行调用");
        self.chooseType = ChooseTypeUserFromAll;
        self.isSingleSelection = YES;
    }
    return self;
}

#pragma mark - 初始化方法

- (instancetype)initWithChooseType:(ChooseType)chooseType isSingleSelection:(BOOL)isSingleSelection
                     specificArray:(NSArray *)specificArray isTree:(BOOL)isTree{
    self = [super init];
    //默认单选用户
    if (self) {
        self.chooseType = chooseType;
        
        if (self.chooseType == ChooseTypeOrganization) {
            self.isSingleSelection = YES;
        }
        self.isSingleSelection = isSingleSelection;
        //目前测试只测试层级的
        //self.isTree = isTree;
        self.isTree = NO;
        if (specificArray) {
            self.specificArray = [NSMutableArray arrayWithArray:specificArray];
        }
    }
    
    return self;
}

#pragma mark --生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;// 这句代码的意思是不让它扩展布局
    
    self.automaticallyAdjustsScrollViewInsets = NO;//关键
    
    if (self.titleString.length > 0) {
        //初始化导航栏
        [self customNavigationController:YES title:self.titleString];
    }
    else{
        if (self.chooseType == ChooseTypeDepartmentFromAll ||self.chooseType == ChooseTypeDepartmentFromSpecific ||self.chooseType == ChooseTypeDepartmentFromSpecificOnly) {
            
            //初始化导航栏
            [self customNavigationController:YES title:@"选择部门"];
            
        }else{
            //初始化导航栏
            [self customNavigationController:YES title:@"选择人员"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePageTag:) name:@"HTMI_AddressBook_HidePageTag" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickDone) name:@"HTMI_AddressBook_SelectedDone" object:nil];
    
    
    //判断是不是从通讯录中选择（也就是从所有中选择）
    //    if (self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization || self.chooseType == ChooseTypeUserFromSpecific) {
    if (self.chooseType == ChooseTypeDepartmentFromAll || self.chooseType == ChooseTypeDepartmentFromSpecificOnly || self.chooseType == ChooseTypeUserFromSpecificOnly) {
        //没有页签
        [HTMIWFCSettingManager manager].choosePageTagHight = 0;
        
        UIViewController *htmihooseFromOrganizationViewController;
        if (self.chooseType == ChooseTypeDepartmentFromSpecificOnly || self.chooseType == ChooseTypeUserFromSpecificOnly) {
            htmihooseFromOrganizationViewController =   [[HTMIABCChooseFromCustomViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
            HTMIABCChooseFromCustomViewController * vc = (HTMIABCChooseFromCustomViewController *)htmihooseFromOrganizationViewController;
            vc.isTree = self.isTree;
            vc.myParentViewController = self;
            
        }
        else{
            if (self.isTree) {
                
                htmihooseFromOrganizationViewController = [[HTMIABCChooseFromOrganizationTreeViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
                
                HTMIABCChooseFromOrganizationTreeViewController * vc = (HTMIABCChooseFromOrganizationTreeViewController *)htmihooseFromOrganizationViewController;
                vc.myParentViewController = self;
                
            }
            
            else{
                htmihooseFromOrganizationViewController = [[HTMIABCChooseFromOrganizationViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
                
                HTMIABCChooseFromOrganizationViewController * vc = (HTMIABCChooseFromOrganizationViewController *)htmihooseFromOrganizationViewController;
                vc.myParentViewController = self;
            }
        }
        
        [self addChildViewController:htmihooseFromOrganizationViewController];
        [self.view addSubview:htmihooseFromOrganizationViewController.view];
        
    }
    else{
        
        //有页签
        [HTMIWFCSettingManager manager].choosePageTagHight = 40;
        
        [self createSegmentView];
        [self createContainerView];
        [self.segmentView mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(0);
        }];
        [self.containerView mas_makeConstraints:^(HTMIWFCMASConstraintMaker *make) {
            make.top.mas_equalTo(self.segmentView.mas_bottom);
            make.left.right.bottom.mas_equalTo(self.view);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//移除所有通知
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    HTLog(@"HTMIABCChooseFormAddressBookViewController");
}

/**
 *	创建配置分段选择栏
 */
- (void)createSegmentView
{
    __weak typeof(self) weakSelf = self;
    self.segmentView = [[HTMIABCDYSegmentControllerView alloc] initWithStyle:DYSementStyleWidthEqualFull];
    
    if (self.chooseType == ChooseTypeUserFromSpecific) {//三个页签
        self.segmentView.buttonWidth = kScreenWidth/3;
        self.segmentView.lineWidth = kScreenWidth/3;
    }
    else{
        
        self.segmentView.buttonWidth = kScreenWidth/2;
        self.segmentView.lineWidth = kScreenWidth/2;
    }
    
    @weakify(self);
    [self.segmentView setTitleArr:self.titleArr andBtnBlock:^(UIButton *button) {
        @strongify(self);
        [weakSelf.containerView updateVCViewFromIndex:button.tag];
        
        self.oldSeletedPageNumber = button.tag;
        //如果是从指定人员中选择，那么在切换选择页面后需要删除之前选额的
        self.index = button.tag;
        
        NSInteger pageNumber = button.tag;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChooseFormAddressBookViewControllerSelectIndexChange" object:[NSString stringWithFormat:@"%ld",(long)pageNumber] userInfo:nil];
    }];
    
    [self.view addSubview:self.segmentView];
}
/**
 *	创建配置视图容器 View
 */
- (void)createContainerView
{
    __weak typeof(self) weakSelf = self;
    self.containerView = [[HTMIABCDYSegmentContainerlView alloc]initWithSeleterConditionTitleArr:self.viewControllerArr andBtnBlock:^(int index) {
        [weakSelf.segmentView updateSelecterToolsIndex:index];
    }];
    
    self.containerView.scrollEnabled = NO;
    [self.view addSubview:self.containerView];
}

- (void)myClickReturn
{
    if (self.isTree) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        float idnex = self.titleArr.count - 1;
        if ((!self.titleArr || idnex != self.index || [[HTMIWFCSettingManager manager] choosePageTagHight] == 0) && self.chooseType != ChooseTypeDepartmentFromAll) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (self.chooseType == ChooseTypeDepartmentFromSpecific|| self.chooseType == ChooseTypeUserFromSpecific ||
                 self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeUserFromSpecific ||  self.chooseType == ChooseTypeOrganization || self.chooseType == ChooseTypeDepartmentFromAll) {//顶部没有页签
            //发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_ClickReturn" object:nil userInfo:nil];
        }
        else{
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 通知监听方法 （监听是否需要隐藏顶部页签）
- (void)hidePageTag:(NSNotification *)note{
    
    NSString * flagString = (NSString *)note.object;
    if ([flagString isEqualToString:@"0"]) {
        
        self.view.backgroundColor = [UIColor colorWithHex:@"#F2F2F4"];
        [self.segmentView mas_updateConstraints:^(HTMIWFCMASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(0);
        }];
        
        [self.segmentView layoutIfNeeded];
    }
    else if([flagString isEqualToString:@"1"]){
        self.view.backgroundColor = [[HTMIWFCSettingManager manager] defaultBackgroundColor];
        
        [self.segmentView mas_updateConstraints:^(HTMIWFCMASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(0);
        }];
        
        [self.segmentView layoutIfNeeded];
        if (self.titleArr.count > 0) {
            [self.segmentView updateSelecterToolsIndex:self.titleArr.count - 1];
        }
        else{
            [self.segmentView updateSelecterToolsIndex:0];
        }
    }
}

/**
 *  确定按钮点击后的监听事件
 */
- (void)clickDone{
    
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    
    if (self.resultBlock) {
        
        NSMutableArray * resultIdArray = [NSMutableArray array];
        
        if (self.chooseType == ChooseTypeDepartmentFromAll) { //从所有部门中选择.
            
            if (self.resultBlock) {
                
                if (self.isTree) {
                    for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
                        //NSString * departmentCode = ((HTMIABCSYS_DepartmentModel *)object.model).DepartmentCode;
                        [resultIdArray addObject:[(HTMIABCSYS_DepartmentModel *)object.model copy]];
                    }
                }
                else{
                    for (HTMIABCSYS_DepartmentModel * object in self.selectedDataSource) {
                        //[resultIdArray addObject:object.DepartmentCode];
                        [resultIdArray addObject:[object copy]];
                    }
                }
                
                self.resultBlock(resultIdArray, self.selectedRouteArray);
            }
        }
        else if (self.chooseType == ChooseTypeDepartmentFromSpecific || self.chooseType == ChooseTypeDepartmentFromSpecificOnly) {//从指定的部门中选择
            
            if (self.resultBlock) {
                
                if (self.isTree) {
                    for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
                        //NSString * departmentCode = ((HTMIABCSYS_DepartmentModel *)object.model).DepartmentCode;
                        [resultIdArray addObject:[(HTMIABCSYS_DepartmentModel *)object.model copy]];
                    }
                }
                else{
                    for (HTMIABCSYS_DepartmentModel * object in self.selectedDataSource) {
                        //[resultIdArray addObject:object.DepartmentCode];
                        [resultIdArray addObject:[object copy]];
                    }
                }
                
                self.resultBlock(resultIdArray, self.selectedRouteArray);
            }
        }
        else if (self.chooseType == ChooseTypeUserFromAll) {//从所有人员中选择
            if (self.resultBlock) {
                
                if (self.isTree) {
                    for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
                        //NSString * userId = ((HTMIABCSYS_UserModel *)object.model).UserId;
                        [resultIdArray addObject:[(HTMIABCSYS_UserModel *)object.model copy]];
                    }
                }
                else{
                    for (HTMIABCSYS_UserModel * object in self.selectedDataSource) {
                        //[resultIdArray addObject:object.UserId];
                        [resultIdArray addObject:[object copy]];
                    }
                }
                
                self.resultBlock(resultIdArray, self.selectedRouteArray);
            }
        }
        else if (self.chooseType == ChooseTypeUserFromSpecific || self.chooseType == ChooseTypeUserFromSpecificOnly) {//从指定的人员中选择
            
            if (self.resultBlock) {
                
                if (self.isTree) {
                    for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
                        //NSString * userId = ((HTMIABCSYS_UserModel *)object.model).UserId;
                        
                        [resultIdArray addObject:[(HTMIABCSYS_UserModel *)object.model copy]];
                    }
                }
                else{
                    for (HTMIABCSYS_UserModel * object in self.selectedDataSource) {
                        //[resultIdArray addObject:object.UserId];
                        [resultIdArray addObject:[object copy]];
                    }
                }
                
                self.resultBlock(resultIdArray, self.selectedRouteArray);
            }
        }
        else if (self.chooseType == ChooseTypeOrganization) {//从指定的人员中选择
            
            if (self.resultBlock) {
                
                if (self.isTree) {
                    for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
                        
                        if ([object.model isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                            //NSString * userId = //((HTMIABCSYS_UserModel *)object.model).UserId;
                            [resultIdArray addObject:[(HTMIABCSYS_UserModel *)object.model copy]];
                        }else{
                            //NSString * DepartmentCode = ((HTMIABCSYS_DepartmentModel *)object.model).DepartmentCode;
                            [resultIdArray addObject:[(HTMIABCSYS_DepartmentModel *)object.model copy]];
                        }
                    }
                }
                else{
                    for (NSObject * object in self.selectedDataSource) {
                        
                        if ([object isKindOfClass:[HTMIABCSYS_UserModel class]]) {
                            //NSString * userId = ((HTMIABCSYS_UserModel *)object).UserId;
                            [resultIdArray addObject:[(HTMIABCSYS_UserModel *)object copy]];
                        }else{
                            //NSString * DepartmentCode = ((HTMIABCSYS_DepartmentModel *)object).DepartmentCode;
                            [resultIdArray addObject:[(HTMIABCSYS_DepartmentModel *)object copy]];
                        }
                    }
                }
                
                self.resultBlock(resultIdArray, self.selectedRouteArray);
            }
        }
        
        //返回到之前的页面
        [self.navigationController popViewControllerAnimated:YES];
    }
}


/**
 *  确定按钮点击后的监听事件,返回ID
 */
/*
 - (void)clickDone{
 
 if (self.resultBlock) {
 
 NSMutableArray * resultIdArray = [NSMutableArray array];
 
 if (self.chooseType == ChooseTypeDepartmentFromAll) { //从所有部门中选择.
 
 if (self.resultBlock) {
 
 if (self.isTree) {
 for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
 NSString * departmentCode = ((HTMIABCSYS_DepartmentModel *)object.model).DepartmentCode;
 [resultIdArray addObject:departmentCode];
 }
 }
 else{
 for (HTMIABCSYS_DepartmentModel * object in self.selectedDataSource) {
 [resultIdArray addObject:object.DepartmentCode];
 }
 }
 
 self.resultBlock(resultIdArray);
 }
 }
 else if (self.chooseType == ChooseTypeDepartmentFromSpecific || self.chooseType == ChooseTypeDepartmentFromSpecificOnly) {//从指定的部门中选择
 
 if (self.resultBlock) {
 
 if (self.isTree) {
 for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
 NSString * departmentCode = ((HTMIABCSYS_DepartmentModel *)object.model).DepartmentCode;
 [resultIdArray addObject:departmentCode];
 }
 }
 else{
 for (HTMIABCSYS_DepartmentModel * object in self.selectedDataSource) {
 [resultIdArray addObject:object.DepartmentCode];
 }
 }
 
 self.resultBlock(resultIdArray);
 }
 }
 else if (self.chooseType == ChooseTypeUserFromAll) {//从所有人员中选择
 if (self.resultBlock) {
 
 if (self.isTree) {
 for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
 NSString * userId = ((HTMIABCSYS_UserModel *)object.model).UserId;
 [resultIdArray addObject:userId];
 }
 }
 else{
 for (HTMIABCSYS_UserModel * object in self.selectedDataSource) {
 [resultIdArray addObject:object.UserId];
 }
 }
 
 self.resultBlock(resultIdArray);
 }
 }
 else if (self.chooseType == ChooseTypeUserFromSpecific || self.chooseType == ChooseTypeUserFromSpecificOnly) {//从指定的人员中选择
 
 if (self.resultBlock) {
 
 if (self.isTree) {
 for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
 NSString * userId = ((HTMIABCSYS_UserModel *)object.model).UserId;
 [resultIdArray addObject:userId];
 }
 }
 else{
 for (HTMIABCSYS_UserModel * object in self.selectedDataSource) {
 [resultIdArray addObject:object.UserId];
 }
 }
 
 self.resultBlock(resultIdArray);
 }
 }
 else if (self.chooseType == ChooseTypeOrganization) {//从指定的人员中选择
 
 if (self.resultBlock) {
 
 if (self.isTree) {
 for (HTMIABCDynamicTreeNode *object in self.selectedDataSource) {
 
 if ([object.model isKindOfClass:[HTMIABCSYS_UserModel class]]) {
 NSString * userId = ((HTMIABCSYS_UserModel *)object.model).UserId;
 [resultIdArray addObject:userId];
 }else{
 NSString * DepartmentCode = ((HTMIABCSYS_DepartmentModel *)object.model).DepartmentCode;
 [resultIdArray addObject:DepartmentCode];
 }
 }
 }
 else{
 for (NSObject * object in self.selectedDataSource) {
 
 if ([object isKindOfClass:[HTMIABCSYS_UserModel class]]) {
 NSString * userId = ((HTMIABCSYS_UserModel *)object).UserId;
 [resultIdArray addObject:userId];
 }else{
 NSString * DepartmentCode = ((HTMIABCSYS_DepartmentModel *)object).DepartmentCode;
 [resultIdArray addObject:DepartmentCode];
 }
 }
 }
 
 self.resultBlock(resultIdArray);
 }
 }
 
 //返回到之前的页面
 [self.navigationController popViewControllerAnimated:YES];
 }
 }
 */


#pragma mark -  getter setter

- (NSMutableArray *)viewControllerArr{
    if (!_viewControllerArr) {
        
        _viewControllerArr = [NSMutableArray array];
        
        if (self.chooseType == ChooseTypeDepartmentFromSpecific|| self.chooseType == ChooseTypeUserFromSpecific) {//三个页签]
            HTMIABCChooseFromCustomViewController *htmiChooseFromCustomViewController =   [[HTMIABCChooseFromCustomViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
            htmiChooseFromCustomViewController.isTree = self.isTree;
            htmiChooseFromCustomViewController.myParentViewController = self;
            
            [_viewControllerArr addObject:htmiChooseFromCustomViewController];
            [self addChildViewController:htmiChooseFromCustomViewController];
            [self.view addSubview:htmiChooseFromCustomViewController.view];
        }
        
        //是否有常用联系人
        if (self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeUserFromSpecific ||  self.chooseType == ChooseTypeOrganization) {
            
            HTMIABCChooseFromContactViewController *htmiChooseFromContactViewController =   [[HTMIABCChooseFromContactViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
            htmiChooseFromContactViewController.isTree = self.isTree;
            htmiChooseFromContactViewController.myParentViewController = self;
            
            [_viewControllerArr addObject:htmiChooseFromContactViewController];
            [self addChildViewController:htmiChooseFromContactViewController];
            [self.view addSubview:htmiChooseFromContactViewController.view];
        }
        
        UIViewController *htmihooseFromOrganizationViewController;
        if (self.isTree) {
            htmihooseFromOrganizationViewController = [[HTMIABCChooseFromOrganizationTreeViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
            HTMIABCChooseFromOrganizationTreeViewController * vc = (HTMIABCChooseFromOrganizationTreeViewController *)htmihooseFromOrganizationViewController;
            vc.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray){
                
            };
            
            vc.myParentViewController = self;
        }
        else{
            htmihooseFromOrganizationViewController = [[HTMIABCChooseFromOrganizationViewController alloc] initWithChooseType:self.chooseType isSingleSelection:self.isSingleSelection specificArray:self.specificArray];
            HTMIABCChooseFromOrganizationViewController * vc = (HTMIABCChooseFromOrganizationViewController *)htmihooseFromOrganizationViewController;
            vc.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray){
                
            };
            vc.myParentViewController = self;
        }
        
        [_viewControllerArr addObject:htmihooseFromOrganizationViewController];
        [self addChildViewController:htmihooseFromOrganizationViewController];
        [self.view addSubview:htmihooseFromOrganizationViewController.view];
    }
    return _viewControllerArr;
}

- (NSArray *)titleArr{
    if (!_titleArr) {
        if (self.chooseType == ChooseTypeUserFromSpecific) {//三个页签]
            
            _titleArr = @[@"系统选择",@"常用联系人",@"组织结构"];
        }
        if (self.chooseType == ChooseTypeDepartmentFromSpecific) {
            
            _titleArr = @[@"系统选择",@"组织结构"];
        }
        if (self.chooseType == ChooseTypeUserFromAll || self.chooseType == ChooseTypeOrganization) {
            
            _titleArr = @[@"常用联系人",@"组织结构"];
        }
    }
    return _titleArr;
}

- (NSMutableArray *)selectedDataSource{
    if (!_selectedDataSource) {
        _selectedDataSource = [NSMutableArray array];
    }
    return _selectedDataSource;
}

@end
