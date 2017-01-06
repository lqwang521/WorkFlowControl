//
//  HTMIWFCOAMatterFormTableViewController+EditType.m
//  MXClient
//
//  Created by 赵志国 on 16/6/20.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterFormTableViewController+EditType.h"
#import "HTMIWFCOAQuickOpinionViewController.h"
//#import "OASelectUserViewController.h"
//#import "HTMIABCDBHelper.h"
//#import "HTMIABCSYS_UserModel.h"

#import "HTMIABCSYS_UserModel.h"
#import "HTMIABCSYS_DepartmentModel.h"

//#import "HTMIABCChooseFormAddressBookViewController.h"
#import "HTMIABCChooseFormAddressBookViewController.h"
#import "UIImage+HTMIWFCWM.h"

#import "HTMIWFCSVProgressHUD.h"

#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
#endif

//版本信息
#define HTMIIOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

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

//取view的坐标及长宽
#define W(view)    view.frame.size.width
#define H(view)    view.frame.size.height
#define X(view)    view.frame.origin.x
#define Y(view)    view.frame.origin.y


/**
 *  意见、签名人名颜色
 */
#define eidtColor [UIColor colorWithRed:41/255.0 green:123/255.0 blue:251/255.0 alpha:1.0]//蓝

/**
 *  必填时添加的背景色
 */
#define mustInputColor [UIColor colorWithRed:254/255.0 green:250/255.0 blue:235/255.0 alpha:1.0]//黄

/**
 *  可编辑时的边框颜色
 */
#define borderCorlor [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]//灰

/**
 *  所有行的最低高度
 */
#define cellMinHeight kH6(50)

/**
 *  可编辑时边框距左边的距离
 */
#define borderLeftWidth kW6(5)

/**
 *  可编辑时边框距上边的距离
 */
#define borderTopHeight kH6(5)

/**
 *  字体距左边的距离
 */
#define stringLeftWidth kW6(12)

/**
 *  字体距上边的距离
 */
#define stringTopHeight kH6(12)


@implementation HTMIWFCOAMatterFormTableViewController (EditType)

#pragma mark -------------------------------------------计算cell行高

- (CGFloat)mytableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat maxAllContentHeight = 0.f;
    
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[indexPath.row];
    
    NSArray *itemListInLine = infoRegion.feildItemList;
    
    for (int i = 0; i < itemListInLine.count; i++) {
        HTMIWFCOAMatterFormFieldItem *fieldItem = itemListInLine[i];
        
        CGFloat percent = fieldItem.percent / 100.f;
        CGFloat itemWidth = kScreenWidth * (percent == 0 ? 1 : percent);
        
        NSString *nameString = [NSString stringWithFormat:@"%@%@%@%@", fieldItem.beforeName, fieldItem.name, fieldItem.endName, fieldItem.splitString];
        NSString *valueString = [NSString stringWithFormat:@"%@%@%@%@", fieldItem.beforeValue, (fieldItem.eidtValue ? fieldItem.eidtValue : @""), fieldItem.value, fieldItem.endValue];
        
        //获取每个item的高度，然后取最大值
        CGFloat itemHeight = [self itemheightTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        if (itemHeight > maxAllContentHeight) {
            maxAllContentHeight = itemHeight;
        }
    }
    
    //设定最低高度为
    CGFloat minHeight = cellMinHeight;
    
    if (!IS_IPHONE_6P) {
        if (self.formLabelFont == 13) {
            minHeight = kH6(40);
        }
    }
    
    if (infoRegion.ScrollFlag == 1) {
        return cellMinHeight;
    }
    
    if (infoRegion.IsSplitRegion && infoRegion.SplitAction == 0) {
        //分割部分
        return 20;
    } else {
        return MAX(minHeight, maxAllContentHeight);
    }
    
}

#pragma mark ------ item高
- (CGFloat)itemheightTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat height = 0;
    
    if ([fieldItem.inputType isEqualToString:@"101"]) {
        //文本
        height = [self textFieldInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"102"]) {
        //大文本
        height = [self textViewInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"200"] ||
               [fieldItem.inputType isEqualToString:@"201"] ||
               [fieldItem.inputType isEqualToString:@"202"] ||
               [fieldItem.inputType isEqualToString:@"203"]) {
        //整数、小数、整数（带千分符）、小数（带千分符）
        height = [self textFieldInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"300"] ||
               [fieldItem.inputType isEqualToString:@"301"] ||
               [fieldItem.inputType isEqualToString:@"302"] ||
               [fieldItem.inputType isEqualToString:@"303"] ||
               [fieldItem.inputType isEqualToString:@"304"]) {
        //日期、日期时间、年、月、周
        height = [self timeSelectInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"401"] ||
               [fieldItem.inputType isEqualToString:@"402"] ||
               [fieldItem.inputType isEqualToString:@"403"] ||
               [fieldItem.inputType isEqualToString:@"412"]) {
        //下拉选择取ID、Name、Value，支持输入结果取Name
        height = [self pulldownListBoxInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"501"] ||
               [fieldItem.inputType isEqualToString:@"502"] ||
               [fieldItem.inputType isEqualToString:@"503"] ||
               [fieldItem.inputType isEqualToString:@"511"] ||
               [fieldItem.inputType isEqualToString:@"512"] ||
               [fieldItem.inputType isEqualToString:@"513"]) {
        //单选（ID、那么、Value），多选（ID、Name、Value）
        height = [self selectInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"601"] ||
               [fieldItem.inputType isEqualToString:@"602"] ||
               [fieldItem.inputType isEqualToString:@"603"] ||
               [fieldItem.inputType isEqualToString:@"611"] ||
               [fieldItem.inputType isEqualToString:@"612"] ||
               [fieldItem.inputType isEqualToString:@"613"]) {
        //选人单选（ID、Name（中文名）、LoginName（登录名）），选人多选（ID、Name、LoginName）
        height = [self peopleInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"901"] ||
               [fieldItem.inputType isEqualToString:@"902"] ||
               [fieldItem.inputType isEqualToString:@"911"] ||
               [fieldItem.inputType isEqualToString:@"912"]) {
        //选部门单选（Name、ID），选部门多选（Name、ID）
        height = [self departmentInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"1001"]) {
        //不限人员、部门。选择的结果有可能是部门，也有可能是人员。只限单选
        height = [self peopleOrDepartmentInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"2001"] ||
               [fieldItem.inputType isEqualToString:@"2002"] ||
               [fieldItem.inputType isEqualToString:@"2003"]) {
        //意见、签名、意见或签名
        height = [self opinionAndAutographInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"3001"] ||
               [fieldItem.inputType isEqualToString:@"3011"] ||
               [fieldItem.inputType isEqualToString:@"3002"] ||
               [fieldItem.inputType isEqualToString:@"3012"]) {
        //读者（单选、多选）    作者（单选、多选）
        height = [self readerOrAuthorInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
    } else {
        //常规
        height = [self normalInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth];
        
    }
    
    return height;
}

#pragma mark ------ TextField && TextView（行高）
- (CGFloat)textFieldInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + cellMinHeight;
                
            } else {//显示name不分行
                allHeight = cellMinHeight;
            }
        } else {//不显示name
            allHeight = cellMinHeight;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

- (CGFloat)textViewInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    CGFloat valueHeight = [self labelSizeWithMaxWidth:itemWidth-40 content:valueString FontOfSize:self.formLabelFont+2].height+26;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + MAX(valueHeight, kH6(110)) + borderTopHeight*2;
                
            } else {//显示name不分行
                allHeight = MAX(valueHeight, kH6(110)) + borderTopHeight*2;
            }
        } else {//不显示name
            allHeight = MAX(valueHeight, kH6(110)) + borderTopHeight*2;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 时间选择（行高）
- (CGFloat)timeSelectInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + cellMinHeight;
                
            } else {//显示name不分行
                allHeight = cellMinHeight;
            }
        } else {//不显示name
            allHeight = cellMinHeight;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 下拉选择（行高）
- (CGFloat)pulldownListBoxInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + cellMinHeight;
                
            } else {//显示name不分行
                allHeight = cellMinHeight;
            }
        } else {//不显示name
            allHeight = cellMinHeight;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 单选多选框（行高）
- (CGFloat)selectInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    NSArray *array = fieldItem.dicts;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + kH6(40)*array.count;
                
            } else {//显示name不分行
                allHeight = kH6(40)*array.count;
            }
        } else {//不显示name
            allHeight = kH6(40)*array.count;
        }
        
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 选人（行高）
- (CGFloat)peopleInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    CGFloat valueHeight = valueString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:valueString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + MAX(valueHeight, kH6(40)) + borderTopHeight*2;
                
            } else {//显示name不分行
                allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
            }
        } else {//不显示name
            allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 选部门（行高）
- (CGFloat)departmentInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    CGFloat valueHeight = valueString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:valueString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + MAX(valueHeight, kH6(40)) + borderTopHeight*2;
                
            } else {//显示name不分行
                allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
            }
        } else {//不显示name
            allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 选人或部门，单选（行高）
- (CGFloat)peopleOrDepartmentInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    CGFloat valueHeight = valueString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:valueString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + MAX(valueHeight, kH6(40)) + borderTopHeight*2;
                
            } else {//显示name不分行
                allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
            }
        } else {//不显示name
            allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 读者 、 作者
- (CGFloat)readerOrAuthorInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    CGFloat valueHeight = valueString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:valueString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                allHeight = nameHeight + MAX(valueHeight, kH6(40)) + borderTopHeight*2;
                
            } else {//显示name不分行
                allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
            }
        } else {//不显示name
            allHeight = MAX(valueHeight, kH6(40)) + borderTopHeight*2;
        }
    } else {
        allHeight = [self inputNoEditHeightByFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2];
    }
    return allHeight;
}

