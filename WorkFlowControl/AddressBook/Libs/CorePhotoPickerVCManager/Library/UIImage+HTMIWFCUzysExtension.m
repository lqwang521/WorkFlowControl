//
//  UIImage+HTMIWFCUzysExtension.m
//  HTMIWFCUzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import "UIImage+HTMIWFCUzysExtension.h"
#import "HTMIWFCUzysAssetsPickerController.h"

#import "UIImage+HTMIWFCWM.h"

@implementation UIImage (HTMIWFCUzysExtension)

+ (UIImage *)Uzys_imageNamed:(NSString *)imageName
{
    UIImage *image = [[self class] getPNGImageHTMIWFC:imageName];
    if (image) {
        return image;
    }
    //使用我们自己的bundle
    NSString *imagePathInControllerBundle = [NSString stringWithFormat:@"%@", imageName];
    image = [[self class] getPNGImageHTMIWFC:imagePathInControllerBundle];
    if(image) {
        return image;
    }
    //使用我们自己的bundle
    //for Swift podfile
    NSString *imagePathInBundleForClass = [NSString stringWithFormat:@"%@/%@", [[NSBundle bundleForClass:[HTMIWFCUzysAssetsPickerController class]] resourcePath], imageName ];
    image = [[self class] getPNGImageHTMIWFC:imagePathInBundleForClass];
    return image;
}
@end
