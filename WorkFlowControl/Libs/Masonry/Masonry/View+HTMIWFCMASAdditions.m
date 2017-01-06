//
//  UIView+HTMIWFCMASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+HTMIWFCMASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (HTMIWFCMASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(HTMIWFCMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    HTMIWFCMASConstraintMaker *constraintMaker = [[HTMIWFCMASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(HTMIWFCMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    HTMIWFCMASConstraintMaker *constraintMaker = [[HTMIWFCMASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    HTMIWFCMASConstraintMaker *constraintMaker = [[HTMIWFCMASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (HTMIWFCMASViewAttribute *)mas_left {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (HTMIWFCMASViewAttribute *)mas_top {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (HTMIWFCMASViewAttribute *)mas_right {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (HTMIWFCMASViewAttribute *)mas_bottom {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (HTMIWFCMASViewAttribute *)mas_leading {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (HTMIWFCMASViewAttribute *)mas_trailing {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (HTMIWFCMASViewAttribute *)mas_width {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (HTMIWFCMASViewAttribute *)mas_height {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (HTMIWFCMASViewAttribute *)mas_centerX {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (HTMIWFCMASViewAttribute *)mas_centerY {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (HTMIWFCMASViewAttribute *)mas_baseline {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (HTMIWFCMASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (HTMIWFCMASViewAttribute *)mas_leftMargin {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (HTMIWFCMASViewAttribute *)mas_rightMargin {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (HTMIWFCMASViewAttribute *)mas_topMargin {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (HTMIWFCMASViewAttribute *)mas_bottomMargin {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (HTMIWFCMASViewAttribute *)mas_leadingMargin {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (HTMIWFCMASViewAttribute *)mas_trailingMargin {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (HTMIWFCMASViewAttribute *)mas_centerXWithinMargins {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (HTMIWFCMASViewAttribute *)mas_centerYWithinMargins {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
    MAS_VIEW *closestCommonSuperview = nil;

    MAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        MAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
