//
//  UIView+HTMIWFCMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+HTMIWFCMASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface MAS_VIEW (MASShorthandAdditions)

@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *left;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *top;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *right;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *bottom;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *leading;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *trailing;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *width;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *height;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *centerX;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *centerY;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *baseline;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if TARGET_OS_IPHONE || TARGET_OS_TV

@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *centerYWithinMargins;

#endif

- (NSArray *)makeConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block;

@end

#define MAS_ATTR_FORWARD(attr)  \
- (HTMIWFCMASViewAttribute *)attr {    \
    return [self mas_##attr];   \
}

@implementation MAS_VIEW (HTMIWFCMASShorthandAdditions)

MAS_ATTR_FORWARD(top);
MAS_ATTR_FORWARD(left);
MAS_ATTR_FORWARD(bottom);
MAS_ATTR_FORWARD(right);
MAS_ATTR_FORWARD(leading);
MAS_ATTR_FORWARD(trailing);
MAS_ATTR_FORWARD(width);
MAS_ATTR_FORWARD(height);
MAS_ATTR_FORWARD(centerX);
MAS_ATTR_FORWARD(centerY);
MAS_ATTR_FORWARD(baseline);

#if TARGET_OS_IPHONE || TARGET_OS_TV

MAS_ATTR_FORWARD(leftMargin);
MAS_ATTR_FORWARD(rightMargin);
MAS_ATTR_FORWARD(topMargin);
MAS_ATTR_FORWARD(bottomMargin);
MAS_ATTR_FORWARD(leadingMargin);
MAS_ATTR_FORWARD(trailingMargin);
MAS_ATTR_FORWARD(centerXWithinMargins);
MAS_ATTR_FORWARD(centerYWithinMargins);

#endif

- (HTMIWFCMASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(^)(HTMIWFCMASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(HTMIWFCMASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(HTMIWFCMASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
