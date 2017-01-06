//
//  HTMIWFCOAMainBodyService.m
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/8.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMainBodyService.h"
#import "HTMIWFCOAOperationDataEntity.h"

#import "HTMIWFCApi.h"

#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
//等比布局使用
#define kW(R)  ((R)*(kScreenWidth)/320)
#define kH(R)  ((R)*(kScreenHeight)/568)
//屏幕尺寸
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))


@implementation HTMIWFCOAMainBodyService

- (void)mainBodyWithContext:(NSDictionary *)context MatterID:(NSString *)matterID isFlowid:(BOOL)isFlowid andDocType:(NSString *)docType andKind:(NSString *)kind block:(OAMainBodyBlock)block
{
    NSMutableArray *operationArray = [NSMutableArray array];
    NSMutableDictionary *moDic = [[NSMutableDictionary alloc]init];
    
    
    
    [HTMIWFCApi requestMainBodyWithContext:context isFlowid:isFlowid andMatterID:matterID andDocType:docType andKind:kind succeed:^(id data) {
        
        NSInteger status = [[data objectForKey:@"Status"] integerValue];
        if (!data) {
            return ;
        }
        if (status == 1) {
            NSDictionary *resultDic = [data objectForKey:@"Result"];
            
            if (![resultDic isEqual:[NSNull null]])
            {
                //正文数据
                NSString *DocAttachmentIDDic = [resultDic objectForKey:@"DocAttachmentID"];
                if (DocAttachmentIDDic.length > 1)
                {
                    HTMIWFCOAMainBodyEntity *mainBody = [[HTMIWFCOAMainBodyEntity alloc]init];
                    
                    mainBody.docAttachmentID = [resultDic objectForKey:@"DocAttachmentID"];
                    mainBody.flowName = [resultDic objectForKey:@"FlowName"];
                    
                    [moDic setObject:mainBody forKey:@"mainBody"];
                }
                
                //操作数据   cc如：提交，暂存，退回等。
                NSArray *operation = [resultDic objectForKey:@"listActionInfo"];
                NSString *string1;
                for (NSDictionary *dic in operation)
                {
                    string1 = [dic objectForKey:@"ActionName"];
                    
                    if (string1.length >1)
                    {
                        HTMIWFCOAOperationDataEntity *operationData = [[HTMIWFCOAOperationDataEntity alloc]init];
                        
                        operationData.actionID = [dic objectForKey:@"ActionID"];
                        operationData.actionName = [dic objectForKey:@"ActionName"];
                        
                        [operationArray addObject:operationData];
                        
                        [moDic setObject:operationArray forKey:@"operationData"];
                    }
                }
                
                //附加数据
                NSString *flowID = [resultDic objectForKey:@"FlowId"];
                NSString *flowName = [resultDic objectForKey:@"FlowName"];
                NSString *currentAuthorID = [resultDic objectForKey:@"CurrentAuthorId"];
                NSString *currentAuthor = [resultDic objectForKey:@"CurrentAuthor"];
                NSString *currentNodeID = [resultDic objectForKey:@"CurrentNodeID"];
                NSString *currentNodeName = [resultDic objectForKey:@"CurrentNodeName"];
                NSString *currentUserID = [resultDic objectForKey:@"CurrentUserId"];
                NSString *currentUserName = [resultDic objectForKey:@"CurrentUsername"];
                NSString *currentTrackID = [resultDic objectForKey:@"CurrentTrackId"];
                
                NSDictionary *appendDic = @{@"flowID":flowID ? flowID : @"",
                                            @"flowName":flowName ? flowName : @"",
                                            @"currentAuthorID":currentAuthorID ? currentAuthorID : @"",
                                            @"currentAuthor":currentAuthor ? currentAuthor : @"",
                                            @"currentNodeID":currentNodeID ? currentNodeID : @"",
                                            @"currentNodeName":currentNodeName ? currentNodeName : @"",
                                            @"currentUserID":currentUserID ? currentUserID : @"",
                                            @"currentUserName":currentUserName ? currentUserName : @"",
                                            @"currentTrackID":currentTrackID ? currentTrackID : @""};
                [moDic setObject:appendDic forKey:@"appendData"];
                
                //
                NSMutableArray *segmentArray = [NSMutableArray array];
                
                //详情
                NSMutableArray *tableItemlist = [NSMutableArray array];
                
                //子表
                NSMutableArray *childFormArray = [NSMutableArray array];
                
                self.allMaxWidthDic = [NSMutableDictionary dictionary];
                
                NSArray *reginonItems = [resultDic objectForKey:@"TabItems"];//几个表单
                for (int i = 0; i < reginonItems.count; i++) {
                    NSDictionary *tableDic = reginonItems[i];
                    HTMIWFCOATableItemsEntity *tableItems = [[HTMIWFCOATableItemsEntity alloc] init];
                    tableItems.tabID = [tableDic objectForKey:@"TabID"];
                    tableItems.tableName = [tableDic objectForKey:@"TabName"];
                    tableItems.flowID = [tableDic objectForKey:@"FlowID"];
                    tableItems.regionsArray = [tableDic objectForKey:@"Regions"];
                    tableItems.tableType = [[tableDic objectForKey:@"TabType"] integerValue];
                    
                    [segmentArray addObject:tableItems.tableName];
                    
                    if (tableItems.tableType == 1) {
                        NSMutableArray *regionList = [[NSMutableArray alloc]init];
                        NSMutableArray *childFormReginArray = [NSMutableArray array];
                        
                        for (int i = 0; i < tableItems.regionsArray.count; i++) {//详情
                            NSDictionary *itemDic = tableItems.regionsArray[i];
                            
                            HTMIWFCOAInfoRegion *infoRegin = [[HTMIWFCOAInfoRegion alloc]init];
                            infoRegin.displayOrder = [[itemDic objectForKey:@"DisplayOrder"] integerValue];
                            infoRegin.vlineVisible = [[itemDic objectForKey:@"VlineVisible"] boolValue];
                            infoRegin.regionID = [itemDic objectForKey:@"RegionID"];
                            infoRegin.backColor = [[itemDic objectForKey:@"BackColor"]integerValue];
                            infoRegin.isTable = [[itemDic objectForKey:@"IsTable"] boolValue];
                            infoRegin.parentTableID = [itemDic objectForKey:@"ParentTableID"];
                            infoRegin.feildItemList = [itemDic objectForKey:@"FieldItems"];
                            infoRegin.tableID = [itemDic objectForKey:@"TableID"];
                            infoRegin.IsSplitRegion = [[itemDic objectForKey:@"IsSplitRegion"] boolValue];
                            infoRegin.ParentRegionID = [itemDic objectForKey:@"ParentRegionID"];
                            infoRegin.SplitAction = [[itemDic objectForKey:@"SplitAction"] integerValue];
                            infoRegin.ScrollFlag = [[itemDic objectForKey:@"ScrollFlag"] integerValue];
                            infoRegin.ScrollFixColCount = [[itemDic objectForKey:@"ScrollFixColCount"] integerValue];
                            infoRegin.isOpen = NO;
                            
                            /**
                             *  开始滑动标记，每个滑动区域开始滑动式初始化
                             */
                            if (infoRegin.IsSplitRegion && infoRegin.ParentRegionID.length<1 && infoRegin.ScrollFlag == 1) {
                                self.eachMaxWidthArray = [NSMutableArray array];
                                self.index++;
                            }
                            
                            NSMutableArray *abc = [NSMutableArray array];
                            
                            for (int j = 0; j < infoRegin.feildItemList.count; j++) {
                                NSDictionary *dic = infoRegin.feildItemList[j];
                                HTMIWFCOAMatterFormFieldItem *matter = [HTMIWFCOAMatterFormFieldItem parserMatterFormFieldForInfoByDic:dic];
                                
                                [abc addObject:matter];
                                
                                CGFloat valueWidth = [self labelSizeWithMaxWidth:0 content:matter.value FontOfSize:IS_IPHONE_6P ? 17 : 15].width + kW(12)*2;
                                if (infoRegin.ScrollFlag == 1 && infoRegin.ParentRegionID.length>0) {
                                    if (self.eachMaxWidthArray.count < infoRegin.feildItemList.count) {
                                        [self.eachMaxWidthArray addObject:[NSString stringWithFormat:@"%f",valueWidth]];
                                        
                                    } else {
                                        
                                        if (valueWidth > [self.eachMaxWidthArray[j] floatValue]) {
                                            [self.eachMaxWidthArray replaceObjectAtIndex:j withObject:[NSString stringWithFormat:@"%f",valueWidth]];
                                        }
                                    }
                                }
                                
                            }
                            
                            if (self.eachMaxWidthArray.count>0) {
                                [self.allMaxWidthDic setObject:self.eachMaxWidthArray forKey:infoRegin.ParentRegionID];
                            }
                            
                            infoRegin.feildItemList = abc;
                            
                            /**
                             *  折叠子表
                             */
                            NSMutableDictionary *childForms = [NSMutableDictionary dictionary];
                            
                            if (infoRegin.IsSplitRegion && infoRegin.ParentRegionID.length<1) {
                                [childForms setObject:infoRegin.regionID forKey:infoRegin.ParentRegionID];
                                
                                [childFormArray addObject:childForms];
                            }
                            
                            if (infoRegin.ParentRegionID.length>0) {
                                [childForms setObject:infoRegin.regionID forKey:infoRegin.ParentRegionID];
                                
                                [childFormArray addObject:childForms];
                                
                                [childFormReginArray addObject:infoRegin];
                            }
                            
                            
                            [regionList addObject:infoRegin];
                            
                            /**
                             *  滑动子表：要获取宽度最大值、
                             */
                            if (infoRegin.IsSplitRegion && infoRegin.ParentRegionID.length<1 && infoRegin.ScrollFlag == 1) {
                                self.sliderArray = [NSMutableArray array];
                            }
                        }
                        
                        tableItems.regionsArray = regionList;//所有行
                        tableItems.childFormArray = childFormArray;//子表折叠行               默认打开
                        tableItems.childFormRegionArray = childFormReginArray;//子表折叠行    默认折叠
                        [tableItemlist addObject:tableItems];
                    }
                }
                
                //附件
                NSMutableArray *attachArr = [[NSMutableArray alloc]init];
                NSArray *attachArray = [resultDic objectForKey:@"listAttInfo"];
                
                for (NSDictionary *attachDic in attachArray)
                {
                    HTMIWFCOAAttachEntity *attach = [[HTMIWFCOAAttachEntity alloc]init];
                    
                    attach.attachID = [attachDic objectForKey:@"AttachmentID"];
                    attach.attachTitle = [attachDic objectForKey:@"AttachmentTitle"];
                    attach.attachType = [attachDic objectForKey:@"AttachmentType"];
                    attach.attachSize = [[attachDic objectForKey:@"AttachmentSize"] integerValue];;
                    attach.encrypt = [[attachDic objectForKey:@"Encrypt"] boolValue];
                    
                    [attachArr addObject:attach];
                }
                
                //其中modic为正文、操作、附加数据      regionList为表单详情数据    attacharr为附件数据
                NSArray *segments = segmentArray;
                block(moDic,tableItemlist,attachArr,segments,self.allMaxWidthDic,nil);
            }
        }
        else {
            NSDictionary *message = [data objectForKey:@"Message"];
            NSString *errorString = [message objectForKey:@"StatusMessage"];
            
            block(nil,nil,errorString,nil,nil,nil);
        }
        
    } failure:^(NSError *error) {
        
        block(nil,nil,nil,nil,nil,error);
    }];
}

