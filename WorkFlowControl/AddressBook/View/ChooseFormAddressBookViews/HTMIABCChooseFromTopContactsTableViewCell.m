//
//  HTMIABCChooseFromTopContactsTableViewCell.m
//  MXClient
//
//  Created by wlq on 16/6/30.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCChooseFromTopContactsTableViewCell.h"
#import "HTMIABCDynamicTreeNode.h"
#import "HTMIABCSYS_UserModel.h"
//other
#import "UIImageView+HTMIWFCWebCache.h"

#import "HTMIWFCSettingManager.h"
#import "UIImage+HTMIWFCWM.h"

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



@implementation HTMIABCChooseFromTopContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //监听属性的变化
    [self addObserver:self forKeyPath:@"htmiDynamicTreeNode.isCheck" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"sys_UserModel.isCheck" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width / 2;
    self.headImageView.layer.masksToBounds = YES; // 裁剪
    self.headImageView.layer.shouldRasterize = YES; // 缓存
    self.headImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"HTMIABCChooseFromTopContactsTableViewCell";
    HTMIABCChooseFromTopContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCChooseFromTopContactsTableViewCell" owner:nil options:nil][0];
    }
    
    return cell;
}

//处理属性改变事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context{
    
    //HTMIABCChooseFromTopContactsTableViewCell *htmiDynamicTreeCell = object;
    
    NSString * newValueString =  [NSString stringWithFormat:@"%@",change[@"new"]];
    
    if ([keyPath isEqualToString:@"htmiDynamicTreeNode.isCheck"]) {
        if ([newValueString isEqualToString:@"1"]) {
            
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else if([newValueString isEqualToString:@"0"]){
            
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
    }
    else if ([keyPath isEqualToString:@"sys_UserModel.isCheck"]){
        
        if ([newValueString isEqualToString:@"1"]) {
            
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else if([newValueString isEqualToString:@"0"]){
            
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
    }
}

- (void)setHtmiDynamicTreeNode:(HTMIABCDynamicTreeNode *)htmiDynamicTreeNode{
    _htmiDynamicTreeNode = htmiDynamicTreeNode;
    
    if (_htmiDynamicTreeNode) {
        
        if (_htmiDynamicTreeNode.isCheck == YES) {
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else{
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
        
        self.nameTitleLabel.text = _htmiDynamicTreeNode.name;
        
        //设置头像
        HTMIABCSYS_UserModel *model = (HTMIABCSYS_UserModel *)_htmiDynamicTreeNode.model;
        
        if (!model.headerBackGroundColor) {
            model.headerBackGroundColor = [[HTMIWFCSettingManager manager] randomColor];
        }
        
        //控制显示
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,model.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:model.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType] withColor:model.headerBackGroundColor]];
    }
}

- (IBAction)clickCheckButton:(id)sender {
    if (self.checkBlock) {
        self.checkBlock(self);
    }
}

- (void)dealloc{
    HTLog(@"HTMIABCChooseFromTopContactsTableViewCell");
    
    @try {
        [self removeObserver:self forKeyPath:@"htmiDynamicTreeNode.isCheck" context:nil];
        [self removeObserver:self forKeyPath:@"sys_UserModel.isCheck" context:nil];
        
    } @catch (NSException *exception) {
        
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
