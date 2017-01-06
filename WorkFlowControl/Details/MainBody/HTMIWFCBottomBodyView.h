//
//  HTMIWFCBottomBodyView.h
//  MXClient
//
//  Created by chong on 16/7/28.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCProgressGradientView.h"
#import "UIImageView+HTMIWFCRotateImgV.h"

@protocol HTMIWFCBottomBodyViewDelegate <NSObject>

-(void)myBottomBodyorbutton:(NSString *)nameString;
-(void)myBottomBodyorSharebutton:(NSString *)nameString;

@end
@interface HTMIWFCBottomBodyView : UIView

@property (nonatomic, strong)UIImageView *myImg1;
@property (nonatomic, strong)UIImageView *myImg2;
@property (nonatomic, strong)UILabel *mylabel1;
@property (nonatomic, strong)UILabel *mylabel2;
@property (nonatomic, strong)UIButton *myBtn1;
@property (nonatomic, strong)UIButton *myBtn2;

@property (nonatomic, strong)id<HTMIWFCBottomBodyViewDelegate> delegate;
@property (nonatomic, strong)HTMIWFCProgressGradientView *progressGradientView;

-(void)startAnimation;
-(void)endAnimation;
@end
