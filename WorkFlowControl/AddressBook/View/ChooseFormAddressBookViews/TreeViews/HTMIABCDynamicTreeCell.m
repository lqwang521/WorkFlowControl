

#import "HTMIABCDynamicTreeCell.h"
//model
#import "HTMIABCSYS_UserModel.h"
//other
#import "UIImageView+HTMIWFCWebCache.h"

#import "HTMIWFCSettingManager.h"

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


//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]


#define DepartmentCellHeight 60
#define EmployeeCellHeight  60

@interface HTMIABCDynamicTreeCell ()
@end

@implementation HTMIABCDynamicTreeCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //    self.avatarImageView.layer.cornerRadius = 5.f;
    self.avatarImageView.layer.masksToBounds = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.underLine.backgroundColor = [UIColor colorWithRed:242/255.f green:244/255.f blue:246/255.f alpha:1];
    self.checkButton.backgroundColor = [UIColor clearColor];
    self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //监听属性的变化
    [self addObserver:self forKeyPath:@"htmiDynamicTreeNode.isCheck" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"htmiDynamicTreeNode.selectedUserCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width / 2;
    self.avatarImageView.layer.masksToBounds = YES; // 裁剪
    self.avatarImageView.layer.shouldRasterize = YES; // 缓存
    self.avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}

//处理属性改变事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context{
    
    HTMIABCDynamicTreeCell *htmiDynamicTreeCell = object;
    
    if ([keyPath isEqualToString:@"htmiDynamicTreeNode.isCheck"]) {
        if (htmiDynamicTreeCell.htmiDynamicTreeNode.isCheck) {
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else{
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
    }
    else if ([keyPath isEqualToString:@"htmiDynamicTreeNode.selectedUserCount"]){
        
        self.countLabel.text =[NSString stringWithFormat:@"%@/%@",self.htmiDynamicTreeNode.selectedUserCount,self.htmiDynamicTreeNode.userCount];
    }
}


- (void)fillWithNode:(HTMIABCDynamicTreeNode*)node
{
    if (node) {
        
    }
}

- (void)setCellStypeWithType:(NSInteger)type originX:(CGFloat)x
{
    if (type == CellType_Department){
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                            self.contentView.frame.origin.y,
                                            kScreenWidth, DepartmentCellHeight);
        
        self.avatarImageView.hidden = YES;
        
        //设置 + 号的位置
        self.plusImageView.frame = CGRectMake(x,(DepartmentCellHeight/2) - (self.plusImageView.frame.size.height/2),
                                              self.plusImageView.frame.size.width,
                                              self.plusImageView.frame.size.height);
        
        NSDictionary *attrs = @{NSFontAttributeName : self.countLabel.font};
        float countLabelWidth = [self.countLabel.text boundingRectWithSize:CGSizeMake(100, self.contentView.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width;
        
        if (self.plusImageView.hidden) {//说明当前是搜索
            //设置 label的位置
            self.nameLabel.frame = CGRectMake(15, 0,
                                              self.contentView.frame.size.width - 15 - 5,
                                              self.contentView.frame.size.height);
        }
        else{
            
            //设置 label的位置
            self.nameLabel.frame = CGRectMake(self.plusImageView.frame.origin.x + self.plusImageView.frame.size.width + 5, 0,
                                              self.contentView.frame.size.width - self.plusImageView.frame.origin.x - self.plusImageView.frame.size.width - 5 - countLabelWidth,
                                              self.contentView.frame.size.height);
        }
        
        //underline
        self.underLine.frame = CGRectMake(x,
                                          self.contentView.frame.size.height - 0.5,
                                          self.contentView.frame.size.width - x,
                                          0.5);
        
        self.countLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame),
                                           0,
                                           countLabelWidth,
                                           self.contentView.frame.size.height);
        
        //控制是已选人员数量否需要隐藏
        //        if (_htmiDynamicTreeNode.chooseType == ChooseTypeDepartmentFromAll) {
        //选择部门时需要
        self.checkButton.frame = CGRectMake(kScreenWidth - self.contentView.frame.size.height, 0, self.contentView.frame.size.height, self.contentView.frame.size.height);
        
        self.checkImageView.frame = CGRectMake(CGRectGetMinX(self.checkButton.frame) + 20, 20, 20, 20);
        
        //        }
    }
    else{
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                            self.contentView.frame.origin.y,
                                            kScreenWidth, EmployeeCellHeight);
        
        self.plusImageView.hidden = YES;
        
        //设置头像的位置
        CGFloat iconWidth = 40;
        self.avatarImageView.frame = CGRectMake(16, EmployeeCellHeight/2.f - iconWidth/2.f, iconWidth, iconWidth);
        
        //这是label
        self.nameLabel.frame = CGRectMake(self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width + 5/*space*/,
                                          0,
                                          self.contentView.frame.size.width - self.avatarImageView.frame.origin.x - self.avatarImageView.frame.size.width - 5 - 5 - self.contentView.frame.size.height -10,
                                          self.contentView.frame.size.height);
        
        //underline
        self.underLine.frame = CGRectMake(x,
                                          self.contentView.frame.size.height - 0.5,
                                          self.contentView.frame.size.width - x,
                                          0.5);
        
        self.checkButton.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame), 0, self.contentView.frame.size.height, self.contentView.frame.size.height);
        
        self.checkImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 20, 20, 20, 20);
        
    }
}

