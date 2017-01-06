//
//  NSMutableArray+HTMIWFCaddImage.m
//  HTMIWFCDCPathButton
//
//  Created by Paul on 3/25/13.
//  Copyright (c) 2013 Paul. All rights reserved.
//

#import "NSMutableArray+HTMIWFCaddImage.h"

@implementation NSMutableArray (HTMIWFCaddImage)

+ (NSMutableArray *)arrayContainImages:(NSUInteger)capacity{
    return [NSMutableArray arrayWithCapacity:capacity];
}

//- (void)addImage:(NSString *)imageName{
//    UIImage *image = [UIImage getPNGImageHTMIWFC:imageName];
//    [self addObject:image];
//}

@end
