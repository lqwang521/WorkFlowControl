//
//  HTMIWFCDownloadView.m
//  断电下载 demo
//
//  Created by 赵志国 on 16/6/24.
//  Copyright (c) 2016年 htmitech.com. All rights reserved.
//

#import "HTMIWFCDownloadView.h"

#import "HTMIWFCDownloadTableViewCell.h"

//#import "HTMIWFCFMDB.h"

#import "HTMIWFCZipArchive.h"
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


@interface HTMIWFCDownloadView ()<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate>
/**
 *  tableView
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 *  下载URL
 */
@property (nonatomic, strong) NSArray *urlArray;

/**
 *  下载文件名
 */
@property (nonatomic, strong) NSArray *fileNameArray;

/**
 *  下载文件大小
 */
@property (nonatomic, strong) NSArray *fileLengthArray;

/**
 *  type,确定图片
 */
@property (nonatomic, strong) NSArray *typeArray;

/**
 *  NSURLConnection
 */
@property (nonatomic, strong) NSMutableDictionary *connectDic;

/**
 *  输出流
 */
@property (nonatomic, strong) NSMutableDictionary *streamDic;

@property (nonatomic, strong) NSDictionary *attachDic;

@property (nonatomic, strong) NSMutableDictionary *progressDic;
@property (nonatomic, strong) NSMutableDictionary *downloadBtnDic;


@end

@implementation HTMIWFCDownloadView

- (instancetype)initWithFrame:(CGRect)frame url:(NSDictionary *)url fileName:(NSArray *)fileName fileLength:(NSArray *)fileLength type:(NSArray *)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
//        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.tableView];
        self.attachDic = url;
        
//        self.urlArray = url;
        self.fileNameArray = fileName;
        self.fileLengthArray = fileLength;
        self.typeArray = type;
        
    }
    
    return self;
}

