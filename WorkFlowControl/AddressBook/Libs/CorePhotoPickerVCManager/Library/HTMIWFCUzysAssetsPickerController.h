//
//  HTMIWFCUzysAssetsPickerController.h
//  HTMIWFCUzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCUzysAssetsPickerController_Configuration.h"
#import "HTMIWFCUzysAppearanceConfig.h"
#import <CoreLocation/CoreLocation.h>

@class HTMIWFCUzysAssetsPickerController;
@protocol HTMIWFCUzysAssetsPickerControllerDelegate<NSObject>
- (void)uzysAssetsPickerController:(HTMIWFCUzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
@optional
- (void)uzysAssetsPickerControllerDidCancel:(HTMIWFCUzysAssetsPickerController *)picker;
- (void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(HTMIWFCUzysAssetsPickerController *)picker;
@end

@interface HTMIWFCUzysAssetsPickerController : UIViewController
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionVideo;
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionPhoto;
//--------------------------------------------------------------------
@property (nonatomic, assign) NSInteger maximumNumberOfSelectionMedia;

@property (nonatomic, weak) id <HTMIWFCUzysAssetsPickerControllerDelegate> delegate;
+ (ALAssetsLibrary *)defaultAssetsLibrary;
/**
 *  setup the appearance, including the all the properties in HTMIWFCUzysAppearanceConfig, check HTMIWFCUzysAppearanceConfig.h out for details.
 *
 *  @param config HTMIWFCUzysAppearanceConfig instance.
 */
+ (void)setUpAppearanceConfig:(HTMIWFCUzysAppearanceConfig *)config;

@end
