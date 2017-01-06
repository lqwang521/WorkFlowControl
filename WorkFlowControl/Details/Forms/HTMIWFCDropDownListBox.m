//
//  HTDropDownListBox.m
//  自定义下拉选择
//
//  Created by 赵志国 on 16/6/16.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import "HTMIWFCDropDownListBox.h"

#import "HTMIWFCDropDownTableViewCell.h"
#import "UIImage+HTMIWFCWM.h"
#define boxSidesPlace kW6(5)//label字体距两边的距离

/**
 *  灰色
 */
#define borderCorlor [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]

/**
 *  蓝色
 */
#define borderSelectCorlor [UIColor colorWithRed:41/255.0 green:123/255.0 blue:251/255.0 alpha:1.0]

/**
 *  必填时添加的背景色
 */
#define mustInputColor [UIColor colorWithRed:254/255.0 green:250/255.0 blue:235/255.0 alpha:1.0]//黄


#define ownWidth  self.bounds.size.width
#define ownHeight self.bounds.size.height

/** 十六进制字符串转颜色 */
#define kColorWithString(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//等比布局使用
#define kW(R)  ((R)*(kScreenWidth)/320)
#define kH(R)  ((R)*(kScreenHeight)/568)

//表单部分zzg    处理方法：5\6一样，6p为他们的1.1倍
#define kW6(R) (IS_IPHONE_6P ? R*1.1 : R)
#define kH6(R) (IS_IPHONE_6P ? R*1.1 : R)

#define formLineWidth kW6(1.5)
#define formLineColor [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]
#define sidesPlace kW6(5)//label字体距两边的距离


#ifdef DEBUG

#define HTLog(...) NSLog(__VA_ARGS__)

#define HTLogDetail(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define HTLog(...)

#define HTLogDetail(fmt, ...)

#endif

#define ISFormType 1

// 2.获得RGB颜色
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)

//取view的坐标及长宽
#define W(view)    view.frame.size.width
#define H(view)    view.frame.size.height
#define X(view)    view.frame.origin.x
#define Y(view)    view.frame.origin.y



@interface HTMIWFCDropDownListBox ()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIView *totalView;

/**
   弹出的tableView
 */
@property (nonatomic, strong) UITableView *popTableView;

/**
   textField自定义边框
 */
@property (nonatomic, strong) UIView *textBorderView;



@end

@implementation HTMIWFCDropDownListBox


#pragma mark ------- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame view:(UIView *)view blockType:(blockType)type isMustinput:(BOOL)isMustinput{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isMustInput = isMustinput;
        
        self.blockType = type;
        
        [self setTotalView:self.totalView];
        
        self.listBoxPlaceView = view;
        self.dropDownClick = NO;
    }
    
    return self;
}

#pragma mark ------ 背景,懒加载
- (UIView *)totalView {
    if (!_totalView) {
        _totalView = [[UIView alloc] initWithFrame:CGRectMake(boxSidesPlace, boxSidesPlace, ownWidth-boxSidesPlace*2, ownHeight-boxSidesPlace*2)];
        if (self.blockType != BlockTextField) {
            _totalView.layer.borderWidth = 1.0;
            _totalView.layer.borderColor = borderCorlor.CGColor;
            _totalView.layer.masksToBounds = YES;
            _totalView.layer.cornerRadius = 2.0;
            if (self.isMustInput) {
                _totalView.backgroundColor = mustInputColor;
            }
        } else {
            [self setTextBorderView:self.textBorderView];
        }
        
        UIImageView *dropDownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ownWidth-40, (ownHeight-boxSidesPlace*2)/2-20, 40, 40)];
        dropDownImageView.image = [UIImage getPNGImageHTMIWFC:@"btn_select_pulldown"];
        dropDownImageView.userInteractionEnabled = YES;
        [_totalView addSubview:dropDownImageView];
        
        [self addSubview:_totalView];
        
        //添加手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropDownClick:)];
        tapGesture.delegate = self;
        [dropDownImageView addGestureRecognizer:tapGesture];
    }
    
    return _totalView;
}

- (UILabel *)selectedLabel {
    if (!_selectedLabel) {
        _selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kW6(7), 0, W(self.totalView)-kW6(7)*2-20, H(self.totalView))];
        _selectedLabel.font = [UIFont systemFontOfSize:self.formLabelFont];
        [self.totalView addSubview:_selectedLabel];
    }
    
    return _selectedLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(kW(7), 0, W(self.totalView)-30-kW(7), H(self.totalView))];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:self.formLabelFont];
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];

        [self.totalView addSubview:_textField];
    }
    
    return _textField;
}

- (UIView *)textBorderView {
    if (!_textBorderView) {
        _textBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W(self.totalView)-30, H(self.totalView))];
        _textBorderView.layer.borderWidth = 1.0;
        _textBorderView.layer.borderColor = borderCorlor.CGColor;
        _textBorderView.layer.cornerRadius = 2;
        if (self.isMustInput) {
            _textBorderView.backgroundColor = mustInputColor;
        }
        
        [self.totalView addSubview:_textBorderView];
    }
    
    return _textBorderView;
}

