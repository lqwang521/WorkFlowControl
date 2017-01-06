//
//  HTMWFCIBottomActionView.h
//  MXClient
//
//  Created by chong on 16/7/21.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTMWFCIBottomActionViewDelegate <NSObject>

-(void)myCountandIdentfier:(int)count andmyActionName:(NSArray *)myActionNameArray;

@end

@interface HTMWFCIBottomActionView : UIView
-(void)bottomActionView:(NSArray *)operationDataArray;

@property (nonatomic, weak)id<HTMWFCIBottomActionViewDelegate> delegate;

@end