#pragma mark ------ 意见、签名、意见或签名（行高）
- (CGFloat)opinionAndAutographInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name并且折行
                if ([fieldItem.inputType isEqualToString:@"2001"]) {
                    //意见
                    CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
                    
                    CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
                    
                    CGFloat height = MAX(editH, kH6(40));
                    
                    allHeight = havedHeight + height + borderTopHeight*2 +nameHeight;
                    
                } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                    //签名
                    if (fieldItem.value.length > 0){
                        allHeight += nameHeight;
                        
                        NSArray *autographArray = [fieldItem.value componentsSeparatedByString:@"\r\n"];
                        
                        for (int i = 0; i < autographArray.count; i++) {
                            NSString *string = autographArray[i];
                            float eachHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:string FontOfSize:self.formLabelFont].height+stringTopHeight;
                            
                            allHeight+=eachHeight;
                        }
                        
                        if ([[autographArray lastObject] rangeOfString:self.myUserName].location == NSNotFound){
                            allHeight+=cellMinHeight;
                        }
                    }
                    
                } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                    //意见及签名
                    CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
                    
                    CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
                    
                    CGFloat height = fieldItem.eidtValue.length>0 ? MAX(editH, kH6(50)) : 0;
                    
                    if (itemWidth > kW6(200)) {//横版
                        allHeight = havedHeight + height +nameHeight + kH6(50);
                        
                    } else {//竖版
                        allHeight = havedHeight + height +nameHeight + kH6(100);
                    }
                }
                
            } else {//显示name不折行
                if ([fieldItem.inputType isEqualToString:@"2001"]) {
                    //意见
                    CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
                    
                    CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
                    
                    CGFloat height = MAX(editH, kH6(40));
                    
                    allHeight = havedHeight + height + borderTopHeight*2;
                    
                } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                    //签名
                    if (fieldItem.value.length > 0){
                        NSArray *autographArray = [fieldItem.value componentsSeparatedByString:@"\r\n"];
                        
                        for (int i = 0; i < autographArray.count; i++) {
                            NSString *string = autographArray[i];
                            float eachHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:string FontOfSize:self.formLabelFont].height+stringTopHeight;
                            
                            allHeight+=eachHeight;
                        }
                        
                        if ([[autographArray lastObject] rangeOfString:self.myUserName].location == NSNotFound){
                            allHeight+=cellMinHeight;
                        }
                    }
                    
                } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                    //意见及签名
                    CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
                    
                    CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
                    
                    CGFloat height = fieldItem.eidtValue.length>0 ? MAX(editH, kH6(50)) : 0;
                    
                    if (itemWidth > kW6(200)) {//横版
                        allHeight = havedHeight + height + kH6(50);
                        
                    } else {//竖版
                        allHeight = havedHeight + height + kH6(100);
                    }
                }
            }
        } else {//不显示name
            if ([fieldItem.inputType isEqualToString:@"2001"]) {
                //意见
                CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
                
                CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
                
                CGFloat height = MAX(editH, kH6(40));
                
                allHeight = havedHeight + height + borderTopHeight*2;
                
            } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                //签名
                if (fieldItem.value.length > 0){
                    NSArray *autographArray = [fieldItem.value componentsSeparatedByString:@"\r\n"];
                    
                    for (int i = 0; i < autographArray.count; i++) {
                        NSString *string = autographArray[i];
                        float eachHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:string FontOfSize:self.formLabelFont].height+stringTopHeight;
                        
                        allHeight+=eachHeight;
                    }
                    
                    if ([[autographArray lastObject] rangeOfString:self.myUserName].location == NSNotFound){
                        allHeight+=cellMinHeight;
                    }
                }
                
            } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                //意见及签名
                CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
                
                CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
                
                CGFloat height = fieldItem.eidtValue.length>0 ? MAX(editH, kH6(50)) : 0;
                
                if (itemWidth > kW6(200)) {//横版
                    allHeight = havedHeight + height + kH6(50);
                    
                } else {//竖版
                    allHeight = havedHeight + height + kH6(100);
                }
            }
        }
        
    } else {//不可编辑
        if ([fieldItem.inputType isEqualToString:@"2001"] || [fieldItem.inputType isEqualToString:@"2003"]) {
            //意见     意见及签名
            CGFloat havedHeight = [self havedOpinionsHeight:fieldItem.opintions itemWidth:itemWidth];
            allHeight = havedHeight+borderTopHeight*2;
            
        } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
            //签名
            if (fieldItem.value.length > 0){
                NSArray *autographArray = [fieldItem.value componentsSeparatedByString:@"\r\n"];
                
                for (int i = 0; i < autographArray.count; i++) {
                    NSString *string = autographArray[i];
                    float eachHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:string FontOfSize:self.formLabelFont].height+stringTopHeight;
                    
                    allHeight+=eachHeight;
                }
            }
        }
    }
    return allHeight;
}

- (CGFloat)havedOpinionsHeight:(NSArray *)opinions itemWidth:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    if (opinions.count > 0) {
        for (int i = 0; i < opinions.count; i++) {
            NSDictionary *dic = opinions[i];
            
            NSString *opinion = ((NSString *)[dic objectForKey:@"opinionText"]).length>0 ? [dic objectForKey:@"opinionText"] : @" ";
            NSString *name = [dic objectForKey:@"userName"];
            NSString *time = [dic objectForKey:@"saveTime"];
            
            CGFloat opinionHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:opinion FontOfSize:self.formLabelFont].height;
            CGFloat nameHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:name FontOfSize:self.formLabelFont].height;
            CGFloat timeHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:time FontOfSize:self.formLabelFont].height;
            
            CGFloat eachheight = opinionHeight + nameHeight + timeHeight + stringTopHeight;
            
            allHeight += eachheight;
        }
        
    }
    return allHeight;
}

#pragma mark ------ 普通模式（行高）
- (CGFloat)normalInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth {
    CGFloat allHeight = 0;
    
    if (fieldItem.nameVisible) {
        allHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:[NSString stringWithFormat:@"%@%@",nameString,valueString] FontOfSize:self.formLabelFont].height+stringTopHeight*2;
        
    } else {
        allHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:valueString FontOfSize:self.formLabelFont].height+stringTopHeight*2;
    }
    
    return allHeight;
}


#pragma mark ------------------------------------------- item内容
- (void)itemDetailsTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight tableView:(UITableView *)tableView cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    if ([fieldItem.inputType isEqualToString:@"101"]) {
        //文本
        [self textFieldInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
    } else if ([fieldItem.inputType isEqualToString:@"102"]) {
        //大文本
        [self textViewInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight cell:cell indexPath:indexPath];
        
    } else if ([fieldItem.inputType isEqualToString:@"200"] ||
               [fieldItem.inputType isEqualToString:@"201"] ||
               [fieldItem.inputType isEqualToString:@"202"] ||
               [fieldItem.inputType isEqualToString:@"203"]) {
        //整数、小数、整数（带千分符）、小数（带千分符）
        [self textFieldInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
    } else if ([fieldItem.inputType isEqualToString:@"300"] ||
               [fieldItem.inputType isEqualToString:@"301"] ||
               [fieldItem.inputType isEqualToString:@"302"] ||
               [fieldItem.inputType isEqualToString:@"303"] ||
               [fieldItem.inputType isEqualToString:@"304"]) {
        //日期、日期时间、年、月、周
        [self timeSelectInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"401"] ||
               [fieldItem.inputType isEqualToString:@"402"] ||
               [fieldItem.inputType isEqualToString:@"403"] ||
               [fieldItem.inputType isEqualToString:@"412"]) {
        //下拉选择取ID、Name、Value，支持输入结果取Name
        [self pulldownListBoxInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight tableView:tableView];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"501"] ||
               [fieldItem.inputType isEqualToString:@"502"] ||
               [fieldItem.inputType isEqualToString:@"503"] ||
               [fieldItem.inputType isEqualToString:@"511"] ||
               [fieldItem.inputType isEqualToString:@"512"] ||
               [fieldItem.inputType isEqualToString:@"513"]) {
        //单选（ID、那么、Value），多选（ID、Name、Value）
        [self selectInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"601"] ||
               [fieldItem.inputType isEqualToString:@"602"] ||
               [fieldItem.inputType isEqualToString:@"603"] ||
               [fieldItem.inputType isEqualToString:@"611"] ||
               [fieldItem.inputType isEqualToString:@"612"] ||
               [fieldItem.inputType isEqualToString:@"613"]) {
        //选人单选（ID、Name（中文名）、LoginName（登录名）），选人多选（ID、Name、LoginName）
        [self selectPeopleInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"901"] ||
               [fieldItem.inputType isEqualToString:@"902"] ||
               [fieldItem.inputType isEqualToString:@"911"] ||
               [fieldItem.inputType isEqualToString:@"912"]) {
        //选部门单选（Name、ID），选部门多选（Name、ID）
        [self selectNodeInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"1001"]) {
        //不限人员、部门。选择的结果有可能是部门，也有可能是人员。只限单选
        [self selectPeopleAndnodeInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
        
    } else if ([fieldItem.inputType isEqualToString:@"2001"] ||
               [fieldItem.inputType isEqualToString:@"2002"] ||
               [fieldItem.inputType isEqualToString:@"2003"]) {
        //意见、签名、意见或签名
        [self opinionAndAutographInputTypeFieldItem:fieldItem superView:view name:nameString value:valueString width:itemWidth cellheight:cellHeight];
        
    } else if ([fieldItem.inputType isEqualToString:@"3001"] ||
               [fieldItem.inputType isEqualToString:@"3011"] ||
               [fieldItem.inputType isEqualToString:@"3002"] ||
               [fieldItem.inputType isEqualToString:@"3012"]) {
        //读者（单选、多选）  作者（单选、多选）
        [self readerOrAuthorInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:view cellHeight:cellHeight];
        
    } else {
        //常规
        [self normalInputTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth superView:view cellheight:cellHeight];
    }
    
}


#pragma mark ------ TextField && TextView（内容）
- (void)textFieldInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    BOOL isMustInput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    NSDictionary *dic = @{@"101":@"0",@"200":@"1",@"201":@"3",@"202":@"2",@"203":@"4"};
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        
        HTMIWFCTxtView *txtView = nil;
        
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                txtView = [[HTMIWFCTxtView alloc] initWithFrame:CGRectMake(0, nameHeight, itemWidth, cellMinHeight)
                                                       textType:[[dic objectForKey:fieldItem.inputType] integerValue]
                                                     beforValue:fieldItem.beforeValue
                                                      textValue:fieldItem.value
                                                       endValue:fieldItem.endValue isMustInput:fieldItem.mustInput
                                                       textFont:self.formLabelFont
                                                      maxLength:fieldItem.maxLength];
            } else {//显示name不分行
                txtView = [[HTMIWFCTxtView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, cellMinHeight)
                                                       textType:[[dic objectForKey:fieldItem.inputType] integerValue]
                                                     beforValue:fieldItem.beforeValue
                                                      textValue:fieldItem.value
                                                       endValue:fieldItem.endValue isMustInput:fieldItem.mustInput
                                                       textFont:self.formLabelFont
                                                      maxLength:fieldItem.maxLength];
            }
        } else {//不显示name
            txtView = [[HTMIWFCTxtView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, cellMinHeight)
                                                   textType:[[dic objectForKey:fieldItem.inputType] integerValue]
                                                 beforValue:fieldItem.beforeValue
                                                  textValue:fieldItem.value
                                                   endValue:fieldItem.endValue isMustInput:fieldItem.mustInput
                                                   textFont:self.formLabelFont
                                                  maxLength:fieldItem.maxLength];
        }
        txtView.delegate = self;
        [view addSubview:txtView];
        
        typeof(self) _weakSelf = self;
        
        txtView.editBlock = ^(NSString *string) {
            
            [self.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:string mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
            
            fieldItem.value = string;
            
            //            [_weakSelf.matterFormTableView reloadData];
        };
    } else {
        if ([fieldItem.inputType isEqualToString:@"101"]) {
            if (fieldItem.nameVisible) {
                UILabel *allLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, cellHeight) text:[NSString stringWithFormat:@"%@%@",nameString,valueString] alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:allLabel];
            } else {
                UILabel *allLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, cellHeight) text:valueString alingment:fieldItem.align textColor:fieldItem.valueFontColor];
                [view addSubview:allLabel];
            }
            
        } else {
            //数字不折行
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, cellHeight)];
            
            if (fieldItem.nameVisible) {
                label.text = [NSString stringWithFormat:@"%@%@",nameString,valueString];
            } else {
                label.text = valueString;
            }
            label.textAlignment = [self alignmentWithString:fieldItem.align];
            label.font = [UIFont systemFontOfSize:self.formLabelFont];
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [self colorWithHexARGBString:[NSString stringWithFormat:@"%x",fieldItem.valueFontColor]];
            [view addSubview:label];
        }
    }
}

