//
//  HTMIWFCMASCompositeConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "HTMIWFCMASConstraint.h"
#import "HTMIWFCMASUtilities.h"

/**
 *	A group of HTMIWFCMASConstraint objects
 */
@interface HTMIWFCMASCompositeConstraint : HTMIWFCMASConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child HTMIWFCMASConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
