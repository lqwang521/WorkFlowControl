//
//  HTMIWFCOpinionAutographView.h
//  HTMIWFCOpinionAutographView
//
//  Created by 赵志国 on 16/6/28.
//  Copyright © 2016年 htmitech.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTMIWFCOpinionAutographViewBlock)(NSString *string);



@interface HTMIWFCOpinionAutographView : UIView

typedef NS_ENUM(NSInteger, SelectType) {
    HorizontalType,//横版
    VerticalType,//竖版
};

@property (nonatomic, assign) SelectType selectType;

@property (nonatomic, copy) HTMIWFCOpinionAutographViewBlock buttonClickBlock;

- (instancetype)initWithFrame:(CGRect)frame selectType:(SelectType)selectType aOro:(NSString *)aOrO;

@end
