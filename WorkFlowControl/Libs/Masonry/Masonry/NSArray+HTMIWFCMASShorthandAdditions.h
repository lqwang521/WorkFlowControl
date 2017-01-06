//
//  NSArray+HTMIWFCMASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+HTMIWFCMASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface NSArray (HTMIWFCMASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(HTMIWFCMASConstraintMaker *make))block;

@end

@implementation NSArray (MASShorthandAdditions)

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
