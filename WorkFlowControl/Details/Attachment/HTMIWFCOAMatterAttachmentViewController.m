//
//  HTMIWFCOAMatterAttachmentViewController.m
//  MXClient
//
//  Created by 赵志国 on 16/6/27.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterAttachmentViewController.h"

#import "HTMIWFCOAAttachEntity.h"

#import "HTMIWFCOAAttachmentEntity.h"

#import "HTMIWFCOAAttachmentListEntity.h"

#import "HTMIWFCDownloadView.h"

#import "HTMIWFCOAMatterAttachPreviewViewController.h"

#import "HTMIWFCApi.h"

//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface HTMIWFCOAMatterAttachmentViewController ()

/**
 *  下载链接
 */
@property (nonatomic, strong) NSMutableArray *urlArray;

/**
 *  附件zip压缩包名
 */
@property (nonatomic, strong) NSMutableArray *fileNameArray;

/**
 *  附件zip压缩文件大小
 */
@property (nonatomic, strong) NSMutableArray *zipFileSize;

/**
 *  附件类型
 */
@property (nonatomic, strong) NSMutableArray *fileTypeArray;

/**
 *  附件名
 */
@property (nonatomic, strong) NSMutableArray *nameArray;

/**
 *  附件大小
 */
@property (nonatomic, strong) NSMutableArray *fileSizeArray;

/**
 *  字典的key，用ID不会重复
 */
@property (nonatomic, strong) NSMutableArray *keyArray;

/**
 *  附件相关
 */
@property (nonatomic, strong) NSMutableDictionary *attachmentDic;


@end

@implementation HTMIWFCOAMatterAttachmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    for (int i = 0; i < self.attachArray.count; i++) {
        HTMIWFCOAAttachEntity *attach = self.attachArray[i];
        
        //下载主要用到的是压缩文件名
        [self.fileNameArray addObject:[NSString stringWithFormat:@"%@.zip",attach.attachID]];
        [self.fileTypeArray addObject:attach.attachType];
        [self.nameArray addObject:attach.attachTitle];
        [self.keyArray addObject:[NSString stringWithFormat:@"%@.zip",attach.attachID]];
        [self.fileSizeArray addObject:[NSString stringWithFormat:@"%d",attach.attachSize]];
        
        
        
        
        [HTMIWFCApi downloadFileWithAttachID:attach.attachID andAttachName:attach.attachTitle andContext:context andKind:self.kind succeed:^(id data) {
            
            HTMIWFCOAAttachmentEntity *attachment = data;
            HTMIWFCOAAttachmentListEntity *attachList = attachment.attachList;
            
//            [self.urlArray addObject:attachList.downloadURL];
            
            //http://172.31.1.41:8081/cloudapi/Files/HZ9f81a4551f1f0e01552db6a6da4fec.zip
            NSArray *urlsArr = [attachList.downloadURL componentsSeparatedByString:@"/"];
            NSString *string = [urlsArr lastObject];
            if (string.length > 0) {
                [self.attachmentDic setObject:@[[NSString stringWithFormat:@"%d",attachList.byteLength],attachList.downloadURL] forKey:string];
            }
            
            
            if (i == self.attachArray.count-1) {
                HTMIWFCDownloadView *downloadView = [[HTMIWFCDownloadView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, self.view.bounds.size.height-20) url:self.attachmentDic fileName:self.fileNameArray fileLength:self.fileSizeArray type:self.fileTypeArray];
                downloadView.nameArray = self.nameArray;
                downloadView.keyArray = self.keyArray;
                [self.view addSubview:downloadView];
                
                [downloadView downloadViewReloadData];
                
                downloadView.pathStringBlock = ^(NSString *pathString) {
                    
                    HTMIWFCOAMatterAttachPreviewViewController *mapvc = [[HTMIWFCOAMatterAttachPreviewViewController alloc] init];
                    mapvc.filePath = pathString;
                    
                    [self.navigationController pushViewController:mapvc animated:YES];
                    
                };
            }
            
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    
    
    // Do any additional setup after loading the view.
}

#pragma  mark ------ 懒加载
- (NSMutableDictionary *)attachmentDic {
    if (!_attachmentDic) {
        _attachmentDic = [NSMutableDictionary dictionary];
    }
    
    return _attachmentDic;
}

- (NSMutableArray *)zipFileSize {
    if (!_zipFileSize) {
        _zipFileSize = [NSMutableArray array];
    }
    
    return _zipFileSize;
}

- (NSMutableArray *)urlArray {
    if (!_urlArray) {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}

- (NSMutableArray *)fileNameArray {
    if (!_fileNameArray) {
        _fileNameArray = [NSMutableArray array];
    }
    return _fileNameArray;
}

- (NSMutableArray *)fileSizeArray {
    if (!_fileSizeArray) {
        _fileSizeArray = [NSMutableArray array];
    }
    return _fileSizeArray;
}

- (NSMutableArray *)fileTypeArray {
    if (!_fileTypeArray) {
        _fileTypeArray = [NSMutableArray array];
    }
    return _fileTypeArray;
}

- (NSMutableArray *)nameArray {
    if (!_nameArray) {
        _nameArray = [NSMutableArray array];
    }
    return _nameArray;
}

- (NSMutableArray *)keyArray {
    if (!_keyArray) {
        _keyArray = [NSMutableArray array];
    }
    return _keyArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
