//
//  HTMIWFCOAMatterFormFieldItem.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/2.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterFormFieldItem.h"

@implementation HTMIWFCOAMatterFormFieldItem



+(HTMIWFCOAMatterFormFieldItem *)parserMatterFormFieldForInfoByDic:(NSDictionary *)dic
{
    HTMIWFCOAMatterFormFieldItem *matterFormField = [[HTMIWFCOAMatterFormFieldItem alloc]init];
    
    
    matterFormField.name = [dic objectForKey:@"Name"];
    matterFormField.beforeName = [dic objectForKey:@"BeforeNameString"];
    matterFormField.endName = [dic objectForKey:@"EndNameString"];
    matterFormField.nameVisible = [[dic objectForKey:@"NameVisible"] boolValue];
    matterFormField.nameColor = [dic objectForKey:@"NameColor"];
    matterFormField.splitString = [dic objectForKey:@"SplitString"];
    matterFormField.nameRN = [[dic objectForKey:@"NameRN"] boolValue];
    matterFormField.value = [dic objectForKey:@"Value"];
    matterFormField.beforeValue = [dic objectForKey:@"BeforeValueString"];
    matterFormField.endValue = [dic objectForKey:@"EndValueString"];
    matterFormField.valueColor = [dic objectForKey:@"ValueColor"];
    matterFormField.percent = [[dic objectForKey:@"Percent"] integerValue];
    matterFormField.displayOrder = [[dic objectForKey:@"DisplayOrder"] integerValue];
    matterFormField.align = [dic objectForKey:@"Align"];
    matterFormField.key = [dic objectForKey:@"Key"];
    matterFormField.fieldType = [dic objectForKey:@"FieldType"];
    matterFormField.fieldNameForDB = [dic objectForKey:@"FiledName"];
    matterFormField.mode = [dic objectForKey:@"Mode"];
    matterFormField.sign = [[dic objectForKey:@"Sign"] boolValue];
    //wlq 暂时修改
    matterFormField.inputType = [[dic objectForKey:@"Input"] isKindOfClass:[NSNull class]] ? @"":[dic objectForKey:@"Input"];
    matterFormField.mustInput = [[dic objectForKey:@"MustInput"] boolValue];
    matterFormField.backColor = [[dic objectForKey:@"BackColor"] integerValue];
    matterFormField.nameBackColor = [[dic objectForKey:@"NameBackColor"] integerValue];
    matterFormField.nameFontColor = [[dic objectForKey:@"NameFontColor"] integerValue];
    matterFormField.valueBackColor = [[dic objectForKey:@"ValueBackColor"] integerValue];
    matterFormField.valueFontColor = [[dic objectForKey:@"ValueFontColor"] integerValue];
    matterFormField.opintions = [dic objectForKey:@"opintions"];
    
    matterFormField.dicts = [dic objectForKey:@"Dics"];
    
    matterFormField.BackColor = [[dic objectForKey:@"BackColor"]integerValue];
    matterFormField.nameBackColor = [[dic objectForKey:@"NameBackColor"]integerValue];
    matterFormField.nameFontColor = [[dic objectForKey:@"NameFontColor"]integerValue];
    matterFormField.valueBackColor = [[dic objectForKey:@"ValueBackColor"]integerValue];
    matterFormField.valueFontColor = [[dic objectForKey:@"ValueFontColor"]integerValue];
    matterFormField.formkey = [dic objectForKey:@"FormKey"];

    matterFormField.maxLength = [[dic objectForKey:@"MaxLength"]integerValue];//wlq add 2016/09/12 字段限制的最大长度

    return matterFormField;
    
}

@end
