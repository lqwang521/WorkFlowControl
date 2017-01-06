//
//  HTMIWFCOAManageFollowViewController.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/26.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAManageFollowViewController.h"
//#import "HTMIWFCFMDatabase.h"
#import "HTMIWFCSVProgressHUD.h"
//#import "HTMIWFCFMDatabaseAdditions.h"
//#import "HTMIABCDBHelper.h"
//#import "HTMIABCSYS_UserModel.h"

#import "UIViewController+HTMIWFCSetTitleFont.h"

#import "UIImage+HTMIWFCWM.h"

//定义应用屏幕宽高
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height


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



@interface HTMIWFCOAManageFollowViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISearchDisplayController *searchDisplay;
@property(nonatomic,strong)NSMutableArray *nameResultArray;//tableview显示用title
@property(nonatomic,strong)NSMutableArray *idResultArray;
@property(nonatomic,strong)NSMutableArray *searchResultArray;//搜索后tableview数据源
@property(nonatomic,strong)NSMutableArray *searchResultID;
@property(nonatomic,strong)NSMutableArray *selectedID;
@property(nonatomic,strong)NSMutableArray *formerSelectFllow;//原tableview 选择的人员
@property(nonatomic,strong)NSString *freeSelectedEmployee;//自由选择的人员

@end

@implementation HTMIWFCOAManageFollowViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    //数据源及可变数组的初始化
    self.nameResultArray = [[NSMutableArray alloc] init];
    self.idResultArray = [[NSMutableArray alloc] init];
    self.searchResultArray = [[NSMutableArray alloc]init];
    self.searchResultID = [[NSMutableArray alloc] init];
    self.selectedID = [[NSMutableArray alloc] init];
    
    //已有的人员
    for (NSDictionary *dic in self.resultList)
    {
        NSString *nameString = [dic objectForKey:@"routeName"];
        NSString *idString = [dic objectForKey:@"routeID"];
        [self.nameResultArray addObject:nameString];
        [self.idResultArray addObject:idString];
    }
    
    //左上按钮  取消
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftItem setTitle:@"取消"];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    
    //右上按钮  确定
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(myDo)];
    [rightItem setTitle:@"确定"];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    
    //wlq update 2016/05/11 适配风格
    [self customNavigationController:NO title:@""];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    //[self.tableView reloadData];
    HTLog(@"自由选择:%hhd",self.IsFreeSelectUser);
    if (self.IsFreeSelectUser)
    {
        //是否自由选择
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
        self.tableView.tableHeaderView = self.searchBar;
        //去掉键盘首字母大写
        self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //是否多选
        if (self.IsMultiSelectResult) {
            self.searchBar.placeholder = @"多选,首字母/拼音/姓名,空格隔开";
        }
        else {
            self.searchBar.placeholder = @"首字母/拼音/姓名";
        }
        
        self.searchDisplay = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
        self.searchBar.delegate = self;
        self.searchDisplay.delegate = self;
        self.searchDisplay.searchResultsDelegate = self;
        self.searchDisplay.searchResultsDataSource = self;
        self.searchDisplay.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView协议

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger number;
    //判断当前TableView是否是searchDisplayController的查找结果表格还是数据源本来的表格
    //或if([tableViewisEqual:self.searchController.searchResultsTableView])
    if (tableView != self.tableView)
    {
        number = self.searchResultArray.count;
    }
    else
    {
        number = self.nameResultArray.count;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    self.title = self.resultInfo;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if (tableView != self.tableView)
    {
        //搜索cell显示
        NSString *newTitle = self.searchResultArray[indexPath.row];
        cell.textLabel.text = newTitle;
        
        cell.tag = indexPath.row;//[self.numberOfClick[indexPath.row] intValue];
        if ((self.formerSelectFllow) && ([self.formerSelectFllow indexOfObject:@(cell.tag)] != NSNotFound)
            ? YES : NO)
        {
            cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else
        {
            //cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
    }
    else
    {
        //原cell显示
        if (self.resultList.count > 0)
        {
            cell.textLabel.text = self.nameResultArray[indexPath.row];
        }
        
        cell.tag = indexPath.row;//[self.numberOfClick[indexPath.row] intValue];
        if ((self.formerSelectFllow) && ([self.formerSelectFllow indexOfObject:@(cell.tag)] != NSNotFound)
            ? YES : NO)
        {
            cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
        }
        else
        {
            //cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
        }
    }
    
    self.tableView.separatorColor = [UIColor colorWithRed:70/255.0 green:186/255.0 blue:66/255.0 alpha:1.0];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView != self.tableView)
    {
        //搜索cell
        if (self.IsMultiSelectResult)
        {
            //多选
            if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
                [self.formerSelectFllow removeObject:@(cell.tag)];
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
                if (!self.formerSelectFllow)
                {
                    self.formerSelectFllow = [[NSMutableArray alloc]init];
                }
                [self.formerSelectFllow addObject:@(cell.tag)];
            }
        }
        else {
            if (cell.accessoryType != UITableViewCellAccessoryCheckmark)
            {
                [self.formerSelectFllow removeAllObjects];
                
                if (!self.formerSelectFllow)
                {
                    self.formerSelectFllow = [[NSMutableArray alloc]init];
                }
                [self.formerSelectFllow addObject:@(cell.tag)];
                [self.searchDisplay.searchResultsTableView reloadData];
            }
        }
    }
    else
    {
        if (self.IsMultiSelectResult)
        {
            //多选
            if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOff_phone"];
                [self.formerSelectFllow removeObject:@(cell.tag)];
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage getPNGImageHTMIWFC:@"mx_singleSelectOn_phone"];
                if (!self.formerSelectFllow)
                {
                    self.formerSelectFllow = [[NSMutableArray alloc]init];
                }
                [self.formerSelectFllow addObject:@(cell.tag)];
            }
        }
        else
        {
            //单选
            if (cell.accessoryType != UITableViewCellAccessoryCheckmark)
            {
                [self.formerSelectFllow removeAllObjects];
                
                if (!self.formerSelectFllow)
                {
                    self.formerSelectFllow = [[NSMutableArray alloc]init];
                }
                [self.formerSelectFllow addObject:@(cell.tag)];
                [self.tableView reloadData];
            }
        }
    }
    
}


