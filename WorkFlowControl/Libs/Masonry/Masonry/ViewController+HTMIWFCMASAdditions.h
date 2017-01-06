//
//  UIViewController+HTMIWFCMASAdditions.h
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "HTMIWFCMASUtilities.h"
#import "HTMIWFCMASConstraintMaker.h"
#import "HTMIWFCMASViewAttribute.h"

#ifdef MAS_VIEW_CONTROLLER

@interface MAS_VIEW_CONTROLLER (HTMIWFCMASAdditions)

/**
 *	following properties return a new HTMIWFCMASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *mas_topLayoutGuide;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *mas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *mas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *mas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *mas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) HTMIWFCMASViewAttribute *mas_bottomLayoutGuideBottom;


@end

#endif