- (IBAction)clickCheck:(id)sender{
    
    if (self.checkBlock != nil) {
        self.checkBlock(self);
    }
}

#pragma mark - setter

- (void)setHtmiDynamicTreeNode:(HTMIABCDynamicTreeNode *)htmiDynamicTreeNode{
    
    _htmiDynamicTreeNode = htmiDynamicTreeNode;
    
    if (_htmiDynamicTreeNode) {
        
        
        if (_htmiDynamicTreeNode.isCheck == YES) {
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else{
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
        
        self.nameLabel.text = _htmiDynamicTreeNode.name;
        
        NSInteger cellType = _htmiDynamicTreeNode.isDepartment;
        
        if (cellType == CellType_Department) {
            
            self.nameLabel.text = [NSString stringWithFormat:@"%@",_htmiDynamicTreeNode.name];
            
            self.countLabel.text =[NSString stringWithFormat:@"%@/%@",self.htmiDynamicTreeNode.selectedUserCount,_htmiDynamicTreeNode.userCount];
            
            //设置加号还是减号
            if (_htmiDynamicTreeNode.isOpen) {
                self.plusImageView.image = [UIImage getPNGImageHTMIWFC:@"icon_minus"];
            }
            else{
                self.plusImageView.image = [UIImage getPNGImageHTMIWFC:@"icon_plus"];
            }
            
            //设置是否显示
            if(_htmiDynamicTreeNode.chooseType == ChooseTypeDepartmentFromAll || _htmiDynamicTreeNode.chooseType == ChooseTypeDepartmentFromSpecific  || _htmiDynamicTreeNode.chooseType == ChooseTypeDepartmentFromSpecificOnly || _htmiDynamicTreeNode.chooseType == ChooseTypeOrganization) {
                
                self.checkButton.enabled = YES;
                self.checkImageView.hidden = NO;
            }
            else{
                self.checkButton.enabled = NO;
                self.checkImageView.hidden = YES;
            }
            
            //控制是已选人员数量否需要隐藏
            if (_htmiDynamicTreeNode.chooseType == ChooseTypeDepartmentFromAll || _htmiDynamicTreeNode.chooseType == ChooseTypeOrganization) {
                
                self.countLabel.hidden = YES;
            }
            else if(_htmiDynamicTreeNode.chooseType == ChooseTypeUserFromAll || _htmiDynamicTreeNode.chooseType == ChooseTypeOrganization){
                self.countLabel.hidden = NO;
            }
            else{
                self.countLabel.hidden = YES;
            }
        }
        else{
            
            self.nameLabel.text = _htmiDynamicTreeNode.name;
            //设置头像
            HTMIABCSYS_UserModel *model = (HTMIABCSYS_UserModel *)_htmiDynamicTreeNode.model;
 
            if (!model.headerBackGroundColor) {
                model.headerBackGroundColor = [[HTMIWFCSettingManager manager] randomColor];
            }
            
            //控制显示
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,model.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:model.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType]  withColor:model.headerBackGroundColor]];
            
            //设置是否显示
            self.checkButton.enabled = YES;
            self.checkImageView.hidden = NO;
            
            self.countLabel.hidden = YES;
        }
        
        //设置显示的位置frame
        [self setCellStypeWithType:cellType originX:_htmiDynamicTreeNode.originX];
    }
}

- (void)dealloc{
    HTLog(@"HTMIABCDynamicTreeCell");
    @try {
        
        [self removeObserver:self forKeyPath:@"htmiDynamicTreeNode.isCheck" context:nil];
        [self removeObserver:self forKeyPath:@"htmiDynamicTreeNode.selectedUserCount" context:nil];
    } @catch (NSException *exception) {
        
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
