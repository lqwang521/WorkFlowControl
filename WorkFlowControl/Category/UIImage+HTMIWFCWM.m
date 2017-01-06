//
//  UIImage+HTMIWFCWM.m
//  QQSlideMenu
//
//  Created by wamaker on 15/6/22.
//  Copyright (c) 2015年 wamaker. All rights reserved.
//

#import "UIImage+HTMIWFCWM.h"

#import "NSString+HTMIWFCExtention.h"
#import "UIColor+HTMIWFCHex.h"

#import "HTMIWFCSettingManager.h"

@implementation UIImage (HTMIWFCWM)


+(UIImage*)getPNGImageHTMIWFC:(NSString *)_image_name
{
    NSString * imageNameString = [NSString stringWithFormat:@"%@%@",@"WorkFlowControlResources.bundle/",_image_name];
    
    return [UIImage imageNamed:imageNameString];
}

+(UIImage*)getJPGImageHTMIWFC:(NSString*)_image_name
{
    NSBundle*bundle=[self getBundleHTMIWFC:@"WorkFlowControlResources"];
    
    NSString*imgPath=[bundle pathForResource:_image_name ofType:@"jpg"];
    
    return[UIImage imageWithContentsOfFile:imgPath];
}

+(NSBundle*)getBundleHTMIWFC:(NSString*)_bundle_name
{
    //NSLog(@"mainBundleresourcePath=%@",[NSBundle mainBundle].resourcePath);
    /*从mainBundle获取tuxiang.bundle*/
    //方法1
    //NSString*component=[NSStringstringWithFormat:@"%@.bundle",_bundle_name];
    //NSString*bundlePath=[[NSBundlemainBundle].resourcePathstringByAppendingPathComponent:component];
    //方法2
    //    NSString*bundlePath=[[NSBundle mainBundle]pathForResource:_bundle_name ofType:@"bundle"];
    //    NSBundle*bundle=[NSBundle bundleWithPath:bundlePath];
    //方法3
    NSBundle * bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"WorkFlowControlResources" withExtension:@"bundle"]];
    return bundle;
}

+ (UIImage *)imageWithRenderColorHTMIWFC:(UIColor *)color renderSize:(CGSize)size
{
    
    UIImage *image = nil;
    UIGraphicsBeginImageContext(size);
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0., 0., size.width, size.height));
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithStringHTMIWFC:(NSString *)string width:(CGFloat)width type:(HeaderImageType)type withColor:(UIColor *)clor
{
    UIImage *image = nil;
    UIColor *color = nil;
    
    switch (type) {
        case HeaderImageTypeDefault:
            return [[UIImage getPNGImageHTMIWFC:@"mx_no_face_phone"] circleImageHTMIWFC];
            break;
        case HeaderImageTypeFirstChar:
            if(string.length > 0){
                //取第一个
                string = [string substringWithRange:NSMakeRange(0, 1)];
            }
            break;
        case HeaderImageTypeLastOne:
            if(string.length > 0){
                //取最后一个
                string = [string substringWithRange:NSMakeRange(string.length - 1, 1)];
            }
            break;
        case HeaderImageTypeLastTwo:
            if(string.length > 2){
                //取末两位
                string = [string substringWithRange:NSMakeRange(string.length - 2, 2)];
            }
            break;
        default:
            break;
    }
    
    if(clor){
        color = clor;
    }else{
        
        //生成三倍图
        //width *=  3; wlq 注释
        ///取名字的32位md5最后一位  对应的  ASCII 十进制值 的末尾值 ( 0 - 9 ) 对应的颜色为底色
        NSInteger index = (NSInteger)[[string md5_32] characterAtIndex:31];
        //取到对应的index
        index = index % 10;
        //约定的颜色值
        NSString *colorHex = @"0DB8F6,00D3A3,FCD240,F26C13,EE523D,4C90FB,FFBF45,48A6DF,00B25E,EC606C";
        NSArray *colorHexArray = [colorHex componentsSeparatedByString:@","];
        //取到颜色值
        color = [UIColor colorFromHexCode:[colorHexArray objectAtIndex:index]];
    }
    
    CGRect rect = CGRectMake(0, 0, width, width);
    
    //UIGraphicsBeginImageContext(rect.size);//这个方法获取的图片发虚
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIColor *stringColor = [UIColor whiteColor];  //设置文本的颜色
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    NSDictionary* attrs =@{NSForegroundColorAttributeName:stringColor,
                           NSFontAttributeName:font,
                           };
    CGSize size = [string textSizeWithFont:font forWidth:40];
    
    CGRect stringRect = CGRectMake((rect.size.width - size.width )/ 2, (rect.size.width - size.height) / 2, size.width, size.height);
    
    [string drawInRect:stringRect withAttributes:attrs];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;//[image circleImageHTMIWFC]; 控件设置圆角了，不需要再设置图片圆角了
}

