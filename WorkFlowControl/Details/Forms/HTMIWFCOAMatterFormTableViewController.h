//
//  HTMIWFCOAMatterFormTableViewController.h
//  MXClient
//
//  Created by 赵志国 on 16/6/20.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTMIWFCOAInfoRegion.h"
#import "HTMIWFCOAMatterFormFieldItem.h"

#import "HTMIWFCOAOperationProtocol.h"

//#import "HTMIWFCFMDB.h"
#ifdef WorkFlowControl_Enable_MX
//#import "MXChat.h"
//#import "MXCircle.h"
#endif

#import "HTMIWFCOAQuickOpinionViewController.h"

#import "HTMIWFCDropDownListBox.h"

#import "HTMIWFCSelectView.h"

#import "HTMIWFCOpinionAutographView.h"

#import "HTMIWFCTxtView.h"

#import "HTMIWFCPickerView.h"

@interface HTMIWFCOAMatterFormTableViewController : UIViewController<UITextViewDelegate,
UIGestureRecognizerDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
HTMIWFCOAQuickOpinionViewController>

@property (nonatomic, strong) HTMIWFCPickerView *datePicker;

/**
 *  所有滑动子表最大宽度
 */
@property (nonatomic, strong) NSDictionary *maxWidthDic;

/**
 *  每个滑动子表最大宽度
 */
@property (nonatomic, strong) NSArray *eachWidthArray;

@property (nonatomic, assign) NSInteger formLabelFont;

/**
 *  第几个滑动区域
 */
@property (nonatomic, assign) NSInteger scrollIndex;

/**
 *  第几个滑动区域
 */
@property (nonatomic, strong) NSMutableArray *scrollViewArray;

/**
 *  滑动区域偏移量
 */
@property (nonatomic, strong) NSMutableDictionary *contentOffSetDic;

/**
 *  滑动区第一行添加排序图标
 */
@property (nonatomic, strong) NSMutableArray *rankArray;

/**
 *  是否请假
 */
@property (nonatomic, copy) NSString *flowID;



@property (nonatomic, strong) NSDictionary *contextMatter;//判断是否分享

@property (nonatomic, assign) NSInteger segmentIndex;

@property (nonatomic, strong) NSMutableArray *infoRegionArray;
@property (nonatomic, strong) NSArray *detaileArray;//详情数据源

@property(nonatomic,weak)id <OAOperationDelegate> operationDelegate;

/**
 *  每行第几个
 */
@property(nonatomic) NSInteger currentEidtFieldItemIndex;

/**
 *  第几行
 */
@property(nonatomic) NSInteger currentEidtRegionIndex;

//wlq add
@property(nonatomic,strong)UITableViewCell *findFromViewTableViewCell;

/**
 *  自己用户名，判断是否是自己时用
 */
@property (nonatomic, copy) NSString *myUserName;//OA_UserName

/**
 *  点击聊天用
 */
@property (nonatomic, strong) NSMutableArray *opinionIdArray;
@property (nonatomic, strong) NSMutableArray *autographNameArray;
@property (nonatomic, assign) NSInteger opinionIdIndex;
@property (nonatomic, assign) NSInteger autographIndex;

/**
 *  下拉框 删除用
 */
@property (nonatomic, strong) NSMutableArray *listBoxArray;

@property (nonatomic, strong) UITableView *matterFormTableView;


- (UITableViewCell *)getCellBy:(id)view;
@end