- (void)textViewInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    BOOL isMustInput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        
        HTMIWFCTxtView *txtView = nil;
        
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                txtView = [[HTMIWFCTxtView alloc] initWithFrame:CGRectMake(0, nameHeight, itemWidth, cellHeight-nameHeight)
                                                       textType:TextTypeTextView
                                                     beforValue:fieldItem.beforeValue
                                                      textValue:fieldItem.value
                                                       endValue:fieldItem.endValue isMustInput:isMustInput
                                                       textFont:self.formLabelFont
                                                      maxLength:fieldItem.maxLength];
            } else {//显示name不分行
                txtView = [[HTMIWFCTxtView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, cellHeight)
                                                       textType:TextTypeTextView
                                                     beforValue:fieldItem.beforeValue
                                                      textValue:fieldItem.value
                                                       endValue:fieldItem.endValue isMustInput:isMustInput
                                                       textFont:self.formLabelFont
                                                      maxLength:fieldItem.maxLength];
            }
        } else {//不显示name
            txtView = [[HTMIWFCTxtView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, cellHeight)
                                                   textType:TextTypeTextView
                                                 beforValue:fieldItem.beforeValue
                                                  textValue:fieldItem.value
                                                   endValue:fieldItem.endValue isMustInput:isMustInput
                                                   textFont:self.formLabelFont
                                                  maxLength:fieldItem.maxLength];
        }
        txtView.delegate = self;
        [view addSubview:txtView];
        
        txtView.editBlock = ^(NSString *string) {
            [self.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:string mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
            
            fieldItem.value = string;
            
            //            NSIndexPath *indexPaths = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            //            NSArray *array = [NSArray arrayWithObjects:indexPaths,nil];
            //            [self.matterFormTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
            //            [self drawLineInView:cell.contentView tableView:self.matterFormTableView indexpath:indexPath];
            //            NSLog(@"%ld",(long)indexPaths.row);
            //
        };
        
        txtView.editEndBlock = ^(NSString *string) {
            [self.matterFormTableView reloadData];
        };
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

#pragma mark ------ 时间选择（内容）
- (void)timeSelectInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    BOOL isMustinput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                namelabel.font = [UIFont systemFontOfSize:self.formLabelFont];
                [view addSubview:namelabel];
                
                [self creatTimeSelectViewFrame:CGRectMake(borderLeftWidth, nameHeight, itemWidth-borderLeftWidth*2, cellHeight-nameHeight-borderTopHeight*2) superView:view valueString:valueString isMustInput:isMustinput];
                
            } else {//显示name不分行
                [self creatTimeSelectViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2) superView:view valueString:valueString isMustInput:isMustinput];
            }
        } else {//不显示name
            [self creatTimeSelectViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2) superView:view valueString:valueString isMustInput:isMustinput];
        }
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

- (void)creatTimeSelectViewFrame:(CGRect)frame superView:(UIView *)superView valueString:(NSString *)valueString isMustInput:(BOOL)isMustinput {
    UIView *borderView = [self creatBorderViewFrame:frame];
    borderView.tag = superView.tag;
    if (isMustinput) {
        borderView.backgroundColor = mustInputColor;
    }
    [superView addSubview:borderView];
    
    UITapGestureRecognizer *timeViewClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewClick:)];
    timeViewClick.delegate = self;
    [borderView addGestureRecognizer:timeViewClick];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(7)*2, H(borderView))];
    timeLabel.text = valueString;
    timeLabel.font = [UIFont systemFontOfSize:self.formLabelFont];
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.numberOfLines = 0;
    if (valueString.length<1) {
        timeLabel.text = @"请选择时间";
        timeLabel.textColor = [UIColor lightGrayColor];
    }
    [borderView addSubview:timeLabel];
}

- (void)timeViewClick:(UITapGestureRecognizer *)tap {
    if (self.datePicker) {
        [self.datePicker removeFromSuperview];
    }
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    UITableViewCell *cell = [self getCellBy:tap.view];
    
    HTMIWFCOAInfoRegion *infoRegion =self.infoRegionArray[[self.matterFormTableView indexPathForCell:cell].row];
    HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[tap.view.tag];
    
    NSDictionary *dic = @{@"300":@"2",@"301":@"3",@"302":@"0",@"303":@"1",@"304":@"4"};
    
    self.datePicker = [[HTMIWFCPickerView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 216+30) myselecttype:[[dic objectForKey:fieldItem.inputType] integerValue] andmyBackColor:[UIColor whiteColor] andmyCellBackClolr:[UIColor whiteColor]];
    [self.view.window addSubview:self.datePicker];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.datePicker.frame = CGRectMake(0, kScreenHeight-246, kScreenWidth, 216+30);
    [UIView commitAnimations];
    
    typeof(self) __weakSelf = self;
    
    typeof(self.datePicker) __weakDatePicker = self.datePicker;
    
    self.datePicker.myPickerBlockString = ^(NSString *timeString) {
        
        if (timeString.length > 0) {
            fieldItem.value = timeString;
            [__weakSelf.matterFormTableView reloadData];
            
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:timeString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            __weakDatePicker.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 216+30);
        } completion:^(BOOL finished) {
            [__weakDatePicker removeFromSuperview];
        }];
    };
}

#pragma mark ------ 下拉选择（内容）
- (void)pulldownListBoxInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight tableView:(UITableView *)tableView {
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:namelabel];
                
                [self creatDropDownListBoxByFrame:CGRectMake(0, nameHeight, itemWidth, cellHeight-nameHeight) superView:view tableView:tableView fieldItem:fieldItem];
                
            } else {//显示name不分行
                [self creatDropDownListBoxByFrame:CGRectMake(0, 0, itemWidth, cellHeight) superView:view tableView:tableView fieldItem:fieldItem];
            }
        } else {//不显示name
            [self creatDropDownListBoxByFrame:CGRectMake(0, 0, itemWidth, cellHeight) superView:view tableView:tableView fieldItem:fieldItem];
        }
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

- (void)creatDropDownListBoxByFrame:(CGRect)frame superView:(UIView *)superView tableView:(UITableView *)tableView fieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem {
    
    BOOL isMustInput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    NSDictionary *dic = @{@"401":@"0",@"402":@"1",@"403":@"2",@"412":@"3"};
    
    HTMIWFCDropDownListBox *dropDownListbox = [[HTMIWFCDropDownListBox alloc] initWithFrame:frame
                                                                                       view:[tableView.subviews firstObject]
                                                                                  blockType:[[dic objectForKey:fieldItem.inputType] integerValue] isMustinput:isMustInput];
    dropDownListbox.userNameArray = [self nameArrayFieldItem:fieldItem];
    dropDownListbox.idArray = [self idArrayFieldItem:fieldItem];
    dropDownListbox.valueArray = [self valueArrayFieldItem:fieldItem];
    dropDownListbox.formLabelFont = self.formLabelFont;
    
    
    if ([fieldItem.inputType isEqualToString:@"412"]) {
        dropDownListbox.textField.text = fieldItem.value;
        dropDownListbox.isMustInput = fieldItem.mustInput;
    } else {
        for (int i = 0; i < fieldItem.dicts.count; i++) {
            NSDictionary *dic = fieldItem.dicts[i];
            NSString *idString = [dic objectForKey:@"id"];
            NSString *nameString = [dic objectForKey:@"name"];
            NSString *valueString = [dic objectForKey:@"value"];
            
            if ([fieldItem.value isEqualToString:idString] ||
                [fieldItem.value isEqualToString:nameString] ||
                [fieldItem.value isEqualToString:valueString]) {
                
                NSString *nameString = [dic objectForKey:@"name"];
                dropDownListbox.selectedLabel.text = nameString;
            }
        }
    }
    
    [superView addSubview:dropDownListbox];
    
    [self.listBoxArray addObject:dropDownListbox];
    
    typeof(dropDownListbox) __weak weakDropDownListBox = dropDownListbox;
    
    dropDownListbox.blockSelf = ^(HTMIWFCDropDownListBox *box) {
        
        for (id __strong view in [tableView.subviews firstObject].subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                [view removeFromSuperview];
                view = nil;
            }
        }
        
        for (HTMIWFCDropDownListBox *listbox in self.listBoxArray) {
            if (listbox != box) {
                listbox.dropDownClick = NO;
            }
        }
    };
    
    dropDownListbox.listBoxBlock = ^(NSString *string) {
        
        [self.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:string mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        
        if (![fieldItem.inputType isEqualToString:@"412"]) {
            fieldItem.value = weakDropDownListBox.selectedLabel.text;
            [self.matterFormTableView reloadData];
        }
    };
}

//ID、name、value数组
- (NSArray *)idArrayFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem {
    NSMutableArray *idArray = [NSMutableArray array];
    
    for (int i = 0; i < fieldItem.dicts.count; i++) {
        NSDictionary *dic = fieldItem.dicts[i];
        [idArray addObject:[dic objectForKey:@"id"]];
    }
    
    return idArray;
}

- (NSArray *)nameArrayFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem {
    NSMutableArray *nameArray = [NSMutableArray array];
    
    for (int i = 0; i < fieldItem.dicts.count; i++) {
        NSDictionary *dic = fieldItem.dicts[i];
        [nameArray addObject:[dic objectForKey:@"name"]];
    }
    
    return nameArray;
}

