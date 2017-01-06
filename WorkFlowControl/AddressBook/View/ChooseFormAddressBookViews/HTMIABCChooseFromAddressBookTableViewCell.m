//
//  HTMIABCChooseFromAddressBookTableViewCell.m
//  MXClient
//
//  Created by wlq on 16/4/19.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCChooseFromAddressBookTableViewCell.h"

#import "HTMIABCDBHelper.h"

#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_DepartmentModel.h"
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



@implementation HTMIABCChooseFromAddressBookTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkButton.enabled = NO;
    self.checkImageView.hidden = YES;
    self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
    
     self.selectionStyle = UITableViewCellSelectionStyleNone;
    //监听属性的变化
    [self addObserver:self forKeyPath:@"sys_UserModel.isCheck" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"sys_DepartmentModel.isCheck" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width / 2;
    self.headImageView.layer.masksToBounds = YES; // 裁剪
    self.headImageView.layer.shouldRasterize = YES; // 缓存
    self.headImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"HTMIABCChooseFromAddressBookTableViewCell";
    HTMIABCChooseFromAddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UIImage getBundleHTMIWFC:@"WorkFlowControlResources"] loadNibNamed:@"HTMIABCChooseFromAddressBookTableViewCell" owner:nil options:nil][0];
    }
   
    return cell;
}

- (IBAction)clickCheck:(id)sender {
    
    if (self.checkBlock != nil) {
        self.checkBlock(self);
    }
}

//- (void)dealloc{
//    self.checkBlock = nil;
//}
- (void)dealloc{
    
    HTLog(@"HTMIABCChooseFromAddressBookTableViewCell");
    
    @try {
        
        [self removeObserver:self forKeyPath:@"sys_UserModel.isCheck" context:nil];
        [self removeObserver:self forKeyPath:@"sys_DepartmentModel.isCheck" context:nil];
    } @catch (NSException *exception) {
        
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//处理属性改变事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context{
    
    NSString * newValueString =  [NSString stringWithFormat:@"%@",change[@"new"]];
    
    if ([newValueString isEqualToString:@"1"]) {
        self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
    }
    else if([newValueString isEqualToString:@"0"]){
        self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
    }
}

- (void)setSys_UserModel:(HTMIABCSYS_UserModel *)sys_UserModel{
    _sys_UserModel = sys_UserModel;
    if (_sys_UserModel) {
        self.nameLabel.text = _sys_UserModel.FullName;
        
        if (_sys_UserModel.isCheck == YES) {
            self.checkImageView.image =  [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else{
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
        
        
        self.checkButton.enabled = YES;
        self.checkImageView.hidden = NO;
        
        
        self.pushImageView.hidden = YES;
        self.pushViewTrailingConstraint.constant = -20;
        
        
        //控制是人员还是部门头像显示
        self.headImageView.hidden = NO;
        self.headerImageViewLeftConstraint.constant = 12;
        
        if (!_sys_UserModel.headerBackGroundColor) {
            _sys_UserModel.headerBackGroundColor = [[HTMIWFCSettingManager manager]randomColor];
        }
        
        //控制显示
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,_sys_UserModel.Photosurl]] placeholderImage:[UIImage imageWithStringHTMIWFC:_sys_UserModel.FullName width:40 type:[[HTMIWFCSettingManager manager] headerImageType]  withColor:_sys_UserModel.headerBackGroundColor]];
    }
}

- (void)setSys_DepartmentModel:(HTMIABCSYS_DepartmentModel *)sys_DepartmentModel{
    _sys_DepartmentModel = sys_DepartmentModel;
    if (_sys_DepartmentModel) {
        self.nameLabel.text = _sys_DepartmentModel.FullName;
        
        if (_sys_DepartmentModel.isCheck == YES) {
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else{
            self.checkImageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
        
        //ChooseTypeOrganization 可以选人员也可以选部门，只是单选
        //wlq update 选择用户时部门也可以选择 ，选择所有子部门的用户_sys_DepartmentModel.chooseType == ChooseTypeUserFromAll ||
        if (
            (_sys_DepartmentModel.chooseType == ChooseTypeDepartmentFromAll || _sys_DepartmentModel.chooseType == ChooseTypeDepartmentFromSpecific  || _sys_DepartmentModel.chooseType ==ChooseTypeDepartmentFromSpecificOnly) ||
            (_sys_DepartmentModel.chooseType == ChooseTypeOrganization)) {
            
            self.checkButton.enabled = YES;
            self.checkImageView.hidden = NO;
        }
        else{
            self.checkButton.enabled = NO;
            self.checkImageView.hidden = YES;
        }
        
        //需要判断 控制push图标是否显示
        if (_sys_DepartmentModel.chooseType == ChooseTypeDepartmentFromAll || _sys_DepartmentModel.chooseType == ChooseTypeUserFromAll || _sys_DepartmentModel.chooseType == ChooseTypeOrganization || _sys_DepartmentModel.chooseType == ChooseTypeDepartmentFromSpecific|| _sys_DepartmentModel.chooseType == ChooseTypeUserFromSpecific) {
            //如果是人员，隐藏push图标
            
            if (_sys_DepartmentModel.chooseType == ChooseTypeDepartmentFromAll || _sys_DepartmentModel.chooseType == ChooseTypeDepartmentFromSpecific) {
                //wlq add
                self.pushImageView.hidden = ![[HTMIABCDBHelper sharedYMDBHelperTool] existDepartmentInDepartment:_sys_DepartmentModel.DepartmentCode];
            }
            else if(_sys_DepartmentModel.chooseType == ChooseTypeUserFromAll || _sys_DepartmentModel.chooseType == ChooseTypeOrganization || _sys_DepartmentModel.chooseType == ChooseTypeUserFromSpecific){
                if ([[HTMIABCDBHelper sharedYMDBHelperTool] existDepartmentInDepartment:_sys_DepartmentModel.DepartmentCode]) {//如果下面有部门，那么跳转按钮一定要显示
                    self.pushImageView.hidden = NO;
                    self.pushViewTrailingConstraint.constant = 10;
                }
                else{
                    if ([[HTMIABCDBHelper sharedYMDBHelperTool] existUserInDepartment:_sys_DepartmentModel.DepartmentCode]) {
                        self.pushImageView.hidden = NO;
                        self.pushViewTrailingConstraint.constant = 10;
                        
                    }
                    else{
                        self.pushImageView.hidden = YES;
                        self.pushViewTrailingConstraint.constant = -20;
                    }
                }
            }
            
        }
        else{
            self.pushImageView.hidden = YES;
            self.pushViewTrailingConstraint.constant = -20;
        }
        
        //控制是人员还是部门头像显示
        self.headImageView.hidden = YES;
        self.headerImageViewLeftConstraint.constant = -40;
    }
}

@end
