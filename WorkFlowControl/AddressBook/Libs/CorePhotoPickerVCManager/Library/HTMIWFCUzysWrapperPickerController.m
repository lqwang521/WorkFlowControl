//
//  HTMIWFCUzysWrapperPickerController.m
//  IdolChat
//
//  Created by Uzysjung on 2014. 1. 28..
//  Copyright (c) 2014년 SKPlanet. All rights reserved.
//

#import "HTMIWFCUzysWrapperPickerController.h"

@interface HTMIWFCUzysWrapperPickerController ()

@end

@implementation HTMIWFCUzysWrapperPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  View Controller Setting /Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}
- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)dealloc
{
//    DLog(@"UzysWrapperPicerController dealloc");
}
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

@end