- (NSArray *)valueArrayFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem {
    NSMutableArray *valueArray = [NSMutableArray array];
    
    for (int i = 0; i < fieldItem.dicts.count; i++) {
        NSDictionary *dic = fieldItem.dicts[i];
        [valueArray addObject:[dic objectForKey:@"value"]];
    }
    
    return valueArray;
}

#pragma mark ------ 单选多选框（内容）
- (void)selectInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    NSArray *array = fieldItem.dicts;
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:namelabel];
                
                [self creatSelectViewFrame:CGRectMake(0, nameHeight, itemWidth, cellHeight-nameHeight) superView:view array:array fieldItem:fieldItem];
                
            } else {//显示name不分行
                [self creatSelectViewFrame:CGRectMake(0, 0, itemWidth, cellHeight) superView:view array:array fieldItem:fieldItem];
            }
        } else {//不显示name
            [self creatSelectViewFrame:CGRectMake(0, 0, itemWidth, cellHeight) superView:view array:array fieldItem:fieldItem];
        }
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

- (void)creatSelectViewFrame:(CGRect)frame superView:(UIView *)superView array:(NSArray *)array fieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem {
    NSDictionary *dic = @{@"501":@"0",
                          @"502":@"1",
                          @"503":@"2",
                          @"511":@"3",
                          @"512":@"4",
                          @"513":@"5"};
    
    BOOL isMustInput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    HTMIWFCSelectView *selectView = [[HTMIWFCSelectView alloc] initWithFrame:frame dicsArray:array selectType:[[dic objectForKey:fieldItem.inputType] integerValue] isMustInput:isMustInput value:[self changValueOrIdToName:fieldItem.value dicArrarr:fieldItem.dicts]];
    [superView addSubview:selectView];
    
    typeof(self) __weakSelf = self;
    
    selectView.MultiSelectionBlock = ^(NSArray *array) {
        
        NSString *string = [array componentsJoinedByString:@";"];
        
        [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:string mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        
        fieldItem.value = string;
        
        [self.matterFormTableView reloadData];
    };
    
    selectView.SingleSelectionBlock = ^(NSString *string) {
        
        [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:string mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        
        fieldItem.value = string;
        
        [self.matterFormTableView reloadData];
    };
}

#pragma mark ------ 选人（内容）
- (void)selectPeopleInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    BOOL isMustinput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        
        UIView *borderView = nil;
        
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:namelabel];
                
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, nameHeight+borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-nameHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    valueLabel.text = @"请选择人员";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
                [borderView addSubview:valueLabel];
                
            } else {//显示name不分行
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    valueLabel.text = @"请选择人员";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
                [borderView addSubview:valueLabel];
            }
            
        } else {//不显示name
            borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
            [view addSubview:borderView];
            
            UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                       text:fieldItem.value
                                                  alingment:fieldItem.align
                                                  textColor:fieldItem.valueFontColor];
            if (fieldItem.value.length < 1) {
                valueLabel.text = @"请选择人员";
                valueLabel.textColor = [UIColor lightGrayColor];
            }
            [borderView addSubview:valueLabel];
        }
        
        if (isMustinput) {
            borderView.backgroundColor = mustInputColor;
        }
        
        borderView.tag = view.tag;
        UITapGestureRecognizer *borderViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecetPeople:)];
        borderViewTap.delegate = self;
        [borderView addGestureRecognizer:borderViewTap];
        
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}


- (void)selecetPeople:(UITapGestureRecognizer *)tap {
    UITableViewCell *cell = [self getCellBy:tap.view];
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[[self.matterFormTableView indexPathForCell:cell].row];
    HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[tap.view.tag];
    
    NSDictionary *dic = @{@"601":@"1",@"602":@"1",@"603":@"1",
                          @"611":@"0",@"612":@"0",@"613":@"0"};
    
    HTMIABCChooseFormAddressBookViewController *abVC = [[HTMIABCChooseFormAddressBookViewController alloc] initWithChooseType:ChooseTypeUserFromAll isSingleSelection:[[dic objectForKey:fieldItem.inputType] integerValue] specificArray:nil isTree:YES];
    [self.navigationController pushViewController:abVC animated:YES];
    
    typeof(self) __weakSelf = self;
    
    abVC.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray) {
        //departmenCode = ID , UserID = value
        
        NSMutableArray *labelTextArray = [NSMutableArray array];
        NSMutableArray *idArray  =[NSMutableArray array];
        NSMutableArray *valueArray = [NSMutableArray array];
        
        for (int i = 0; i < resultArray.count; i++) {
            HTMIABCSYS_UserModel *userModel = resultArray[i];
            
            [labelTextArray addObject:userModel.FullName];
            [idArray addObject:userModel.UserId];
            [valueArray addObject:userModel.UserId];
        }
        NSString *labelTextString = [labelTextArray componentsJoinedByString:@";"];
        NSString *idString = [idArray componentsJoinedByString:@";"];
        NSString *valueString = [valueArray componentsJoinedByString:@";"];
        
        fieldItem.value = labelTextString;
        
        if ([fieldItem.inputType isEqualToString:@"601"] || [fieldItem.inputType isEqualToString:@"611"]) {
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:idString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        }else if ([fieldItem.inputType isEqualToString:@"602"] || [fieldItem.inputType isEqualToString:@"612"]) {
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:labelTextString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        }else if ([fieldItem.inputType isEqualToString:@"603"] || [fieldItem.inputType isEqualToString:@"613"]) {
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:valueString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        }
        
        [__weakSelf.matterFormTableView reloadData];
    };
}

#pragma mark ------ 读者 、 作者
- (void)readerOrAuthorInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    BOOL isMustinput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        
        UIView *borderView = nil;
        
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:namelabel];
                
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, nameHeight+borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-nameHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    if ([fieldItem.inputType isEqualToString:@"3001" ] ||
                        [fieldItem.inputType isEqualToString:@"3011"]) {
                        valueLabel.text = @"请选择读者";
                        valueLabel.textColor = [UIColor lightGrayColor];
                    } else if (([fieldItem.inputType isEqualToString:@"3002" ] ||
                                [fieldItem.inputType isEqualToString:@"3012"])) {
                        valueLabel.text = @"请选择作者";
                        valueLabel.textColor = [UIColor lightGrayColor];
                    }
                    
                }
                [borderView addSubview:valueLabel];
                
            } else {//显示name不分行
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    if ([fieldItem.inputType isEqualToString:@"3001" ] ||
                        [fieldItem.inputType isEqualToString:@"3011"]) {
                        valueLabel.text = @"请选择读者";
                        valueLabel.textColor = [UIColor lightGrayColor];
                    } else if (([fieldItem.inputType isEqualToString:@"3002" ] ||
                                [fieldItem.inputType isEqualToString:@"3012"])) {
                        valueLabel.text = @"请选择作者";
                        valueLabel.textColor = [UIColor lightGrayColor];
                    }
                }
                [borderView addSubview:valueLabel];
            }
            
        } else {//不显示name
            borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
            [view addSubview:borderView];
            
            UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                       text:fieldItem.value
                                                  alingment:fieldItem.align
                                                  textColor:fieldItem.valueFontColor];
            if (fieldItem.value.length < 1) {
                if ([fieldItem.inputType isEqualToString:@"3001" ] ||
                    [fieldItem.inputType isEqualToString:@"3011"]) {
                    valueLabel.text = @"请选择读者";
                    valueLabel.textColor = [UIColor lightGrayColor];
                } else if (([fieldItem.inputType isEqualToString:@"3002" ] ||
                            [fieldItem.inputType isEqualToString:@"3012"])) {
                    valueLabel.text = @"请选择作者";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
            }
            [borderView addSubview:valueLabel];
        }
        
        if (isMustinput) {
            borderView.backgroundColor = mustInputColor;
        }
        
        borderView.tag = view.tag;
        UITapGestureRecognizer *borderViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecetReaderOrAuthor:)];
        borderViewTap.delegate = self;
        [borderView addGestureRecognizer:borderViewTap];
        
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

- (void)selecetReaderOrAuthor:(UITapGestureRecognizer *)tap {
    UITableViewCell *cell = [self getCellBy:tap.view];
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[[self.matterFormTableView indexPathForCell:cell].row];
    HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[tap.view.tag];
    
    NSDictionary *dic = @{@"3001":@"1",@"3002":@"1",
                          @"3011":@"0",@"3012":@"0"};
    
    
    
    HTMIABCChooseFormAddressBookViewController *abVC = [[HTMIABCChooseFormAddressBookViewController alloc] initWithChooseType:ChooseTypeUserFromAll isSingleSelection:[[dic objectForKey:fieldItem.inputType] integerValue] specificArray:nil isTree:YES];
    [self.navigationController pushViewController:abVC animated:YES];
    
    typeof(self) __weakSelf = self;
    
    abVC.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray) {
        //departmenCode = ID , UserID = value
        
        NSMutableArray *labelTextArray = [NSMutableArray array];
        NSMutableArray *idArray  =[NSMutableArray array];
        NSMutableArray *valueArray = [NSMutableArray array];
        
        for (int i = 0; i < resultArray.count; i++) {
            HTMIABCSYS_UserModel *userModel = resultArray[i];
            
            [labelTextArray addObject:userModel.FullName];
            [idArray addObject:userModel.UserId];
            [valueArray addObject:userModel.UserId];
        }
        NSString *labelTextString = [labelTextArray componentsJoinedByString:@";"];
        NSString *idString = [idArray componentsJoinedByString:@";"];
        NSString *valueString = [valueArray componentsJoinedByString:@";"];
        
        fieldItem.value = labelTextString;
        
        [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:idString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        
        [__weakSelf.matterFormTableView reloadData];
    };
}

#pragma mark ------ 选部门（内容）
- (void)selectNodeInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    BOOL isMustinput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        
        UIView *borderView = nil;
        
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:namelabel];
                
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, nameHeight+borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-nameHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    valueLabel.text = @"请选择部门";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
                [borderView addSubview:valueLabel];
                
            } else {//显示name不分行
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    valueLabel.text = @"请选择部门";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
                [borderView addSubview:valueLabel];
            }
            
        } else {//不显示name
            borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
            [view addSubview:borderView];
            
            UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                       text:fieldItem.value
                                                  alingment:fieldItem.align
                                                  textColor:fieldItem.valueFontColor];
            if (fieldItem.value.length < 1) {
                valueLabel.text = @"请选择部门";
                valueLabel.textColor = [UIColor lightGrayColor];
            }
            [borderView addSubview:valueLabel];
        }
        
        if (isMustinput) {
            borderView.backgroundColor = mustInputColor;
        }
        
        borderView.tag = view.tag;
        UITapGestureRecognizer *borderViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecetNode:)];
        borderViewTap.delegate = self;
        [borderView addGestureRecognizer:borderViewTap];
        
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

