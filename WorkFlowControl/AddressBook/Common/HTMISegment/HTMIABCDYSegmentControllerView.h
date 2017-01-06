

#import <UIKit/UIKit.h>
typedef void(^BtnClick)(UIButton *button);

typedef enum : NSUInteger {
    DYSementStyleDefault,
    DYSementStyleWidthEqual, //必须设置buttonWidth，默认60
    DYSementStyleWidthEqualFull,
} DYSementStyle;

@interface HTMIABCDYSegmentControllerView : UIScrollView


@property (nonatomic, assign) CGFloat buttonWidth;/**< 自动 */
@property (nonatomic, assign) CGFloat lineWidth;/**< 默认等于 button 宽 */
@property (nonatomic, assign) CGFloat space;/**< 间距，默认25 */

@property (nonatomic, strong) UIColor *selectedColor;/**< 默认 red */
@property (nonatomic, strong) UIColor *unselectedColor;/**< default black */
@property (nonatomic, strong) UIFont *titleFont;/**< 14 */



- (instancetype)initWithStyle:(DYSementStyle)style;

- (void)setTitleArr:(NSArray *)titleArr andBtnBlock:(BtnClick)btnClick;

- (void)updateSelecterToolsIndex:(NSInteger )index;


@end
