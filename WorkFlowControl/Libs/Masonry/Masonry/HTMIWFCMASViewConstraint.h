//
//  HTMIWFCMASConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "HTMIWFCMASViewAttribute.h"
#import "HTMIWFCMASConstraint.h"
#import "HTMIWFCMASLayoutConstraint.h"
#import "HTMIWFCMASUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface HTMIWFCMASViewConstraint : HTMIWFCMASConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *secondViewAttribute;

/**
 *	initialises the HTMIWFCMASViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.mas_left, view.mas_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(HTMIWFCMASViewAttribute *)firstViewAttribute;

/**
 *  Returns all HTMIWFCMASViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of HTMIWFCMASViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(MAS_VIEW *)view;

@end
