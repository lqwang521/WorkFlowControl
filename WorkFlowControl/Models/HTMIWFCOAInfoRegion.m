//
//  HTMIWFCOAInfoRegion.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/2.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAInfoRegion.h"

@implementation HTMIWFCOAInfoRegion

+ (NSMutableArray *)parserInforRegionBydic:(NSDictionary *)dic
{
    NSMutableArray *regionList = [[NSMutableArray alloc]init];
    
    NSArray *reginonItems = [dic objectForKey:@"RegionItems"];
    
    for (NSDictionary *itemDic in reginonItems)
    {
        HTMIWFCOAInfoRegion *infoRegin = [[HTMIWFCOAInfoRegion alloc]init];
        infoRegin.displayOrder = [[itemDic objectForKey:@"DisplayOrder"] integerValue];
        infoRegin.vlineVisible = [[itemDic objectForKey:@"VlineVisible"] boolValue];
        infoRegin.regionID = [itemDic objectForKey:@"RegionID"];
        infoRegin.backColor = [[itemDic objectForKey:@"BackColor"]integerValue];
        
        infoRegin.backColor = [[itemDic objectForKey:@"backColor"]integerValue];
        infoRegin.feildItemList = [itemDic objectForKey:@"FieldItems"];
        
        infoRegin.isTable = [[itemDic objectForKey:@"IsTable"] boolValue];
        infoRegin.parentTableID = [itemDic objectForKey:@"ParentTableID"];
        infoRegin.tableID = [itemDic objectForKey:@"TableID"];
        
        infoRegin.IsSplitRegion = [[itemDic objectForKey:@"IsSplitRegion"] boolValue];
        infoRegin.ParentRegionID = [itemDic objectForKey:@"ParentRegionID"];
        infoRegin.SplitAction = [[itemDic objectForKey:@"SplitAction"] integerValue];
        
        infoRegin.ScrollFlag = [[itemDic objectForKey:@"ScrollFlag"] integerValue];
        infoRegin.ScrollFixColCount = [[itemDic objectForKey:@"ScrollFixColCount"] integerValue];
        
        NSMutableArray *abc = [NSMutableArray array];
        for (NSDictionary *dic in infoRegin.feildItemList)
        {
            HTMIWFCOAMatterFormFieldItem *matter = [HTMIWFCOAMatterFormFieldItem parserMatterFormFieldForInfoByDic:dic];
            
            [abc addObject:matter];
        }
        
        infoRegin.feildItemList = abc;
        
        [regionList addObject:infoRegin];
    }
    return regionList;
}



@end
