//
//  HTMIWFCMIBodyView.h
//  MXClient
//
//  Created by chong on 16/7/28.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTMIWFCMIBodyViewDelegate <NSObject>

-(void)reloadRequestView;

@end

@interface HTMIWFCMIBodyView : UIView
//{
//    UIImageView *myImgView;
//    UITextView *myTextView;
//}
@property (nonatomic, weak)id<HTMIWFCMIBodyViewDelegate> delegate;

@property (nonatomic, strong)UIImageView *myImgView;
@property (nonatomic, strong)UILabel *myLabelString;
@property (nonatomic, strong)UITextView *myTextView;

@end
