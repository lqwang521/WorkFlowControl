//
//  UIImage+HTMIWFCWM.h
//  QQSlideMenu
//
//  Created by wamaker on 15/6/22.
//  Copyright (c) 2015年 wamaker. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "HTMIABCHeaderImageType.h"

#import "HTMIABCHeaderImageType.h"

@interface UIImage (HTMIWFCWM)

- (instancetype)roundImage;

+(UIImage*)getPNGImageHTMIWFC:(NSString*)_image_name;

+(UIImage*)getJPGImageHTMIWFC:(NSString*)_image_name;

+(NSBundle*)getBundleHTMIWFC:(NSString*)_bundle_name;

/**
 *  根据颜色生成图片
 *
 *  @param color 色值
 *  @param size  大小
 *
 *  @return 图片
 */
+ (UIImage *)imageWithRenderColorHTMIWFC:(UIColor *)color renderSize:(CGSize)size;

+ (UIImage *)imageWithStringHTMIWFC:(NSString *)string width:(CGFloat)width type:(HeaderImageType)type withColor:(UIColor *)clor;

/**
 *  获取图片，根据当前的色调
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
+ (UIImage *)imageWithViewHueHTMIWFC:(NSString *)imageName;

/**
 *  导航栏获取图片，根据当前的色调
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
+ (UIImage *)imageNavigationWithViewHueHTMIWFC:(NSString *)imageName;

/**
 *  获取图片，根据当前的风格进行图片名拼接
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
+ (UIImage *)imageWithViewStyleHTMIWFC:(NSString *)imageName;

- (UIImage *)circleImageHTMIWFC;

- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius;

//获取某个特定View里的图片
+ (UIImage*)captureViewHTMIWFC:(UIView *)theView;

//自定义长宽的图片
+ (UIImage *)reSizeImageHTMIWFC:(UIImage *)image toSize:(CGSize)reSize;

/**
 *  base64字符串转Image
 *
 *  @param imageBaseString base64字符串
 *
 *  @return Image
 */
+ (UIImage *)imageFromBaseString:(NSString *)imageBaseString;

/**
 *  Image转base64字符串
 *
 *  @param originImage Image
 *
 *  @return base64字符串
 */
+ (NSString *)baseStringFromImage:(UIImage *)originImage;


@end
