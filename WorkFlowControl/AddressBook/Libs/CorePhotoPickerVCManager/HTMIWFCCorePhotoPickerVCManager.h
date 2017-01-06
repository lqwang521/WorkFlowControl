//
//  HTMIWFCCorePhotoPickerVC.h
//  PhotoPicker
//
//  Created by muxi on 15/2/13.
//  Copyright (c) 2015年 muxi. All rights reserved.
//  照片选取控制器

#import <UIKit/UIKit.h>
#import "HTMIWFCCorePhoto.h"
#import "HTMIWFCHMSingleton.h"


typedef void(^FinishPickingMedia)(NSArray *medias);


typedef enum{
    
    //用户拍照
    HTMIWFCCorePhotoPickerVCMangerTypeCamera=0,
    
    //单张照片选取
    HTMIWFCCorePhotoPickerVCMangerTypeSinglePhoto,
    
    //多张照片选取
    HTMIWFCCorePhotoPickerVCMangerTypeMultiPhoto,
    
    //视频选取（暂不考虑，本框架仍可以完美支持）
    HTMIWFCCorePhotoPickerVCMangerTypeVideo,
    
}HTMIWFCCorePhotoPickerVCMangerType;


typedef enum{
    
    //无错误,可用
    HTMIWFCCorePhotoPickerUnavailableTypeNone,
    
    //相机不可用
    HTMIWFCCorePhotoPickerUnavailableTypeCamera,
    
    //相册不可用
    HTMIWFCCorePhotoPickerUnavailableTypePhoto,
    
}HTMIWFCCorePhotoPickerUnavailableType;



@interface HTMIWFCCorePhotoPickerVCManager : NSObject
HTMIWFCHMSingletonH(HTMIWFCCorePhotoPickerVCManager)

//照片选取器类型
@property (nonatomic,assign) HTMIWFCCorePhotoPickerVCMangerType pickerVCManagerType;

//照片选取器不可用类型
@property (nonatomic,assign) HTMIWFCCorePhotoPickerUnavailableType unavailableType;

//照片选取控制器
@property (nonatomic,strong) UIViewController *imagePickerController;

//选取结束block
@property (nonatomic,copy) FinishPickingMedia finishPickingMedia;

/**
 *  多选参数，单行此属性将自动忽略
 *  此属性=0，表示不限制
 */
@property (nonatomic,assign) NSInteger maxSelectedPhotoNumber;                               //最多可选取的照片数量




@end