- (void)selecetNode:(UITapGestureRecognizer *)tap {
    UITableViewCell *cell = [self getCellBy:tap.view];
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[[self.matterFormTableView indexPathForCell:cell].row];
    HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[tap.view.tag];
    
    NSDictionary *dic = @{@"901":@"1",@"902":@"1",
                          @"911":@"0",@"912":@"0"};
    
    HTMIABCChooseFormAddressBookViewController *abVC = [[HTMIABCChooseFormAddressBookViewController alloc] initWithChooseType:ChooseTypeDepartmentFromAll isSingleSelection:[[dic objectForKey:fieldItem.inputType] integerValue] specificArray:nil isTree:YES];
    [self.navigationController pushViewController:abVC animated:YES];
    
    typeof(self) __weakSelf = self;
    
    abVC.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray) {
        //其中 departmentCode 为ID
        
        NSMutableArray *labelTextArray = [NSMutableArray array];
        NSMutableArray *idArray = [NSMutableArray array];
        
        for (int i = 0; i < resultArray.count; i++) {
            HTMIABCSYS_DepartmentModel *departmentModel = resultArray[i];
            
            [labelTextArray addObject:departmentModel.FullName];
            [idArray addObject:departmentModel.DepartmentCode];
        }
        NSString *labelTextString = [labelTextArray componentsJoinedByString:@";"];
        NSString *idString = [idArray componentsJoinedByString:@";"];
        
        fieldItem.value = labelTextString;
        
        if ([fieldItem.inputType isEqualToString:@"901"] || [fieldItem.inputType isEqualToString:@"911"]) {
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:labelTextString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        } else if ([fieldItem.inputType isEqualToString:@"902"] || [fieldItem.inputType isEqualToString:@"912"]) {
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:idString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        }
        
        [__weakSelf.matterFormTableView reloadData];
    };
}

#pragma mark ------ 选人或部门，单选（内容）
- (void)selectPeopleAndnodeInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth totalView:(UIView *)view cellHeight:(CGFloat)cellHeight {
    
    BOOL isMustinput = [self isMustInput:fieldItem.mustInput value:fieldItem.value];
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        
        UIView *borderView = nil;
        
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name且分行显示
                
                UILabel *namelabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight) text:nameString alingment:fieldItem.align textColor:fieldItem.nameFontColor];
                [view addSubview:namelabel];
                
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, nameHeight+borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-nameHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    valueLabel.text = @"请选择人员或部门";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
                [borderView addSubview:valueLabel];
                
            } else {//显示name不分行
                borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
                [view addSubview:borderView];
                
                UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                           text:fieldItem.value
                                                      alingment:fieldItem.align
                                                      textColor:fieldItem.valueFontColor];
                if (fieldItem.value.length < 1) {
                    valueLabel.text = @"请选择人员或部门";
                    valueLabel.textColor = [UIColor lightGrayColor];
                }
                [borderView addSubview:valueLabel];
            }
            
        } else {//不显示name
            borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, cellHeight-borderTopHeight*2)];
            [view addSubview:borderView];
            
            UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(kW6(7), 0, W(borderView)-kW6(14), H(borderView))
                                                       text:fieldItem.value
                                                  alingment:fieldItem.align
                                                  textColor:fieldItem.valueFontColor];
            if (fieldItem.value.length < 1) {
                valueLabel.text = @"请选择人员或部门";
                valueLabel.textColor = [UIColor lightGrayColor];
            }
            [borderView addSubview:valueLabel];
        }
        
        if (isMustinput) {
            borderView.backgroundColor = mustInputColor;
        }
        
        borderView.tag = view.tag;
        UITapGestureRecognizer *borderViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecetNodeAndPeople:)];
        borderViewTap.delegate = self;
        [borderView addGestureRecognizer:borderViewTap];
        
        
    } else {
        [self inputNoEditFieldItem:fieldItem nameString:nameString valueString:valueString width:itemWidth-stringLeftWidth*2 cellHeight:cellHeight superView:view];
    }
}

- (void)selecetNodeAndPeople:(UITapGestureRecognizer *)tap {
    UITableViewCell *cell = [self getCellBy:tap.view];
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[[self.matterFormTableView indexPathForCell:cell].row];
    HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[tap.view.tag];
    
    HTMIABCChooseFormAddressBookViewController *abVC = [[HTMIABCChooseFormAddressBookViewController alloc] initWithChooseType:ChooseTypeOrganization isSingleSelection:YES specificArray:nil isTree:YES];
    [self.navigationController pushViewController:abVC animated:YES];
    
    typeof(self) __weakSelf = self;
    
    abVC.resultBlock = ^(NSArray *resultArray, NSArray *selectedRouteArray) {
        
        NSString *string = nil;
        for (id any in resultArray) {
            if ([any isKindOfClass:[HTMIABCSYS_DepartmentModel class]]) {
                HTMIABCSYS_DepartmentModel *model = any;
                string = model.FullName;
            } else {
                HTMIABCSYS_UserModel *model = any;
                string = model.FullName;
            }
        }
        
        fieldItem.value = string;
        
        [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:string mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
        
        [__weakSelf.matterFormTableView reloadData];
    };
}

#pragma mark ------ 意见、签名、意见或签名（内容）
- (void)opinionAndAutographInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem superView:(UIView *)superView name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth cellheight:(CGFloat)cellHeight {
    
    if ((![fieldItem.mode isEqual:[NSNull null]] && [fieldItem.mode isEqualToString:@"1"])) {
        if (fieldItem.nameVisible) {
            if (fieldItem.nameRN) {//显示name并且折行
                CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
                
                if ([fieldItem.inputType isEqualToString:@"2001"]) {
                    [self creatOpinionByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:nameHeight superView:superView];
                    
                } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                    [self creatAutographByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:nameHeight superView:superView];
                    
                } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                    [self creatOpnionOrAutographByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:nameHeight superView:superView];
                    
                }
            } else {//显示name不折行
                if ([fieldItem.inputType isEqualToString:@"2001"]) {
                    [self creatOpinionByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:0 superView:superView];
                    
                } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                    [self creatAutographByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:0 superView:superView];
                    
                } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                    [self creatOpnionOrAutographByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:0 superView:superView];
                }
            }
        } else {//不显示name
            if ([fieldItem.inputType isEqualToString:@"2001"]) {
                [self creatOpinionByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:0 superView:superView];
                
            } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                [self creatAutographByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:0 superView:superView];
                
            } else if ([fieldItem.inputType isEqualToString:@"2003"]) {
                [self creatOpnionOrAutographByFielditem:fieldItem itemWidth:itemWidth cellHeight:cellHeight nameHeight:0 superView:superView];
                
            }
        }
    } else {
        
        if (fieldItem.nameVisible && fieldItem.nameRN) {
            CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
            UILabel *nameLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight)
                                                      text:fieldItem.name
                                                 alingment:fieldItem.align
                                                 textColor:fieldItem.nameFontColor];
            [superView addSubview:nameLabel];
            
            if ([fieldItem.inputType isEqualToString:@"2001"] || [fieldItem.inputType isEqualToString:@"2003"]) {
                [self opnionAndAutographOipnions:fieldItem.opintions superView:superView itemWidth:itemWidth nameHeight:nameHeight];
                
            } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                [self autograph:fieldItem.value superView:superView itemWidth:itemWidth nameHeight:nameHeight];
            }
        } else {
            if ([fieldItem.inputType isEqualToString:@"2001"] || [fieldItem.inputType isEqualToString:@"2003"]) {
                [self opnionAndAutographOipnions:fieldItem.opintions superView:superView itemWidth:itemWidth nameHeight:0];
                
            } else if ([fieldItem.inputType isEqualToString:@"2002"]) {
                [self autograph:fieldItem.value superView:superView itemWidth:itemWidth nameHeight:0];
            }
        }
        
    }
}

/**
 *  意见
 */
- (void)creatOpinionByFielditem:(HTMIWFCOAMatterFormFieldItem *)fieldItem itemWidth:(CGFloat)itemWidth cellHeight:(CGFloat)cellHeight nameHeight:(CGFloat)nameHeight superView:(UIView *)superView {
    CGFloat havedHeight = [self opnionAndAutographOipnions:fieldItem.opintions superView:superView itemWidth:itemWidth nameHeight:nameHeight];//已经存在的意见
    
    UILabel *nameLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight)
                                              text:fieldItem.name
                                         alingment:fieldItem.align
                                         textColor:fieldItem.nameFontColor];
    [superView addSubview:nameLabel];
    
    //"请填写意见"点击
    UIView *opinionView = [[UIView alloc] initWithFrame:CGRectMake(0, nameHeight+havedHeight, itemWidth, cellHeight-havedHeight-nameHeight)];
    opinionView.userInteractionEnabled = YES;
    opinionView.tag = superView.tag;
    [superView addSubview:opinionView];
    
    UIView *borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, borderTopHeight, itemWidth-borderLeftWidth*2, H(opinionView)-borderTopHeight*2)];
    [opinionView addSubview:borderView];
    
    if (fieldItem.mustInput && fieldItem.eidtValue.length<1) {
        borderView.backgroundColor = mustInputColor;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(stringLeftWidth, borderTopHeight, itemWidth-stringLeftWidth*2, H(opinionView)-borderTopHeight*2)];
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:self.formLabelFont];
    label.text = fieldItem.eidtValue;
    [opinionView addSubview:label];
    if (fieldItem.eidtValue.length < 1) {
        label.text = @"请填写意见";
        label.textColor = [UIColor lightGrayColor];
    }
    
    UITapGestureRecognizer *opinionViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opinionViewTapClick:)];
    opinionViewTap.delegate = self;
    [opinionView addGestureRecognizer:opinionViewTap];
    
}

/**
 *  签名
 */