/**
 *  返回圆形图像, 若图像不为正方形，则截取中央正方形
 *
 *  @param original 原始的ImageView，用于获取大小
 *
 *  @return 修正好的图片
 */
- (instancetype)roundImage {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat compare = self.size.width + self.size.height;
    CGFloat circleW, circleX, circleY;
    if (compare > 0) {
        circleW = self.size.height;
        circleY = 0;
        circleX = (self.size.width + circleW) / 2.0;
    } else if (compare == 0) {
        circleW = self.size.width;
        circleX = circleY = 0;
    } else {
        circleW = self.size.width;
        circleX = 0;
        circleY = (self.size.height + circleW) / 2.0;
    }
    CGRect circleRect = CGRectMake(circleX, circleY, circleW, circleW);
    CGContextAddEllipseInRect(ctx, circleRect);
    CGContextClip(ctx);
    
    [self drawInRect:circleRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius {
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    imageLayer.contents = (id) self.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = cornerRadius;
    
    UIGraphicsBeginImageContext(self.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}


- (UIImage *)circleImageHTMIWFC {
    
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    // 获得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置一个范围
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // 根据一个rect创建一个椭圆
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪
    CGContextClip(ctx);
    
    // 将原照片画到图形上下文
    [self drawInRect:rect];
    
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  获取图片，根据当前的色调
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
+ (UIImage *)imageWithViewHueHTMIWFC:(NSString *)imageName{
    
    NSMutableString * imageNameEndString = [NSMutableString stringWithString:imageName];
    
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        
        [imageNameEndString appendString:@"_blue"];
    }
    else{
        [imageNameEndString appendString:@"_white"];
    }
    
    UIImage * image = [[self class]imageNamed:imageNameEndString];
    
    return image;
}

/**
 *  导航栏获取图片，根据当前的色调
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
+ (UIImage *)imageNavigationWithViewHueHTMIWFC:(NSString *)imageName{
    
    NSMutableString * imageNameEndString = [NSMutableString stringWithString:imageName];
    
    if ([[HTMIWFCSettingManager manager] navigationBarIsLightColor]) {
        
        [imageNameEndString appendString:@"_blue"];
    }
    else{
        [imageNameEndString appendString:@"_white"];
    }
    
    
    UIImage * image = [[self class] getPNGImageHTMIWFC:imageNameEndString];
    
    return image;
}

/**
 *  获取图片，根据当前的风格进行图片名拼接
 *
 *  @param imageName 图片名
 *
 *  @return 图片
 */
+ (UIImage *)imageWithViewStyleHTMIWFC:(NSString *)imageName{
    
    NSMutableString * imageNameEndString = [NSMutableString stringWithString:imageName];
    
    //拼接图片名
    NSString * viewStyleString = @"4";//[HTMIABCUserdefault defaultLoadViewStyle];
    
    //应该有一个默认Style
    if (viewStyleString.length > 0) {
        
        [imageNameEndString appendString:@"_style"];
        [imageNameEndString appendString:@"4"];//写死的就是4
    }
    
    UIImage * image = [[self class]imageNamed:imageNameEndString];
    
    return image;
}


//获取某个特定View里的图片
+ (UIImage*)captureViewHTMIWFC:(UIView *)theView
{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//自定义长宽的图片
+ (UIImage *)reSizeImageHTMIWFC:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImageHTMIWFC = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImageHTMIWFC;
}

+ (UIImage *)imageFromBaseString:(NSString *)imageBaseString{
    
    if (!imageBaseString) {
        return nil;
    }
    NSData * decodedImageData   = [[NSData alloc] initWithBase64EncodedString:imageBaseString options:0];
    
    UIImage * decodedImage      = [UIImage imageWithData:decodedImageData];
    
    NSLog(@"===Decoded image size: %@", NSStringFromCGSize(decodedImage.size));
    
    return decodedImage;
    
}

+ (NSString *)baseStringFromImage:(UIImage *)originImage{
    
    if (!originImage) {
        return @"";
    }
    NSData *imageData = UIImageJPEGRepresentation(originImage, 1.0f);
    
    NSString *encodedImageString = [imageData base64EncodedStringWithOptions:0];
    
    NSLog(@"===Encoded image:\n%@", encodedImageString);
    
    return encodedImageString;
}


@end