#pragma mark ------ UITableViewDatasource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCell = @"downloadCell";
    HTMIWFCDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (!cell) {
        cell = [[HTMIWFCDownloadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell ];
    }
    for (id any in cell.contentView.subviews) {
        [any removeFromSuperview];
    }
    
    [cell creatCellByType:self.typeArray[indexPath.row] fileName:self.nameArray[indexPath.row] fileLength:self.fileLengthArray[indexPath.row] cellIndex:indexPath.row];
    
    [self.progressDic setObject:cell.progressView forKey:self.keyArray[indexPath.row]];
    [self.downloadBtnDic setObject:cell.downloadBtn forKey:self.keyArray[indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //先判断是否需要下载
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fullPath = [path stringByAppendingPathComponent:self.fileNameArray[indexPath.row]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:fullPath]) {//不存在
        [cell.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [cell.downloadBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_accessory_download"] forState:UIControlStateNormal];
        cell.progressView.alpha = 0.0;
        
        [cell refreshLengthLabel:[self changeFileLength:self.fileLengthArray[indexPath.row]]];
        
    } else {
        
        if ([self fileSizeAtPath:fullPath] < [[self.attachDic objectForKey:self.keyArray[indexPath.row]][0] integerValue]) {
            //存在，但还没下完
            long long currentSize = [self fileSizeAtPath:fullPath];
            NSInteger allSize = [[self.attachDic objectForKey:self.keyArray[indexPath.row]][0] integerValue];
            
            for (id view in cell.contentView.subviews) {
                
                if ([view isKindOfClass:[UIProgressView class]]) {
                    UIProgressView *progress = view;
                    progress.progress = (float)currentSize/allSize;
                }
                
            }
            
            [cell.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
            [cell.downloadBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_accessory_time_start"] forState:UIControlStateNormal];
            
            [cell refreshLengthLabel:[NSString stringWithFormat:@"%@-%.0f%%",[self changeFileLength:self.fileLengthArray[indexPath.row]],(float)currentSize/allSize*100]];
            
        } else {
            [cell.downloadBtn setTitle:@"打开" forState:UIControlStateNormal];
            [cell.downloadBtn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_accessory_look"] forState:UIControlStateNormal];
            cell.progressView.alpha = 0.0;
            
            [cell refreshLengthLabel:[NSString stringWithFormat:@"%@-%@",[self changeFileLength:self.fileLengthArray[indexPath.row]],@"已下载"]];
        }
    }
    
    typeof(self) __weakSelf = self;
    typeof(cell) __weakCell = cell;
    
    cell.downloadBtnBlock = ^(UIButton *btn) {
      
        if ([btn.titleLabel.text isEqualToString:@"下载"]) {
            __weakCell.progressView.alpha = 1.0;
            [__weakSelf download:btn];
            [btn setTitle:@"暂停" forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_accessory_time_out"] forState:UIControlStateNormal];
            
        } else if ([btn.titleLabel.text isEqualToString:@"暂停"]) {
            
            [btn setTitle:@"下载" forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_accessory_time_start"] forState:UIControlStateNormal];
            
            NSURLConnection *connect = [__weakSelf.connectDic objectForKey:self.fileNameArray[btn.tag]];
            [connect cancel];
            
        } else if ([btn.titleLabel.text isEqualToString:@"打开"]) {
            NSString *checkPath = [path stringByAppendingPathComponent:__weakSelf.nameArray[indexPath.row]];
            
            
            __weakSelf.pathStringBlock(checkPath);
        }
        
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat nameheight = [self labelSizeWithMaxWidth:kScreenWidth-kW6(117) content:self.nameArray[indexPath.row] FontOfSize:15.0].height+kH6(12);
    CGFloat cellHeight = MAX(nameheight+kH6(20)+kH6(16), kH6(65));
    
    return cellHeight;
}

#pragma mark ------ 下载
- (void)download:(UIButton *)btn {
    
    NSString *urlString = ((NSArray *)self.attachDic[self.keyArray[btn.tag]])[1];
    NSURL *url = [NSURL URLWithString:urlString];
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [caches stringByAppendingPathComponent:self.fileNameArray[btn.tag]];
    
    long long currentInteger = [self fileSizeAtPath:fullPath];
    NSString *range = [NSString stringWithFormat:@"bytes= %zd-",currentInteger];
    [request setValue:range forHTTPHeaderField:@"range"];
    
    //发送异步请求
    NSURLConnection *connect = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [self.connectDic setObject:connect forKey:self.fileNameArray[btn.tag]];
    
    //创建输出流
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:fullPath append:YES];
    
    [self.streamDic setObject:stream forKey:self.fileNameArray[btn.tag]];
    
    //打开数据流
    [stream open];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *string = connection.currentRequest.URL.absoluteString;
    NSArray *array = [string componentsSeparatedByString:@"/"];
    
    
    for (int i = 0; i < self.fileNameArray.count; i++) {
        NSString *name = self.fileNameArray[i];
        if ([name isEqualToString:[array lastObject]]) {
            
            NSOutputStream *stream = [self.streamDic objectForKey:name];
            [stream write:data.bytes maxLength:data.length];
            
            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *fullPath = [caches stringByAppendingPathComponent:self.fileNameArray[i]];
            long long size = [self fileSizeAtPath:fullPath];
            
            UIProgressView *progress = [self.progressDic objectForKey:self.keyArray[i]];
            progress.progress = (float)size/[[self.attachDic objectForKey:self.keyArray[i]][0] integerValue];
            
            HTMIWFCDownloadTableViewCell *cell = [self getCellByProgressView:progress];
            [cell refreshLengthLabel:[NSString stringWithFormat:@"%@-%.0f%%",[self changeFileLength:self.fileLengthArray[i]],(float)size/[[self.attachDic objectForKey:self.keyArray[i]][0] integerValue]*100]];
            
            break;
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *string = connection.currentRequest.URL.absoluteString;
    NSArray *array = [string componentsSeparatedByString:@"/"];
    
    for (int i = 0; i < self.fileNameArray.count; i++) {
        NSString *name = self.fileNameArray[i];
        if ([name isEqualToString:[array lastObject]]) {
            
            NSOutputStream *stream = [self.streamDic objectForKey:name];
            //关闭输出流
            [stream close];
            stream = nil;
            UIButton *btn = [self.downloadBtnDic objectForKey:self.keyArray[i]];
            [btn setTitle:@"打开" forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage getPNGImageHTMIWFC:@"btn_accessory_look"] forState:UIControlStateNormal];
            
            UIProgressView *progress = [self.progressDic objectForKey:self.keyArray[i]];
            progress.alpha = 0.0;
            
            HTMIWFCDownloadTableViewCell *cell = [self getCellByProgressView:progress];
            [cell refreshLengthLabel:[NSString stringWithFormat:@"%@-%@",[self changeFileLength:self.fileLengthArray[i]],@"已下载"]];
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *newZipLocalPath = [path stringByAppendingPathComponent:name];
            HTMIWFCZipArchive *zip = [[HTMIWFCZipArchive alloc]init];
            //根据文件位置解压该文件
            if ([zip UnzipOpenFile:newZipLocalPath Password:@"password"])
            {
                //解压到哪里
                if ([zip UnzipFileTo:path overWrite:YES])
                {
//                    NSString *localFilePath = [[self.programDirectory stringByAppendingString:@"/"] stringByAppendingString:attachEntity.attachTitle];
                }
                [zip UnzipCloseFile];
            }
            else
            {
                NSLog(@"解压失败");
                NSFileManager *manager = [NSFileManager defaultManager];
                [manager removeItemAtPath:newZipLocalPath error:nil];
            }
        }
    }
}

//计算字符串长度
- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize {
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}


- (HTMIWFCDownloadTableViewCell *)getCellByProgressView:(UIProgressView *)view {
    HTMIWFCDownloadTableViewCell *cell = nil;
    
    if ([[view superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[view superview];
    }
    else if ([[[view superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[[view superview] superview];
    }
    else if ([[[[view superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[[[view superview] superview] superview];
    }
    else if ([[[[[view superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[[[[view superview] superview] superview] superview];
    }
    else if ([[[[[[view superview] superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[[[[[view superview] superview] superview] superview] superview];
    }
    else if ([[[[[[[view superview] superview] superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[[[[[[view superview] superview] superview] superview] superview] superview];
    }
    else if ([[[[[[[[view superview] superview] superview] superview] superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        cell = (HTMIWFCDownloadTableViewCell *)[[[[[[[view superview] superview] superview] superview] superview] superview] superview];
    }
    
    return cell;
}

- (NSString *)changeFileLength:(NSString *)length {
    NSString *newLength = nil;
    
    //文件大小   以M或KB显示
    float M = 1024*1024;
    float kb = 1024;
    if ([length floatValue]/M >= 1) {
        //M
        newLength = [NSString stringWithFormat:@"%.2fM",[length floatValue]/M];
    }
    else if ([length floatValue]/kb >= 1) {
        //kb
        newLength = [NSString stringWithFormat:@"%.2fkb",[length floatValue]/kb];
    }
    else {
        //b
        newLength = [NSString stringWithFormat:@"%@b",length];
    }
    
    return newLength;
}

/**
 *  获取文件大小
 *
 *  @param filePath 路径
 *
 *  @return 大小
 */
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

#pragma mark ------ 懒加载
- (NSMutableDictionary *)connectDic {
    if (!_connectDic) {
        _connectDic = [NSMutableDictionary dictionary];
    }
    
    return _connectDic;
}

- (NSMutableDictionary *)streamDic {
    if (!_streamDic) {
        _streamDic = [NSMutableDictionary dictionary];
    }
    
    return _streamDic;
}

- (NSMutableDictionary *)progressDic {
    if (!_progressDic) {
        _progressDic = [NSMutableDictionary dictionary];
    }
    
    return _progressDic;
}

- (NSMutableDictionary *)downloadBtnDic {
    if (!_downloadBtnDic) {
        _downloadBtnDic = [NSMutableDictionary dictionary];
    }
    
    return _downloadBtnDic;
}

- (void)downloadViewReloadData {
    [self.tableView reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
