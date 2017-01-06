//
//  HTMIPersonal InformationViewController.m
//  MXClient
//
//  Created by wlq on 16/4/18.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIABCPersonalInformationViewController.h"

//controller
#import "HTMIABCPersonalInfoEditViewController.h"
#import "HTMIABCAddressBookManager.h"

//cell
#import "HTMIABCPersonalInformationHeaderTableViewCell.h"
#import "HTMIABCPersonalInformationNormalTableViewCell.h"

//model
#import "HTMIABCTD_UserModel.h"
#import "HTMIABCSYS_UserModel.h"

//other
#import "HTMIWFCApi.h"
//选择图片需要
#import "HTMIWFCCorePhotoPickerVCManager.h"
//#import "Loading.h"
#import "HTMIABCDBHelper.h"
#import "UIImageView+HTMIWFCWebCache.h"
#import "HTMIABCUserdefault.h"
#import "HTMIWFCSVProgressHUD.h"

//#import "MXConfig.h"

#import "UIImage+HTMIWFCWM.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "HTMIWFCSettingManager.h"

#import "HTMIWFCSVProgressHUD.h"


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

@interface HTMIABCPersonalInformationViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

/**
 *  行数据数组
 */
@property (strong,nonatomic) NSMutableArray * cellDataArray;

/**
 *  用户模型
 */
@property (copy,nonatomic)HTMIABCSYS_UserModel* sys_UserModel;

@end

@implementation HTMIABCPersonalInformationViewController

#pragma mark - 生命周期

