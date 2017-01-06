

#import <UIKit/UIKit.h>

typedef void(^ScrollPage)(int);

@interface HTMIABCDYSegmentContainerlView : UIScrollView

- (void)updateVCViewFromIndex:(NSInteger )index;

- (instancetype)initWithSeleterConditionTitleArr:(NSArray *)vcArr andBtnBlock:(ScrollPage)page;

@end
