//
//  HTMIWFCCorePhotoPickerVC.m
//  PhotoPicker
//
//  Created by muxi on 15/2/13.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "HTMIWFCCorePhotoPickerVCManager.h"
#import "HTMIWFCUzysAssetsPickerController.h"

#import "HTMIWFCSettingManager.h"

@interface HTMIWFCCorePhotoPickerVCManager ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,HTMIWFCUzysAssetsPickerControllerDelegate>

//相册多选控制器
@property (nonatomic,strong) HTMIWFCUzysAssetsPickerController *multiImagePickerController;

@end

@implementation HTMIWFCCorePhotoPickerVCManager
HTMIWFCHMSingletonM(HTMIWFCCorePhotoPickerVCManager)


/**
 *  选取器类型
 */
-(void)setPickerVCManagerType:(HTMIWFCCorePhotoPickerVCMangerType)pickerVCManagerType{
    
    //记录
    _pickerVCManagerType=pickerVCManagerType;
    
    //只有设置了值，才能确定照片选取器
    //初始化照片选取器
    [self pickerVCPrepareWithManagerType:pickerVCManagerType];
}


/**
 *  初始化照片选取器
 */
-(void)pickerVCPrepareWithManagerType:(HTMIWFCCorePhotoPickerVCMangerType)managerType{
    
    //重置错误值
    self.unavailableType=HTMIWFCCorePhotoPickerUnavailableTypeNone;
    
    if(HTMIWFCCorePhotoPickerVCMangerTypeCamera==_pickerVCManagerType || HTMIWFCCorePhotoPickerVCMangerTypeSinglePhoto==_pickerVCManagerType){
        //这个是系统相册选取器
        //sourceType
        UIImagePickerControllerSourceType sourceType=[self tranformHTMIWFCCorePhotoPickerVCMangerTypeForSourceType:managerType];
        
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
        
        
        if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
            
            imagePickerController.navigationBar.tintColor = [[HTMIWFCSettingManager manager] blueColor];
        }
        else{
            
            imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
            
            //imagePickerController.navigationController.navigationBar.tintColor = [[HTMIWFCSettingManager manager] navigationBarColor];
            
        }
        
//        if ([[HTMIWFCSettingManager manager]navigationBarIsLightColor]) {
//            imagePickerController.navigationItem.leftBarButtonItem.tintColor = [[HTMIWFCSettingManager manager]blueColor];
//            imagePickerController.navigationItem.rightBarButtonItem.tintColor =[[HTMIWFCSettingManager manager]blueColor];
//        }
//        else{
//            imagePickerController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
//            imagePickerController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
//        }
        
        //判断是否可用
        BOOL isSourceTypeAvailable = [UIImagePickerController isSourceTypeAvailable:sourceType];
        
        if(!isSourceTypeAvailable){
            //不可用，直接抛出错误
            self.unavailableType=[self tranformHTMIWFCCorePhotoPickerVCMangerTypeForUnavailableType:managerType];
            NSLog(@"当前设备不可用:%@",@(managerType));
            return;
        }
        
        //错误处理完毕，配置照片选取控制器
        //类型
        imagePickerController.sourceType=sourceType;
        
        //允许编辑
        imagePickerController.allowsEditing=YES;
        
        //代理
        imagePickerController.delegate=self;
        
        //记录控制器
        self.imagePickerController=imagePickerController;
        
    }else if (HTMIWFCCorePhotoPickerVCMangerTypeMultiPhoto==_pickerVCManagerType){
        //这个是第三方多张照片选取器
        
        HTMIWFCUzysAssetsPickerController *multiImagePickerController=[[HTMIWFCUzysAssetsPickerController alloc] init];
        //记录控制器
        self.multiImagePickerController=multiImagePickerController;
        
        //暂不支持选视频
        multiImagePickerController.maximumNumberOfSelectionVideo=0;
        
        //初始化最大允许选取的图片数量
        multiImagePickerController.maximumNumberOfSelectionPhoto=MAXFLOAT;
        
        //设置代理
        multiImagePickerController.delegate=self;
        
        //记录控制器
        self.imagePickerController=multiImagePickerController;
        
    }else{
        //视频选取器，暂不支持
    }
}






-(void)setMaxSelectedPhotoNumber:(NSInteger)maxSelectedPhotoNumber{
    
    if(maxSelectedPhotoNumber<=0) return;
    
    //记录
    _maxSelectedPhotoNumber=maxSelectedPhotoNumber;
    
    if(self.multiImagePickerController==nil) return;
    
    //设置
    self.multiImagePickerController.maximumNumberOfSelectionPhoto=maxSelectedPhotoNumber;
}




#pragma mark  -系统自带控制器选取相册代理方法区
#pragma mark  选取了照片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //关闭自己
    [picker dismissViewControllerAnimated:YES completion:^{
        
        HTMIWFCCorePhoto *photo=[HTMIWFCCorePhoto photoWithInfoDict:info];
        
        if(self.finishPickingMedia != nil) _finishPickingMedia(@[photo]);
    }];
}

#pragma mark  点击了取消按钮
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    //直接取消
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 多选代理方法区

-(void)uzysAssetsPickerController:(HTMIWFCUzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    //获取相册数组
    NSArray *photos=[HTMIWFCCorePhoto photosWithAssets:assets];
    
    if(self.finishPickingMedia != nil) _finishPickingMedia(photos);
}

#pragma mark  超过选取上限
-(void)uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(HTMIWFCUzysAssetsPickerController *)picker{
    NSLog(@"超过选取上限");
}

#pragma mark  取消
-(void)uzysAssetsPickerControllerDidCancel:(HTMIWFCUzysAssetsPickerController *)picker{
    //直接取消：无需操作
}



/**
 *  HTMIWFCCorePhotoPickerVCMangerType 转 UIImagePickerControllerSourceType
 */
-(UIImagePickerControllerSourceType)tranformHTMIWFCCorePhotoPickerVCMangerTypeForSourceType:(HTMIWFCCorePhotoPickerVCMangerType)type{
    
    if(HTMIWFCCorePhotoPickerVCMangerTypeCamera == type) return UIImagePickerControllerSourceTypeCamera;
    
    if(HTMIWFCCorePhotoPickerVCMangerTypeSinglePhoto == type) return UIImagePickerControllerSourceTypePhotoLibrary;
    
    return 0;
}

/**
 *  HTMIWFCCorePhotoPickerVCMangerType 转 HTMIWFCCorePhotoPickerUnavailableType
 */
-(HTMIWFCCorePhotoPickerUnavailableType)tranformHTMIWFCCorePhotoPickerVCMangerTypeForUnavailableType:(HTMIWFCCorePhotoPickerVCMangerType)type{
    
    if(HTMIWFCCorePhotoPickerVCMangerTypeCamera == type) return HTMIWFCCorePhotoPickerUnavailableTypeCamera;
    
    if(HTMIWFCCorePhotoPickerVCMangerTypeSinglePhoto == type) return HTMIWFCCorePhotoPickerUnavailableTypePhoto;
    
    return 0;
}

@end
