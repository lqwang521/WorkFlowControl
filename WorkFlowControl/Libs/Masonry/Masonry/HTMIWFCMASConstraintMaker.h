//
//  HTMIWFCMASConstraintBuilder.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "HTMIWFCMASConstraint.h"
#import "HTMIWFCMASUtilities.h"

typedef NS_OPTIONS(NSInteger, MASAttribute) {
    MASAttributeLeft = 1 << NSLayoutAttributeLeft,
    MASAttributeRight = 1 << NSLayoutAttributeRight,
    MASAttributeTop = 1 << NSLayoutAttributeTop,
    MASAttributeBottom = 1 << NSLayoutAttributeBottom,
    MASAttributeLeading = 1 << NSLayoutAttributeLeading,
    MASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    MASAttributeWidth = 1 << NSLayoutAttributeWidth,
    MASAttributeHeight = 1 << NSLayoutAttributeHeight,
    MASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    MASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    MASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if TARGET_OS_IPHONE || TARGET_OS_TV
    
    MASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    MASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    MASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    MASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    MASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    MASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    MASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    MASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating HTMIWFCMASConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface HTMIWFCMASConstraintMaker : NSObject

/**
 *	The following properties return a new HTMIWFCMASViewConstraint
 *  with the first item set to the makers associated view and the appropriate HTMIWFCMASViewAttribute
 */
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *left;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *top;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *right;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *bottom;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *leading;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *trailing;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *width;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *height;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *centerX;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *centerY;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *baseline;

#if TARGET_OS_IPHONE || TARGET_OS_TV

@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *leftMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *rightMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *topMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new HTMIWFCMASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  MASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *(^attributes)(MASAttribute attrs);

/**
 *	Creates a HTMIWFCMASCompositeConstraint with type HTMIWFCMASCompositeConstraintTypeEdges
 *  which generates the appropriate HTMIWFCMASViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *edges;

/**
 *	Creates a HTMIWFCMASCompositeConstraint with type HTMIWFCMASCompositeConstraintTypeSize
 *  which generates the appropriate HTMIWFCMASViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *size;

/**
 *	Creates a HTMIWFCMASCompositeConstraint with type HTMIWFCMASCompositeConstraintTypeCenter
 *  which generates the appropriate HTMIWFCMASViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) HTMIWFCMASConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any MASConstrait are created with this view as the first item
 *
 *	@return	a new HTMIWFCMASConstraintMaker
 */
- (id)initWithView:(MAS_VIEW *)view;

/**
 *	Calls install method on any HTMIWFCMASConstraints which have been created by this maker
 *
 *	@return	an array of all the installed HTMIWFCMASConstraints
 */
- (NSArray *)install;

- (HTMIWFCMASConstraint * (^)(dispatch_block_t))group;

@end