//点击弹出或收回
- (void)dropDownClick:(UITapGestureRecognizer *)tap {

    self.blockSelf(self);
    
    if (self.dropDownClick) {
        [self.popTableView removeFromSuperview];
        
        if (self.blockType == BlockTextField) {
            self.textBorderView.layer.borderColor = borderCorlor.CGColor;
        } else {
            self.totalView.layer.borderColor = borderCorlor.CGColor;
        }
        
    } else {
        //把self.tolbar 在self 上的point 转化为在self.listBoxPlaceView 上的
        CGPoint point = [self convertPoint:self.frame.origin toView:self.listBoxPlaceView];
        
        CGFloat popViewHeight = self.userNameArray.count>4 ? kH6(40)*4 : kH6(40)*self.userNameArray.count;
        CGFloat popViewWidth = 0;
        
        if (self.blockType == BlockTextField) {
            self.textBorderView.layer.borderColor = borderSelectCorlor.CGColor;
            popViewWidth = W(self.totalView)-30;
            
        } else {
            self.totalView.layer.borderColor = borderSelectCorlor.CGColor;
            popViewWidth = W(self.totalView);
        }
        
        if (kScreenHeight - 64 - 44 - point.y - ownHeight >= popViewHeight) {
            self.popTableView = [[UITableView alloc] initWithFrame:CGRectMake(point.x+kW6(5), point.y+ownHeight-kW6(5), popViewWidth, 0)];
            
            [self addAnimation:CGRectMake(point.x+kW6(5), point.y+ownHeight-kW6(5), popViewWidth, popViewHeight)];
        }
        else {
            self.popTableView = [[UITableView alloc] initWithFrame:CGRectMake(point.x+kW6(5), point.y+kW6(5), popViewWidth, 0)];
            
            [self addAnimation:CGRectMake(point.x+kW6(5), point.y+kW6(5)-popViewHeight, popViewWidth, popViewHeight)];
        }
        self.popTableView.delegate = self;
        self.popTableView.dataSource = self;
        self.popTableView.tag = 888;
        self.popTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.popTableView.layer.borderWidth = 0.5;
        self.popTableView.layer.borderColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0].CGColor;
        //tableView上要把弹出试图添加到最上层，要不不能点击
        [self.listBoxPlaceView addSubview:self.popTableView];
        
    }
    
    self.dropDownClick = !self.dropDownClick;
}


//popViewAnimation
- (void)addAnimation:(CGRect)rect {
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.popTableView.frame = rect;
    [UIView commitAnimations];
}


#pragma mark ----- UITableViewDelegate && UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *popCell = @"popCell";
    HTMIWFCDropDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:popCell];
    if (!cell) {
        cell = [[HTMIWFCDropDownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:popCell labelString:self.userNameArray[indexPath.row] labelFont:self.formLabelFont width:ownWidth];
    }
    else{
        cell.label.text = self.userNameArray[indexPath.row];
    }
    
    for (id any in cell.contentView.subviews) {
        if ([any isKindOfClass:[UIImageView class]]) {
            [any removeFromSuperview];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height-0.5, cell.bounds.size.width, 0.5)];
    lineImageView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [cell.contentView addSubview:lineImageView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.blockType == BlockTextField) {
        self.textField.text = self.userNameArray[indexPath.row];
    } else {
        self.selectedLabel.text = self.userNameArray[indexPath.row];
    }
    
    if (self.blockType == BlockID) {
        self.listBoxBlock(self.idArray[indexPath.row]);
        
    } else if (self.blockType == BlockUserName) {
        self.listBoxBlock(self.userNameArray[indexPath.row]);
        
    } else if (self.blockType == BlockValue) {
        self.listBoxBlock(self.valueArray[indexPath.row]);
        
    } else if (self.blockType == BlockTextField) {
        self.listBoxBlock(self.userNameArray[indexPath.row]);
        
    }
    
    if (self.blockType == BlockTextField) {
        self.textBorderView.layer.borderColor = borderCorlor.CGColor;
    } else {
        self.totalView.layer.borderColor = borderCorlor.CGColor;
    }
    
    [self.popTableView removeFromSuperview];
    
    self.dropDownClick = !self.dropDownClick;
    
    self.totalView.backgroundColor = [UIColor whiteColor];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kH6(40);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textBorderView.layer.borderColor = borderSelectCorlor.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.textBorderView.layer.borderColor = borderCorlor.CGColor;
    self.listBoxBlock(self.textField.text);
}

- (void)textFieldValueChanged:(UITextField *)textField {
    if (self.isMustInput && textField.text.length<=0) {
        self.textBorderView.backgroundColor = mustInputColor;
    } else {
        self.textBorderView.backgroundColor = [UIColor whiteColor];
    }
}
//超出父控件后一样可以相应处理事件
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if (view == nil) {
//        CGPoint tempoint = [self.textView convertPoint:point fromView:self];
//        if (CGRectContainsPoint(self.textView.bounds, tempoint))
//        {
//            view = self.textView;
//       	}
//    }
//    return view;
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
