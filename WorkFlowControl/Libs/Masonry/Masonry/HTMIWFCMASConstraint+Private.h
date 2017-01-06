//
// HTMIWFCMASConstraint+Private.h
//  Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "HTMIWFCMASConstraint.h"

@protocol HTMIWFCMASConstraintDelegate;


@interface HTMIWFCMASConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually HTMIWFCMASConstraintMaker but could be a parent HTMIWFCMASConstraint
 */
@property (nonatomic, weak) id<HTMIWFCMASConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with MASEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface HTMIWFCMASConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    HTMIWFCMASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (HTMIWFCMASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (HTMIWFCMASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol HTMIWFCMASConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A HTMIWFCMASViewConstraint may turn into a HTMIWFCMASCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(HTMIWFCMASConstraint *)constraint shouldBeReplacedWithConstraint:(HTMIWFCMASConstraint *)replacementConstraint;

- (HTMIWFCMASConstraint *)constraint:(HTMIWFCMASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
