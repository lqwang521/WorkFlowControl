//
//  HTMIWFCOADoneService.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/9.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOADoneService.h"

@implementation HTMIWFCOADoneService

+ (HTMIWFCOADoneEntity *)parserMyDoneBydictionary:(NSDictionary *)dic
{
    HTMIWFCOADoneEntity *done = [[HTMIWFCOADoneEntity alloc]init];
    
    done.DocID = [dic objectForKey:@"DocID"];
    done.DocTitle = [dic objectForKey:@"DocTitle"];
    done.SendFrom = [dic objectForKey:@"SendFrom"];
    done.SendDate = [dic objectForKey:@"SendDate"];
    done.DocType = [dic objectForKey:@"DocType"];
    done.iconId = [dic objectForKey:@"iconId"];
    done.kind = [dic objectForKey:@"Kind"];
    return done;
}

@end