- (void)creatAutographByFielditem:(HTMIWFCOAMatterFormFieldItem *)fieldItem itemWidth:(CGFloat)itemWidth cellHeight:(CGFloat)cellHeight nameHeight:(CGFloat)nameHeight superView:(UIView *)superView {
    
    UILabel *nameLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight)
                                              text:fieldItem.name
                                         alingment:fieldItem.align
                                         textColor:fieldItem.nameFontColor];
    [superView addSubview:nameLabel];
    
    CGFloat havedHeight = [self autograph:fieldItem.value superView:superView itemWidth:itemWidth nameHeight:nameHeight];
    
    NSArray *autographArray = [fieldItem.value componentsSeparatedByString:@"\r\n"];
    if ([[autographArray lastObject] rangeOfString:self.myUserName].location == NSNotFound){
        //上一个签名不是自己
        UIView *borderView = [self creatBorderViewFrame:CGRectMake(borderLeftWidth, cellHeight-kH6(45), itemWidth-borderLeftWidth*2, kH6(40))];
        borderView.tag = superView.tag;
        [superView addSubview:borderView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(W(borderView)-30, 0, 40, 40)];
        imageView.image = [UIImage getPNGImageHTMIWFC:@"btn_singnature"];
        [borderView addSubview:imageView];
        
        UILabel *autoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kW6(7), 0, itemWidth-stringLeftWidth-kW6(30), kH6(40))];
        autoLabel.userInteractionEnabled = YES;
        autoLabel.font = [UIFont systemFontOfSize:self.formLabelFont];
        autoLabel.text = fieldItem.eidtValue;
        autoLabel.adjustsFontSizeToFitWidth = YES;
        autoLabel.numberOfLines = 0;
        if (fieldItem.eidtValue.length < 1) {
            autoLabel.text = @"签名";
            autoLabel.textColor = [UIColor lightGrayColor];
        }
        [borderView addSubview:autoLabel];
        
        if (fieldItem.mustInput && fieldItem.eidtValue.length<1) {
            borderView.backgroundColor = mustInputColor;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autographTap:)];
        tap.delegate = self;
        [borderView addGestureRecognizer:tap];
        
    }
}

/**
 *  签名或意见
 */
- (void)creatOpnionOrAutographByFielditem:(HTMIWFCOAMatterFormFieldItem *)fieldItem itemWidth:(CGFloat)itemWidth cellHeight:(CGFloat)cellHeight nameHeight:(CGFloat)nameHeight superView:(UIView *)superView {
    
    UILabel *nameLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, nameHeight)
                                              text:fieldItem.name
                                         alingment:fieldItem.align
                                         textColor:fieldItem.nameFontColor];
    [superView addSubview:nameLabel];
    
    CGFloat havedHeight = [self opnionAndAutographOipnions:fieldItem.opintions superView:superView itemWidth:itemWidth nameHeight:nameHeight];//已经存在的意见
    
    CGFloat eidtHeight = 0;
    if (fieldItem.eidtValue.length > 0) {//编写的意见或签名
        CGFloat editH = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:fieldItem.eidtValue FontOfSize:self.formLabelFont].height+stringTopHeight*2;
        
        eidtHeight = MAX(editH, kH6(50));
        
        UILabel *eidtLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, nameHeight+havedHeight+(itemWidth>kW6(200) ? kH6(50) :kH6(100)), itemWidth-stringLeftWidth*2, cellHeight-(nameHeight+havedHeight+(itemWidth>kW6(200) ? kH6(50) :kH6(100)))) text:fieldItem.eidtValue alingment:@"Left" textColor:fieldItem.valueFontColor];
        [superView addSubview:eidtLabel];
    }
    
    HTMIWFCOpinionAutographView *oaView = [[HTMIWFCOpinionAutographView alloc]
                                           initWithFrame:CGRectMake(0,nameHeight+havedHeight,itemWidth,cellHeight-nameHeight-havedHeight-eidtHeight)
                                           selectType:itemWidth>kW6(200) ? HorizontalType :VerticalType aOro:fieldItem.aOrO];
    [superView addSubview:oaView];
    
    BOOL isMustInput = [self isMustInput:fieldItem.mustInput value:fieldItem.eidtValue];
    if (isMustInput) {
        oaView.backgroundColor = mustInputColor;
    }
    
    typeof(self) __weakSelf = self;
    
    oaView.buttonClickBlock = ^(NSString *string) {
        
        if ([string isEqualToString:@"签名"]) {
            fieldItem.eidtValue = self.myUserName;
            fieldItem.aOrO = @"签名";
            
            //签名     暂时显示姓名，提交空格
            [__weakSelf.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:@" " mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
            
            [__weakSelf.matterFormTableView reloadData];
            
        } else if ([string isEqualToString:@"意见"]) {
            HTMIWFCOAQuickOpinionViewController *qovc = [[HTMIWFCOAQuickOpinionViewController alloc] init];
            qovc.delegate = self;
            if (![fieldItem.eidtValue isEqualToString:self.myUserName]) {
                qovc.opinionString = fieldItem.eidtValue;
            }
            [self.navigationController pushViewController:qovc animated:YES];
            
            UITableViewCell *cell = [self getCellBy:superView];
            __weakSelf.currentEidtRegionIndex = [self.matterFormTableView indexPathForCell:cell].row;
            __weakSelf.currentEidtFieldItemIndex = superView.tag;
            
        }
    };
}

//已经存在的意见
- (CGFloat)opnionAndAutographOipnions:(NSArray *)opinions superView:(UIView *)superView itemWidth:(CGFloat)itemWidth nameHeight:(CGFloat)nameLabelHeight{
    CGFloat allheight = 0;
    
    for (int i = 0; i < opinions.count; i++) {
        NSDictionary *dic = opinions[i];
        
        NSString *opinion = ((NSString *)[dic objectForKey:@"opinionText"]).length>0 ? [dic objectForKey:@"opinionText"] : @" ";
        NSString *name = [dic objectForKey:@"userName"];
        NSString *time = [dic objectForKey:@"saveTime"];
        
        CGFloat opinionHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:opinion FontOfSize:self.formLabelFont].height;
        CGFloat nameHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:name FontOfSize:self.formLabelFont].height;
        CGFloat timeHeight = [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:time FontOfSize:self.formLabelFont].height;
        
        CGRect opinionFrame =CGRectMake(stringLeftWidth,
                                        stringTopHeight+allheight+nameLabelHeight,
                                        itemWidth-stringLeftWidth*2,
                                        opinionHeight);
        UILabel *opinionLabel = [self creatLabelWithFrame:opinionFrame text:opinion alingment:@"Left" textColor:-16777216];
        [superView addSubview:opinionLabel];
        
        CGRect nameframe = CGRectMake(stringLeftWidth,
                                      stringTopHeight+opinionHeight+allheight+nameLabelHeight,
                                      [self labelSizeWithMaxWidth:0 content:name FontOfSize:self.formLabelFont].width,
                                      nameHeight);
        UILabel *nameLabel = [self creatLabelWithFrame:nameframe text:name alingment:@"Left" textColor:-16777216];
        nameLabel.userInteractionEnabled = YES;
        nameLabel.textColor = eidtColor;
        [superView addSubview:nameLabel];
        
        CGRect timeframe = CGRectMake(stringLeftWidth,
                                      stringTopHeight+opinionHeight+nameHeight+allheight+nameLabelHeight,
                                      itemWidth-stringLeftWidth*2,
                                      timeHeight);
        UILabel *timeLabel = [self creatLabelWithFrame:timeframe text:time alingment:@"Left" textColor:-16777216];
        [superView addSubview:timeLabel];
        
        CGFloat eachHeight = stringTopHeight + opinionHeight + nameHeight + timeHeight;
        
        allheight += eachHeight;
        
        //聊天
        if (((NSString *)[dic objectForKey:@"UserID"]).length > 0) {
            [self.opinionIdArray addObject:[dic objectForKey:@"UserID"]];
            nameLabel.tag = self.opinionIdIndex;
            
            self.opinionIdIndex += 1;
            
            UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameTapClick:)];
            nameTap.delegate = self;
            [nameLabel addGestureRecognizer:nameTap];
        }
    }
    
    return allheight;
}

- (void)opinionViewTapClick:(UITapGestureRecognizer *)tap {
    UITableViewCell *cell = [self getCellBy:tap.view];
    self.currentEidtRegionIndex = [self.matterFormTableView indexPathForCell:cell].row;
    self.currentEidtFieldItemIndex = tap.view.tag;
    
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[self.currentEidtRegionIndex];
    HTMIWFCOAMatterFormFieldItem *fieldItem = infoRegion.feildItemList[self.currentEidtFieldItemIndex];
    
    HTMIWFCOAQuickOpinionViewController *qqvc = [[HTMIWFCOAQuickOpinionViewController alloc] init];
    qqvc.delegate = self;
    qqvc.opinionString = fieldItem.eidtValue;
    [self.navigationController pushViewController:qqvc animated:YES];
    
    
}

//已经存在的签名
- (CGFloat)autograph:(NSString *)autograph superView:(UIView *)superView itemWidth:(CGFloat)itemWidth nameHeight:(CGFloat)nameHeight {
    float allHeight = 0.0;
    if (autograph.length > 0) {
        
        NSArray *autographArray = [autograph componentsSeparatedByString:@"\r\n"];
        for (int i = 0; i < autographArray.count; i++) {
            [self.autographNameArray addObject:autographArray[i]];
            
            CGFloat nameWidth = [self labelSizeWithMaxWidth:0 content:autographArray[i] FontOfSize:self.formLabelFont].width;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(stringLeftWidth,
                                                                       allHeight+stringTopHeight+nameHeight,
                                                                       nameWidth>(itemWidth-stringLeftWidth*2) ? itemWidth-stringLeftWidth*2 : nameWidth,
                                                                       [self labelSizeWithMaxWidth:nameWidth>(itemWidth-stringLeftWidth*2) ? itemWidth-stringLeftWidth*2 : nameWidth content:autographArray[i] FontOfSize:self.formLabelFont].height)];
            label.font = [UIFont systemFontOfSize:self.formLabelFont];
            label.userInteractionEnabled = YES;
            label.textColor = eidtColor;
            label.text = autographArray[i];
            label.adjustsFontSizeToFitWidth = YES;
            label.numberOfLines = 0;
            label.tag = self.autographIndex;
            self.autographIndex++;
            [superView addSubview:label];
            
            float h = stringTopHeight+label.frame.size.height;
            allHeight+=h;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputTypeTenClick:)];
            tap.delegate = self;
            [label addGestureRecognizer:tap];
        }
    }
    return allHeight;
}

//签名点击事件
-(void)autographTap:(UITapGestureRecognizer *)tap {
    NSInteger currentEidtFieldItemIndex = tap.view.tag;
    HTMIWFCOAMatterFormFieldItem *fieldItem;
    
    UITableViewCell *cell = [self getCellBy:tap.view];
    
    
    NSInteger currentEidtRegionIndex = [self.matterFormTableView indexPathForCell:cell].row;
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[currentEidtRegionIndex];
    fieldItem = infoRegion.feildItemList[currentEidtFieldItemIndex];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *contextDic = [userdefaults objectForKey:@"kContextDictionary"];
    fieldItem.eidtValue = self.myUserName;
    
    NSString *attribute = [contextDic objectForKey:@"attribute1"];
    
    NSString *writeString = nil;
    if (attribute.length < 1) {
        writeString = [NSString stringWithFormat:@"%@#%@(%@)#2",[contextDic objectForKey:@"OA_UserId"],[contextDic objectForKey:@"OA_UserName"],[contextDic objectForKey:@"ThirdDepartmentName"]];
    } else {
        writeString = [NSString stringWithFormat:@"%@#%@#1",[contextDic objectForKey:@"OA_UserId"],[contextDic objectForKey:@"attribute1"]];
    }
    [self.operationDelegate oaOperationDelegateEditOperationForKey:fieldItem.key value:writeString mode:fieldItem.mode input:fieldItem.inputType formkey:fieldItem.formkey];
    [self.matterFormTableView reloadData];
}

