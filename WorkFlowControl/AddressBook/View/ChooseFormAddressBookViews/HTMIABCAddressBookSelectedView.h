
#import <UIKit/UIKit.h>

#import "HTMIABCReOrderTableView.h"
#import "HTMIABCSelectedBadgeView.h"

@interface HTMIABCAddressBookSelectedView : UIView

@property (nonatomic,strong) HTMIABCSelectedBadgeView *badge;
@property (nonatomic,strong) UIButton *shoppingCartBtn;
@property (nonatomic,strong) UIView *parentView;
@property (nonatomic,strong) HTMIABCReOrderTableView *htmiReOrderTableView;


- (instancetype) initWithFrame:(CGRect)frame inView:(UIView *)parentView withObjects:(NSMutableArray *)objects;

- (void)updateFrame:(UIView *)view;

- (void)setSelectedCountWithCountNumber:(NSInteger)nTotal;

- (void)setCartImage:(NSString *)imageName;

- (void)dismissAnimated:(BOOL) animated;
@end
