

#import <UIKit/UIKit.h>

@interface HTMIABCSelectedBadgeView : UIView

-(instancetype)initWithFrame:(CGRect)frame withString:(NSString *)string;

-(instancetype)initWithFrame:(CGRect)frame withString:(NSString *)string withTextColor:(UIColor *)textColor;

@property (nonatomic,strong) NSString *htmiBadgeValue;

@end