#pragma mark - 事件

- (void)back{
    [self.formerSelectFllow removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)myDo{
    
    //新逻辑，添加attribute3（财务）  attribute5（合同）字段
    if (self.formerSelectFllow.count > 0)
    {
        for (NSNumber *index in self.formerSelectFllow)
        {
            HTLog(@"1.%@\n2.%@",self.idResultArray[[index integerValue]],self.nameResultArray[[index integerValue]]);
        }
        [HTMIWFCSVProgressHUD show];
        
        NSMutableArray *selectedArray = [[NSMutableArray alloc] init];
        
        NSArray *array = @[[self.hasSelectedRoute objectForKey:@"RouteID"]];
        //人员   返回人员 routeID 可能多个
        for (NSNumber *index in self.formerSelectFllow)
        {
            //[selectedArray addObject:self.idResultArray[[index integerValue]]];
            NSString *myID = self.nameResultArray[[index integerValue]];
            HTLog(@"%@",myID);
            
            //            NSArray *resultArray = [[HTMIABCDBHelper sharedYMDBHelperTool] searchUsersBySearchString:myID inDepartment:@""];
            //            for (HTMIABCSYS_UserModel *object in resultArray) {
            //                NSString *IDs = object.ThirdUserId;// [rs stringForColumn:@"thridThirdUserId"];
            //                HTLog(@"%@,%@",myID,IDs);
            //                [selectedArray addObject:IDs];
            //            }
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate followDidSelected:selectedArray hasSelectedRoute:array];
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:self.title delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UISearchDisplayDelegate  负责响应search事件

//searchBar “取消” 改为 “确定”
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self.searchBar setShowsCancelButton:YES];
    for (UIView *subView in [[self.searchBar.subviews lastObject] subviews])
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *)subView;
            [button setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    if (self.formerSelectFllow.count > 0)
    {
        [HTMIWFCSVProgressHUD show];
        
        NSMutableArray *selectedArray = [[NSMutableArray alloc] init];
        NSArray *array = self.hasSelectedRoute.count>0? @[[self.hasSelectedRoute objectForKey:@"RouteID"]]: @[];
        //人员   返回人员 routeID 可能多个
        for (NSNumber *index in self.formerSelectFllow)
        {
            [selectedArray addObject:self.searchResultID[[index integerValue]]];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate followDidSelected:selectedArray hasSelectedRoute:array];
        }];
    }
    else
    {
        
    }
    [self.searchResultArray removeAllObjects];
    [self.searchResultID removeAllObjects];
    [self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    /*
    //每次输入一个字符都会调用一次
    [self.searchResultArray removeAllObjects];
    [self.searchResultID removeAllObjects];
    [self.formerSelectFllow removeAllObjects];
    
    NSArray *searchArray = [searchString componentsSeparatedByString:@" "];
    HTLog(@"%@",searchArray);
    
    //路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"personinfo.sqlite"];
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    [db open];
    if ([db open])
    {
        for (int i = 0; i < searchArray.count; i++) {
            
            
            NSMutableArray *nameSearchResults = [NSMutableArray array];
            NSMutableArray *idSearchResults = [NSMutableArray array];
            
            NSArray *resultArray = [[HTMIABCDBHelper sharedYMDBHelperTool] searchUsersBySearchString:searchString inDepartment:@""];
            
            for (HTMIABCSYS_UserModel *object in resultArray) {
                
                [nameSearchResults addObject:object.FullName];
                [idSearchResults addObject:object.UserId];
            }
            
            [self.searchResultArray addObjectsFromArray:nameSearchResults];
            [self.searchResultID addObjectsFromArray:idSearchResults];
        }
        
        [db close];
    }
    */
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
}

@end
