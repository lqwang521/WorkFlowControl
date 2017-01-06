//
//  HTMIWFCSelectView.m
//  单选多选
//
//  Created by 赵志国 on 16/6/16.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import "HTMIWFCSelectView.h"

#import "HTMIWFCSelectTableViewCell.h"

#import "UIImage+HTMIWFCWM.h"

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



@interface HTMIWFCSelectView ()<UITableViewDataSource,UITableViewDelegate>

/**
 *  多选时存放选中数据
 */
@property (nonatomic, strong) NSMutableArray *selectedArray;

/**
 *  单选时选中行
 */
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UITableView *boxTableView;

/**
 *  array
 */
@property (nonatomic, strong) NSArray *dicsArray;

/**
 *  是否必填
 */
@property (nonatomic, assign) BOOL isMustInput;

/**
 *  已经选了的
 */
@property (nonatomic, copy) NSString *valueString;

@end

@implementation HTMIWFCSelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame dicsArray:(NSArray *)dicsArray selectType:(selectType)selectType isMustInput:(BOOL)isMustInput value:(NSString *)valueString {
    self = [super initWithFrame:frame];
    if (self) {
        self.boxTableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.boxTableView.delegate = self;
        self.boxTableView.dataSource = self;
        self.boxTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.boxTableView.scrollEnabled = NO;
        [self addSubview:self.boxTableView];
        
        self.selectedIndex = -1;
        
        self.selectType = selectType;
        self.dicsArray = dicsArray;
        
        for (int i = 0; i < self.dicsArray.count; i++) {
            NSDictionary *dic = self.dicsArray[i];
            
            [self.idArray addObject:[dic objectForKey:@"id"]];
            [self.nameArray addObject:[dic objectForKey:@"name"]];
            [self.valueArray addObject:[dic objectForKey:@"value"]];
        }
        
        self.isMustInput = isMustInput;
        self.valueString = valueString;
    }
    
    return self;
}

#pragma mark UITableViewDelegate && UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCell = @"selectBoxCell";
    HTMIWFCSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (!cell) {
        cell = [[HTMIWFCSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell cellWidth:self.frame.size.width];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.isMustInput && self.valueString.length<1) {
        cell.backgroundColor = [UIColor colorWithRed:254/255.0 green:250/255.0 blue:235/255.0 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (self.selectType == SingleSelectionID ||
        self.selectType == SingleSelectionName ||
        self.selectType == SingleSelectionValue) {
        //单选
        if (indexPath.row == self.selectedIndex ||
            [self.valueString isEqualToString:self.nameArray[indexPath.row]]) {
            [cell.cellImageView setImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_selected"]];
            
        } else {
            [cell.cellImageView setImage:[UIImage getPNGImageHTMIWFC:@"btn_radio_normal"]];
        }
        
    } else if (self.selectType == MultiSelectionID ||
               self.selectType == MultiSelectionName ||
               self.selectType == MultiSelectionValue) {
            NSArray *selectArray = [self.valueString componentsSeparatedByString:@";"];
            
            
            if ([selectArray containsObject:self.nameArray[indexPath.row]]) {
                cell.cellImageView.image = [UIImage getPNGImageHTMIWFC:@"btn_check_selected"];
                
                if (self.selectType == MultiSelectionID) {
                    [self.selectedArray addObject:self.idArray[indexPath.row]];
                } else if (self.selectType == MultiSelectionName) {
                    [self.selectedArray addObject:self.nameArray[indexPath.row]];
                } else if (self.selectType == MultiSelectionValue) {
                    [self.selectedArray addObject:self.valueArray[indexPath.row]];
                }
                
            } else {
                cell.cellImageView.image = [UIImage getPNGImageHTMIWFC:@"btn_check_normal"];
            }
    }

    cell.cellLabel.text = self.nameArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.selectType == SingleSelectionName) {//单选返回name
        self.selectedIndex = indexPath.row;
        self.SingleSelectionBlock(self.nameArray[indexPath.row]);
        
    } else if (self.selectType == SingleSelectionID) {//单选返回id
        self.selectedIndex = indexPath.row;
        self.SingleSelectionBlock(self.idArray[indexPath.row]);
        
    } else if (self.selectType == SingleSelectionValue) {//单选返回value
        self.selectedIndex = indexPath.row;
        self.SingleSelectionBlock(self.valueArray[indexPath.row]);
        
    } else if (self.selectType == MultiSelectionName) {//多选返回name
        NSArray *selectArray = [self.valueString componentsSeparatedByString:@";"];
        
        
        if ([selectArray containsObject:self.nameArray[indexPath.row]]) {
            [self.selectedArray removeObject:self.nameArray[indexPath.row]];
        } else {
            [self.selectedArray addObject:self.nameArray[indexPath.row]];
        }
        
        self.MultiSelectionBlock(self.selectedArray);
        
    } else if (self.selectType == MultiSelectionID) {//多选返回id
        NSArray *selectArray = [self.valueString componentsSeparatedByString:@";"];
        
        
        if ([selectArray containsObject:self.nameArray[indexPath.row]]) {
            [self.selectedArray removeObject:self.idArray[indexPath.row]];
        } else {
            [self.selectedArray addObject:self.idArray[indexPath.row]];
        }
        
        self.MultiSelectionBlock(self.selectedArray);
        
    } else if (self.selectType == MultiSelectionValue) {//多选返回value
        NSArray *selectArray = [self.valueString componentsSeparatedByString:@";"];
        
        
        if ([selectArray containsObject:self.nameArray[indexPath.row]]) {
            [self.selectedArray removeObject:self.valueArray[indexPath.row]];
        } else {
            [self.selectedArray addObject:self.valueArray[indexPath.row]];
        }
        
        self.MultiSelectionBlock(self.selectedArray);
        
    }
    
//    [tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kH6(40);
}

#pragma mark ------ 懒加载
- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    
    return _selectedArray;
}

- (NSMutableArray *)idArray {
    if (!_idArray) {
        _idArray = [NSMutableArray array];
    }
    
    return _idArray;
}

- (NSMutableArray *)nameArray {
    if (!_nameArray) {
        _nameArray = [NSMutableArray array];
    }
    
    return _nameArray;
}

- (NSMutableArray *)valueArray {
    if (!_valueArray) {
        _valueArray = [NSMutableArray array];
    }
    
    return _valueArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
