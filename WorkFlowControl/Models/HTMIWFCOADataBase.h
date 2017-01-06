//
//  HTMIWFCOADataBase.h
//  MXClient
//
//  Created by HTRF on 15/6/24.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMIWFCOADataBase : NSObject

@property (nonatomic, copy)NSString *DocNodeID;
@property (nonatomic, copy)NSString *ParentDocNodeID;
@property (nonatomic, copy)NSString *NodeName;
@property (nonatomic, copy)NSString *NodeIconURL;
@property (nonatomic, copy)NSString *Remark;
@property (nonatomic, copy)NSString *NodeIconDownloadURL;

@end