#pragma mark ------ 普通模式（内容）
- (void)normalInputTypeFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem name:(NSString *)nameString value:(NSString *)valueString width:(CGFloat)itemWidth superView:(UIView *)superView cellheight:(CGFloat)cellHeight {
    
    CGFloat nameHeight = nameString.length>0 ? [self labelSizeWithMaxWidth:itemWidth-stringLeftWidth*2 content:nameString FontOfSize:self.formLabelFont].height+stringTopHeight*2 : 0;
    
    if (fieldItem.nameVisible) {
        if (fieldItem.nameRN) {//显示name且分行显示
            UILabel *nameLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, valueString.length>0 ? nameHeight : cellHeight)
                                                      text:nameString
                                                 alingment:fieldItem.align
                                                 textColor:fieldItem.nameFontColor];
            
            UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, nameHeight, itemWidth-stringLeftWidth*2, cellHeight-nameHeight)
                                                       text:valueString
                                                  alingment:fieldItem.align
                                                  textColor:fieldItem.valueFontColor];
            [superView addSubview:nameLabel];
            [superView addSubview:valueLabel];
            
        } else {//显示name不分行
            UILabel *label = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, cellHeight) text:[NSString stringWithFormat:@"%@%@",nameString,valueString] alingment:fieldItem.align textColor:fieldItem.nameFontColor];
            
            [superView addSubview:label];
        }
    } else {//不显示name
        UILabel *valueLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, itemWidth-stringLeftWidth*2, cellHeight) text:valueString alingment:fieldItem.align textColor:fieldItem.valueFontColor];
        [superView addSubview:valueLabel];
    }
}


#pragma mark --------------------------------cell显示内容--------------------------------------
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    HTMIWFCOAInfoRegion *infoRegion = self.infoRegionArray[indexPath.row];
    
    UIColor *cellColor = [self colorWithHexARGBString:[NSString stringWithFormat:@"%lx",(long)infoRegion.backColor]];
    cell.backgroundColor = cellColor;
    NSLog(@"%ld",(long)indexPath.row);
    CGFloat currentX = 0;
    
    CGFloat cellHeight = [self mytableView:tableView heightForRowAtIndexPath:indexPath];
    
    NSArray *itemListInLine = infoRegion.feildItemList;
    
    /**
     *  滑动子表部分    最大宽度、scrollView数组联动
     */
    if (infoRegion.IsSplitRegion && infoRegion.ParentRegionID.length<1 && infoRegion.ScrollFlag == 1) {
        self.eachWidthArray = [self.maxWidthDic objectForKey:infoRegion.regionID];
    }
    
    CGFloat staticFlagWidth = 0;//固定前几行的宽度
    CGFloat contentWidth = 0;//滑动宽度
    
    NSMutableArray *scrollViewArray = [NSMutableArray array];
    BOOL isHave = NO;
    NSInteger replaceIndex = 0;
    
    UIScrollView *scrollView = nil;
    if (infoRegion.ScrollFlag == 1 && infoRegion.ParentRegionID.length>0) {
        for (int i = 0; i < self.eachWidthArray.count; i++) {
            HTMIWFCOAMatterFormFieldItem *fieldItem = itemListInLine[i];
            CGFloat percent = fieldItem.percent / 100.f;
            CGFloat itemWidth = kScreenWidth * (percent == 0 ? 1 : percent);
            
            if (i < infoRegion.ScrollFixColCount) {
                staticFlagWidth+=MAX(itemWidth, [self.eachWidthArray[i] floatValue]);
            }
            else {
                contentWidth+=MAX(itemWidth, [self.eachWidthArray[i] floatValue]);
            }
        }
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(staticFlagWidth, 0, kScreenWidth-staticFlagWidth, cellHeight)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(contentWidth, cellHeight);
        [scrollView setContentOffset:CGPointMake([[self.contentOffSetDic objectForKey:infoRegion.ParentRegionID] floatValue], 0)];
        [cell.contentView addSubview:scrollView];
        
        [scrollViewArray addObject:infoRegion.regionID];
        [scrollViewArray addObject:scrollView];
        
        if (self.scrollViewArray.count > 0) {
            for (int j = 0; j < self.scrollViewArray.count; j++) {
                NSArray *array = self.scrollViewArray[j];
                if ([infoRegion.regionID isEqualToString:array[0]]) {
                    replaceIndex = j;
                    isHave = YES;
                }
            }
        }
        
        if (isHave) {
            [self.scrollViewArray replaceObjectAtIndex:replaceIndex withObject:scrollViewArray];
        }
        else {
            [self.scrollViewArray addObject:scrollViewArray];
        }
    }
    
    for (NSInteger i = 0; i<[itemListInLine count]; i++) {
        HTMIWFCOAMatterFormFieldItem *fieldItem = itemListInLine[i];
        
        UIColor *backColor = [self colorWithHexARGBString:[NSString stringWithFormat:@"%x",fieldItem.BackColor]];
        
        CGFloat percent = fieldItem.percent / 100.f;
        CGFloat itemWidth = kScreenWidth * (percent == 0 ? 1 : percent);
        
        NSString *nameString = [NSString stringWithFormat:@"%@%@%@%@", fieldItem.beforeName, fieldItem.name, fieldItem.endName, fieldItem.splitString];
        NSString *valueString = [NSString stringWithFormat:@"%@%@%@%@", fieldItem.beforeValue, (fieldItem.eidtValue ? fieldItem.eidtValue : @""), fieldItem.value, fieldItem.endValue];
        
        UIView *totalView = [[UIView alloc] init];
        totalView.tag = i;
        if (fieldItem.BackColor != 0) {
            totalView.backgroundColor = backColor;
        }
        
        /**
         *  滑动子表
         */
        if (infoRegion.ScrollFlag == 1 && infoRegion.ParentRegionID.length>0) {
            //滑动
            totalView.frame = CGRectMake(currentX, 0, MAX(itemWidth, [self.eachWidthArray[i] floatValue]) , cellHeight);
            
            if (i >= infoRegion.ScrollFixColCount) {
                //滑动部分
                [scrollView addSubview:totalView];
                
                // 加上一条纵向的分割线   BOOL vlineVisible
                if (i > 0 && infoRegion.vlineVisible && currentX > 0) {
                    //添加竖线
                    UIImageView *splitView = [[UIImageView alloc] init];
                    splitView.frame = CGRectMake(currentX, 0, formLineWidth, cellHeight);
                    splitView.backgroundColor = formLineColor;
                    [scrollView addSubview:splitView];
                }
                
                currentX += MAX(itemWidth, [self.eachWidthArray[i] floatValue]);  // 左移 x 值，供后续 Label 使用
                
            } else {
                //固定部分
                [cell.contentView addSubview:totalView];
                
                // 加上一条纵向的分割线   BOOL vlineVisible
                if (i > 0 && infoRegion.vlineVisible) {
                    //添加竖线
                    UIImageView *splitView = [[UIImageView alloc] init];
                    splitView.frame = CGRectMake(currentX, 0, 2, cellHeight);
                    splitView.backgroundColor = formLineColor;
                    [cell.contentView addSubview:splitView];
                }
                
                //固定行后边加一条线
                if (i == infoRegion.ScrollFixColCount-1) {
                    UIImageView *splitView = [[UIImageView alloc] init];
                    splitView.frame = CGRectMake(currentX+MAX(itemWidth, [self.eachWidthArray[i] floatValue])-formLineWidth, 0, formLineWidth, cellHeight);
                    splitView.backgroundColor = formLineColor;
                    [cell.contentView addSubview:splitView];
                }
                
                currentX += [self.eachWidthArray[i] floatValue];  // 左移 x 值，供后续 Label 使用
            }
            
            if (i == infoRegion.ScrollFixColCount-1) {
                currentX = 0;
            }
            
            //显示内容
            [self itemDetailsTypeFieldItem:fieldItem name:nameString value:valueString width:MAX(itemWidth, [self.eachWidthArray[i] floatValue]) totalView:totalView cellHeight:cellHeight tableView:tableView cell:cell indexPath:indexPath];
            
            //筛选按钮
            //            if (self.rankArray.count > 0) {
            //                if (![self.rankArray containsObject:infoRegion.ParentRegionID]) {
            //                    //不包含
            //                    [self.rankArray addObject:infoRegion.ParentRegionID];
            //                    //添加排序图片
            //                    UIImageView *rankImageView = [[UIImageView alloc] initWithFrame:CGRectMake(W(totalView)-kW(12), 0, kW(12), cellHeight)];
            //                    rankImageView.image = [UIImage getPNGImageHTMIWFC:@"btn_matterform_paixu"];
            //                    [totalView addSubview:rankImageView];
            //
            //                }
            //
            //            } else {
            //                [self.rankArray addObject:infoRegion.ParentRegionID];
            //                //添加排序图片
            //                UIImageView *rankImageView = [[UIImageView alloc] initWithFrame:CGRectMake(W(totalView)-kW(12), 0, kW(12), cellHeight)];
            //                rankImageView.image = [UIImage getPNGImageHTMIWFC:@"btn_matterform_paixu"];
            //                [totalView addSubview:rankImageView];
            //
            //            }
            
        } else {
            //不滑动
            totalView.frame = CGRectMake(currentX, 0, itemWidth, cellHeight);
            [cell.contentView addSubview:totalView];
            
            //显示内容
            [self itemDetailsTypeFieldItem:fieldItem name:nameString value:valueString width:itemWidth totalView:totalView cellHeight:cellHeight tableView:tableView cell:cell indexPath:indexPath];
            
            // 加上一条纵向的分割线   BOOL vlineVisible
            if (i > 0 && infoRegion.vlineVisible) {
                //添加竖线
                UIImageView *splitView = [[UIImageView alloc] init];
                splitView.frame = CGRectMake(currentX, 0, formLineWidth, cellHeight);
                splitView.backgroundColor = formLineColor;
                [cell.contentView addSubview:splitView];
            }
            
            currentX += itemWidth;  // 左移 x 值，供后续 Label 使用
        }
    }
    
    //画线
    [self drawLineInView:cell.contentView tableView:tableView indexpath:indexPath];
    
    if (infoRegion.IsSplitRegion && infoRegion.SplitAction == 0) {
        //分割部分
        
    } else if (infoRegion.IsSplitRegion && infoRegion.SplitAction == 1) {
        UIImageView *downImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-60, cellHeight/2-30, 60, 60)];
        
        if (infoRegion.isOpen) {
            downImage.image = [UIImage getPNGImageHTMIWFC:@"btn_angle_down_circle"];
        } else {
            downImage.image = [UIImage getPNGImageHTMIWFC:@"btn_angle_up_circle"];
        }
        
        [cell.contentView addSubview:downImage];
    }
}

