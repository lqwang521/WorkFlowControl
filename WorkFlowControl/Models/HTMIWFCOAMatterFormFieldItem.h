//
//  HTMIWFCOAMatterFormFieldItem.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/2.
//  Copyright (c) 2015年 MXClient. All rights reserved.


//表单

#import <Foundation/Foundation.h>

@interface HTMIWFCOAMatterFormFieldItem : NSObject

@property (copy, nonatomic) NSString *name;//表单“:”前的内容
@property (copy, nonatomic) NSString *beforeName;
@property (copy, nonatomic) NSString *endName;
@property (nonatomic) BOOL nameVisible;
@property (copy, nonatomic) NSString *nameColor;
@property (copy, nonatomic) NSString *splitString;//冒号
@property (nonatomic,assign) BOOL nameRN;

@property (nonatomic,copy) NSString *value;
@property (copy, nonatomic) NSString *eidtValue;
@property (copy, nonatomic) NSString *eidtMustColor;//必填背景色

@property (copy, nonatomic) NSString *beforeValue;
@property (copy, nonatomic) NSString *endValue;
@property (copy, nonatomic) NSString *valueColor;

@property (nonatomic,assign) NSInteger percent;
@property (nonatomic,assign) NSInteger displayOrder;
@property (copy, nonatomic) NSString *align;
@property(nonatomic,copy)NSString *key;
@property (copy, nonatomic) NSString *fieldType;
@property (copy, nonatomic) NSString *fieldNameForDB;
@property (copy, nonatomic) NSString *mode;
@property(nonatomic,strong)NSArray *opintions;
@property (nonatomic,assign) BOOL sign;

@property (copy, nonatomic) NSString *inputType;
@property (nonatomic,assign) NSInteger BackColor;
@property (nonatomic,assign) NSInteger nameBackColor;
@property (nonatomic,assign) NSInteger nameFontColor;
@property (nonatomic,assign) NSInteger valueBackColor;
@property (nonatomic,assign) NSInteger valueFontColor;
//为了解决，多tab页，每页内容上传的问题
@property(nonatomic,copy)NSString *formkey;
// 必填项
@property (nonatomic,assign) BOOL mustInput;

//单选还是多选 （当 inputType = 26 时）
@property (nonatomic,assign) BOOL isRadio;

//选项List
@property (strong, nonatomic) NSArray *dicts;

/**
 *  签名还是意见
 */
@property (nonatomic, copy) NSString *aOrO;

/**
 *  是否存在自定义控件
 */
@property (nonatomic, assign) BOOL isHaveTextField;

//wlq add 2016/09/12 字段限制的最大长度
@property (assign, nonatomic) NSInteger maxLength;

+(HTMIWFCOAMatterFormFieldItem *)parserMatterFormFieldForInfoByDic:(NSDictionary *)dic;

@end
