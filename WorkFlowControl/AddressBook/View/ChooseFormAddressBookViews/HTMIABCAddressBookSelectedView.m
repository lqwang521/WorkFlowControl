
#import "HTMIABCAddressBookSelectedView.h"

#import "HTMIABCOverlayView.h"
//other
#import "UIColor+HTMIWFCHex.h"
#import "UIImage+HTMIWFCWM.h"

/** 十六进制字符串转颜色 */
#define kColorWithString(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//等比布局使用
#define kW(R)  ((R)*(kScreenWidth)/320)
#define kH(R)  ((R)*(kScreenHeight)/568)

//表单部分zzg    处理方法：5\6一样，6p为他们的1.1倍
#define kW6(R) (IS_IPHONE_6P ? R*1.1 : R)
#define kH6(R) (IS_IPHONE_6P ? R*1.1 : R)

#define formLineWidth kW6(1.5)
#define formLineColor [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]
#define sidesPlace kW6(5)//label字体距两边的距离


#ifdef DEBUG

#define HTLog(...) NSLog(__VA_ARGS__)

#define HTLogDetail(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define HTLog(...)

#define HTLogDetail(fmt, ...)

#endif

#define ISFormType 1

// 2.获得RGB颜色
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)


#define ROW_HEIGHT 60.0

#define kTopCoverViewHight 104


@interface HTMIABCAddressBookSelectedView ()<HTMIABCReOrderTableViewDelegate>{
    
    
}

@property (nonatomic,strong) HTMIABCOverlayView *overlayView;

@property (nonatomic,strong) UILabel *countLabel;

@property (nonatomic,strong) UIButton *confirmButton;

@property (nonatomic,assign) NSInteger nTotal;

@property (nonatomic,strong) UIView *myCoverView;

@property (nonatomic,assign) BOOL up;

@end

@implementation HTMIABCAddressBookSelectedView


- (instancetype)initWithFrame:(CGRect)frame inView:(UIView *)parentView withObjects:(NSMutableArray *)objects
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentView = parentView;
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI
{
    //横线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    line.layer.borderColor = [UIColor lightGrayColor].CGColor;
    line.layer.borderWidth = 0.25;
    [self addSubview:line];
    
    [self addSubview:self.countLabel];
    [self addSubview:self.confirmButton];
    [self addSubview:self.shoppingCartBtn];
    
    if (!_badge) {
        _badge = [[HTMIABCSelectedBadgeView alloc] initWithFrame:CGRectMake(self.shoppingCartBtn.frame.size.width - 15 -3, 5, 15, 15) withString:nil];
        [self.shoppingCartBtn addSubview:_badge];
    }
    
    int maxHeight = 300;
    self.htmiReOrderTableView = [[HTMIABCReOrderTableView alloc] initWithFrame:CGRectMake(0,self.parentView.bounds.size.height - maxHeight, self.bounds.size.width, maxHeight) withObjects:nil canReorder:YES];
    self.htmiReOrderTableView.delegate = self;
    
    self.overlayView = [[HTMIABCOverlayView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.overlayView.ShoppingCartView = self;
    [self.overlayView addSubview:self];
    [self.parentView addSubview:self.overlayView];
    
    self.overlayView.alpha = 0.0;
    
    self.up = NO;
}


#pragma mark - private method

- (void)setCartImage:(NSString *)imageName
{
    [self.shoppingCartBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:imageName] forState:UIControlStateNormal];
}

- (void)clickCartBtn:(UIButton *)sender
{
    
    if (![_badge.htmiBadgeValue intValue]) {
        [self.shoppingCartBtn setUserInteractionEnabled:NO];
        return;
    }
    
    [self updateFrame:self.htmiReOrderTableView];
    [self.overlayView addSubview:self.htmiReOrderTableView];
    [self.window insertSubview:self.myCoverView belowSubview:self.overlayView];
    
    self.overlayView.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint point = self.shoppingCartBtn.center;
        CGPoint labelPoint = self.countLabel.center;
        
        point.y -= (self.htmiReOrderTableView.frame.size.height + 25);
        labelPoint.x -= 60;
        
        [self.shoppingCartBtn setCenter:point];
        [self.countLabel setCenter:labelPoint];
        
        
    } completion:^(BOOL finished) {
        
        self.up = YES;
    }];
}