#pragma mark ------ 私有方法
- (CGFloat)inputNoEditHeightByFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem nameString:(NSString *)nameString valueString:(NSString *)valueString width:(CGFloat)width {
    CGFloat height = 0;
    
    if (fieldItem.nameVisible) {
        height = [self labelSizeWithMaxWidth:width content:[NSString stringWithFormat:@"%@%@",nameString,valueString] FontOfSize:self.formLabelFont].height+stringTopHeight*2;
    } else {
        height = [self labelSizeWithMaxWidth:width content:valueString FontOfSize:self.formLabelFont].height+stringTopHeight*2;
    }
    
    return height;
}

- (void)inputNoEditFieldItem:(HTMIWFCOAMatterFormFieldItem *)fieldItem nameString:(NSString *)nameString valueString:(NSString *)valueString width:(CGFloat)width cellHeight:(CGFloat)cellHeight superView:(UIView *)superView {
    if (fieldItem.nameVisible) {
        UILabel *allLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, width, cellHeight) text:[NSString stringWithFormat:@"%@%@",nameString,valueString] alingment:fieldItem.align textColor:fieldItem.nameFontColor];
        [superView addSubview:allLabel];
    } else {
        UILabel *allLabel = [self creatLabelWithFrame:CGRectMake(stringLeftWidth, 0, width, cellHeight) text:valueString alingment:fieldItem.align textColor:fieldItem.valueFontColor];
        [superView addSubview:allLabel];
    }
}

/**
 *  边框
 */
- (UIView *)creatBorderViewFrame:(CGRect)frame {
    UIView *borderView = [[UIView alloc] initWithFrame:frame];
    borderView.userInteractionEnabled = YES;
    borderView.layer.borderWidth = 1.0;
    borderView.layer.borderColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0].CGColor;
    borderView.layer.masksToBounds = YES;
    borderView.layer.cornerRadius = 2.0;
    
    return borderView;
}

- (BOOL)isMustInput:(BOOL)mustinput value:(NSString *)value {
    BOOL isMustinput = NO;
    
    if (mustinput && value.length<1) {
        isMustinput = YES;
    }
    
    return isMustinput;
}

/**
 *  签名中姓名Label点击聊天
 *
 *  @param tap UITapGestureRecognizer
 */
- (void)inputTypeTenClick:(UITapGestureRecognizer *)tap{
    /*
#ifdef WorkFlowControl_Enable_MX
    NSArray *autoArray = [self.autographNameArray[tap.view.tag] componentsSeparatedByString:@"("];
    
    NSString *userID;
    
    NSArray *resultArray = [[HTMIABCDBHelper sharedYMDBHelperTool] searchUsersBySearchString:[autoArray firstObject] inDepartment:@""];
    for (HTMIABCSYS_UserModel *object in resultArray) {
        userID = object.UserId;
        
        break;
    }
    
    if (userID.length > 0) {
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userdefault objectForKey:@"kOA_userIDString"];
        if ([userID isEqualToString:userid]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无法与自己聊天" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else{
            NSArray *userArr = @[userID];
//            [[MXChat sharedInstance]chat:userArr withViewController:self withFailCallback:^(id object, MXError *error) {
//                NSLog(@"%@",error.description);
//            }];
        }
    }
#endif
     */
}

#pragma mark ------ value 或 id 转化为 name
- (NSString *)changValueOrIdToName:(NSString *)valueId dicArrarr:(NSArray *)dicArrarr {
    NSArray *array = [valueId componentsSeparatedByString:@";"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    NSString *nameString = nil;
    
    for (int i = 0; i < dicArrarr.count; i++) {
        NSDictionary *dic = dicArrarr[i];
        
        NSString *name = [dic objectForKey:@"name"];
        NSString *idString = [dic objectForKey:@"id"];
        NSString *valueString = [dic objectForKey:@"value"];
        
        for (int j = 0; j < array.count; j++) {
            NSString *string = array[j];
            if ([string isEqualToString:idString] || [string isEqualToString:valueString] || [string isEqualToString:name]) {
                [mutableArray addObject:name];
            }
        }
    }
    nameString = [mutableArray componentsJoinedByString:@";"];
    
    return nameString;
}

/**
 *  意见中姓名点击进入聊天事件
 *
 *  @param nameTap UITapGestureRecognizer
 */
- (void)nameTapClick:(UITapGestureRecognizer *)nameTap{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userdefault objectForKey:@"kOA_userIDString"];
    
    if ([self.opinionIdArray[nameTap.view.tag] isEqualToString:userid]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无法与自己聊天" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        NSArray *userArr = @[self.opinionIdArray[nameTap.view.tag]];
        
#ifdef WorkFlowControl_Enable_MX
//        [[MXChat sharedInstance]chat:userArr withViewController:self withFailCallback:^(id object, MXError *error) {
//            [HTMIWFCSVProgressHUD showErrorWithStatus:error.description duration:2.0];
//        }];
#endif
    }
}

/**
 *  删除选择项弹出视图的
 */
- (void)removeChoiceView {
    
    UIView *view = [self.view viewWithTag:888];
    [view removeFromSuperview];
    
    for (HTMIWFCDropDownListBox *listbox in self.listBoxArray) {
        
        listbox.dropDownClick = NO;
    }
}

#pragma mark  ------ 不可编辑时的namelabel  or  valuelabel
- (UILabel *)creatLabelWithFrame:(CGRect)frame text:(NSString *)text alingment:(NSString *)alignment textColor:(NSInteger)textColor {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = [self alignmentWithString:alignment];
    label.font = [UIFont systemFontOfSize:self.formLabelFont];
    label.numberOfLines = 0;
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [self colorWithHexARGBString:[NSString stringWithFormat:@"%x",textColor]];
    
    return label;
}

#pragma mark  ------ 对齐方式
- (NSTextAlignment)alignmentWithString:(NSString *)alignStr {
    if ([alignStr isEqualToString:@"Right"]) {
        return NSTextAlignmentRight;
    }
    else if ([alignStr isEqualToString:@"Left"]) {
        return NSTextAlignmentLeft;
    }
    else if ([alignStr isEqualToString:@"Center"]) {
        return NSTextAlignmentCenter;
    }
    else {
        return NSTextAlignmentLeft;
    }
}

#pragma mark  ------ 计算label大小
- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize{
    if (content.length < 1) {
        return CGSizeMake(0, 0);
    }
    
    if (HTMIIOS_VERSION > 7.2) {
        NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
        //UILabel根据内容自适应大小
        //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
        return [content boundingRectWithSize:CGSizeMake(width, 0)
                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                  attributes:dic
                                     context:nil].size;
    }
    else {
        CGSize size;
        
        NSAttributedString* atrString = [[NSAttributedString alloc] initWithString:content];
        
        NSRange range = NSMakeRange(0, atrString.length);
        
        NSDictionary* dic = [atrString attributesAtIndex:0 effectiveRange:&range];
        
        size = [content boundingRectWithSize:CGSizeMake(width, 0)  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
        
        return  size;
    }
    
    return CGSizeMake(0, 0);
}

#pragma mark  ------ 画线
- (void)drawLineInView:(UIView *)view tableView:(UITableView *)tableView indexpath:(NSIndexPath *)indexPath {
    UIImageView *leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, formLineWidth, [self mytableView:tableView heightForRowAtIndexPath:indexPath])];
    leftLine.backgroundColor = formLineColor;
    [view addSubview:leftLine];
    
    UIImageView *rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-formLineWidth, 0, formLineWidth, [self mytableView:tableView heightForRowAtIndexPath:indexPath])];
    rightLine.backgroundColor = formLineColor;
    [view addSubview:rightLine];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, formLineWidth)];
    lineImage.backgroundColor = formLineColor;
    [view addSubview:lineImage];
    
    //最下边的线
    if (indexPath.row == self.infoRegionArray.count-1) {
        UIImageView *lastLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, [self mytableView:tableView heightForRowAtIndexPath:indexPath]-formLineWidth, kScreenWidth, formLineWidth)];
        lastLine.backgroundColor = formLineColor;
        [view addSubview:lastLine];
    }
}

#pragma mark  ------ 十六进制字符串变为 color   R G B A
- (UIColor *)colorWithHexARGBString:(NSString *)color {
    if ([color isEqualToString:@"0"]) {
        return [UIColor blackColor];
    }
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 8) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 8)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //a
    NSString *aString = [cString substringWithRange:range];
    
    //r
    range.location = 2;
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 4;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 6;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:((float) a / 255.0f)];
}

//键盘相关
- (void)txtViewDelegateBeginEdit:(UITextField *)textField{
    
    //    UIView *view = textField.superview;
    //
    //    while (![view isKindOfClass:[UITableViewCell class]]) {
    //
    //        view = [view superview];
    //
    //    }
    //
    //    UITableViewCell *cell = (UITableViewCell*)view;
    
    
    //    CGRect rect = [cell convertRect:cell.frame toView:self.view];
    //
    //    if (rect.origin.y / 2 + rect.size.height >= kScreenHeight - 282) {
    //
    //        self.matterFormTableView.contentInset = UIEdgeInsetsMake(0, 0, 282, 0);
    //
    //        [self.matterFormTableView scrollToRowAtIndexPath:[self.matterFormTableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    //
    //    }
    
    
    //    NSIndexPath * indexPath =[self.matterFormTableView indexPathForCell:cell];
    //
    //    [self.matterFormTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)notification
{
    //    if (YES) {//是不是第一行
    //
    //        //获取键盘高度，在不同设备上，以及中英文下是不同的
    //        CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    //
    //        //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    //        CGFloat offset = (kbHeight + 40);
    //
    //        // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    //        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //
    //        //将视图上移计算好的偏移
    //        if(offset > 0) {
    //            [UIView animateWithDuration:duration animations:^{
    //                self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    //            }];
    //        }
    //    }
    //    else{
    //        // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    //        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //
    //        [UIView animateWithDuration:duration animations:^{
    //            self.view.frame = CGRectMake(0.0f, -40, self.view.frame.size.width, self.view.frame.size.height);
    //        }];
    //    }
}

//键盘消失时的处理，文本输入框回到页面底部。
- (void)keyboardWillHide:(NSNotification *)notification {
    
    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end