-(instancetype)init{
    
    if (self = [super init]) {
        
        NSBundle * bundle = [UIImage getBundleHTMIWFC:@"WorkFlowControlResources"];
        
        self = [super initWithNibName:@"HTMIABCPersonalInformationViewController" bundle:bundle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customNavigationController:YES title:@"个人信息"];
    
    self.mainTableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([HTMIABCDBHelper sharedYMDBHelperTool].isSyncDBing) {
        
        [HTMIWFCSVProgressHUD showWithStatus:@"信息同步中..." maskType:HTMIWFCSVProgressHUDMaskTypeNone];
    }
    else{
        
        //初始化数据
        [self initData];
        
        [HTMIWFCSVProgressHUD dismiss];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [HTMIWFCSVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --UIActionSheet代理方法

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 2) {//点击取消按钮
        return;
    }
    
    HTMIWFCCorePhotoPickerVCMangerType type=0;
    
    
    if(buttonIndex==0) type=HTMIWFCCorePhotoPickerVCMangerTypeCamera;
    
    if(buttonIndex==1) type=HTMIWFCCorePhotoPickerVCMangerTypeSinglePhoto;
    
    HTMIWFCCorePhotoPickerVCManager *manager=[HTMIWFCCorePhotoPickerVCManager sharedHTMIWFCCorePhotoPickerVCManager];
    
    //设置类型
    manager.pickerVCManagerType = type;
    
    //最多可选3张
    manager.maxSelectedPhotoNumber=1;
    
    //错误处理
    if(manager.unavailableType!=HTMIWFCCorePhotoPickerUnavailableTypeNone){
        HTLog(@"设备不可用");
        
        return;
    }
    
    UIViewController *pickerVC = manager.imagePickerController;//在属性中进行设置
    
    //这里面可能会后多张图片
    //选取结束
    manager.finishPickingMedia=^(NSArray *medias){
        
        [medias enumerateObjectsUsingBlock:^(HTMIWFCCorePhoto *photo, NSUInteger idx, BOOL *stop) {
            HTLog(@"%@",photo.editedImage);
            
            
            NSString * imageString =  [UIImage baseStringFromImage:photo.editedImage];
            
            self.sys_UserModel.Photosurl = imageString;
            
            //处理图片
            //1上传图片 以及图片Url
            [HTMIWFCSVProgressHUD show];
            [HTMIWFCApi updateUserInfo:self.sys_UserModel succeed:^(id dicResult) {
                
                [HTMIWFCSVProgressHUD dismiss];
                
                if (dicResult && [dicResult isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary  * dicMessage = [dicResult objectForKey:@"Message"];
                    
                    if (dicMessage && [dicMessage isKindOfClass:[NSDictionary class]]) {
                        
                        NSString * statusCode = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusCode"]];
                        
                        if ([statusCode isEqualToString:@"200"]) {
                            
                            NSString * result = [NSString stringWithFormat:@"%@",[dicResult objectForKey:@"Result"]];
                            
                            //成功了
                            if ([result isEqualToString:@"1"]) { //result可能返回0
                                
                                //2上传成功存入本地数据库
                                NSString *UserIDString = [HTMIABCUserdefault defaultLoadUserID];
                                [[HTMIABCDBHelper sharedYMDBHelperTool]UpdateCurrentUserInfoByUserId:UserIDString fieldNameLower:[@"Photosurl" lowercaseString] value:imageString];
                                
                                [self.mainTableView reloadData];
                            }
                            else{
                                [HTMIWFCApi showErrorStringWithError:@"修改头像失败" error:nil onView:nil];
                            }
                        }
                        else{
                            NSString * statusMessage = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusMessage"]];
                            [HTMIWFCApi showErrorStringWithError:statusMessage error:nil onView:nil];
                        }
                    }
                }
                
            } failure:^(NSError *error) {
                [HTMIWFCSVProgressHUD dismiss];
                [HTMIWFCApi showErrorStringWithError:nil error:error onView:nil];
            }];
        }];
    };
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

#pragma mark --TableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HTMIABCTD_UserModel * model =  self.cellDataArray[indexPath.row];
    
    if ([model.FieldName isEqualToString:@"Photosurl"]) {
        return 80;
    }
    else{
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cellDataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HTMIABCTD_UserModel * model =  self.cellDataArray[indexPath.row];
    
    if ([model.FieldName isEqualToString:@"Photosurl"]) {
        
        HTMIABCPersonalInformationHeaderTableViewCell *  cell = [HTMIABCPersonalInformationHeaderTableViewCell cellWithTableView:tableView];
        
        //从数据库获取当前用户的信息
        HTMIABCSYS_UserModel *sys_UserModel = [[HTMIABCDBHelper sharedYMDBHelperTool] getCurrentUserInfo:[HTMIABCUserdefault defaultLoadUserID]];
        UIImage * headerImage = [UIImage imageFromBaseString:sys_UserModel.Photosurl];
        
        //判断是否有图片，如果没有使用默认头像
        if (headerImage) {
            
            [cell.headerImageView setImage:headerImage];
        }
        else{
            NSString *imagePath = [NSString stringWithFormat:@"%@:%@/%@/%@",EMUrl,EMPORT,EMapiDir,self.sys_UserModel.Photosurl];
            
            [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage getPNGImageHTMIWFC:@"mx_no_face_phone"]];
        }
        
        return cell;
    }
    else{
        
        HTMIABCPersonalInformationNormalTableViewCell* cell = [HTMIABCPersonalInformationNormalTableViewCell cellWithTableView:tableView];
        cell.sys_UserModel = self.sys_UserModel;
        cell.td_UserModel = self.cellDataArray[indexPath.row];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HTMIABCTD_UserModel * td_UserModel =  self.cellDataArray[indexPath.row];
    
    if ([td_UserModel.FieldName isEqualToString:@"Photosurl"]) {
        //选择照片
        UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍摄" otherButtonTitles:@"照片库", nil];
        
        [sheet showInView:self.view];
        
    }
    else{
        if (td_UserModel.EnabledEdit) {
            HTMIABCPersonalInfoEditViewController * vc = [HTMIABCPersonalInfoEditViewController new];
            //必须先给这个属性辅助，显示的数据从这个属性中获取
            vc.td_UserModel = td_UserModel;
            vc.sys_UserModel = [self.sys_UserModel copy];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//用于取消选择记忆
}

#pragma mark --私有方法

- (void)initData{
    
    
    HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
    
    NSSortDescriptor *disOrderAscend = [NSSortDescriptor sortDescriptorWithKey:@"DisOrder" ascending:YES];
    
    NSMutableArray * arrayAll = [addressBookSingletonClass.tdUserModelArray mutableCopy];
    
    //这个不好用
    //    [arrayAll enumerateObjectsUsingBlock:^(HTMIABCTD_UserModel * model, NSUInteger idx, BOOL *stop) {
    //
    //        if (!model.IsActive) {
    //            [arrayAll removeObject:model];
    //            idx--;
    //        }
    //    }];
    
    for (int i=0; i<arrayAll.count; i++) {
        HTMIABCTD_UserModel * model = arrayAll[i];
        
        if (!model.IsActive) {
            
            [arrayAll removeObject:model];
            i--;
        }
    }
    
    //按顺序添加排序描述器
    NSArray *arrayDesc = [arrayAll sortedArrayUsingDescriptors:@[disOrderAscend]];
    
    self.cellDataArray = [NSMutableArray arrayWithArray:arrayDesc];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //#warning --暂未完成 用户的id应该从userdefaults中获取 zhangweicw
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        NSString *UserID = [userdefaults objectForKey:@"UserID"] ==  nil ? @"":[userdefaults objectForKey:@"UserID"];
        //从数据库获取当前用户的信息
        self.sys_UserModel = [[HTMIABCDBHelper sharedYMDBHelperTool] getCurrentUserInfo:UserID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.mainTableView reloadData];
        });
    });
}

#pragma mark --Getter

- (NSMutableArray *)cellDataArray{
    if (!_cellDataArray) {
        _cellDataArray = [NSMutableArray array];
        
    }
    return _cellDataArray;
}

@end