- (void)updateFrame:(UIView *)view
{
    float height = 0;
    int nRow =  [self.htmiReOrderTableView.objects count];
    
    height = nRow * ROW_HEIGHT + 30; //+ nSection * SECTION_HEIGHT;
    int maxHeight = 300;//self.parentView.frame.size.height - 240;
    if (height >= maxHeight) {
        height = maxHeight;
    }
    
    if (nRow <= 0) {
        [self dismissAnimated:YES];
    }
    else{
        //初始Y
        float orignY = self.htmiReOrderTableView.frame.origin.y;
        self.htmiReOrderTableView.frame = CGRectMake(self.htmiReOrderTableView.frame.origin.x, self.frame.origin.y - height, self.htmiReOrderTableView.frame.size.width, height);
        
        float currentY = self.htmiReOrderTableView.frame.origin.y;
        if (self.up) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CGPoint point = self.shoppingCartBtn.center;
                point.y -= orignY - currentY;
                [self.shoppingCartBtn setCenter:point];
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

#pragma mark - dismiss
- (void)dismissAnimated:(BOOL)animated
{
    [self.myCoverView removeFromSuperview];
    self.overlayView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        
        CGPoint point = self.shoppingCartBtn.center;
        CGPoint labelPoint = self.countLabel.center;
        point.y += (self.htmiReOrderTableView.frame.size.height + 25);
        labelPoint.x += 60;
        [self.shoppingCartBtn setCenter:point];
        [self.countLabel setCenter:labelPoint];
        
    } completion:^(BOOL finished) {
        self.up = NO;
    }];
}

- (void)setSelectedCountWithCountNumber:(NSInteger)nTotal
{
    _nTotal = nTotal;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    
    NSString *amount = [formatter stringFromNumber:[NSNumber numberWithInteger:nTotal]];
    if(nTotal > 0)
    {
        self.countLabel.font = [UIFont systemFontOfSize:15.0f];
        self.countLabel.textColor = [UIColor colorWithHex:@"#333333"];
        self.countLabel.text = [NSString stringWithFormat:@"已选择%@",amount];
        self.confirmButton.enabled = YES;
        [self.confirmButton setBackgroundColor:[UIColor colorWithHex:@"#297BFB"]];
        //        if ([kApplicationHue isEqualToString:@"_white"]) {//如果是白色色调就用蓝色
        //             [self.confirmButton setBackgroundColor:[UIColor colorWithHex:@"#297BFB"]];
        //        }
        //        else{
        //            [self.confirmButton setBackgroundColor:navBarColor];
        //        }
        [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.shoppingCartBtn setUserInteractionEnabled:YES];
    }
    else
    {
        [self.countLabel setTextColor:[UIColor colorWithHex:@"#999999"]];
        [self.countLabel setText:@"已选择0"];
        [self.countLabel setFont:[UIFont systemFontOfSize:15.0]];
        self.confirmButton.enabled = NO;
        [self.confirmButton setBackgroundColor:[UIColor colorWithHex:@"#CCCCCC"]];
        [self.confirmButton setTitle:@"未选择" forState:UIControlStateNormal];
        [self.shoppingCartBtn setUserInteractionEnabled:NO];
    }
}

- (void)clickConfirm:(UIButton *)sender
{
    [self dismissAnimated:YES];
    
    //发送确定选择通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_SelectedDone" object:nil userInfo:nil];
}

#pragma mark - Getter Setter

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        //确认按钮
        _confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _confirmButton.frame = CGRectMake(self.bounds.size.width - 110, 0, 110,50);
        _confirmButton.backgroundColor = [UIColor colorWithHex:@"#CCCCCC"];
        [_confirmButton setTitle:[NSString stringWithFormat:@"未选择"] forState:UIControlStateNormal];
        
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [_confirmButton addTarget:self action:@selector(clickConfirm:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.enabled = NO;
    }
    return _confirmButton;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, self.bounds.size.width, 30)];
        [_countLabel setTextColor:[UIColor grayColor]];
        [_countLabel setText:@"已选择0"];
        [_countLabel setFont:[UIFont systemFontOfSize:15.0]];
    }
    return _countLabel;
}

- (UIView *)myCoverView{
    if (!_myCoverView) {
        _myCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth,kTopCoverViewHight)];
        _myCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _myCoverView.alpha = 1.0;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAnimated:)];
        [_myCoverView addGestureRecognizer:gesture];
        
    }
    return _myCoverView;
}

- (UIButton *)shoppingCartBtn{
    if (!_shoppingCartBtn) {
        _shoppingCartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shoppingCartBtn setUserInteractionEnabled:NO];
        [_shoppingCartBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"icon_personnel_normal"] forState:UIControlStateNormal];
        _shoppingCartBtn.frame = CGRectMake(10,-15,60,60);
        [_shoppingCartBtn addTarget:self action:@selector(clickCartBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shoppingCartBtn;
}


@end
