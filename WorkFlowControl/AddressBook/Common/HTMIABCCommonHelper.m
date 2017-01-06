//
//  HTMIABCCommonHelper.m
//  Express
//
//  Created by admin on 15/11/13.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "HTMIABCCommonHelper.h"

@implementation HTMIABCCommonHelper

-(instancetype)init{
    
    if (self = [super init]) {
        //wlq add 图片缓存路径
        NSString *path_sandox = NSHomeDirectory();
        //设置一个图片的存储路径
        NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/"];
        
        _imageCachePath = [imagePath copy];
    }
    return self;
}

/**
 *  验证手机号
 *
 *  @param Phone 手机号码
 *
 *  @return 是否符合条件
 */
+ (BOOL)isValidatePhone:(NSString *)Phone {
    
    NSString *phoneRegex = @"^(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$";

    NSPredicate * phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:Phone];
}

/**
 *  验证邮箱
 *
 *  @param email 邮箱
 *
 *  @return 是否符合条件
 */
+ (BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**
 *  隐藏键盘
 */
+ (void)hideKeyBoard{
    //发出退出键盘通知
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

+ (instancetype)getInstance {
    static HTMIABCCommonHelper *common;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        common = [[HTMIABCCommonHelper alloc] init];
  
    });
    
    return common;
}

+ (UIImage *)getImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor *)getRandomColor
{
    return [UIColor colorWithRed:(float)(1+arc4random()%99)/100 green:(float)(1+arc4random()%99)/100 blue:(float)(1+arc4random()%99)/100 alpha:1];
}

/*0--1 : lerp( float percent, float x, float y ){ return x + ( percent * ( y - x ) ); };*/
+ (float)lerp:(float)percent min:(float)nMin max:(float)nMax
{
    float result = nMin;
    
    result = nMin + percent * (nMax - nMin);
    
    return result;
}

+ (NSString *)getImageCachePath{
    
    HTMIABCCommonHelper * temp = [HTMIABCCommonHelper getInstance];
    return temp.imageCachePath;
}



@end
