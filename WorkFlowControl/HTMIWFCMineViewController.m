//
//  HTMIWFCMineViewController.m
//  MXClient
//
//  Created by 赵志国 on 2016/9/25.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCMineViewController.h"

#import "HTMIWFCSegmentedControl.h"

#import "HTMIWFCMyStartViewController.h"

#import "HTMIWFCMyAttentionViewController.h"

#import "HTMIWFCSettingManager.h"

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
/** 默认的蓝色色调的色值 */
#define kApplicationHueBlueColor RGB(0, 122, 255)



@interface HTMIWFCMineViewController ()

@property (nonatomic, strong) HTMIWFCSegmentedControl *hmSegmentedControl;

@property (nonatomic, strong) HTMIWFCMyStartViewController *startVC;

@property (nonatomic, strong) HTMIWFCMyAttentionViewController *attentionVC;

@end

@implementation HTMIWFCMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setHmSegmentedControl:self.hmSegmentedControl];
    
    [self.view addSubview:self.startVC.view];
    //    [self setAttentionVC:self.attentionVC];
    //    [self setStartVC:self.startVC];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (HTMIWFCSegmentedControl *)hmSegmentedControl {
    if (!_hmSegmentedControl) {
        NSArray *array = @[@"我发起的",@"我关注的"];
        _hmSegmentedControl = [[HTMIWFCSegmentedControl alloc] initWithSectionTitles:array];
        _hmSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _hmSegmentedControl.frame = CGRectMake(0, 0, kScreenWidth, 50);
        _hmSegmentedControl.selectedSegmentIndex = 0;
        _hmSegmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _hmSegmentedControl.selectionStyle = HTMIWFCSegmentedControlSelectionStyleFullWidthStripe;
        _hmSegmentedControl.selectionIndicatorLocation = HTMIWFCSegmentedControlSelectionIndicatorLocationDown;
        
        
        if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {//如果是白色色调
            _hmSegmentedControl.selectionIndicatorColor = [[HTMIWFCSettingManager manager] blueColor];
            
            _hmSegmentedControl.titleTextAttributes =@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
            _hmSegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [[HTMIWFCSettingManager manager] blueColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
        }
        else{
            _hmSegmentedControl.selectionIndicatorColor = [[HTMIWFCSettingManager manager] navigationBarColor];
            
            _hmSegmentedControl.titleTextAttributes =@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
            _hmSegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [[HTMIWFCSettingManager manager] navigationBarColor],NSFontAttributeName :[UIFont systemFontOfSize:14]};
        }
        
        _hmSegmentedControl.selectionIndicatorHeight = 2.0;
        [_hmSegmentedControl addTarget:self action:@selector(segmentPress:) forControlEvents:UIControlEventValueChanged];
        _hmSegmentedControl.backgroundColor = [UIColor whiteColor];
        [self.view addSubview: _hmSegmentedControl];
    }
    
    return _hmSegmentedControl;
}

- (HTMIWFCMyStartViewController *)startVC {
    if (!_startVC) {
        _startVC = [[HTMIWFCMyStartViewController alloc] init];
        _startVC.view.frame = CGRectMake(0, 50, kScreenWidth, kScreenHeight-64-50);
        [self addChildViewController:_startVC];
    }
    
    return _startVC;
}

- (HTMIWFCMyAttentionViewController *)attentionVC {
    if (!_attentionVC) {
        _attentionVC = [[HTMIWFCMyAttentionViewController alloc] init];
        
        
        if (self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {// 有tabbar并且显示
            
            _attentionVC.view.frame = CGRectMake(0, 50, kScreenWidth, kScreenHeight-64-50-49);
        }
        else{
            _attentionVC.view.frame = CGRectMake(0, 50, kScreenWidth, kScreenHeight-64-50);
        }
        
        [self addChildViewController:_attentionVC];
    }
    
    return _attentionVC;
}

- (void)segmentPress:(HTMIWFCSegmentedControl *)segment {
    if (segment.selectedSegmentIndex == 0) {
        [self transitionFromViewController:self.attentionVC toViewController:self.startVC duration:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
        
    } else if (segment.selectedSegmentIndex == 1) {
        [self transitionFromViewController:self.startVC toViewController:self.attentionVC duration:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        }];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
