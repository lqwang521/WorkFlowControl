//
//  UIViewController+HTMIWFCMASAdditions.m
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+HTMIWFCMASAdditions.h"

#ifdef MAS_VIEW_CONTROLLER

@implementation MAS_VIEW_CONTROLLER (HTMIWFCMASAdditions)

- (HTMIWFCMASViewAttribute *)mas_topLayoutGuide {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (HTMIWFCMASViewAttribute *)mas_topLayoutGuideTop {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (HTMIWFCMASViewAttribute *)mas_topLayoutGuideBottom {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (HTMIWFCMASViewAttribute *)mas_bottomLayoutGuide {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (HTMIWFCMASViewAttribute *)mas_bottomLayoutGuideTop {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (HTMIWFCMASViewAttribute *)mas_bottomLayoutGuideBottom {
    return [[HTMIWFCMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
