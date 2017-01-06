

#import "HTMIABCSelectedFromAddressBookTableViewCell.h"

#import "HTMIABCDynamicTreeNode.h"

#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_DepartmentModel.h"

//other
#import "UIImageView+HTMIWFCWebCache.h"

#import "UIColor+HTMIWFCHex.h"

#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCSettingManager.h"

//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]

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




//start 定义弱引用和强引用

#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif

//end

@interface  HTMIABCSelectedFromAddressBookTableViewCell()

@property (strong,nonatomic)UIButton * deleteButton;

@property (strong,nonatomic)UIImageView * headerImageView;

@property (strong,nonatomic)UILabel * nameLabel;
@property (strong,nonatomic)UIView * splitView;

@end

@implementation HTMIABCSelectedFromAddressBookTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.deleteButton = [[UIButton alloc] init];
        self.deleteButton.frame = CGRectMake(kScreenWidth - 84, 0, 60, 60);
        self.deleteButton.backgroundColor = [UIColor clearColor];
        [self.deleteButton setImage:[UIImage getPNGImageHTMIWFC:@"Home_delete_icon"]  forState:UIControlStateNormal];
        [self.deleteButton setImage:[UIImage getPNGImageHTMIWFC:@"Home_delete_icon"]  forState:UIControlStateSelected];
        [self.deleteButton addTarget:self action:@selector(clickDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteButton];
        
        
        self.headerImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.headerImageView];
        

        
        self.nameLabel = [[UILabel alloc]init];
        
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        self.nameLabel.textColor = [UIColor colorWithHex:@"#666666"];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.nameLabel];
        
        
        self.splitView = [[UIView alloc]initWithFrame:CGRectMake(0, 59, kScreenWidth, 1)];
        self.splitView.backgroundColor = RGB(239, 240, 240);
        [self.contentView addSubview:self.splitView];
        
        
        
    }
    
    return self;
}

- (void)clickDelete:(id)sender{
    
    if (self.deleteBlock != nil) {
        self.deleteBlock(self);
    }
}

- (void)dealloc{
    HTLog(@"%@",@"HTMIABCSelectedFromAddressBookTableViewCell");
}

- (void)setHtmiDynamicTreeNode:(HTMIABCDynamicTreeNode *)htmiDynamicTreeNode{
    
    _htmiDynamicTreeNode = htmiDynamicTreeNode;
    if (_htmiDynamicTreeNode.isDepartment == NO) {//人员选择
        HTMIABCSYS_UserModel * model = (HTMIABCSYS_UserModel *)_htmiDynamicTreeNode.model;
        
        if (!model.headerBackGroundColor) {
            model.headerBackGroundColor = [[HTMIWFCSettingManager manager] randomColor] ;
        }
        
        //控制显示
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,model.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:model.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType]  withColor:model.headerBackGroundColor]];
        self.nameLabel.text = model.FullName;
        self.headerImageView.hidden = NO;
        self.headerImageView.frame = CGRectMake(12, 10, 40, 40);
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerImageView.frame) + 12/*space*/, 10, CGRectGetMinX(self.deleteButton.frame) - CGRectGetMaxX(self.headerImageView.frame) - 17, 40);
        
    }
    else{//部门选择
        
        HTMIABCSYS_DepartmentModel * model = (HTMIABCSYS_DepartmentModel *)_htmiDynamicTreeNode.model;
        self.nameLabel.text = model.FullName;
        self.headerImageView.hidden = YES;
        self.nameLabel.frame = CGRectMake(12/*space*/, 10, CGRectGetMinX(self.deleteButton.frame) - 17, 40);
    }
}

- (void)setSys_UserModel:(HTMIABCSYS_UserModel *)sys_UserModel{
    _sys_UserModel = sys_UserModel;
    if (_sys_UserModel) {
        self.nameLabel.text = _sys_UserModel.FullName;
    
        if (!_sys_UserModel.headerBackGroundColor) {
            _sys_UserModel.headerBackGroundColor = [[HTMIWFCSettingManager manager] randomColor];
        }
        
        //控制显示
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,_sys_UserModel.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:_sys_UserModel.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType] withColor:_sys_UserModel.headerBackGroundColor]];
        self.headerImageView.hidden = NO;
        self.headerImageView.frame = CGRectMake(12, 10, 40, 40);
        self.headerImageView.layer.cornerRadius = self.headerImageView.bounds.size.width / 2;
        self.headerImageView.layer.masksToBounds = YES; // 裁剪
        self.headerImageView.layer.shouldRasterize = YES; // 缓存
        self.headerImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerImageView.frame) + 12/*space*/, 10, CGRectGetMinX(self.deleteButton.frame) - CGRectGetMaxX(self.headerImageView.frame) - 17, 40);
    }
}

- (void)setSys_DepartmentModel:(HTMIABCSYS_DepartmentModel *)sys_DepartmentModel{
    _sys_DepartmentModel = sys_DepartmentModel;
    if (_sys_DepartmentModel) {
        self.nameLabel.text = _sys_DepartmentModel.FullName;
        self.headerImageView.hidden = YES;
        self.nameLabel.frame = CGRectMake(12/*space*/, 10, CGRectGetMinX(self.deleteButton.frame) - 17, 40);
    }
}

- (void)setSpliteViewHiden:(BOOL)hiden{
    self.splitView.hidden = hiden;
}

@end
