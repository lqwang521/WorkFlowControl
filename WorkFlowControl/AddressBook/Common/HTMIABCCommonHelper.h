//
//  HTMIABCCommonHelper.h
//  Express
//
//  Created by admin on 15/11/13.
//  Copyright © 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface HTMIABCCommonHelper : NSObject

@property (assign, nonatomic) CGFloat screenW;          // 屏幕宽度
@property (assign, nonatomic) CGFloat screenH;          // 屏幕高度


+ (instancetype)getInstance;

+ (BOOL)isValidatePhone:(NSString *)Phone;

+ (BOOL)isValidateEmail:(NSString *)email;

+ (void)hideKeyBoard;


//将view转为image
+ (UIImage *)getImageFromView:(UIView *)view;

//获取随机颜色color
+ (UIColor *)getRandomColor;

//根据比例（0...1）在min和max中取值
+ (float)lerp:(float)percent min:(float)nMin max:(float)nMax;

+ (NSString *)getImageCachePath;

//图片缓存路径
@property (copy, nonatomic,readonly) NSString * imageCachePath;

@end
