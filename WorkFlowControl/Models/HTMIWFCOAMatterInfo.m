//
// HTMIWFCOAMatterInfo.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/5/29.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterInfo.h"

@implementation HTMIWFCOAMatterInfo

+ (HTMIWFCOAMatterInfo *)parserMyMatterInfoByResultDic:(NSDictionary *)dic
{
    HTMIWFCOAMatterInfo *mi = [[HTMIWFCOAMatterInfo alloc]init];
    
    mi.DocID = [dic objectForKey:@"DocID"];
    mi.DocTitle = [dic objectForKey:@"DocTitle"];
    mi.SendFrom = [dic objectForKey:@"SendFrom"];
    mi.SendDate = [dic objectForKey:@"SendDate"];
    mi.DocType = [dic objectForKey:@"DocType"];
    mi.iconId = [dic objectForKey:@"iconId"];
    mi.kind = [dic objectForKey:@"Kind"];
    
    return mi;
}

+ (HTMIWFCAttentEntity *)parserMyAttentionByResultDic:(NSDictionary *)dic {
    HTMIWFCAttentEntity *attention = [[HTMIWFCAttentEntity alloc] init];
    
    attention.idInteger = [[dic objectForKey:@"Id"] integerValue];
    attention.UserId = [dic objectForKey:@"UserId"];
    attention.DocID = [dic objectForKey:@"DocId"];
    attention.DocTitle = [dic objectForKey:@"DocTitle"];
    attention.SendFrom = [dic objectForKey:@"SendFrom"];
    attention.SendDate = [dic objectForKey:@"SendDate"];
    attention.DocType = [dic objectForKey:@"DocType"];
    attention.iconId = [dic objectForKey:@"iconId"];
    attention.kind = [dic objectForKey:@"Kind"];
    attention.attentionFlag = [dic objectForKey:@"AttentionFlag"];
    attention.allowPush = [dic objectForKey:@"AllowPush"];
    
    return attention;
}

@end
