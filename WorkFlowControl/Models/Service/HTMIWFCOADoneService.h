//
//  HTMIWFCOADoneService.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/9.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>



#import <HTMIWFCOADoneEntity.h>

@interface HTMIWFCOADoneService : NSObject

+ (HTMIWFCOADoneEntity *)parserMyDoneBydictionary:(NSDictionary *)dic;

@end