- (void)myLeaveWithFlowID:(NSString *)flowID block:(OAMainBodyBlock)block
{
    NSMutableArray *operationArray = [NSMutableArray array];
    NSMutableDictionary *moDic = [[NSMutableDictionary alloc]init];
    
    
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *context = [userdefaults objectForKey:@"kContextDictionary"];
    
    [HTMIWFCApi requestMyLeaveWithContext:context andFlowID:flowID succeed:^(id data) {
        
        //详情
        NSMutableArray *tableItemlist = [NSMutableArray array];
        //子表
        NSMutableArray *childFormArray = [NSMutableArray array];
        
        
        //操作数据
        NSDictionary *resultDic = [data objectForKey:@"Result"];
        
        //wlq update 可能服务器端出现问题，请求过来的是nsnull,如果不处理程序会崩溃
        if (!resultDic || [resultDic isKindOfClass:[NSNull class]]) {
            block(moDic,tableItemlist,nil,nil,nil,nil);
            return;
        }
        
        NSString *docID = [resultDic objectForKey:@"DocID"];
        NSString *flowId = [resultDic objectForKey:@"FlowId"];
        NSString *currentNodeID = [resultDic objectForKey:@"CurrentNodeID"];
        NSString *currentTrackId = [resultDic objectForKey:@"CurrentTrackId"];
        NSString *flowName = [resultDic objectForKey:@"FlowName"];
        NSString *kind = [resultDic objectForKey:@"Kind"];
        
        [moDic setObject:docID forKey:@"kDocID"];
        [moDic setObject:flowId forKey:@"kFlowID"];
        [moDic setObject:currentNodeID forKey:@"kCurrentNodeID"];
        [moDic setObject:currentTrackId forKey:@"kCurrentTrackId"];
        [moDic setObject:flowName forKey:@"kFlowName"];
        [moDic setObject:kind forKey:@"kKind"];
        
        NSArray *operation = [resultDic objectForKey:@"listActionInfo"];
        NSString *string1;
        for (NSDictionary *dic in operation)
        {
            string1 = [dic objectForKey:@"ActionName"];
            
            if (string1.length >1)
            {
                HTMIWFCOAOperationDataEntity *operationData = [[HTMIWFCOAOperationDataEntity alloc]init];
                
                operationData.actionID = [dic objectForKey:@"ActionID"];
                operationData.actionName = [dic objectForKey:@"ActionName"];
                
                [operationArray addObject:operationData];
                
                [moDic setObject:operationArray forKey:@"operationData"];
            }
        }
        

        @try {
            NSArray *reginonItems = [resultDic objectForKey:@"TabItems"];
            for (int i = 0; i < reginonItems.count; i++) {
                NSDictionary *tableDic = reginonItems[i];
                HTMIWFCOATableItemsEntity *tableItems = [[HTMIWFCOATableItemsEntity alloc] init];
                tableItems.tabID = [tableDic objectForKey:@"TabID"];
                tableItems.tableName = [tableDic objectForKey:@"TabName"];
                tableItems.flowID = [tableDic objectForKey:@"FlowID"];
                tableItems.regionsArray = [tableDic objectForKey:@"Regions"];
                tableItems.tableType = [[tableDic objectForKey:@"TabType"] integerValue];
                
                if (tableItems.tableType == 1) {
                    NSMutableArray *regionList = [[NSMutableArray alloc]init];
                    
                    for (int i = 0; i < tableItems.regionsArray.count; i++) {
                        NSDictionary *itemDic = tableItems.regionsArray[i];
                        
                        HTMIWFCOAInfoRegion *infoRegin = [[HTMIWFCOAInfoRegion alloc]init];
                        infoRegin.displayOrder = [[itemDic objectForKey:@"DisplayOrder"] integerValue];
                        infoRegin.vlineVisible = [[itemDic objectForKey:@"VlineVisible"] boolValue];
                        infoRegin.regionID = [itemDic objectForKey:@"RegionID"];
                        infoRegin.backColor = [[itemDic objectForKey:@"BackColor"]integerValue];
                        infoRegin.isTable = [[itemDic objectForKey:@"IsTable"] boolValue];
                        infoRegin.parentTableID = [itemDic objectForKey:@"ParentTableID"];
                        infoRegin.feildItemList = [itemDic objectForKey:@"FieldItems"];
                        infoRegin.tableID = [itemDic objectForKey:@"TableID"];
                        infoRegin.IsSplitRegion = [[itemDic objectForKey:@"IsSplitRegion"] boolValue];
                        infoRegin.ParentRegionID = [itemDic objectForKey:@"ParentRegionID"];
                        infoRegin.isOpen = YES;
                        
                        NSMutableArray *abc = [NSMutableArray array];
                        for (NSDictionary *dic in infoRegin.feildItemList)
                        {
                            HTMIWFCOAMatterFormFieldItem *matter = [HTMIWFCOAMatterFormFieldItem parserMatterFormFieldForInfoByDic:dic];
                            
                            [abc addObject:matter];
                        }
                        
                        infoRegin.feildItemList = abc;
                        
                        NSMutableDictionary *childForms = [NSMutableDictionary dictionary];
                        
                        if (infoRegin.IsSplitRegion && infoRegin.ParentRegionID.length<1) {
                            [childForms setObject:infoRegin.regionID forKey:infoRegin.ParentRegionID];
                            
                            [childFormArray addObject:childForms];
                        }
                        
                        if (infoRegin.ParentRegionID.length>0) {
                            [childForms setObject:infoRegin.regionID forKey:infoRegin.ParentRegionID];
                            
                            [childFormArray addObject:childForms];
                        }
                        
                        
                        [regionList addObject:infoRegin];
                    }
                    
                    tableItems.regionsArray = regionList;
                    tableItems.childFormArray = childFormArray;
                    [tableItemlist addObject:tableItems];
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        block(moDic,tableItemlist,nil,nil,nil,nil);
        
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark  ------ 计算label大小
- (CGSize)labelSizeWithMaxWidth:(CGFloat)width content:(NSString *)content FontOfSize:(CGFloat)FontOfSize{
    if (content.length < 1) {
        return CGSizeMake(0, 0);
    }
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:FontOfSize]};
    //UILabel根据内容自适应大小
    //参数1:宽高限制   参数2:附加   参数3:计算时只用到font就OK     参数4:nil
    return [content boundingRectWithSize:CGSizeMake(width, 0)
                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                              attributes:dic
                                 context:nil].size;
}

@end
