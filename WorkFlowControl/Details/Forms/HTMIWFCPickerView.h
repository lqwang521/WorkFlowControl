//
//  HTMIWFCPickerView.h
//  testPickerView
//
//  Created by chong on 16/7/8.
//  Copyright © 2016年 chong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTMIWFCPickerViewDelegate <NSObject>

-(void)myresignFirstResponder;

@end
@interface HTMIWFCPickerView : UIView

typedef void(^mySelectPickerBlock)(NSString *myPickerString);

typedef NS_ENUM(NSInteger, myDateENUM){
    myYear = 0,             //年
    myYearMonth,        //年月
    myYearMonthDay,     //年月日
    myAlldate,          //年月日时分
    myWeek,             //年周
};
//选择初始化时间的类型
-(instancetype)initWithFrame:(CGRect)frame myselecttype:(myDateENUM)pickerString andmyBackColor:(UIColor *)backColor andmyCellBackClolr:(UIColor *)cellBackColor;
//返回给主页面的选择时间
@property (nonatomic, strong)mySelectPickerBlock myPickerBlockString;
//枚举值
@property (nonatomic,assign)myDateENUM *mydateType;

@property (nonatomic, weak)id<HTMIWFCPickerViewDelegate> delegate;

@end
