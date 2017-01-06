//
//  YMDBHelper.m
//  Pedometer
//
//  Created by ymsc on 15/8/11.
//  Copyright (c) 2015年 ymsc. All rights reserved.
//

#import "HTMIABCDBHelper.h"

#import "HTMIABCDDFileReader.h"

#pragma mark --Model头文件

//部门模型
#import "HTMIABCSYS_DepartmentModel.h"

//人员模型
#import "HTMIABCSYS_UserModel.h"

//人员部门关系模型
#import "HTMIABCSYS_OrgUserModel.h"

//人员属性定义模型
#import "HTMIABCTD_UserModel.h"

//保密模型
#import "HTMIABCTD_UserFieldSecretModel.h"

//常用联系人模型
#import "HTMIABCT_UserRelationshipModel.h"

//#import "AppDelegate+PrivateMethod.h"
#import "HTMIABCAddressBookManager.h"

#import "HTMIWFCAFNManager.h"

#import "HTMIWFCZipArchive.h"

//#import "MBProgressHUD+Add.h"

#import "HTMIABCUserdefault.h"

//#import "MXConfig.h"

#import "NSString+HTMIWFCExtention.h"

#import "HTMIWFCApi.h"

#import "HTMIWFCSVProgressHUD.h"

//自己托管的服务器 8081
#define EMUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMMUrl"]
#define EMPORT [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCPORT"]
#define EMapiDir [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCEMapiDir"]
#define EMSoftWare [[NSUserDefaults standardUserDefaults] objectForKey:@"HTMIWFCSoftWare"]

#define MX_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_URL"]
#define MX_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_PORT"]
#define MX_MQTT_URL [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_URL"]
#define MX_MQTT_PORT [[NSUserDefaults standardUserDefaults] objectForKey:@"MX_MQTT_PORT"]

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



@implementation HTMIABCDBHelper

//部门表名
NSString * const HTMIABCTABLE_NAME_SYS_Department = @"SYS_Department";

//人员关系表名
NSString * const HTMIABCTABLE_NAME_SYS_OrgUser = @"SYS_OrgUser";

//人员表
NSString * const HTMIABCTABLE_NAME_SYS_User = @"SYS_User";

//用户常用联系人
NSString * const HTMIABCTABLE_NAME_T_UserRelationship = @"T_UserRelationship";

//人员属性定义表
NSString * const HTMIABCTABLE_NAME_TD_User = @"TD_User";

//定义某个保密字段哪些人能看
NSString * const HTMIABCTABLE_NAME_TD_UserFieldSecret = @"TD_UserFieldSecret";


#pragma mark --定义某个保密字段哪些人能看

NSString * const HTMIABCTD_UserFieldSecret_USERID = @"UserId";
NSString * const HTMIABCTD_UserFieldSecret_FIELDNAME = @"FieldName";


#pragma mark --人员属性定义字段

NSString * const HTMIABCTD_User_FIELDNAME = @"FieldName";
NSString * const HTMIABCTD_User_DISLABEL = @"DisLabel";
NSString * const HTMIABCTD_User_DISORDER = @"DisOrder";
NSString * const HTMIABCTD_User_ISACTIVE = @"IsActive";
NSString * const HTMIABCTD_User_ENABLEDEDIT = @"EnabledEdit";
NSString * const HTMIABCTD_User_SECRETFLAG = @"SecretFlag";
NSString * const HTMIABCTD_User_ACTION = @"Action";

#pragma mark --用户常用联系人表字段
NSString * const HTMIABCT_UserRelationshipCOLUMN_USERID = @"UserId";
NSString * const HTMIABCT_UserRelationshipCOLUMN_CUSERID = @"CUserId";


#pragma mark --部门表字段
// * 部门 字段 共27个
NSString * const HTMIABCDEPARTMENTCODE = @"DepartmentCode";
NSString * const HTMIABCSHORTNAME = @"ShortName";
NSString * const HTMIABCFULLNAME = @"FullName";
NSString * const HTMIABCORGANISETYPE = @"OrganiseType";
NSString * const HTMIABCPARENTDEPARTMENT = @"ParentDepartment";
NSString * const HTMIABCPOSTCODE = @"PostCode";
NSString * const HTMIABCTELEPHONE = @"Telephone";
NSString * const HTMIABCFAX = @"Fax";
NSString * const HTMIABCADDRESS = @"Address";
NSString * const HTMIABCREMARK = @"Remark";
NSString * const HTMIABCISDELETE = @"IsDelete";
NSString * const HTMIABCCREATEDBY = @"CreatedBy";
NSString * const HTMIABCCREATEDDATE = @"CreatedDate";
NSString * const HTMIABCMODIFIEDBY = @"ModifiedBy";
NSString * const HTMIABCMODIFIEDDATE = @"ModifiedDate";
NSString * const HTMIABCUNIVERSALPWD = @"UniversalPwd";
NSString * const HTMIABCPINYIN = @"Pinyin";
NSString * const HTMIABCOULABEL = @"OULabel";
NSString * const HTMIABCOULEVEL = @"OULevel";
NSString * const HTMIABCADCODE = @"ADCode";
NSString * const HTMIABCAPPCODE = @"AppCode";
NSString * const HTMIABCUNIVERSALCODE = @"UniversalCode";
NSString * const HTMIABCISVIRTUAL = @"IsVirtual";
NSString * const HTMIABCSYS_Department_IP = @"IP";
NSString * const HTMIABCPORT = @"Port";
NSString * const HTMIABCTHIRDDEPARTMENTID = @"ThirdDepartmentId";
NSString * const HTMIABCDISORDER = @"DisOrder";

//wlq add
NSString * const HTMIABCSYS_Department_PinYinQuanPin = @"PinYinQuanPin";

#pragma mark --人员关系表字段名称
NSString * const HTMIABCSYS_OrgUser_ID = @"ID";
NSString * const HTMIABCSYS_OrgUser_USERID = @"UserId";
NSString * const HTMIABCSYS_OrgUser_DEPARTMENTCODE = @"DepartmentCode";
NSString * const HTMIABCSYS_OrgUser_CREATEDBY = @"CreatedBy";
NSString * const HTMIABCSYS_OrgUser_CREATEDDATE = @"CreatedDate";
NSString * const HTMIABCSYS_OrgUser_DISORDER = @"DisOrder";

//带//表示更新个人信息的时候更新了
#pragma mark --人员表字段名称
NSString * const HTMIABCSYS_User_USERID = @"UserId";
NSString * const HTMIABCSYS_User_PASSWORD = @"Password";//
NSString * const HTMIABCSYS_User_PASSWORDKEY = @"PasswordKey";//
NSString * const HTMIABCSYS_User_PASSWORDIV = @"PasswordIV";//
NSString * const HTMIABCSYS_User_FULLNAME = @"FullName";//
NSString * const HTMIABCSYS_User_GENDER = @"Gender";//
NSString * const HTMIABCSYS_User_ISDN = @"ISDN";//
NSString * const HTMIABCSYS_User_EMAIL = @"Email";//
NSString * const HTMIABCSYS_User_STATUS = @"Status";//
NSString * const HTMIABCSYS_User_TELEPHONE = @"Telephone";//
NSString * const HTMIABCSYS_User_FAX = @"Fax";//
NSString * const HTMIABCSYS_User_OFFICE = @"Office";//
NSString * const HTMIABCSYS_User_SIGNPICS = @"SignPics";//
NSString * const HTMIABCSYS_User_PICS = @"Pics";//
NSString * const HTMIABCSYS_User_USERTYPE = @"UserType";//
NSString * const HTMIABCSYS_User_PASSWORDLASTCHANGED = @"PasswordLastChanged";//
NSString * const HTMIABCSYS_User_MOBILE = @"Mobile";//
NSString * const HTMIABCSYS_User_POSITION = @"Position";//
NSString * const HTMIABCSYS_User_PHOTOSURL = @"Photosurl";//
NSString * const HTMIABCSYS_User_REPASSWORDDATE = @"RePasswordDate";//
NSString * const HTMIABCSYS_User_REPASSWORDKEY = @"RePasswordKey";//
NSString * const HTMIABCSYS_User_MODIFIEDDATE = @"ModifiedDate";//

NSString * const HTMIABCSYS_User_CREATEDBY = @"CreatedBy";
NSString * const HTMIABCSYS_User_CREATEDDATE = @"CreatedDate";
NSString * const HTMIABCSYS_User_MODIFIEDBY = @"ModifiedBy";

NSString * const HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID = @"PhotosurlAttchmentGuid";//

NSString * const HTMIABCSYS_User_THIRDUSERID = @"ThirdUserId";//
NSString * const HTMIABCSYS_User_ATTRIBUTE1 = @"attribute1";//
NSString * const HTMIABCSYS_User_ATTRIBUTE2 = @"attribute2";//
NSString * const HTMIABCSYS_User_ATTRIBUTE3 = @"attribute3";//
NSString * const HTMIABCSYS_User_ATTRIBUTE4 = @"attribute4";//
NSString * const HTMIABCSYS_User_ATTRIBUTE5 = @"attribute5";//
NSString * const HTMIABCSYS_User_ISEMPUSER = @"IsEMPUser";
NSString * const HTMIABCSYS_User_ISEMIUSER = @"IsEMIUser";
NSString * const HTMIABCSYS_User_EXT1 = @"ext1";
NSString * const HTMIABCSYS_User_EXT2 = @"ext2";
NSString * const HTMIABCSYS_User_EXT3 = @"ext3";
NSString * const HTMIABCSYS_User_EXT4 = @"ext4";
NSString * const HTMIABCSYS_User_EXT5 = @"ext5";
NSString * const HTMIABCSYS_User_EXT6 = @"ext6";
NSString * const HTMIABCSYS_User_EXT7 = @"ext7";
NSString * const HTMIABCSYS_User_EXT8 = @"ext8";
NSString * const HTMIABCSYS_User_EXT9 = @"ext9";
NSString * const HTMIABCSYS_User_EXT10 = @"ext10";

//wlq add 名字处理的字段
NSString * const HTMIABCSYS_User_PinYinHeader = @"PinYinHeader";
NSString * const HTMIABCSYS_User_PinYinSuoXie = @"PinYinSuoXie";
NSString * const HTMIABCSYS_User_PinYinQuanPin = @"PinYinQuanPin";


/**
 *  创建数据库以及表
 */
- (void)creatDatabaseAndTables{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"AddressBook.sqlite"];
    
    HTLog(@"DBPaht:%@",filePath);
    
    //创建数据库，并加入到队列中，此时已经默认打开了数据库，无须手动打开，只需要从队列中去除数据库即可
    
    self.queue = [HTMIWFCFMDatabaseQueue databaseQueueWithPath:filePath];
    
    //取出数据库，这里的db就是数据库，在数据库中创建表
    
    __block BOOL result = NO;
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        [db open];
        
        /*==================================================*/
        /* Table: TD_User   人员属性定义表      */
        /*==================================================*/
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS TD_User ( FieldName varchar(100) PRIMARY KEY NOT NULL,DisLabel varchar(100) NOT NULL,DisOrder integer NOT NULL,IsActive bool NOT NULL,EnabledEdit bool NOT NULL,SecretFlag smallint NOT NULL DEFAULT(0), Action smallint NOT NULL )"];
        
        
        /*======================================================*/
        /* Table: SYS_Department   部门表     */
        /*=====================================================*/
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SYS_Department (DepartmentCode varchar(100) PRIMARY KEY NOT NULL,ShortName varchar(100), FullName varchar(500) NOT NULL , PinYinQuanPin text , OrganiseType varchar(8) NOT NULL,ParentDepartment varchar(50), PostCode varchar(6),Telephone varchar(20), Fax varchar(40),Address varchar(500),Remark varchar(500),IsDelete integer DEFAULT(0),CreatedBy varchar(20),CreatedDate timestamp, ModifiedBy varchar(20),ModifiedDate timestamp,UniversalPwd varchar(100),Pinyin varchar(200),OULabel varchar,OULevel integer,ADCode varchar(200),AppCode varchar(100),UniversalCode varchar(128),IsVirtual integer,IP varchar,Port varchar(5),ThirdDepartmentId varchar(100),DisOrder integer)"];
        
        /*======================================*/
        /* Table: SYS_User     人员表    */
        /*========================================*/
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SYS_User (UserId varchar(20) PRIMARY KEY NOT NULL,Password varchar(200),PasswordKey varchar(50),PasswordIV varchar(50),FullName varchar(100) NOT NULL,Gender smallint,ISDN varchar(20), Email varchar(255), Status smallint,  Telephone varchar(100), Fax varchar(20), Office varchar(40), SignPics image,Pics image,UserType integer, PasswordLastChanged datetime,Mobile varchar(100), Position varchar(100),Photosurl varchar(100),RePasswordDate timestamp,RePasswordKey varchar(100),CreatedBy varchar(20), CreatedDate timestamp,    ModifiedBy varchar(20),ModifiedDate timestamp,PhotosurlAttchmentGuid text,ThirdUserId text,attribute1 text,attribute2 text, attribute3 text,attribute4 text,attribute5 text,IsEMPUser smallint,IsEMIUser smallint,ext1 text, ext2 text,ext3 text,ext4 text,ext5 text,ext6 text,ext7 text,ext8 text,ext9 text,ext10 text,PinYinHeader text,PinYinSuoXie text,PinYinQuanPin text)"];
        
        
        /*======================================*/
        /* Table: SYS_OrgUser  人员部门关系表  */
        /*======================================*/
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS SYS_OrgUser (ID integer PRIMARY KEY NOT NULL, UserId varchar(20) NOT NULL,DepartmentCode varchar(50) NOT NULL, CreatedBy varchar(40),CreatedDate timestamp,DisOrder integer)"];
        
        
        /*=========================================*/
        /* Table: TD_UserFieldSecret定义某个保密字段哪些人能看                  */
        /*=========================================*/
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS TD_UserFieldSecret (UserId varchar(20) NOT NULL, FieldName varchar(50) NOT NULL,PRIMARY KEY(UserId, FieldName))"];
        
        /*==================================*/
        /* Table: T_UserRelationship   用户的常用联系人表*/
        /*==================================*/
        
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_UserRelationship (UserId varchar(20) NOT NULL,CUserId varchar(20) NOT NULL,PRIMARY KEY(UserId, CUserId))"];
        
        [db close];
    }];
    
}

/**
 *  读取一行数据
 */
- (void)Getdata:(HTMIABCDDFileReader *)reader rowCount:(int)count datalines:(NSMutableArray *)datalines
{
    [datalines removeAllObjects];
    
    if (count == 0) {
        return;
    }
    
    NSString * line;
    
    for (int i=0; i<count; i++)
    {
        line = [reader readLine];
        
        NSString * lineString = [[line stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [datalines addObject:(lineString)];
        
    }
}


/**
 *  同步数据库
 *
 *  @return 同步是否成功
 */
- (NSString *)syncDB{
    
    @try {
        
        //返回结果
        NSMutableString *resultStr = [[NSMutableString alloc]init];
        
        
        NSString * strFilePath = [HTMIABCUserdefault defaultLoadAddressBookPath];
        
        //判断文件是否存在
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        
        if(![fileManager fileExistsAtPath:strFilePath]) {
            return @"文件不存在";
        }
        
        //按行读取文件
        HTMIABCDDFileReader * reader = [[HTMIABCDDFileReader alloc] initWithFilePath:strFilePath];
        
        NSString *line = nil;
        //读取时间
        NSString *firstLine = [reader readLine];
        HTLog(@"time:%@", firstLine);
        
        NSString * year = [firstLine substringWithRange:NSMakeRange(0,4)];
        NSString * month = [firstLine substringWithRange:NSMakeRange(4,2)];
        NSString * date = [firstLine substringWithRange:NSMakeRange(6,2)];
        NSString * hours = [firstLine substringWithRange:NSMakeRange(8,2)];
        NSString * minutes = [firstLine substringWithRange:NSMakeRange(10,2)];
        NSString * seconds = [firstLine substringWithRange:NSMakeRange(12,2)];
        NSString * synchronizationeventStamp = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year,month,date,hours,minutes,seconds];
        
        //这个操作应该在插入数据库成功之后
        //        //保存时间戳
        //        [HTMIABCUserdefault defaultSaveAddressBookSynchronizationeventStamp:synchronizationeventStamp];
        self.synchronizationeventStamp = synchronizationeventStamp;
        
        
        //纪录数据行
        NSMutableArray *datalines = [[NSMutableArray alloc] init];
        
        while ((line = [reader readLine])) {
            
            HTLog(@"read line: %@", line);
            
            
            NSArray *array = [line componentsSeparatedByString:@"ú"];
            int count = [array[1] intValue];
            
            if ([array[0] isEqualToString:@"2-0"] )//SYS_DEPARTMENT("2-0", "SYS_Department"),
            {
                //如果行数大于0，第一行应该单独读取，
                if (count > 0){
                    NSString * strField = [reader readLine]; //对应表的字段，也就是列头
                    
                    [self Getdata:reader rowCount:count datalines:datalines];//插入条纪录
                    
                    [self insertToSYS_Department:strField linestrs:datalines];
                    
                }
                
            }
            else if([array[0] isEqualToString:@"2-1"] )//SYS_USER("2-1", "SYS_User"),
            {
                
                
                if (count > 0){
                    NSString * strField = [reader readLine]; //对应表的字段，也就是列头
                    
                    [self Getdata:reader rowCount:count datalines:datalines];//插入条纪录
                    //wlq update 2016/04/17
                    
                    [self insertToSYS_User:strField linestrs:datalines];
                    
                }
            }
            else if([array[0] isEqualToString:@"2-2"] )//SYS_ORGUSER("2-2", "SYS_OrgUser"),
            {
                if (count > 0){
                    NSString * strField = [reader readLine]; //对应表的字段，也就是列头
                    
                    [self Getdata:reader rowCount:count datalines:datalines];//插入条纪录
                    
                    [self insertToSYS_OrgUser:strField linestrs:datalines];
                }
            }
            else if([array[0] isEqualToString:@"2-3"] )//TD_USER("2-3", "TD_User"),
            {
                if (count > 0)
                {
                    NSString * strField = [reader readLine]; //对应表的字段，也就是列头
                    
                    [self Getdata:reader rowCount:count datalines:datalines];//插入条纪录
                    
                    [self insertToTD_User:strField linestrs:datalines];
                    
                }
                
            }
            else if([array[0] isEqualToString:@"2-4"] )//TD_USERFIELDSECRET("2-4", "TD_UserFieldSecret"),
            {
                if (count > 0)
                {
                    NSString * strField = [reader readLine]; //对应表的字段，也就是列头
                    
                    [self Getdata:reader rowCount:count datalines:datalines];//插入条纪录
                    
                    [self insertToTD_UserFieldSecret:strField linestrs:datalines];
                }
                
            }
            else if([array[0] isEqualToString:@"2-5"] )//T_USERRELATIONSHIP("2-5","T_UserRelationship");
            {
                if (count > 0)
                {
                    NSString * strField = [reader readLine]; //对应表的字段，也就是列头
                    
                    [self Getdata:reader rowCount:count datalines:datalines];//插入条纪录
                    
                    [self insertToT_UserRelationship:strField linestrs:datalines];
                }
                
            }
        }
        
        return [NSString stringWithFormat:@"同步成功：\n%@",resultStr];
        
    }
    @catch (NSException *exception) {
        return [NSString stringWithFormat:@"同步出错：\n%@", exception.reason];//这里有BUG，需要测试环境来调试
    }
    @finally
    {
        
        //#pragma Mark 删除test.txt文件
        //
        //        NSFileManager * fileManager = [NSFileManager defaultManager];
        //        if ([fileManager fileExistsAtPath:[HTMIABCUserdefault defaultLoadAddressBookPath]]) {
        //            //如果test.txt文件存在则删除
        //            [fileManager removeItemAtPath:[HTMIABCUserdefault defaultLoadAddressBookPath] error:nil];
        //        }
    }
}

//SYS_DEPARTMENT("2-0", "SYS_Department"),
//SYS_USER("2-1", "SYS_User"),
//SYS_ORGUSER("2-2", "SYS_OrgUser"),
//TD_USER("2-3", "TD_User"),
//TD_USERFIELDSECRET("2-4", "TD_UserFieldSecret"),
//T_USERRELATIONSHIP("2-5","T_UserRelationship");

/**
 *  插入部门表
 *
 *  @param fieldNameStrings 表头，未拆分字符串
 *  @param linestrs         行未拆分数据数组
 */
- (void)insertToSYS_Department:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    //wlq update 2016/04/20
    //[self insertToTable:TABLE_NAME_SYS_Department fieldNameStrings:fieldNameStrings linestrs:linestrs];
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        [db open];
        
        NSString * strFieldNames = [[fieldNameStrings stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        
        NSArray *arrayFieldNames = [strFieldNames componentsSeparatedByString:@"ú"];
        
        for (int i = 0; i < arrayFieldNames.count; i++) {
            
            //判断字段是否存在
            if (![db columnExists:arrayFieldNames[i] inTableWithName:HTMIABCTABLE_NAME_SYS_Department]) {
                
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",HTMIABCTABLE_NAME_SYS_Department,arrayFieldNames[i]];
                
                [db executeUpdate:sql];
            }
        }
        
        
        for (NSString *line in linestrs) {
            
            NSArray *array = [line componentsSeparatedByString:@"ú"];
            
            NSString *prefix = [NSString stringWithFormat:@"REPLACE INTO %@ (", HTMIABCTABLE_NAME_SYS_Department];
            
            NSMutableString *middle = [NSMutableString new];
            
            int nameFieldPosition = -1;
            
            for(int i=0; i<[arrayFieldNames count]; i++){
                NSString *columnName = [arrayFieldNames objectAtIndex:i];// 列名
                
                [middle appendString:@"'"];
                [middle appendString:columnName];
                [middle appendString:@"',"];
                if ([columnName isEqualToString:HTMIABCFULLNAME]) {//判断是否存在姓名字段
                    nameFieldPosition = i;
                    
                    [middle appendString:@"'"];
                    [middle appendString:HTMIABCSYS_Department_PinYinQuanPin];
                    [middle appendString:@"',"];
                }
            }
            
            NSString *cuttedMiddle = [middle substringToIndex:[middle length]-1];
            
            
            NSMutableString *suffix = [NSMutableString new];
            [suffix appendString:@") values ("];
            for(int i=0;i<[array count];i++){
                NSString *columnValue = [array objectAtIndex:i];// 列值
                
                [suffix appendString:@"'"];
                [suffix appendString:columnValue];
                [suffix appendString:@"',"];
                
                if (nameFieldPosition == i) {//部门名称字段存在，处理部门名称
                    //columnValue 这个就是的姓名
                    
                    //获取全拼
                    NSString * strPinyin = [self transformToPinyin:columnValue];
                    
                    [suffix appendString:@"'"];
                    [suffix appendString:strPinyin];
                    [suffix appendString:@"',"];
                }
            }
            
            NSString *cuttedSuffix = [suffix substringToIndex:[suffix length]-1];
            
            NSMutableString *sql = [NSMutableString new];
            [sql appendString:prefix];
            [sql appendString:cuttedMiddle];
            [sql appendString:cuttedSuffix];
            [sql appendString:@");"];
            
            [db executeUpdate:sql];
        }
        
        [db close];
        
    }];
    
}


/**
 *  插入人员属性定义表
 *
 *  @param fieldNameStrings 表头，未拆分字符串
 *  @param linestrs         行未拆分数据数组
 */
- (void)insertToTD_User:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    [self insertToTable:@"TD_User" fieldNameStrings:fieldNameStrings linestrs:linestrs];
    
    
}


/**
 *  插入人员表
 *
 *  @param fieldNameStrings 表头，未拆分字符串
 *  @param linestrs         行未拆分数据数组
 */
- (void)insertToSYS_User:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    //wlq update 2016/04/17
    //[self insertToTable:@"SYS_User" fieldNameStrings:fieldNameStrings linestrs:linestrs];
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        [db open];
        
        NSString * strFieldNames = [[fieldNameStrings stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        
        NSArray *arrayFieldNames = [strFieldNames componentsSeparatedByString:@"ú"];
        
        for (int i = 0; i < arrayFieldNames.count; i++) {
            
            //判断字段是否存在
            if (![db columnExists:arrayFieldNames[i] inTableWithName:HTMIABCTABLE_NAME_SYS_User]) {
                
                
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",HTMIABCTABLE_NAME_SYS_User,arrayFieldNames[i]];
                
                [db executeUpdate:sql];
            }
        }
        
        
        for (NSString *line in linestrs) {
            
            NSArray *array = [line componentsSeparatedByString:@"ú"];
            
            NSString *prefix = [NSString stringWithFormat:@"REPLACE INTO %@ (", HTMIABCTABLE_NAME_SYS_User];
            
            NSMutableString *middle = [NSMutableString new];
            
            int nameFieldPosition = -1;
            
            for(int i=0; i<[arrayFieldNames count]; i++){
                NSString *columnName = [arrayFieldNames objectAtIndex:i];// 列名
                
                [middle appendString:@"'"];
                [middle appendString:columnName];
                [middle appendString:@"',"];
                if ([columnName isEqualToString:HTMIABCSYS_User_FULLNAME]) {//判断是否存在姓名字段
                    nameFieldPosition = i;
                    
                    
                    [middle appendString:@"'"];
                    [middle appendString:HTMIABCSYS_User_PinYinHeader];
                    [middle appendString:@"',"];
                    
                    [middle appendString:@"'"];
                    [middle appendString:HTMIABCSYS_User_PinYinSuoXie];
                    [middle appendString:@"',"];
                    
                    [middle appendString:@"'"];
                    [middle appendString:HTMIABCSYS_User_PinYinQuanPin];
                    [middle appendString:@"',"];
                }
            }
            
            NSString *cuttedMiddle = [middle substringToIndex:[middle length]-1];
            
            
            NSMutableString *suffix = [NSMutableString new];
            [suffix appendString:@") values ("];
            for(int i=0;i<[array count];i++){
                NSString *columnValue = [array objectAtIndex:i];// 列值
                
                [suffix appendString:@"'"];
                [suffix appendString:columnValue];
                [suffix appendString:@"',"];
                
                if (nameFieldPosition == i) {//姓名字段存在，处理姓名
                    //columnValue 这个就是用户的姓名
                    
                    
                    
                    //设置缩写
                    NSString * suoxie = @"";
                    NSMutableString *sb = [NSMutableString new];
                    for(int i = 0 ; i < columnValue.length; i++){
                        suoxie = [self firstCharactor:[columnValue substringWithRange:NSMakeRange(i,1)]];
                        [sb appendString:suoxie];
                    }
                    
                    //wlq update 没有用了
                    //设置头字母
                    NSString * strHeader = @"";//可以直接从缩写中获取第一个字符//[self firstCharactor:columnValue];
                    
                    NSString * strSuoXie = sb;
                    //获取全拼
                    NSString * strPinyin = [self transformToPinyin:columnValue];
                    
                    [suffix appendString:@"'"];
                    [suffix appendString:strHeader];
                    [suffix appendString:@"',"];
                    
                    [suffix appendString:@"'"];
                    [suffix appendString:strSuoXie];
                    [suffix appendString:@"',"];
                    
                    [suffix appendString:@"'"];
                    [suffix appendString:strPinyin];
                    [suffix appendString:@"',"];
                }
            }
            
            NSString *cuttedSuffix = [suffix substringToIndex:[suffix length]-1];
            
            NSMutableString *sql = [NSMutableString new];
            [sql appendString:prefix];
            [sql appendString:cuttedMiddle];
            [sql appendString:cuttedSuffix];
            [sql appendString:@");"];
            
            [db executeUpdate:sql];
        }
        
        [db close];
        
    }];
}




/**
 *  插入人员部门关系表
 *
 *  @param fieldNameStrings 表头，未拆分字符串
 *  @param linestrs         行未拆分数据数组
 */
- (void)insertToSYS_OrgUser:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    [self insertToTable:@"SYS_OrgUser" fieldNameStrings:fieldNameStrings linestrs:linestrs];
    
}

/**
 *  TD_UserFieldSecret定义某个保密字段哪些人能看
 *
 *  @param fieldNameStrings 表头，未拆分字符串
 *  @param linestrs         行未拆分数据数组
 */
- (void)insertToTD_UserFieldSecret:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    [self insertToTable:@"TD_UserFieldSecret" fieldNameStrings:fieldNameStrings linestrs:linestrs];
    
}

/**
 *  用户的常用联系人表
 *
 *  @param fieldNameStrings 表头，未拆分字符串
 *  @param linestrs         行未拆分数据数组
 */
- (void)insertToT_UserRelationship:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    [self insertToTable:HTMIABCTABLE_NAME_T_UserRelationship fieldNameStrings:fieldNameStrings linestrs:linestrs];
}

/**
 *  公共的插入方法
 *
 *  @param strTableName     表名
 *  @param fieldNameStrings 字段字符串，未拆分
 *  @param linestrs         内容行数组
 */
-  (void)insertToTable:(NSString *)strTableName fieldNameStrings:(NSString *)fieldNameStrings linestrs:(NSArray *)linestrs{
    
    //    __block BOOL result = NO;
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        [db open];
        
        NSString * strFieldNames = [[fieldNameStrings stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        
        NSArray *arrayFieldNames = [strFieldNames componentsSeparatedByString:@"ú"];
        
        for (int i = 0; i < arrayFieldNames.count; i++) {
            
            //判断字段是否存在
            if (![db columnExists:arrayFieldNames[i] inTableWithName:strTableName]) {
                
                
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",strTableName,arrayFieldNames[i]];
                
                [db executeUpdate:sql];
            }
        }
        
        
        for (NSString *line in linestrs) {
            
            NSArray *array = [line componentsSeparatedByString:@"ú"];
            
            NSString *prefix = [NSString stringWithFormat:@"REPLACE INTO %@ (", strTableName];
            
            NSMutableString *middle = [NSMutableString new];
            for(int i=0;i<[arrayFieldNames count];i++){
                NSString *columnName = [arrayFieldNames objectAtIndex:i];// 列名
                
                [middle appendString:@"'"];
                [middle appendString:columnName];
                [middle appendString:@"',"];
            }
            
            NSString *cuttedMiddle = [middle substringToIndex:[middle length]-1];
            
            
            NSMutableString *suffix = [NSMutableString new];
            [suffix appendString:@") values ("];
            for(int i=0;i<[array count];i++){
                NSString *columnValue = [array objectAtIndex:i];// 列值
                
                [suffix appendString:@"'"];
                [suffix appendString:columnValue];
                [suffix appendString:@"',"];
                
            }
            
            NSString *cuttedSuffix = [suffix substringToIndex:[suffix length]-1];
            
            NSMutableString *sql = [NSMutableString new];
            [sql appendString:prefix];
            [sql appendString:cuttedMiddle];
            [sql appendString:cuttedSuffix];
            [sql appendString:@");"];
            
            [db executeUpdate:sql];
        }
        
        [db close];
        
    }];
}


#pragma mark --部门表相关操作

/**
 *  获取部门表中的根节点
 *
 *  @return 部门模型
 */
- (HTMIABCSYS_DepartmentModel *)getRootDepartment{
    __block HTMIABCSYS_DepartmentModel *mSYS_Department;
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ not in (select %@ from %@)",HTMIABCTABLE_NAME_SYS_Department,HTMIABCPARENTDEPARTMENT,HTMIABCDEPARTMENTCODE,HTMIABCTABLE_NAME_SYS_Department];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            while (result.next)
            {
                mSYS_Department = [HTMIABCSYS_DepartmentModel new];
                
                NSString * departmentCode = [result stringForColumn:HTMIABCDEPARTMENTCODE];
                mSYS_Department.DepartmentCode = departmentCode;
                
                NSString * ShortName = [result stringForColumn:HTMIABCSHORTNAME];
                mSYS_Department.ShortName = ShortName;
                
                NSString * fullName = [result stringForColumn:HTMIABCFULLNAME];
                mSYS_Department.FullName = fullName;
                
                NSString * OrganiseType = [result stringForColumn:HTMIABCORGANISETYPE];
                mSYS_Department.OrganiseType = OrganiseType;
                
                NSString * ParentDepartment = [result stringForColumn:HTMIABCPARENTDEPARTMENT];
                mSYS_Department.ParentDepartment = ParentDepartment;
                
                NSString * PostCode = [result stringForColumn:HTMIABCPOSTCODE];
                mSYS_Department.PostCode = PostCode;
                
                NSString * Telephone = [result stringForColumn:HTMIABCTELEPHONE];
                mSYS_Department.Telephone = Telephone;
                
                NSString * Fax = [result stringForColumn:HTMIABCFAX];
                mSYS_Department.Fax = Fax;
                
                NSString * Address = [result stringForColumn:HTMIABCADDRESS];
                mSYS_Department.Address = Address;
                
                NSString * Remark = [result stringForColumn:HTMIABCREMARK];
                mSYS_Department.Remark = Remark;
                
                int IsDelete = [result intForColumn:HTMIABCISDELETE];
                mSYS_Department.IsDelete = IsDelete;
                
                NSString * CreatedBy = [result stringForColumn:HTMIABCCREATEDBY];
                mSYS_Department.CreatedBy = CreatedBy;
                
                NSString * CreatedDate = [result stringForColumn:HTMIABCCREATEDDATE];
                mSYS_Department.CreatedDate = CreatedDate;
                
                NSString * ModifiedBy = [result stringForColumn:HTMIABCMODIFIEDBY];
                mSYS_Department.ModifiedBy = ModifiedBy;
                
                NSString * ModifiedDate = [result stringForColumn:HTMIABCMODIFIEDDATE];
                mSYS_Department.ModifiedDate = ModifiedDate;
                
                NSString * UniversalPwd = [result stringForColumn:HTMIABCUNIVERSALPWD];
                mSYS_Department.UniversalPwd = UniversalPwd;
                
                NSString * Pinyin = [result stringForColumn:HTMIABCPINYIN];
                mSYS_Department.Pinyin = Pinyin;
                
                NSString * OULabel = [result stringForColumn:HTMIABCOULABEL];
                mSYS_Department.OULabel = OULabel;
                
                int OULevel = [result intForColumn:HTMIABCOULEVEL];
                mSYS_Department.OULevel = OULevel;
                
                NSString * ADCode = [result stringForColumn:HTMIABCADCODE];
                mSYS_Department.ADCode = ADCode;
                
                NSString * AppCode = [result stringForColumn:HTMIABCAPPCODE];
                mSYS_Department.AppCode = AppCode;
                
                NSString * UniversalCode = [result stringForColumn:HTMIABCUNIVERSALCODE];
                mSYS_Department.UniversalCode = UniversalCode;
                
                int IsVirtual = [result intForColumn:HTMIABCISVIRTUAL];
                mSYS_Department.IsVirtual = IsVirtual;
                
                NSString * sys_Department_IP = [result stringForColumn:HTMIABCSYS_Department_IP];
                mSYS_Department.IP = sys_Department_IP;
                
                NSString * Port = [result stringForColumn:HTMIABCPORT];
                mSYS_Department.Port = Port;
                
                NSString * ThirdDepartmentId = [result stringForColumn:HTMIABCTHIRDDEPARTMENTID];
                mSYS_Department.ThirdDepartmentId = ThirdDepartmentId;
                
                int DisOrder = [result intForColumn:HTMIABCDISORDER];
                mSYS_Department.DisOrder = DisOrder;
                
                //wlq add
                NSString * strPinYinQuanPin = [result stringForColumn:HTMIABCSYS_Department_PinYinQuanPin];
                mSYS_Department.PinYinQuanPin = strPinYinQuanPin;
                
                break;
                
            }
            
            
        } @catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return mSYS_Department;
}

- (NSMutableArray *)getDepartmentAndUsers:(NSString *)DepartmentCode{
    
    __block NSMutableArray * allDataArrayInDepartmentCode;
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    //    __block int index = 0;
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_Department,HTMIABCPARENTDEPARTMENT,DepartmentCode];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            allDataArrayInDepartmentCode = [NSMutableArray array];
            NSMutableArray * departmentArray = [NSMutableArray array];
            while (result.next)
            {
                HTMIABCSYS_DepartmentModel *mSYS_Department = [HTMIABCSYS_DepartmentModel new];
                
                NSString * departmentCode = [result stringForColumn:HTMIABCDEPARTMENTCODE];
                mSYS_Department.DepartmentCode = departmentCode;
                
                NSString * ShortName = [result stringForColumn:HTMIABCSHORTNAME];
                mSYS_Department.ShortName = ShortName;
                
                NSString * fullName = [result stringForColumn:HTMIABCFULLNAME];
                mSYS_Department.FullName = fullName;
                
                NSString * OrganiseType = [result stringForColumn:HTMIABCORGANISETYPE];
                mSYS_Department.OrganiseType = OrganiseType;
                
                NSString * ParentDepartment = [result stringForColumn:HTMIABCPARENTDEPARTMENT];
                mSYS_Department.ParentDepartment = ParentDepartment;
                
                NSString * PostCode = [result stringForColumn:HTMIABCPOSTCODE];
                mSYS_Department.PostCode = PostCode;
                
                NSString * Telephone = [result stringForColumn:HTMIABCTELEPHONE];
                mSYS_Department.Telephone = Telephone;
                
                NSString * Fax = [result stringForColumn:HTMIABCFAX];
                mSYS_Department.Fax = Fax;
                
                NSString * Address = [result stringForColumn:HTMIABCADDRESS];
                mSYS_Department.Address = Address;
                
                NSString * Remark = [result stringForColumn:HTMIABCREMARK];
                mSYS_Department.Remark = Remark;
                
                int IsDelete = [result intForColumn:HTMIABCISDELETE];
                mSYS_Department.IsDelete = IsDelete;
                
                NSString * CreatedBy = [result stringForColumn:HTMIABCCREATEDBY];
                mSYS_Department.CreatedBy = CreatedBy;
                
                NSString * CreatedDate = [result stringForColumn:HTMIABCCREATEDDATE];
                mSYS_Department.CreatedDate = CreatedDate;
                
                NSString * ModifiedBy = [result stringForColumn:HTMIABCMODIFIEDBY];
                mSYS_Department.ModifiedBy = ModifiedBy;
                
                NSString * ModifiedDate = [result stringForColumn:HTMIABCMODIFIEDDATE];
                mSYS_Department.ModifiedDate = ModifiedDate;
                
                NSString * UniversalPwd = [result stringForColumn:HTMIABCUNIVERSALPWD];
                mSYS_Department.UniversalPwd = UniversalPwd;
                
                NSString * Pinyin = [result stringForColumn:HTMIABCPINYIN];
                mSYS_Department.Pinyin = Pinyin;
                
                NSString * OULabel = [result stringForColumn:HTMIABCOULABEL];
                mSYS_Department.OULabel = OULabel;
                
                int OULevel = [result intForColumn:HTMIABCOULEVEL];
                mSYS_Department.OULevel = OULevel;
                
                NSString * ADCode = [result stringForColumn:HTMIABCADCODE];
                mSYS_Department.ADCode = ADCode;
                
                NSString * AppCode = [result stringForColumn:HTMIABCAPPCODE];
                mSYS_Department.AppCode = AppCode;
                
                NSString * UniversalCode = [result stringForColumn:HTMIABCUNIVERSALCODE];
                mSYS_Department.UniversalCode = UniversalCode;
                
                int IsVirtual = [result intForColumn:HTMIABCISVIRTUAL];
                mSYS_Department.IsVirtual = IsVirtual;
                
                NSString * sys_Department_IP = [result stringForColumn:HTMIABCSYS_Department_IP];
                mSYS_Department.IP = sys_Department_IP;
                
                NSString * Port = [result stringForColumn:HTMIABCPORT];
                mSYS_Department.Port = Port;
                
                NSString * ThirdDepartmentId = [result stringForColumn:HTMIABCTHIRDDEPARTMENTID];
                mSYS_Department.ThirdDepartmentId = ThirdDepartmentId;
                
                int DisOrder = [result intForColumn:HTMIABCDISORDER];
                mSYS_Department.DisOrder = DisOrder;
                
#pragma mark --操作数据库
                
                [departmentArray addObject:mSYS_Department];
            }
            
            //HTMIABCSYS_UserModel 集合
            NSMutableArray * userArray =  [self findPartmentIdOrgUser:DepartmentCode]; //(departmentCode, mSYS_Department);
            
            NSSortDescriptor *disOrderAscend = [NSSortDescriptor sortDescriptorWithKey:@"DisOrder" ascending:YES];
            
            // 按顺序添加排序描述器
            NSArray *departmentArrayDesc = [departmentArray sortedArrayUsingDescriptors:@[disOrderAscend]];
            
            // 按顺序添加排序描述器
            NSArray *userArrayDesc = [userArray sortedArrayUsingDescriptors:@[disOrderAscend]];
            
            [allDataArrayInDepartmentCode addObjectsFromArray:departmentArrayDesc];
            
            [allDataArrayInDepartmentCode addObjectsFromArray:userArrayDesc];
            
        } @catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return allDataArrayInDepartmentCode;
}

/**
 *  根据部门的code获取部门
 *
 *  @param DepartmentCode 部门code
 *
 *  @return 部门模型
 */
- (HTMIABCSYS_DepartmentModel *)getDepartmentByDepartmentCode:(NSString *)DepartmentCode{
    
    __block HTMIABCSYS_DepartmentModel *mSYS_Department;
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_Department,HTMIABCDEPARTMENTCODE,DepartmentCode];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            while (result.next)
            {
                mSYS_Department = [HTMIABCSYS_DepartmentModel new];
                
                NSString * departmentCode = [result stringForColumn:HTMIABCDEPARTMENTCODE];
                mSYS_Department.DepartmentCode = departmentCode;
                
                NSString * ShortName = [result stringForColumn:HTMIABCSHORTNAME];
                mSYS_Department.ShortName = ShortName;
                
                NSString * fullName = [result stringForColumn:HTMIABCFULLNAME];
                mSYS_Department.FullName = fullName;
                
                NSString * OrganiseType = [result stringForColumn:HTMIABCORGANISETYPE];
                mSYS_Department.OrganiseType = OrganiseType;
                
                NSString * ParentDepartment = [result stringForColumn:HTMIABCPARENTDEPARTMENT];
                mSYS_Department.ParentDepartment = ParentDepartment;
                
                NSString * PostCode = [result stringForColumn:HTMIABCPOSTCODE];
                mSYS_Department.PostCode = PostCode;
                
                NSString * Telephone = [result stringForColumn:HTMIABCTELEPHONE];
                mSYS_Department.Telephone = Telephone;
                
                NSString * Fax = [result stringForColumn:HTMIABCFAX];
                mSYS_Department.Fax = Fax;
                
                NSString * Address = [result stringForColumn:HTMIABCADDRESS];
                mSYS_Department.Address = Address;
                
                NSString * Remark = [result stringForColumn:HTMIABCREMARK];
                mSYS_Department.Remark = Remark;
                
                int IsDelete = [result intForColumn:HTMIABCISDELETE];
                mSYS_Department.IsDelete = IsDelete;
                
                NSString * CreatedBy = [result stringForColumn:HTMIABCCREATEDBY];
                mSYS_Department.CreatedBy = CreatedBy;
                
                NSString * CreatedDate = [result stringForColumn:HTMIABCCREATEDDATE];
                mSYS_Department.CreatedDate = CreatedDate;
                
                NSString * ModifiedBy = [result stringForColumn:HTMIABCMODIFIEDBY];
                mSYS_Department.ModifiedBy = ModifiedBy;
                
                NSString * ModifiedDate = [result stringForColumn:HTMIABCMODIFIEDDATE];
                mSYS_Department.ModifiedDate = ModifiedDate;
                
                NSString * UniversalPwd = [result stringForColumn:HTMIABCUNIVERSALPWD];
                mSYS_Department.UniversalPwd = UniversalPwd;
                
                NSString * Pinyin = [result stringForColumn:HTMIABCPINYIN];
                mSYS_Department.Pinyin = Pinyin;
                
                NSString * OULabel = [result stringForColumn:HTMIABCOULABEL];
                mSYS_Department.OULabel = OULabel;
                
                int OULevel = [result intForColumn:HTMIABCOULEVEL];
                mSYS_Department.OULevel = OULevel;
                
                NSString * ADCode = [result stringForColumn:HTMIABCADCODE];
                mSYS_Department.ADCode = ADCode;
                
                NSString * AppCode = [result stringForColumn:HTMIABCAPPCODE];
                mSYS_Department.AppCode = AppCode;
                
                NSString * UniversalCode = [result stringForColumn:HTMIABCUNIVERSALCODE];
                mSYS_Department.UniversalCode = UniversalCode;
                
                int IsVirtual = [result intForColumn:HTMIABCISVIRTUAL];
                mSYS_Department.IsVirtual = IsVirtual;
                
                NSString * sys_Department_IP = [result stringForColumn:HTMIABCSYS_Department_IP];
                mSYS_Department.IP = sys_Department_IP;
                
                NSString * Port = [result stringForColumn:HTMIABCPORT];
                mSYS_Department.Port = Port;
                
                NSString * ThirdDepartmentId = [result stringForColumn:HTMIABCTHIRDDEPARTMENTID];
                mSYS_Department.ThirdDepartmentId = ThirdDepartmentId;
                
                int DisOrder = [result intForColumn:HTMIABCDISORDER];
                mSYS_Department.DisOrder = DisOrder;
                
                //wlq add
                NSString * strPinYinQuanPin = [result stringForColumn:HTMIABCSYS_Department_PinYinQuanPin];
                mSYS_Department.PinYinQuanPin = strPinYinQuanPin;
                
                break;
                
            }
            
            
        } @catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return mSYS_Department;
}

/**
 *  获取部门下的一级子部门
 *
 *  @param DepartmentCode 部门节点
 *
 *  @return 部门数组
 */
- (NSMutableArray *)getDepartments:(NSString *)DepartmentCode{
    
    __block NSMutableArray * departmentArray;
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_Department,HTMIABCPARENTDEPARTMENT,DepartmentCode];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            departmentArray = [NSMutableArray array];
            
            while (result.next)
            {
                HTMIABCSYS_DepartmentModel *mSYS_Department = [HTMIABCSYS_DepartmentModel new];
                
                NSString * departmentCode = [result stringForColumn:HTMIABCDEPARTMENTCODE];
                mSYS_Department.DepartmentCode = departmentCode;
                
                NSString * ShortName = [result stringForColumn:HTMIABCSHORTNAME];
                mSYS_Department.ShortName = ShortName;
                
                NSString * fullName = [result stringForColumn:HTMIABCFULLNAME];
                mSYS_Department.FullName = fullName;
                
                NSString * OrganiseType = [result stringForColumn:HTMIABCORGANISETYPE];
                mSYS_Department.OrganiseType = OrganiseType;
                
                NSString * ParentDepartment = [result stringForColumn:HTMIABCPARENTDEPARTMENT];
                mSYS_Department.ParentDepartment = ParentDepartment;
                
                NSString * PostCode = [result stringForColumn:HTMIABCPOSTCODE];
                mSYS_Department.PostCode = PostCode;
                
                NSString * Telephone = [result stringForColumn:HTMIABCTELEPHONE];
                mSYS_Department.Telephone = Telephone;
                
                NSString * Fax = [result stringForColumn:HTMIABCFAX];
                mSYS_Department.Fax = Fax;
                
                NSString * Address = [result stringForColumn:HTMIABCADDRESS];
                mSYS_Department.Address = Address;
                
                NSString * Remark = [result stringForColumn:HTMIABCREMARK];
                mSYS_Department.Remark = Remark;
                
                int IsDelete = [result intForColumn:HTMIABCISDELETE];
                mSYS_Department.IsDelete = IsDelete;
                
                NSString * CreatedBy = [result stringForColumn:HTMIABCCREATEDBY];
                mSYS_Department.CreatedBy = CreatedBy;
                
                NSString * CreatedDate = [result stringForColumn:HTMIABCCREATEDDATE];
                mSYS_Department.CreatedDate = CreatedDate;
                
                NSString * ModifiedBy = [result stringForColumn:HTMIABCMODIFIEDBY];
                mSYS_Department.ModifiedBy = ModifiedBy;
                
                NSString * ModifiedDate = [result stringForColumn:HTMIABCMODIFIEDDATE];
                mSYS_Department.ModifiedDate = ModifiedDate;
                
                NSString * UniversalPwd = [result stringForColumn:HTMIABCUNIVERSALPWD];
                mSYS_Department.UniversalPwd = UniversalPwd;
                
                NSString * Pinyin = [result stringForColumn:HTMIABCPINYIN];
                mSYS_Department.Pinyin = Pinyin;
                
                NSString * OULabel = [result stringForColumn:HTMIABCOULABEL];
                mSYS_Department.OULabel = OULabel;
                
                int OULevel = [result intForColumn:HTMIABCOULEVEL];
                mSYS_Department.OULevel = OULevel;
                
                NSString * ADCode = [result stringForColumn:HTMIABCADCODE];
                mSYS_Department.ADCode = ADCode;
                
                NSString * AppCode = [result stringForColumn:HTMIABCAPPCODE];
                mSYS_Department.AppCode = AppCode;
                
                NSString * UniversalCode = [result stringForColumn:HTMIABCUNIVERSALCODE];
                mSYS_Department.UniversalCode = UniversalCode;
                
                int IsVirtual = [result intForColumn:HTMIABCISVIRTUAL];
                mSYS_Department.IsVirtual = IsVirtual;
                
                NSString * sys_Department_IP = [result stringForColumn:HTMIABCSYS_Department_IP];
                mSYS_Department.IP = sys_Department_IP;
                
                NSString * Port = [result stringForColumn:HTMIABCPORT];
                mSYS_Department.Port = Port;
                
                NSString * ThirdDepartmentId = [result stringForColumn:HTMIABCTHIRDDEPARTMENTID];
                mSYS_Department.ThirdDepartmentId = ThirdDepartmentId;
                
                int DisOrder = [result intForColumn:HTMIABCDISORDER];
                mSYS_Department.DisOrder = DisOrder;
                
                [departmentArray addObject:mSYS_Department];
            }
            
            
        } @catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return departmentArray;
}

/**
 *  通过搜索拼音获取部门
 *
 *  @param searchString 搜索条件
 *
 *  @return 部门数组
 */
- (NSMutableArray *)getDepartmentBySearchString:(NSString *)searchString inDepartment:(NSString *)departmentCode{
    
    __block NSMutableArray * departmentArray;
    
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        
        if (![db open]) {
            [db open];
        }
        
        NSMutableString * strSql = [NSMutableString stringWithFormat:@"select * from (select * from SYS_Department where ParentDepartment like '%@",departmentCode];
        
        if ([searchString isChinese]) {
            
            [strSql appendString:@"%') where FullName like '%"];
            [strSql appendString:searchString];//拼音全拼
            [strSql appendString:@"%'"];
        }
        else{
            
            [strSql appendString:@"%') where PinYinQuanPin like '%"];
            
            NSString * strQuanPin =[self transformToPinyin:searchString];
            [strSql appendString:strQuanPin];//拼音全拼
            [strSql appendString:@"%'"];
        }
        
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            departmentArray = [NSMutableArray array];
            while (result.next)
            {
                HTMIABCSYS_DepartmentModel *mSYS_Department = [HTMIABCSYS_DepartmentModel new];
                
                NSString * departmentCode = [result stringForColumn:HTMIABCDEPARTMENTCODE];
                mSYS_Department.DepartmentCode = departmentCode;
                
                NSString * ShortName = [result stringForColumn:HTMIABCSHORTNAME];
                mSYS_Department.ShortName = ShortName;
                
                NSString * fullName = [result stringForColumn:HTMIABCFULLNAME];
                mSYS_Department.FullName = fullName;
                
                NSString * OrganiseType = [result stringForColumn:HTMIABCORGANISETYPE];
                mSYS_Department.OrganiseType = OrganiseType;
                
                NSString * ParentDepartment = [result stringForColumn:HTMIABCPARENTDEPARTMENT];
                mSYS_Department.ParentDepartment = ParentDepartment;
                
                NSString * PostCode = [result stringForColumn:HTMIABCPOSTCODE];
                mSYS_Department.PostCode = PostCode;
                
                NSString * Telephone = [result stringForColumn:HTMIABCTELEPHONE];
                mSYS_Department.Telephone = Telephone;
                
                NSString * Fax = [result stringForColumn:HTMIABCFAX];
                mSYS_Department.Fax = Fax;
                
                NSString * Address = [result stringForColumn:HTMIABCADDRESS];
                mSYS_Department.Address = Address;
                
                NSString * Remark = [result stringForColumn:HTMIABCREMARK];
                mSYS_Department.Remark = Remark;
                
                int IsDelete = [result intForColumn:HTMIABCISDELETE];
                mSYS_Department.IsDelete = IsDelete;
                
                NSString * CreatedBy = [result stringForColumn:HTMIABCCREATEDBY];
                mSYS_Department.CreatedBy = CreatedBy;
                
                NSString * CreatedDate = [result stringForColumn:HTMIABCCREATEDDATE];
                mSYS_Department.CreatedDate = CreatedDate;
                
                NSString * ModifiedBy = [result stringForColumn:HTMIABCMODIFIEDBY];
                mSYS_Department.ModifiedBy = ModifiedBy;
                
                NSString * ModifiedDate = [result stringForColumn:HTMIABCMODIFIEDDATE];
                mSYS_Department.ModifiedDate = ModifiedDate;
                
                NSString * UniversalPwd = [result stringForColumn:HTMIABCUNIVERSALPWD];
                mSYS_Department.UniversalPwd = UniversalPwd;
                
                NSString * Pinyin = [result stringForColumn:HTMIABCPINYIN];
                mSYS_Department.Pinyin = Pinyin;
                
                NSString * OULabel = [result stringForColumn:HTMIABCOULABEL];
                mSYS_Department.OULabel = OULabel;
                
                int OULevel = [result intForColumn:HTMIABCOULEVEL];
                mSYS_Department.OULevel = OULevel;
                
                NSString * ADCode = [result stringForColumn:HTMIABCADCODE];
                mSYS_Department.ADCode = ADCode;
                
                NSString * AppCode = [result stringForColumn:HTMIABCAPPCODE];
                mSYS_Department.AppCode = AppCode;
                
                NSString * UniversalCode = [result stringForColumn:HTMIABCUNIVERSALCODE];
                mSYS_Department.UniversalCode = UniversalCode;
                
                int IsVirtual = [result intForColumn:HTMIABCISVIRTUAL];
                mSYS_Department.IsVirtual = IsVirtual;
                
                NSString * sys_Department_IP = [result stringForColumn:HTMIABCSYS_Department_IP];
                mSYS_Department.IP = sys_Department_IP;
                
                NSString * Port = [result stringForColumn:HTMIABCPORT];
                mSYS_Department.Port = Port;
                
                NSString * ThirdDepartmentId = [result stringForColumn:HTMIABCTHIRDDEPARTMENTID];
                mSYS_Department.ThirdDepartmentId = ThirdDepartmentId;
                
                int DisOrder = [result intForColumn:HTMIABCDISORDER];
                mSYS_Department.DisOrder = DisOrder;
                
                //存入数组中
                [departmentArray addObject:mSYS_Department];
            }
            
        } @catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return departmentArray;
}

#pragma mark --人员部门关系表相关操作

//根据人员ID获取部门ID  List<SYS_User>
- (NSMutableArray *)findPartmentIdOrgUser:(NSString *)DepartmentCode{
    
    __block NSMutableArray * sys_OrgUserModelArray;
    
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSqlSYS_OrgUser = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_OrgUser,HTMIABCSYS_OrgUser_DEPARTMENTCODE,DepartmentCode];
        HTMIWFCFMResultSet *resultSYS_OrgUser = [db executeQuery:strSqlSYS_OrgUser];
        
        @try {
            
            sys_OrgUserModelArray =  [NSMutableArray array];
            while (resultSYS_OrgUser.next)
            {
                
                HTMIABCSYS_OrgUserModel * mSYS_OrgUser =[HTMIABCSYS_OrgUserModel new];
                
                int sys_OrgUser_Id = [resultSYS_OrgUser intForColumn:HTMIABCSYS_OrgUser_ID];
                NSString * sys_OrgUser_userId = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_USERID];
                NSString * sys_OrgUser_departmentCode = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                NSString * sys_OrgUser_createdBy = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_CREATEDBY];
                NSString * sys_OrgUser_createdDate = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_CREATEDDATE];
                int sys_OrgUser_disOrder = [resultSYS_OrgUser intForColumn:HTMIABCSYS_OrgUser_DISORDER];
                
                mSYS_OrgUser.ID  = sys_OrgUser_Id;
                mSYS_OrgUser.UserId = sys_OrgUser_userId;
                mSYS_OrgUser.DepartmentCode = sys_OrgUser_departmentCode;
                mSYS_OrgUser.CreatedBy = sys_OrgUser_createdBy;
                mSYS_OrgUser.CreatedDate = sys_OrgUser_createdDate;
                mSYS_OrgUser.DisOrder = sys_OrgUser_disOrder;
                
                //因为需要排序，将disOrder作为属性赋值给用户模型
                HTMIABCSYS_UserModel * mSYS_User =  [self findUserIdSYS_Users:sys_OrgUser_userId FMDatabase:db];
                if (mSYS_User) {
                    mSYS_User.DisOrder = sys_OrgUser_disOrder;
                    //wlq update,用户不需要存储部门
                    //mSYS_User.mSYS_Department = mSYS_Department;
                    [sys_OrgUserModelArray addObject:mSYS_User];
                }
            }
            
        } @catch (NSException *exception) {
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (resultSYS_OrgUser) {
                [resultSYS_OrgUser close];
            }
        }
    }];
    
    return sys_OrgUserModelArray;
}


#pragma mark --用户表相关操作

#warning 暂未完成，需要获取用户的DepartmentCode
// 获取用户详细信息
-(HTMIABCSYS_UserModel *)findUserIdSYS_Users:(NSString *)userIds FMDatabase:(HTMIWFCFMDatabase *)db{
    
    __block HTMIABCSYS_UserModel * mSYS_User;
    
    //执行查询语句
    //    NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",TABLE_NAME_SYS_User,SYS_User_USERID,userIds];
    
    NSString * strSql = [NSString stringWithFormat:@"select * from (select * from %@ where %@ = '%@' ) u left join SYS_OrgUser on u.UserId = SYS_OrgUser.UserId ",HTMIABCTABLE_NAME_SYS_User,HTMIABCSYS_User_USERID,userIds];
    
    HTMIWFCFMResultSet *result = [db executeQuery:strSql];
    
    @try {
        
        while (result.next)
        {
            mSYS_User = [HTMIABCSYS_UserModel new];
            //wlq add
            NSString * sys_User_DepartmentCode = [result stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
            mSYS_User.departmentCode = sys_User_DepartmentCode;
            
            NSString * sys_User_UserId = [result stringForColumn:HTMIABCSYS_User_USERID];
            mSYS_User.UserId = sys_User_UserId;
            
            NSString * sys_User_Password = [result stringForColumn:HTMIABCSYS_User_PASSWORD];
            mSYS_User.Password = sys_User_Password;
            
            NSString * sys_User_PasswordKey = [result stringForColumn:HTMIABCSYS_User_PASSWORDKEY];
            mSYS_User.PasswordKey = sys_User_PasswordKey;
            
            NSString * sys_User_PasswordIV = [result stringForColumn:HTMIABCSYS_User_PASSWORDIV];
            mSYS_User.PasswordIV = sys_User_PasswordIV;
            
            NSString * sys_User_FullName = [result stringForColumn:HTMIABCSYS_User_FULLNAME];
            mSYS_User.FullName = sys_User_FullName;
            
            
            //设置头字母
            mSYS_User.header = [result stringForColumn:HTMIABCSYS_User_PinYinHeader];
            
            
            mSYS_User.suoXie =[result stringForColumn:HTMIABCSYS_User_PinYinSuoXie];
            
            mSYS_User.pinyin = [result stringForColumn:HTMIABCSYS_User_PinYinQuanPin];
            
            
            
            int sys_User_Gender = [result intForColumn:HTMIABCSYS_User_GENDER];
            mSYS_User.Gender = sys_User_Gender;
            
            NSString * sys_User_ISDN = [result stringForColumn:HTMIABCSYS_User_ISDN];
            mSYS_User.ISDN = sys_User_ISDN;
            
            NSString * sys_User_Email = [result stringForColumn:HTMIABCSYS_User_EMAIL];
            mSYS_User.Email = sys_User_Email;
            
            int sys_User_Status = [result intForColumn:HTMIABCSYS_User_STATUS];
            mSYS_User.Status = sys_User_Status;
            
            NSString * sys_User_Telephone = [result stringForColumn:HTMIABCSYS_User_TELEPHONE];
            mSYS_User.Telephone = sys_User_Telephone;
            
            NSString * sys_User_Fax = [result stringForColumn:HTMIABCSYS_User_FAX];
            mSYS_User.Fax = sys_User_Fax;
            
            NSString * sys_User_Office = [result stringForColumn:HTMIABCSYS_User_OFFICE];
            mSYS_User.Office = sys_User_Office;
            
#warning 此处转换成NSdData 不确定是否能够成功
            //byte[] SignPicsDatas = cursor.getBlob(cursor
            //                                                      .getColumnIndex(SIGNPICS));
            NSData * sys_User_SignPics = [result dataForColumn:HTMIABCSYS_User_SIGNPICS];
            mSYS_User.SignPics = sys_User_SignPics;
            
            NSData * sys_User_Pics = [result dataForColumn:HTMIABCSYS_User_PICS];
            mSYS_User.Pics = sys_User_Pics;
            
            NSString * sys_User_PasswordLastChanged = [result stringForColumn:HTMIABCSYS_User_PASSWORDLASTCHANGED];
            mSYS_User.PasswordLastChanged = sys_User_PasswordLastChanged;
            
            NSString * sys_User_Mobile = [result stringForColumn:HTMIABCSYS_User_MOBILE];
            mSYS_User.Mobile = sys_User_Mobile;
            
            NSString * sys_User_Position = [result stringForColumn:HTMIABCSYS_User_POSITION];
            mSYS_User.Position = sys_User_Position;
            
            NSString * sys_User_Photosurl = [result stringForColumn:HTMIABCSYS_User_PHOTOSURL];
            mSYS_User.Photosurl = sys_User_Photosurl;
            
            NSString * sys_User_RePasswordDate = [result stringForColumn:HTMIABCSYS_User_REPASSWORDDATE];
            mSYS_User.RePasswordDate = sys_User_RePasswordDate;
            
            NSString * sys_User_RePasswordKey = [result stringForColumn:HTMIABCSYS_User_REPASSWORDKEY];
            mSYS_User.RePasswordKey = sys_User_RePasswordKey;
            
            NSString * sys_User_CreatedBy = [result stringForColumn:HTMIABCSYS_User_CREATEDBY];
            mSYS_User.CreatedBy = sys_User_CreatedBy;
            
            NSString * sys_User_CreatedDate = [result stringForColumn:HTMIABCSYS_User_CREATEDDATE];
            mSYS_User.CreatedDate = sys_User_CreatedDate;
            
            NSString * sys_User_ModifiedBy = [result stringForColumn:HTMIABCSYS_User_MODIFIEDBY];
            mSYS_User.ModifiedBy = sys_User_ModifiedBy;
            
            NSString * sys_User_ModifiedDate = [result stringForColumn:HTMIABCSYS_User_MODIFIEDDATE];
            mSYS_User.ModifiedDate = sys_User_ModifiedDate;
            
            NSString * sys_User_PhotosurlAttchmentGuid = [result stringForColumn:HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID];
            mSYS_User.PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid;
            
            NSString * sys_User_ThirdUserId = [result stringForColumn:HTMIABCSYS_User_THIRDUSERID];
            mSYS_User.ThirdUserId = sys_User_ThirdUserId;
            
            int sys_User_isEMIUser = [result intForColumn:HTMIABCSYS_User_ISEMIUSER];
            mSYS_User.IsEMIUser= sys_User_isEMIUser;
            
            int sys_User_IsEMPUser = [result intForColumn:HTMIABCSYS_User_ISEMPUSER];
            mSYS_User.IsEMPUser = sys_User_IsEMPUser;
            
            break;
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        if (result) {
            [result close];
        }
    }
    
    return mSYS_User;
}


// 获取用户详细信息
-(HTMIABCSYS_UserModel *)findUserIdSYS_User:(NSString *) userIds FMDatabase:(HTMIWFCFMDatabase *)db{
    __block HTMIABCSYS_UserModel * mSYS_User;
    
    if (![db open]) {
        [db open];
    }
    
    //执行查询语句
    //    NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",TABLE_NAME_SYS_User,SYS_User_USERID,userIds];
    
    NSString * strSql = [NSString stringWithFormat:@"select * from (select * from %@ where %@ = '%@' ) u left join SYS_OrgUser on u.UserId = SYS_OrgUser.UserId ",HTMIABCTABLE_NAME_SYS_User,HTMIABCSYS_User_USERID,userIds];
    HTMIWFCFMResultSet *result = [db executeQuery:strSql];
    
    @try {
        while (result.next)
        {
            mSYS_User = [HTMIABCSYS_UserModel new];
            
            //wlq add
            NSString * sys_User_DepartmentCode = [result stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
            mSYS_User.departmentCode = sys_User_DepartmentCode;
            
            NSString * sys_User_UserId = [result stringForColumn:HTMIABCSYS_User_USERID];
            mSYS_User.UserId = sys_User_UserId;
            
            NSString * sys_User_Password = [result stringForColumn:HTMIABCSYS_User_PASSWORD];
            mSYS_User.Password = sys_User_Password;
            
            NSString * sys_User_PasswordKey = [result stringForColumn:HTMIABCSYS_User_PASSWORDKEY];
            mSYS_User.PasswordKey = sys_User_PasswordKey;
            
            NSString * sys_User_PasswordIV = [result stringForColumn:HTMIABCSYS_User_PASSWORDIV];
            mSYS_User.PasswordIV = sys_User_PasswordIV;
            
            NSString * sys_User_FullName = [result stringForColumn:HTMIABCSYS_User_FULLNAME];
            mSYS_User.FullName = sys_User_FullName;
            
            //设置头字母
            mSYS_User.header = [result stringForColumn:HTMIABCSYS_User_PinYinHeader];
            
            mSYS_User.suoXie =[result stringForColumn:HTMIABCSYS_User_PinYinSuoXie];
            
            mSYS_User.pinyin = [result stringForColumn:HTMIABCSYS_User_PinYinQuanPin];
            
            int sys_User_Gender = [result intForColumn:HTMIABCSYS_User_GENDER];
            mSYS_User.Gender = sys_User_Gender;
            
            NSString * sys_User_ISDN = [result stringForColumn:HTMIABCSYS_User_ISDN];
            mSYS_User.ISDN = sys_User_ISDN;
            
            NSString * sys_User_Email = [result stringForColumn:HTMIABCSYS_User_EMAIL];
            mSYS_User.Email = sys_User_Email;
            
            int sys_User_Status = [result intForColumn:HTMIABCSYS_User_STATUS];
            mSYS_User.Status = sys_User_Status;
            
            NSString * sys_User_Telephone = [result stringForColumn:HTMIABCSYS_User_TELEPHONE];
            mSYS_User.Telephone = sys_User_Telephone;
            
            NSString * sys_User_Fax = [result stringForColumn:HTMIABCSYS_User_FAX];
            mSYS_User.Fax = sys_User_Fax;
            
            NSString * sys_User_Office = [result stringForColumn:HTMIABCSYS_User_OFFICE];
            mSYS_User.Office = sys_User_Office;
            
            NSData * sys_User_SignPics = [result dataForColumn:HTMIABCSYS_User_SIGNPICS];
            mSYS_User.SignPics = sys_User_SignPics;
            
            NSData * sys_User_Pics = [result dataForColumn:HTMIABCSYS_User_PICS];
            mSYS_User.Pics = sys_User_Pics;
            
            NSString * sys_User_PasswordLastChanged = [result stringForColumn:HTMIABCSYS_User_PASSWORDLASTCHANGED];
            mSYS_User.PasswordLastChanged = sys_User_PasswordLastChanged;
            
            NSString * sys_User_Mobile = [result stringForColumn:HTMIABCSYS_User_MOBILE];
            mSYS_User.Mobile = sys_User_Mobile;
            
            NSString * sys_User_Position = [result stringForColumn:HTMIABCSYS_User_POSITION];
            mSYS_User.Position = sys_User_Position;
            
            NSString * sys_User_Photosurl = [result stringForColumn:HTMIABCSYS_User_PHOTOSURL];
            mSYS_User.Photosurl = sys_User_Photosurl;
            
            NSString * sys_User_RePasswordDate = [result stringForColumn:HTMIABCSYS_User_REPASSWORDDATE];
            mSYS_User.RePasswordDate = sys_User_RePasswordDate;
            
            NSString * sys_User_RePasswordKey = [result stringForColumn:HTMIABCSYS_User_REPASSWORDKEY];
            mSYS_User.RePasswordKey = sys_User_RePasswordKey;
            
            NSString * sys_User_CreatedBy = [result stringForColumn:HTMIABCSYS_User_CREATEDBY];
            mSYS_User.CreatedBy = sys_User_CreatedBy;
            
            NSString * sys_User_CreatedDate = [result stringForColumn:HTMIABCSYS_User_CREATEDDATE];
            mSYS_User.CreatedDate = sys_User_CreatedDate;
            
            NSString * sys_User_ModifiedBy = [result stringForColumn:HTMIABCSYS_User_MODIFIEDBY];
            mSYS_User.ModifiedBy = sys_User_ModifiedBy;
            
            NSString * sys_User_ModifiedDate = [result stringForColumn:HTMIABCSYS_User_MODIFIEDDATE];
            
            mSYS_User.ModifiedDate = sys_User_ModifiedDate;
            
            NSString * sys_User_PhotosurlAttchmentGuid = [result stringForColumn:HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID];
            mSYS_User.PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid;
            
            NSString * sys_User_ThirdUserId = [result stringForColumn:HTMIABCSYS_User_THIRDUSERID];
            mSYS_User.ThirdUserId = sys_User_ThirdUserId;
            
            int sys_User_isEMIUser = [result intForColumn:HTMIABCSYS_User_ISEMIUSER];
            mSYS_User.IsEMIUser= sys_User_isEMIUser;
            
            int sys_User_IsEMPUser = [result intForColumn:HTMIABCSYS_User_ISEMPUSER];
            mSYS_User.IsEMPUser = sys_User_IsEMPUser;
            
            
#pragma mark --操作数据库,为了获取用户的disorder，用来排序
            HTMIABCSYS_OrgUserModel * mSYS_OrgUser; //= [self getSYSOrgUser:mSYS_User];
            
            //执行查询语句
            NSString * strSqlSYS_OrgUser = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_OrgUser,HTMIABCSYS_OrgUser_USERID,mSYS_User.UserId];
            
            HTMIWFCFMResultSet *resultSYS_OrgUser = [db executeQuery:strSqlSYS_OrgUser];
            
            @try {
                
                while (resultSYS_OrgUser.next)
                {
                    mSYS_OrgUser =[HTMIABCSYS_OrgUserModel new];
                    
                    int sys_OrgUser_Id = [resultSYS_OrgUser intForColumn:HTMIABCSYS_OrgUser_ID];
                    NSString * sys_OrgUser_userId = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_USERID];
                    NSString * sys_OrgUser_departmentCode = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                    NSString * sys_OrgUser_createdBy = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_CREATEDBY];
                    NSString * sys_OrgUser_createdDate = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_CREATEDDATE];
                    int sys_OrgUser_disOrder = [resultSYS_OrgUser intForColumn:HTMIABCSYS_OrgUser_DISORDER];
                    
                    mSYS_OrgUser.ID  = sys_OrgUser_Id;
                    mSYS_OrgUser.UserId = sys_OrgUser_userId;
                    mSYS_OrgUser.DepartmentCode = sys_OrgUser_departmentCode;
                    mSYS_OrgUser.CreatedBy = sys_OrgUser_createdBy;
                    mSYS_OrgUser.CreatedDate = sys_OrgUser_createdDate;
                    mSYS_OrgUser.DisOrder = sys_OrgUser_disOrder;
                    
                    mSYS_User.DisOrder = sys_OrgUser_disOrder;
                    
                    break;
                }
                
            } @catch (NSException *exception) {
                HTLog(@"DBError%@",exception.description);
            } @finally {
                [resultSYS_OrgUser close];
            }
            
            
            break;
        }
        
    } @catch (NSException *exception) {
        HTLog(@"DBError%@",exception.description);
    } @finally {
        if (result) {
            [result close];
        }
    }
    
    return mSYS_User;
}

/**
 *  更新当前用户信息
 *
 *  @param model 用户信息模型
 */
- (void)UpdateCurrentUserInfo:(HTMIABCSYS_UserModel *)model{
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        NSMutableString *sqlFirstPart = [NSMutableString stringWithFormat:@"Update %@ ( '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@' ) ", HTMIABCTABLE_NAME_SYS_User,HTMIABCSYS_User_PASSWORD,HTMIABCSYS_User_PASSWORDKEY,HTMIABCSYS_User_PASSWORDIV,HTMIABCSYS_User_FULLNAME,HTMIABCSYS_User_GENDER,HTMIABCSYS_User_ISDN,HTMIABCSYS_User_EMAIL,HTMIABCSYS_User_STATUS,HTMIABCSYS_User_TELEPHONE,HTMIABCSYS_User_FAX,HTMIABCSYS_User_OFFICE,HTMIABCSYS_User_SIGNPICS,HTMIABCSYS_User_PICS,HTMIABCSYS_User_USERTYPE,HTMIABCSYS_User_PASSWORDLASTCHANGED,HTMIABCSYS_User_MOBILE,HTMIABCSYS_User_POSITION,HTMIABCSYS_User_PHOTOSURL,HTMIABCSYS_User_REPASSWORDDATE,HTMIABCSYS_User_REPASSWORDKEY,HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID,HTMIABCSYS_User_THIRDUSERID,HTMIABCSYS_User_ATTRIBUTE1,HTMIABCSYS_User_ATTRIBUTE2,HTMIABCSYS_User_ATTRIBUTE3,HTMIABCSYS_User_ATTRIBUTE4,HTMIABCSYS_User_ATTRIBUTE5];
        
        NSString *sqlSecondPart = [NSString stringWithFormat:@" values ( '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@' )",model.Password,model.PasswordKey,model.PasswordIV,model.FullName,[NSString stringWithFormat:@"%d",model.Gender],model.ISDN,model.Email,[NSString stringWithFormat:@"%d",model.Status],model.Telephone,model.Fax,model.Office,[[NSString alloc] initWithData:model.SignPics  encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:model.Pics  encoding:NSUTF8StringEncoding],[NSString stringWithFormat:@"%d",model.UserType],model.PasswordLastChanged,model.Mobile,model.Position,model.Photosurl,model.RePasswordDate,model.RePasswordKey,model.PhotosurlAttchmentGuid,model.ThirdUserId,model.attribute1,model.attribute2,model.attribute3,model.attribute4,model.attribute5];
        
        [sqlFirstPart appendString:sqlSecondPart];
        
        [db executeUpdate:sqlFirstPart];
        
    }];
    
}


- (void)UpdateCurrentUserInfoByUserId:(NSString *)userId fieldNameLower:(NSString *)fieldNameLower value:(NSString *)value{
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //用户表所有字段名
        NSArray * userTableFieldArray = @[HTMIABCSYS_User_USERID,HTMIABCSYS_User_PASSWORD,HTMIABCSYS_User_PASSWORDKEY,HTMIABCSYS_User_PASSWORDIV,HTMIABCSYS_User_FULLNAME,HTMIABCSYS_User_GENDER,HTMIABCSYS_User_ISDN,HTMIABCSYS_User_EMAIL,HTMIABCSYS_User_STATUS,HTMIABCSYS_User_TELEPHONE,HTMIABCSYS_User_FAX,HTMIABCSYS_User_OFFICE,HTMIABCSYS_User_SIGNPICS,HTMIABCSYS_User_PICS,HTMIABCSYS_User_USERTYPE,HTMIABCSYS_User_PASSWORDLASTCHANGED,HTMIABCSYS_User_MOBILE,HTMIABCSYS_User_POSITION,HTMIABCSYS_User_PHOTOSURL,HTMIABCSYS_User_REPASSWORDDATE,HTMIABCSYS_User_REPASSWORDKEY,HTMIABCSYS_User_MODIFIEDDATE,HTMIABCSYS_User_CREATEDBY,HTMIABCSYS_User_CREATEDDATE,HTMIABCSYS_User_MODIFIEDBY,HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID,HTMIABCSYS_User_THIRDUSERID,HTMIABCSYS_User_ATTRIBUTE1,HTMIABCSYS_User_ATTRIBUTE2,HTMIABCSYS_User_ATTRIBUTE3,HTMIABCSYS_User_ATTRIBUTE4,HTMIABCSYS_User_ATTRIBUTE5,HTMIABCSYS_User_ISEMPUSER,HTMIABCSYS_User_ISEMIUSER,HTMIABCSYS_User_EXT1,HTMIABCSYS_User_EXT2,HTMIABCSYS_User_EXT3,HTMIABCSYS_User_EXT4,HTMIABCSYS_User_EXT5,HTMIABCSYS_User_EXT6,HTMIABCSYS_User_EXT7,HTMIABCSYS_User_EXT8,HTMIABCSYS_User_EXT9,HTMIABCSYS_User_EXT10];
        
        int index = -1;
        for (int i = 0; i < userTableFieldArray.count; i++) {
            
            NSString * str = userTableFieldArray[i];
            if ([fieldNameLower isEqualToString:[str lowercaseString]]) {
                index = i;
                break;
            }
        }
        
        NSString * strFieldName = userTableFieldArray[index];
        
        //就算区分大小写，这里面遍历之后取出表中的字段就ok拉 fieldName
        
        NSMutableString *sqlFirstPart = [NSMutableString stringWithFormat:@"UPDATE %@ set %@  =  '%@' where %@ = '%@'", HTMIABCTABLE_NAME_SYS_User,strFieldName,value,HTMIABCSYS_User_USERID,userId];
        
        
        BOOL isSuccess = [db executeUpdate:sqlFirstPart];
        
        HTLog(@"%d",isSuccess);
        
    }];
}


/**
 *  获取当前用户详细信息
 *
 *  @param userId 用户Id
 *
 *  @return 用户信息
 */
-(HTMIABCSYS_UserModel *)getCurrentUserInfo:(NSString *)userId{
    
    __block HTMIABCSYS_UserModel * mSYS_User;
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        //        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",TABLE_NAME_SYS_User,SYS_User_USERID,userId];
        
        NSString * strSql = [NSString stringWithFormat:@"select * from (select * from %@ where %@ = '%@' ) u left join SYS_OrgUser on u.UserId = SYS_OrgUser.UserId ",HTMIABCTABLE_NAME_SYS_User,HTMIABCSYS_User_USERID,userId];
        
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            while (result.next)
            {
                //创建一个字典
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                
                mSYS_User = [HTMIABCSYS_UserModel new];
                
                //wlq add
                NSString * sys_User_DepartmentCode = [result stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                mSYS_User.departmentCode = sys_User_DepartmentCode;
                
                NSString * sys_User_UserId = [result stringForColumn:HTMIABCSYS_User_USERID];
                mSYS_User.UserId = sys_User_UserId;
                sys_User_UserId = sys_User_UserId ? sys_User_UserId:@"";
                [dic setObject:sys_User_UserId forKey:[HTMIABCSYS_User_USERID lowercaseString]];
                
                NSString * sys_User_Password = [result stringForColumn:HTMIABCSYS_User_PASSWORD];
                mSYS_User.Password = sys_User_Password;
                sys_User_Password = sys_User_Password ? sys_User_Password:@"";
                [dic setObject:sys_User_Password forKey:[HTMIABCSYS_User_PASSWORD lowercaseString]];
                
                NSString * sys_User_PasswordKey = [result stringForColumn:HTMIABCSYS_User_PASSWORDKEY];
                mSYS_User.PasswordKey = sys_User_PasswordKey;
                sys_User_PasswordKey = sys_User_PasswordKey ? sys_User_PasswordKey:@"";
                [dic setObject:sys_User_PasswordKey forKey:[HTMIABCSYS_User_PASSWORDKEY lowercaseString]];
                
                NSString * sys_User_PasswordIV = [result stringForColumn:HTMIABCSYS_User_PASSWORDIV];
                mSYS_User.PasswordIV = sys_User_PasswordIV;
                sys_User_PasswordIV = sys_User_PasswordIV ? sys_User_PasswordIV:@"";
                [dic setObject:sys_User_PasswordIV forKey:[HTMIABCSYS_User_PASSWORDIV lowercaseString]];
                
                NSString * sys_User_FullName = [result stringForColumn:HTMIABCSYS_User_FULLNAME];
                mSYS_User.FullName = sys_User_FullName;
                sys_User_FullName = sys_User_FullName ? sys_User_FullName:@"";
                [dic setObject:sys_User_FullName forKey:[HTMIABCSYS_User_FULLNAME lowercaseString]];
                
                //设置头字母
                mSYS_User.header = [result stringForColumn:HTMIABCSYS_User_PinYinHeader];
                
                mSYS_User.suoXie =[result stringForColumn:HTMIABCSYS_User_PinYinSuoXie];
                
                mSYS_User.pinyin = [result stringForColumn:HTMIABCSYS_User_PinYinQuanPin];
                
                int sys_User_Gender = [result intForColumn:HTMIABCSYS_User_GENDER];
                mSYS_User.Gender = sys_User_Gender;
                [dic setObject:[NSNumber numberWithInt:sys_User_Gender] forKey:[HTMIABCSYS_User_GENDER lowercaseString]];
                
                NSString * sys_User_ISDN = [result stringForColumn:HTMIABCSYS_User_ISDN];
                mSYS_User.ISDN = sys_User_ISDN;
                sys_User_ISDN = sys_User_ISDN ? sys_User_ISDN:@"";
                [dic setObject:sys_User_ISDN forKey:[HTMIABCSYS_User_ISDN lowercaseString]];
                
                NSString * sys_User_Email = [result stringForColumn:HTMIABCSYS_User_EMAIL];
                mSYS_User.Email = sys_User_Email;
                sys_User_Email = sys_User_Email ? sys_User_Email:@"";
                [dic setObject:sys_User_Email forKey:[HTMIABCSYS_User_EMAIL lowercaseString]];
                
                int sys_User_Status = [result intForColumn:HTMIABCSYS_User_STATUS];
                mSYS_User.Status = sys_User_Status;
                [dic setObject:[NSNumber numberWithInt:sys_User_Status] forKey:[HTMIABCSYS_User_STATUS lowercaseString]];
                
                NSString * sys_User_Telephone = [result stringForColumn:HTMIABCSYS_User_TELEPHONE];
                mSYS_User.Telephone = sys_User_Telephone;
                sys_User_Telephone = sys_User_Telephone ? sys_User_Telephone:@"";
                [dic setObject:sys_User_Telephone forKey:[HTMIABCSYS_User_TELEPHONE lowercaseString]];
                
                NSString * sys_User_Fax = [result stringForColumn:HTMIABCSYS_User_FAX];
                mSYS_User.Fax = sys_User_Fax;
                sys_User_Fax = sys_User_Fax ? sys_User_Fax:@"";
                [dic setObject:sys_User_Fax forKey:[HTMIABCSYS_User_FAX lowercaseString]];
                
                NSString * sys_User_Office = [result stringForColumn:HTMIABCSYS_User_OFFICE];
                mSYS_User.Office = sys_User_Office;
                sys_User_Office = sys_User_Office ? sys_User_Office:@"";
                [dic setObject:sys_User_Office forKey:[HTMIABCSYS_User_OFFICE lowercaseString]];
                
                NSData * sys_User_SignPics = [result dataForColumn:HTMIABCSYS_User_SIGNPICS];
                mSYS_User.SignPics = sys_User_SignPics;
                sys_User_SignPics = sys_User_SignPics ? sys_User_SignPics:[NSData new];
                [dic setObject:sys_User_SignPics forKey:[HTMIABCSYS_User_SIGNPICS lowercaseString]];
                
                NSData * sys_User_Pics = [result dataForColumn:HTMIABCSYS_User_PICS];
                mSYS_User.Pics = sys_User_Pics;
                sys_User_Pics = sys_User_Pics ? sys_User_Pics:[NSData new];
                [dic setObject:sys_User_Pics forKey:[HTMIABCSYS_User_PICS lowercaseString]];
                
                NSString * sys_User_PasswordLastChanged = [result stringForColumn:HTMIABCSYS_User_PASSWORDLASTCHANGED];
                mSYS_User.PasswordLastChanged = sys_User_PasswordLastChanged;
                sys_User_PasswordLastChanged = sys_User_PasswordLastChanged ? sys_User_PasswordLastChanged:@"";
                [dic setObject:sys_User_PasswordLastChanged forKey:[HTMIABCSYS_User_PASSWORDLASTCHANGED lowercaseString]];
                
                
                NSString * sys_User_Mobile = [result stringForColumn:HTMIABCSYS_User_MOBILE];
                mSYS_User.Mobile = sys_User_Mobile;
                sys_User_Mobile = sys_User_Mobile ? sys_User_Mobile:@"";
                [dic setObject:sys_User_Mobile forKey:[HTMIABCSYS_User_MOBILE lowercaseString]];
                
                NSString * sys_User_Position = [result stringForColumn:HTMIABCSYS_User_POSITION];
                mSYS_User.Position = sys_User_Position;
                sys_User_Position = sys_User_Position ? sys_User_Position:@"";
                [dic setObject:sys_User_Position forKey:[HTMIABCSYS_User_POSITION lowercaseString]];
                
                NSString * sys_User_Photosurl = [result stringForColumn:HTMIABCSYS_User_PHOTOSURL];
                mSYS_User.Photosurl = sys_User_Photosurl;
                sys_User_Photosurl = sys_User_Photosurl ? sys_User_Photosurl:@"";
                [dic setObject:sys_User_Photosurl forKey:[HTMIABCSYS_User_PHOTOSURL lowercaseString]];
                
                NSString * sys_User_RePasswordDate = [result stringForColumn:HTMIABCSYS_User_REPASSWORDDATE];
                mSYS_User.RePasswordDate = sys_User_RePasswordDate;
                sys_User_RePasswordDate = sys_User_RePasswordDate ? sys_User_RePasswordDate:@"";
                [dic setObject:sys_User_RePasswordDate forKey:[HTMIABCSYS_User_REPASSWORDDATE lowercaseString]];
                
                NSString * sys_User_RePasswordKey = [result stringForColumn:HTMIABCSYS_User_REPASSWORDKEY];
                mSYS_User.RePasswordKey = sys_User_RePasswordKey;
                sys_User_RePasswordKey = sys_User_RePasswordKey ? sys_User_RePasswordKey:@"";
                [dic setObject:sys_User_RePasswordKey forKey:[HTMIABCSYS_User_REPASSWORDKEY lowercaseString]];
                
                NSString * sys_User_CreatedBy = [result stringForColumn:HTMIABCSYS_User_CREATEDBY];
                mSYS_User.CreatedBy = sys_User_CreatedBy;
                sys_User_CreatedBy = sys_User_CreatedBy ? sys_User_CreatedBy:@"";
                [dic setObject:sys_User_CreatedBy forKey:[HTMIABCSYS_User_CREATEDBY lowercaseString]];
                
                NSString * sys_User_CreatedDate = [result stringForColumn:HTMIABCSYS_User_CREATEDDATE];
                mSYS_User.CreatedDate = sys_User_CreatedDate;
                sys_User_CreatedDate = sys_User_CreatedDate ? sys_User_CreatedDate:@"";
                [dic setObject:sys_User_CreatedDate forKey:[HTMIABCSYS_User_CREATEDDATE lowercaseString]];
                
                NSString * sys_User_ModifiedBy = [result stringForColumn:HTMIABCSYS_User_MODIFIEDBY];
                mSYS_User.ModifiedBy = sys_User_ModifiedBy;
                sys_User_ModifiedBy = sys_User_ModifiedBy ? sys_User_ModifiedBy:@"";
                [dic setObject:sys_User_ModifiedBy forKey:[HTMIABCSYS_User_MODIFIEDBY lowercaseString]];
                
                NSString * sys_User_ModifiedDate = [result stringForColumn:HTMIABCSYS_User_MODIFIEDDATE];
                mSYS_User.ModifiedDate = sys_User_ModifiedDate;
                sys_User_ModifiedDate = sys_User_ModifiedDate ? sys_User_ModifiedDate:@"";
                [dic setObject:sys_User_ModifiedDate forKey:[HTMIABCSYS_User_MODIFIEDDATE lowercaseString]];
                
                
                NSString * sys_User_PhotosurlAttchmentGuid = [result stringForColumn:HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID];
                mSYS_User.PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid;
                sys_User_PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid ? sys_User_PhotosurlAttchmentGuid:@"";
                [dic setObject:sys_User_PhotosurlAttchmentGuid forKey:[HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID lowercaseString]];
                
                NSString * sys_User_ThirdUserId = [result stringForColumn:HTMIABCSYS_User_THIRDUSERID];
                mSYS_User.ThirdUserId = sys_User_ThirdUserId;
                sys_User_ThirdUserId = sys_User_ThirdUserId ? sys_User_ThirdUserId:@"";
                [dic setObject:sys_User_ThirdUserId forKey:[HTMIABCSYS_User_THIRDUSERID lowercaseString]];
                
                int sys_User_isEMIUser = [result intForColumn:HTMIABCSYS_User_ISEMIUSER];
                mSYS_User.IsEMIUser= sys_User_isEMIUser;
                [dic setObject:[NSNumber numberWithInt:sys_User_isEMIUser] forKey:[HTMIABCSYS_User_ISEMIUSER lowercaseString]];
                
                int sys_User_IsEMPUser = [result intForColumn:HTMIABCSYS_User_ISEMPUSER];
                mSYS_User.IsEMPUser = sys_User_IsEMPUser;
                [dic setObject:[NSNumber numberWithInt:sys_User_IsEMPUser] forKey:[HTMIABCSYS_User_ISEMPUSER lowercaseString]];
                
                mSYS_User.userInfoDic = dic;
                
                break;
            }
        } @catch (NSException *exception) {
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return mSYS_User;
}

// 获取人员列表 ArrayList<SYS_User>
- (NSArray *)getSYSUer{
    
    __block NSMutableArray * userList;
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        NSString * strSql = [NSString stringWithFormat:@"select * from (select * from %@) u left join SYS_OrgUser on u.UserId = SYS_OrgUser.UserId ",HTMIABCTABLE_NAME_SYS_User];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            userList = [NSMutableArray array];
            
            while (result.next)
            {
                
                HTMIABCSYS_UserModel * mSYS_User = [HTMIABCSYS_UserModel new];
                
                //wlq add
                NSString * sys_User_DepartmentCode = [result stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                mSYS_User.departmentCode = sys_User_DepartmentCode;
                
                NSString * sys_User_UserId = [result stringForColumn:HTMIABCSYS_User_USERID];
                mSYS_User.UserId = sys_User_UserId;
                
                NSString * sys_User_Password = [result stringForColumn:HTMIABCSYS_User_PASSWORD];
                mSYS_User.Password = sys_User_Password;
                
                NSString * sys_User_PasswordKey = [result stringForColumn:HTMIABCSYS_User_PASSWORDKEY];
                mSYS_User.PasswordKey = sys_User_PasswordKey;
                
                NSString * sys_User_PasswordIV = [result stringForColumn:HTMIABCSYS_User_PASSWORDIV];
                mSYS_User.PasswordIV = sys_User_PasswordIV;
                
                NSString * sys_User_FullName = [result stringForColumn:HTMIABCSYS_User_FULLNAME];
                mSYS_User.FullName = sys_User_FullName;
                
                
                //设置头字母
                mSYS_User.header = [result stringForColumn:HTMIABCSYS_User_PinYinHeader];
                
                
                mSYS_User.suoXie =[result stringForColumn:HTMIABCSYS_User_PinYinSuoXie];
                
                mSYS_User.pinyin = [result stringForColumn:HTMIABCSYS_User_PinYinQuanPin];
                
                int sys_User_Gender = [result intForColumn:HTMIABCSYS_User_GENDER];
                mSYS_User.Gender = sys_User_Gender;
                
                NSString * sys_User_ISDN = [result stringForColumn:HTMIABCSYS_User_ISDN];
                mSYS_User.ISDN = sys_User_ISDN;
                
                NSString * sys_User_Email = [result stringForColumn:HTMIABCSYS_User_EMAIL];
                mSYS_User.Email = sys_User_Email;
                
                int sys_User_Status = [result intForColumn:HTMIABCSYS_User_STATUS];
                mSYS_User.Status = sys_User_Status;
                
                NSString * sys_User_Telephone = [result stringForColumn:HTMIABCSYS_User_TELEPHONE];
                mSYS_User.Telephone = sys_User_Telephone;
                
                NSString * sys_User_Fax = [result stringForColumn:HTMIABCSYS_User_FAX];
                mSYS_User.Fax = sys_User_Fax;
                
                NSString * sys_User_Office = [result stringForColumn:HTMIABCSYS_User_OFFICE];
                mSYS_User.Office = sys_User_Office;
                
                NSData * sys_User_SignPics = [result dataForColumn:HTMIABCSYS_User_SIGNPICS];
                mSYS_User.SignPics = sys_User_SignPics;
                
                NSData * sys_User_Pics = [result dataForColumn:HTMIABCSYS_User_PICS];
                mSYS_User.Pics = sys_User_Pics;
                
                
                NSString * sys_User_PasswordLastChanged = [result stringForColumn:HTMIABCSYS_User_PASSWORDLASTCHANGED];
                mSYS_User.PasswordLastChanged = sys_User_PasswordLastChanged;
                
                
                NSString * sys_User_Mobile = [result stringForColumn:HTMIABCSYS_User_MOBILE];
                mSYS_User.Mobile = sys_User_Mobile;
                
                NSString * sys_User_Position = [result stringForColumn:HTMIABCSYS_User_POSITION];
                mSYS_User.Position = sys_User_Position;
                
                NSString * sys_User_Photosurl = [result stringForColumn:HTMIABCSYS_User_PHOTOSURL];
                mSYS_User.Photosurl = sys_User_Photosurl;
                
                NSString * sys_User_RePasswordDate = [result stringForColumn:HTMIABCSYS_User_REPASSWORDDATE];
                
                
                mSYS_User.RePasswordDate = sys_User_RePasswordDate;
                
                NSString * sys_User_RePasswordKey = [result stringForColumn:HTMIABCSYS_User_REPASSWORDKEY];
                mSYS_User.RePasswordKey = sys_User_RePasswordKey;
                
                NSString * sys_User_CreatedBy = [result stringForColumn:HTMIABCSYS_User_CREATEDBY];
                mSYS_User.CreatedBy = sys_User_CreatedBy;
                
                NSString * sys_User_CreatedDate = [result stringForColumn:HTMIABCSYS_User_CREATEDDATE];
                
                mSYS_User.CreatedDate = sys_User_CreatedDate;
                
                NSString * sys_User_ModifiedBy = [result stringForColumn:HTMIABCSYS_User_MODIFIEDBY];
                mSYS_User.ModifiedBy = sys_User_ModifiedBy;
                
                NSString * sys_User_ModifiedDate = [result stringForColumn:HTMIABCSYS_User_MODIFIEDDATE];
                
                mSYS_User.ModifiedDate = sys_User_ModifiedDate;
                
                NSString * sys_User_PhotosurlAttchmentGuid = [result stringForColumn:HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID];
                mSYS_User.PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid;
                
                NSString * sys_User_ThirdUserId = [result stringForColumn:HTMIABCSYS_User_THIRDUSERID];
                mSYS_User.ThirdUserId = sys_User_ThirdUserId;
                
                int sys_User_isEMIUser = [result intForColumn:HTMIABCSYS_User_ISEMIUSER];
                mSYS_User.IsEMIUser= sys_User_isEMIUser;
                
                int sys_User_IsEMPUser = [result intForColumn:HTMIABCSYS_User_ISEMPUSER];
                mSYS_User.IsEMPUser = sys_User_IsEMPUser;
                
                
                HTMIABCSYS_OrgUserModel * mSYS_OrgUser; //= [self getSYSOrgUser:mSYS_User];
                
#pragma mark --操作数据库
                //执行查询语句
                NSString * strSqlSYS_OrgUser = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_OrgUser,HTMIABCSYS_OrgUser_USERID,mSYS_User.UserId];
                
                HTMIWFCFMResultSet *resultSYS_OrgUser = [db executeQuery:strSqlSYS_OrgUser];
                
                @try {
                    
                    while (resultSYS_OrgUser.next)
                    {
                        mSYS_OrgUser =[HTMIABCSYS_OrgUserModel new];
                        
                        int sys_OrgUser_Id = [resultSYS_OrgUser intForColumn:HTMIABCSYS_OrgUser_ID];
                        NSString * sys_OrgUser_userId = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_USERID];
                        NSString * sys_OrgUser_departmentCode = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                        NSString * sys_OrgUser_createdBy = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_CREATEDBY];
                        NSString * sys_OrgUser_createdDate = [resultSYS_OrgUser stringForColumn:HTMIABCSYS_OrgUser_CREATEDDATE];
                        int sys_OrgUser_disOrder = [resultSYS_OrgUser intForColumn:HTMIABCSYS_OrgUser_DISORDER];
                        
                        mSYS_OrgUser.ID  = sys_OrgUser_Id;
                        mSYS_OrgUser.UserId = sys_OrgUser_userId;
                        mSYS_OrgUser.DepartmentCode = sys_OrgUser_departmentCode;
                        mSYS_OrgUser.CreatedBy = sys_OrgUser_createdBy;
                        mSYS_OrgUser.CreatedDate = sys_OrgUser_createdDate;
                        mSYS_OrgUser.DisOrder = sys_OrgUser_disOrder;
                        
                        
                        break;
                    }
                    
                } @catch (NSException *exception) {
                    HTLog(@"DBError%@",exception.description);
                } @finally  {
                    [resultSYS_OrgUser close];
                }
                
                if (mSYS_OrgUser && mSYS_OrgUser.DepartmentCode.length >0) {
                    
                }
                
                if (mSYS_User) {
                    
                    [userList addObject:mSYS_User];
                }
            }
            
            
            
        } @catch (NSException *exception) {
            
            
            HTLog(@"DBError%@",exception.description);
            
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    
    return userList;
}

-  (HTMIABCSYS_UserModel *)findIdUser:(NSString *)userIds{
    
    __block  HTMIABCSYS_UserModel * mSYS_User;
    
    
    //HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        //        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",TABLE_NAME_SYS_User,SYS_User_USERID,userIds];///* + " desc" */
        
        NSString * strSql = [NSString stringWithFormat:@"select * from (select * from %@ where %@ = '%@' ) u left join SYS_OrgUser on u.UserId = SYS_OrgUser.UserId ",HTMIABCTABLE_NAME_SYS_User,HTMIABCSYS_User_USERID,userIds];
        
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            while (result.next)
            {
                
                mSYS_User = [HTMIABCSYS_UserModel new];
                
                //wlq add
                NSString * sys_User_DepartmentCode = [result stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                mSYS_User.departmentCode = sys_User_DepartmentCode;
                
                NSString * sys_User_UserId = [result stringForColumn:HTMIABCSYS_User_USERID];
                mSYS_User.UserId = sys_User_UserId;
                
                NSString * sys_User_Password = [result stringForColumn:HTMIABCSYS_User_PASSWORD];
                mSYS_User.Password = sys_User_Password;
                
                NSString * sys_User_PasswordKey = [result stringForColumn:HTMIABCSYS_User_PASSWORDKEY];
                mSYS_User.PasswordKey = sys_User_PasswordKey;
                
                NSString * sys_User_PasswordIV = [result stringForColumn:HTMIABCSYS_User_PASSWORDIV];
                mSYS_User.PasswordIV = sys_User_PasswordIV;
                
                NSString * sys_User_FullName = [result stringForColumn:HTMIABCSYS_User_FULLNAME];
                mSYS_User.FullName = sys_User_FullName;
                
                
                //设置头字母
                mSYS_User.header = [result stringForColumn:HTMIABCSYS_User_PinYinHeader];
                
                
                mSYS_User.suoXie =[result stringForColumn:HTMIABCSYS_User_PinYinSuoXie];
                
                mSYS_User.pinyin = [result stringForColumn:HTMIABCSYS_User_PinYinQuanPin];
                
                int sys_User_Gender = [result intForColumn:HTMIABCSYS_User_GENDER];
                mSYS_User.Gender = sys_User_Gender;
                
                NSString * sys_User_ISDN = [result stringForColumn:HTMIABCSYS_User_ISDN];
                mSYS_User.ISDN = sys_User_ISDN;
                
                NSString * sys_User_Email = [result stringForColumn:HTMIABCSYS_User_EMAIL];
                mSYS_User.Email = sys_User_Email;
                
                int sys_User_Status = [result intForColumn:HTMIABCSYS_User_STATUS];
                mSYS_User.Status = sys_User_Status;
                
                NSString * sys_User_Telephone = [result stringForColumn:HTMIABCSYS_User_TELEPHONE];
                mSYS_User.Telephone = sys_User_Telephone;
                
                NSString * sys_User_Fax = [result stringForColumn:HTMIABCSYS_User_FAX];
                mSYS_User.Fax = sys_User_Fax;
                
                NSString * sys_User_Office = [result stringForColumn:HTMIABCSYS_User_OFFICE];
                mSYS_User.Office = sys_User_Office;
                
                //                byte[] SignPicsDatas = cursor.getBlob(cursor
                //                                                      .getColumnIndex(SIGNPICS));
                NSData * sys_User_SignPics = [result dataForColumn:HTMIABCSYS_User_SIGNPICS];
                mSYS_User.SignPics = sys_User_SignPics;
                
                NSData * sys_User_Pics = [result dataForColumn:HTMIABCSYS_User_PICS];
                mSYS_User.Pics = sys_User_Pics;
                
                NSString * sys_User_PasswordLastChanged = [result stringForColumn:HTMIABCSYS_User_PASSWORDLASTCHANGED];
                mSYS_User.PasswordLastChanged = sys_User_PasswordLastChanged;
                
                NSString * sys_User_Mobile = [result stringForColumn:HTMIABCSYS_User_MOBILE];
                mSYS_User.Mobile = sys_User_Mobile;
                
                NSString * sys_User_Position = [result stringForColumn:HTMIABCSYS_User_POSITION];
                mSYS_User.Position = sys_User_Position;
                
                NSString * sys_User_Photosurl = [result stringForColumn:HTMIABCSYS_User_PHOTOSURL];
                mSYS_User.Photosurl = sys_User_Photosurl;
                
                NSString * sys_User_RePasswordDate = [result stringForColumn:HTMIABCSYS_User_REPASSWORDDATE];
                
                mSYS_User.RePasswordDate = sys_User_RePasswordDate;
                
                NSString * sys_User_RePasswordKey = [result stringForColumn:HTMIABCSYS_User_REPASSWORDKEY];
                mSYS_User.RePasswordKey = sys_User_RePasswordKey;
                
                NSString * sys_User_CreatedBy = [result stringForColumn:HTMIABCSYS_User_CREATEDBY];
                mSYS_User.CreatedBy = sys_User_CreatedBy;
                
                NSString * sys_User_CreatedDate = [result stringForColumn:HTMIABCSYS_User_CREATEDDATE];
                
                mSYS_User.CreatedDate = sys_User_CreatedDate;
                
                NSString * sys_User_ModifiedBy = [result stringForColumn:HTMIABCSYS_User_MODIFIEDBY];
                mSYS_User.ModifiedBy = sys_User_ModifiedBy;
                
                NSString * sys_User_ModifiedDate = [result stringForColumn:HTMIABCSYS_User_MODIFIEDDATE];
                
                mSYS_User.ModifiedDate = sys_User_ModifiedDate;
                
                NSString * sys_User_PhotosurlAttchmentGuid = [result stringForColumn:HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID];
                mSYS_User.PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid;
                
                NSString * sys_User_ThirdUserId = [result stringForColumn:HTMIABCSYS_User_THIRDUSERID];
                mSYS_User.ThirdUserId = sys_User_ThirdUserId;
                
                int sys_User_isEMIUser = [result intForColumn:HTMIABCSYS_User_ISEMIUSER];
                mSYS_User.IsEMIUser= sys_User_isEMIUser;
                
                int sys_User_IsEMPUser = [result intForColumn:HTMIABCSYS_User_ISEMPUSER];
                mSYS_User.IsEMPUser = sys_User_IsEMPUser;
                
                break;
            }
            
        }@catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
            
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    
    return mSYS_User;
}

#pragma mark --用户常用联系人表相关操作

//wlq update 常用联系人应该按照用户进行检索
//List<T_UserRelationship>
/**
 *  获取常用联系人
 *
 *  @return 常用联系人数组
 */
- (NSMutableArray *)getContactList{
    
    __block NSMutableArray * userRelationMap;
    
    //HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *UserID = [userdefaults objectForKey:@"UserID"] ==  nil ? @"":[userdefaults objectForKey:@"UserID"];
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",HTMIABCTABLE_NAME_T_UserRelationship,HTMIABCT_UserRelationshipCOLUMN_USERID,UserID];///* + " desc" */
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            userRelationMap = [NSMutableArray array];
            
            while (result.next)
            {
                
                // HTMIABCT_UserRelationshipModel * mT_UserRelationship = [HTMIABCT_UserRelationshipModel new];
                
                //未被使用的字段
                //NSString * userId = [result stringForColumn:HTMIABCT_UserRelationshipCOLUMN_USERID];
                NSString * cUserId = [result stringForColumn:HTMIABCT_UserRelationshipCOLUMN_CUSERID];
                
                
                HTMIABCSYS_UserModel * mSYS_User = [self findUserIdSYS_User:cUserId FMDatabase:db];
                
                // mT_UserRelationship.CUserId = cUserId;
                //mT_UserRelationship.UserId = userId;
                
                NSString * headerName = @"";
                if (mSYS_User.FullName && mSYS_User.FullName.length > 0) {
                    headerName = mSYS_User.FullName;
                } else {
                    
                }
                
                if (mSYS_User) {
                    [userRelationMap addObject:mSYS_User];
                }
            }
        }@catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
            
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    
    return userRelationMap;
}


/**
 *  删除常用联系人
 *
 *  @param userId 用户id
 */
- (void)deleteUser:(NSString * )userId{
    
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_T_UserRelationship,HTMIABCT_UserRelationshipCOLUMN_CUSERID,userId];
        
        BOOL isSuccess = [db executeUpdate:strSql];
        
        HTLog(@"%d",isSuccess);
        //[db close];
        
    }];
}


#pragma mark --人员属性表相关操作

// 根据FieldName来进行获取人员属性
/**
 *  获取人员属性配置数据集合
 *
 *  @return 员属性配置数据集合
 */
- (NSMutableArray *)getTD_Users{
    
    
    __block NSMutableArray * array;
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@",HTMIABCTABLE_NAME_TD_User];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            array = [NSMutableArray new];
            
            while (result.next)
            {
                HTMIABCTD_UserModel * mTD_User = [HTMIABCTD_UserModel new];
                
                NSString * sys_User_FieldName = [result stringForColumn:HTMIABCTD_User_FIELDNAME];
                mTD_User.FieldName = sys_User_FieldName;
                
                NSString * sys_User_DisLabel = [result stringForColumn:HTMIABCTD_User_DISLABEL];
                mTD_User.DisLabel = sys_User_DisLabel;
                
                int sys_User_DisOrder = [result intForColumn:HTMIABCTD_User_DISORDER];
                mTD_User.DisOrder = sys_User_DisOrder;
                
                NSString * sys_User_IsActive = [result stringForColumn:HTMIABCTD_User_ISACTIVE];
                
                
                mTD_User.IsActive = [self getBoolByString:sys_User_IsActive];
                
                NSString * sys_User_EnabledEdit = [result stringForColumn:HTMIABCTD_User_ENABLEDEDIT];
                
                mTD_User.EnabledEdit = [self getBoolByString:sys_User_EnabledEdit];
                
                int sys_User_SecretFlag = [result intForColumn:HTMIABCTD_User_SECRETFLAG];
                mTD_User.SecretFlag = sys_User_SecretFlag;
                
                int sys_User_action = [result intForColumn:HTMIABCTD_User_ACTION];
                mTD_User.Action = sys_User_action;
                
                
                [array addObject:mTD_User];
                
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            if (result) {
                [result close];
            }
        }
        
    }];
    
    return array;
    
}


#pragma mark --定义某个保密字段哪些人能看

-(HTMIABCTD_UserFieldSecretModel *)getUserFieldSecret:(NSString *)userIds {
    
    
    __block HTMIABCTD_UserFieldSecretModel *mTD_UserFieldSecret;
    
    //HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_TD_UserFieldSecret,HTMIABCTD_UserFieldSecret_USERID,userIds];
        HTMIWFCFMResultSet *result = [db executeQuery:strSql];
        
        @try {
            
            while (result.next)
            {
                mTD_UserFieldSecret = [HTMIABCTD_UserFieldSecretModel new];
                
                
                NSString * td_UserFieldSecret_userId = [result stringForColumn:HTMIABCTD_UserFieldSecret_USERID];
                mTD_UserFieldSecret.UserId = td_UserFieldSecret_userId;
                
                NSString * td_UserFieldSecret_FieldName = [result stringForColumn:HTMIABCTD_UserFieldSecret_FIELDNAME];
                mTD_UserFieldSecret.FieldName = td_UserFieldSecret_FieldName;
                
                
                break;
            }
            
        } @catch (NSException *exception) {
            HTLog(@"DBError%@",exception.description);
        } @finally {
            if (result) {
                [result close];
            }
        }
        
    }];
    
    return mTD_UserFieldSecret;
}

#pragma mark --私有方法

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    if (aString) {
        //转成了可变字符串
        NSMutableString *str = [NSMutableString stringWithString:aString];
        //先转换为带声调的拼音
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
        //再转换为不带声调的拼音
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
        //转化为大写拼音
        NSString *pinYin = [str capitalizedString];
        
        if (pinYin.length > 0) {
            //获取并返回首字母
            return [pinYin substringToIndex:1];
        }
        else{
            return @"";
        }
    }else{
        return @"";
    }
}

//获取一个新的队列
- (HTMIWFCFMDatabaseQueue *)getOneNewQueue{
    NSString *filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"AddressBook.sqlite"];
    
    //创建数据库，并加入到队列中，此时已经默认打开了数据库，无须手动打开，只需要从队列中去除数据库即可
    
    HTMIWFCFMDatabaseQueue *queue = [HTMIWFCFMDatabaseQueue databaseQueueWithPath:filePath];
    return queue;
}

/**
 *  通过字符串获取BOOL值
 *
 *  @param str 字符串
 *
 *  @return 对应的BOOL值
 */
- (BOOL)getBoolByString:(NSString *)str{
    
    if ([str isEqualToString:@"True"] || [str isEqualToString:@"true"] || [str isEqualToString:@"TRUE"]|| [str isEqualToString:@"1"]) {
        return YES;
    }
    else if([str isEqualToString:@"False"] || [str isEqualToString:@"false"] || [str isEqualToString:@"FALSE"]|| [str isEqualToString:@"0"]){
        return NO;
    }
    else{
        return NO;
    }
}


/**
 *  汉字转拼音
 *
 *  @param strChinese 汉字
 *
 *  @return 拼音
 */
- (NSString *)transformToPinyin:(NSString *)strChinese
{
    NSMutableString *mutableString = [NSMutableString stringWithString:strChinese];
    
    CFStringTransform((CFMutableStringRef)mutableString,NULL,kCFStringTransformToLatin,false);
    
    mutableString = (NSMutableString*)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString * strResult =  [mutableString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return strResult;
}


/**
 *  程序启动同步通讯录
 */
- (void)syncAddressBook{
    
    //wlq add 2016/04/14
    //创建数据库以及各个表
    [[HTMIABCDBHelper sharedYMDBHelperTool] creatDatabaseAndTables];
    
    //    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AddressBookFirstStart"]){
    //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AddressBookFirstStart"];
    //    }
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserID = [userdefaults objectForKey:@"UserID"] ==  nil ? @"":[userdefaults objectForKey:@"UserID"];
    NSString *UserName = [userdefaults objectForKey:@"UserName"]==  nil ? @"":[userdefaults objectForKey:@"UserName"];
    NSString *OA_UserId = [userdefaults objectForKey:@"OA_UserId"]==  nil ? @"":[userdefaults objectForKey:@"OA_UserId"];
    NSString *OA_UserName = [userdefaults objectForKey:@"OA_UserName"]==  nil ? @"":[userdefaults objectForKey:@"OA_UserName"];
    NSString *ThirdDepartmentId = [userdefaults objectForKey:@"ThirdDepartmentId"]==  nil ? @"":[userdefaults objectForKey:@"ThirdDepartmentId"];
    NSString *ThirdDepartmentName = [userdefaults objectForKey:@"ThirdDepartmentName"]==  nil ? @"":[userdefaults objectForKey:@"ThirdDepartmentName"];
    NSString *attribute1 = [userdefaults objectForKey:@"attribute1"]==  nil ? @"":[userdefaults objectForKey:@"attribute1"];
    NSString *OA_UnitId = [userdefaults objectForKey:@"OA_UnitId"]==  nil ? @"":[userdefaults objectForKey:@"OA_UnitId"];
    NSString *MRS_UserId = [userdefaults objectForKey:@"MRS_UserId"]==  nil ? @"":[userdefaults objectForKey:@"MRS_UserId"];
    
    //比以前多的
    NSString *IsEMIUser = [userdefaults objectForKey:@"IsEMIUser"]==  nil ? @"":[userdefaults objectForKey:@"IsEMIUser"];
    
    NSString *NetworkName = [userdefaults objectForKey:@"NetworkName"]==  nil ? @"":[userdefaults objectForKey:@"NetworkName"];
    
    NSString *path = [NSString stringWithFormat:@"%@:%@/%@/api/GetMobileData/GetSyncData",EMUrl,EMPORT,EMapiDir];
    NSMutableDictionary *myDic1 = [NSMutableDictionary dictionary];
    
    
    [myDic1 setObject:UserID forKey:@"UserID"];
    [myDic1 setObject:UserName forKey:@"UserName"];
    [myDic1 setObject:OA_UserId forKey:@"OA_UserId"];
    [myDic1 setObject:OA_UnitId forKey:@"OA_UnitId"];
    [myDic1 setObject:OA_UserName forKey:@"OA_UserName"];
    [myDic1 setObject:MRS_UserId forKey:@"MRS_UserId"];
    [myDic1 setObject:ThirdDepartmentId forKey:@"ThirdDepartmentId"];
    [myDic1 setObject:ThirdDepartmentName forKey:@"ThirdDepartmentName"];
    [myDic1 setObject:attribute1 forKey:@"attribute1"];
    
    [myDic1 setObject:IsEMIUser forKey:@"IsEMIUser"];
    [myDic1 setObject:NetworkName forKey:@"NetworkName"];
    
    NSMutableDictionary *myDic2 = [NSMutableDictionary dictionary];
    [myDic2 setObject:myDic1 forKey:@"context"];
    
    NSString * synchronizationeventStamp = [HTMIABCUserdefault defaultLoadAddressBookSynchronizationeventStamp];
    if (!synchronizationeventStamp) {
        synchronizationeventStamp = @"";
    }
    [myDic2 setObject:synchronizationeventStamp forKey:@"LastSyncTime"];
    
    HTLog(@"通讯录同步时间戳%@",synchronizationeventStamp);
    HTLog(@"通讯录同步path%@",path);
    HTLog(@"通讯录同步参数%@",myDic2);
    self.isSyncDBing = YES;
    [HTMIWFCApi syncAddressBook:path andParams:myDic2 succeed:^(id resultDic) {
        //返回来的直接就是json转好的对象
        
        HTLog(@"%@",resultDic);
        
        if (resultDic && [resultDic isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary  * dicMessage = [resultDic objectForKey:@"Message"];
            
            if (dicMessage && [dicMessage isKindOfClass:[NSDictionary class]]) {
                NSString * statusCode = [NSString stringWithFormat:@"%@",[dicMessage objectForKey:@"StatusCode"]];
                
                if ([statusCode isEqualToString:@"200"]) {
                    
                    NSString * strStatus = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"Status"]];
                    if ([strStatus isEqualToString:@"1"]) {
                        NSString * strResult =  [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"Result"]];
                        
                        [self downLoadAndUnZip:strResult];
                    }
                    else{
                        
                        [HTMIWFCSVProgressHUD showErrorWithStatus:@"组织结构请求失败"];
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        [HTMIWFCApi showErrorStringWithError:@"通讯录同步失败" error:error onView:nil];
        self.isSyncDBing = NO;
    }];
}

- (void)downLoadAndUnZip:(NSString *)filePath{
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES) firstObject];
    
    NSString *fileName = [filePath lastPathComponent];
    
    //文件保存路径
    NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/AddressBookSyncDir/%@",documentDirectory,fileName];//%@/.zipself.ByteLength//.zip自身就带的%d
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    //BOOL isHave = [fileManager fileExistsAtPath:filepath];
    
    NSString *documentPath = [NSString stringWithFormat:@"%@/AddressBookSyncDir",documentDirectory];
    
    //创建存储目录,可以提前判断该路径是否存在下载文件！
    [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    //删除文件夹下的所有文件
    //Check files
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:documentPath];
    NSString *myfileName;
    while (myfileName= [dirEnum nextObject]) {
        NSError * error = [NSError new];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",documentPath,myfileName] error:&error];
        //        HTLog(@"%@",error);
    }
    
    //创建请求,下载文件
    NSString *urlStr = [NSString stringWithFormat:@"%@",filePath];
    HTLog(@"下载路径：%@",urlStr);
    NSURL *url = [[NSURL alloc]initWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [HTMIWFCApi downloadFile:request url:url documentsDirectoryPath:documentsDirectoryPath succeed:^(id operation) {
        
        // 已完成下载
        HTLog(@"下载成功");
        
        //下载之后并且开始解压  有密码传入密码
        HTMIWFCZipArchive *htmiWFCZipArchive =  [[HTMIWFCZipArchive alloc]init];
        if ([htmiWFCZipArchive UnzipOpenFile:documentsDirectoryPath Password:@"password"]) {
            if ([htmiWFCZipArchive UnzipFileTo:documentPath overWrite:YES]) {
                
                HTLog(@"解压完成");
                
                //删除ZIP文件
                
                NSFileManager * fileManager = [NSFileManager defaultManager];
                //                if ([fileManager fileExistsAtPath:documentsDirectoryPath]) {//下次同步统一处理了
                //                    //如果test.txt文件存在则删除
                //                    [fileManager removeItemAtPath:documentsDirectoryPath error:nil];
                //                }
                //
                //获取文件路径
                //                NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                //                                                                              NSUserDomainMask,
                //                                                                              YES) firstObject];
                NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/%@",documentPath,[filePath lastPathComponent]];
                
                NSArray *arrPath = [documentsDirectoryPath componentsSeparatedByString:@"."];
                NSString * strTemp = arrPath[0];
                NSString *strFilePath = [NSString stringWithFormat:@"%@%@",strTemp,@".txt"];
                
                __weak typeof(self) weakSelf = self;
                
                //处理文件
                if([fileManager fileExistsAtPath:strFilePath]) {
                    
                    self.isSyncDBing = YES;
                    
                    [HTMIABCUserdefault defaultSaveAddressBookPath:strFilePath];//下次同步统一处理了
                    
                    dispatch_queue_t q1 = dispatch_queue_create("com.htmi.syncDB", DISPATCH_QUEUE_SERIAL);
                    
                    
                    dispatch_async(q1, ^{
                        [[HTMIABCDBHelper sharedYMDBHelperTool] syncDB];
                    });
                    
                    dispatch_async(q1, ^{
                        
                        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //保存时间戳
                        [HTMIABCUserdefault defaultSaveAddressBookSynchronizationeventStamp:weakSelf.synchronizationeventStamp];
                        
                        
                        HTMIABCAddressBookManager * addressBookSingletonClass = [HTMIABCAddressBookManager sharedInstance];
                        
                        //缓存用户属性配置表信息
                        addressBookSingletonClass.tdUserModelArray = [[HTMIABCDBHelper sharedYMDBHelperTool] getTD_Users];
                        
                        
                        
                        //                        });
                    });
                    
                    dispatch_async(q1, ^{
                        
                        weakSelf.isSyncDBing = NO;
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_Sync_Done" object:@"db_sync_done" userInfo:nil];
                        
                        HTLogDetail(@"SyncDone:%@",@"AddressBookSyncDone");
                        /*
                         // 合并汇总结果
                         dispatch_group_t dispatchGroup = dispatch_group_create();
                         
                         dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                         
                         // 并行执行的线程一
                         HTMIABCSYS_DepartmentModel * model = [HTMIABCSYS_DepartmentModel new];
                         //缓存所有的部门以及子部门
                         //AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
                         HTMIAddressBookSingletonClass * addressBookSingletonClass = [HTMIAddressBookSingletonClass sharedInstance];
                         HTLog(@"使用异步函数执行主队列中的任务1--%@",[NSThread currentThread]);
                         if (addressBookSingletonClass.departmentList.SYS_DepartmentList.count <= 0) {
                         
                         addressBookSingletonClass.departmentList =  [[HTMIABCDBHelper sharedYMDBHelperTool] getDepartments:@"100" sys_DepartmentModel:model];
                         
                         }
                         });
                         
                         dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                         HTLog(@"使用异步函数执行主队列中的任务1--%@",[NSThread currentThread]);
                         // 并行执行的线程二
                         //同步 appDelegate.userList
                         //将用户缓存到内存中
                         HTMIAddressBookSingletonClass * addressBookSingletonClass = [HTMIAddressBookSingletonClass sharedInstance];
                         
                         if (addressBookSingletonClass.userList.count <= 0) {
                         [[HTMIABCDBHelper sharedYMDBHelperTool] getSYSUer];
                         }
                         });
                         
                         dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
                         
                         //通讯录同步完成
                         weakSelf.isSyncDBing = NO;
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"HTMI_AddressBook_Sync_Done" object:@"db_sync_done" userInfo:nil];
                         });
                         
                         */
                    });
                }
            }
        }
    } failure:^(NSError *error) {
        [HTMIWFCApi showErrorStringWithError:@"通讯录同步文件下载失败" error:error onView:nil];
         self.isSyncDBing = NO;
    }];
}

//wlq add
/**
 *  检索部门下的用户
 *
 *  @param strSearchString   检索字符串
 *  @param strDepartmentCode 部门code
 *
 *  @return 用户集合
 */
- (NSMutableArray *)searchUsersBySearchString:(NSString *)strSearchString inDepartment:(NSString *)strDepartmentCode{
    
    __block NSMutableArray *userArray;
    
    [self.queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        NSString * suoxie = @"";
        NSMutableString *sb = [NSMutableString new];
        for(int i = 0 ; i < strSearchString.length; i++){
            suoxie = [self firstCharactor:[strSearchString substringWithRange:NSMakeRange(i,1)]];
            [sb appendString:suoxie];
        }
        
        //执行查询语句
        //NSString * strSql = [NSString stringWithFormat:@"select * from %@",TABLE_NAME_SYS_User];
        NSMutableString *strSqlString = [NSMutableString new];
        if (strDepartmentCode && strDepartmentCode.length >0) {
            
            if ([strSearchString isChinese]) {
                //在部门下检索
                [strSqlString appendString:@"select * from (select * from  (select * from Sys_orguser where DepartmentCode like '"];
                [strSqlString appendString:strDepartmentCode];
                [strSqlString appendString:@"%') u left join SYS_User on u.UserId = SYS_User.UserId) where FullName like '%"];
                [strSqlString appendString:strSearchString];
                
                [strSqlString appendString:@"%' or Telephone like '%"];
                [strSqlString appendString:strSearchString];
                
                [strSqlString appendString:@"%' or Mobile like '%"];
                [strSqlString appendString:strSearchString];
                [strSqlString appendString:@"%'"];
            }
            else{
                //在部门下检索
                [strSqlString appendString:@"select * from (select * from  (select * from Sys_orguser where DepartmentCode like '"];
                [strSqlString appendString:strDepartmentCode];
                [strSqlString appendString:@"%') u left join SYS_User on u.UserId = SYS_User.UserId) where PinYinSuoXie like '%"];
                [strSqlString appendString:sb];
                
                [strSqlString appendString:@"%' or PinYinQuanPin like '%"];
                NSString * strPinyin = [self transformToPinyin:strSearchString];
                [strSqlString appendString:strPinyin];
                [strSqlString appendString:@"%' or Telephone like '%"];
                [strSqlString appendString:strSearchString];
                
                [strSqlString appendString:@"%' or Mobile like '%"];
                [strSqlString appendString:strSearchString];
                [strSqlString appendString:@"%'"];
            }
            
        }
        else{
            if ([strSearchString isChinese]) {
                [strSqlString appendString:@"select * from SYS_User where FullName like '%"];
                [strSqlString appendString:strSearchString];
                
                [strSqlString appendString:@"%' or Telephone like '%"];
                [strSqlString appendString:strSearchString];
                
                [strSqlString appendString:@"%' or Mobile like '%"];
                [strSqlString appendString:strSearchString];
                [strSqlString appendString:@"%'"];
            }
            else{
                
                [strSqlString appendString:@"select * from SYS_User where PinYinSuoXie like '%"];
                [strSqlString appendString:sb];
                [strSqlString appendString:@"%' or PinYinQuanPin like '%"];
                NSString * strPinyin = [self transformToPinyin:strSearchString];
                [strSqlString appendString:strPinyin];
                [strSqlString appendString:@"%' or Telephone like '%"];
                [strSqlString appendString:strSearchString];
                
                [strSqlString appendString:@"%' or Mobile like '%"];
                [strSqlString appendString:strSearchString];
                [strSqlString appendString:@"%'"];
            }
        }
        
        HTMIWFCFMResultSet *result = [db executeQuery:strSqlString];
        
        
        @try {
            userArray = [NSMutableArray array];
            while (result.next)
            {
                HTMIABCSYS_UserModel * mSYS_User = [HTMIABCSYS_UserModel new];
                
                if (strDepartmentCode && strDepartmentCode.length >0) {
                    //wlq add
                    NSString * sys_User_DepartmentCode = [result stringForColumn:HTMIABCSYS_OrgUser_DEPARTMENTCODE];
                    mSYS_User.departmentCode = sys_User_DepartmentCode;
                }
                
                NSString * sys_User_UserId = [result stringForColumn:HTMIABCSYS_User_USERID];
                mSYS_User.UserId = sys_User_UserId;
                
                NSString * sys_User_Password = [result stringForColumn:HTMIABCSYS_User_PASSWORD];
                mSYS_User.Password = sys_User_Password;
                
                NSString * sys_User_PasswordKey = [result stringForColumn:HTMIABCSYS_User_PASSWORDKEY];
                mSYS_User.PasswordKey = sys_User_PasswordKey;
                
                NSString * sys_User_PasswordIV = [result stringForColumn:HTMIABCSYS_User_PASSWORDIV];
                mSYS_User.PasswordIV = sys_User_PasswordIV;
                
                NSString * sys_User_FullName = [result stringForColumn:HTMIABCSYS_User_FULLNAME];
                mSYS_User.FullName = sys_User_FullName;
                
                
                //设置头字母
                mSYS_User.header = [result stringForColumn:HTMIABCSYS_User_PinYinHeader];
                
                
                mSYS_User.suoXie =[result stringForColumn:HTMIABCSYS_User_PinYinSuoXie];
                
                mSYS_User.pinyin = [result stringForColumn:HTMIABCSYS_User_PinYinQuanPin];
                
                int sys_User_Gender = [result intForColumn:HTMIABCSYS_User_GENDER];
                mSYS_User.Gender = sys_User_Gender;
                
                NSString * sys_User_ISDN = [result stringForColumn:HTMIABCSYS_User_ISDN];
                mSYS_User.ISDN = sys_User_ISDN;
                
                NSString * sys_User_Email = [result stringForColumn:HTMIABCSYS_User_EMAIL];
                mSYS_User.Email = sys_User_Email;
                
                int sys_User_Status = [result intForColumn:HTMIABCSYS_User_STATUS];
                mSYS_User.Status = sys_User_Status;
                
                NSString * sys_User_Telephone = [result stringForColumn:HTMIABCSYS_User_TELEPHONE];
                mSYS_User.Telephone = sys_User_Telephone;
                
                NSString * sys_User_Fax = [result stringForColumn:HTMIABCSYS_User_FAX];
                mSYS_User.Fax = sys_User_Fax;
                
                NSString * sys_User_Office = [result stringForColumn:HTMIABCSYS_User_OFFICE];
                mSYS_User.Office = sys_User_Office;
                
                //                byte[] SignPicsDatas = cursor.getBlob(cursor
                //                                                      .getColumnIndex(SIGNPICS));
                NSData * sys_User_SignPics = [result dataForColumn:HTMIABCSYS_User_SIGNPICS];
                mSYS_User.SignPics = sys_User_SignPics;
                
                NSData * sys_User_Pics = [result dataForColumn:HTMIABCSYS_User_PICS];
                mSYS_User.Pics = sys_User_Pics;
                
                NSString * sys_User_PasswordLastChanged = [result stringForColumn:HTMIABCSYS_User_PASSWORDLASTCHANGED];
                mSYS_User.PasswordLastChanged = sys_User_PasswordLastChanged;
                
                NSString * sys_User_Mobile = [result stringForColumn:HTMIABCSYS_User_MOBILE];
                mSYS_User.Mobile = sys_User_Mobile;
                
                NSString * sys_User_Position = [result stringForColumn:HTMIABCSYS_User_POSITION];
                mSYS_User.Position = sys_User_Position;
                
                NSString * sys_User_Photosurl = [result stringForColumn:HTMIABCSYS_User_PHOTOSURL];
                mSYS_User.Photosurl = sys_User_Photosurl;
                
                NSString * sys_User_RePasswordDate = [result stringForColumn:HTMIABCSYS_User_REPASSWORDDATE];
                
                
                mSYS_User.RePasswordDate = sys_User_RePasswordDate;
                
                NSString * sys_User_RePasswordKey = [result stringForColumn:HTMIABCSYS_User_REPASSWORDKEY];
                mSYS_User.RePasswordKey = sys_User_RePasswordKey;
                
                NSString * sys_User_CreatedBy = [result stringForColumn:HTMIABCSYS_User_CREATEDBY];
                mSYS_User.CreatedBy = sys_User_CreatedBy;
                
                NSString * sys_User_CreatedDate = [result stringForColumn:HTMIABCSYS_User_CREATEDDATE];
                
                mSYS_User.CreatedDate = sys_User_CreatedDate;
                
                NSString * sys_User_ModifiedBy = [result stringForColumn:HTMIABCSYS_User_MODIFIEDBY];
                mSYS_User.ModifiedBy = sys_User_ModifiedBy;
                
                NSString * sys_User_ModifiedDate = [result stringForColumn:HTMIABCSYS_User_MODIFIEDDATE];
                
                mSYS_User.ModifiedDate = sys_User_ModifiedDate;
                
                NSString * sys_User_PhotosurlAttchmentGuid = [result stringForColumn:HTMIABCSYS_User_PHOTOSURLATTCHMENTGUID];
                mSYS_User.PhotosurlAttchmentGuid = sys_User_PhotosurlAttchmentGuid;
                
                NSString * sys_User_ThirdUserId = [result stringForColumn:HTMIABCSYS_User_THIRDUSERID];
                mSYS_User.ThirdUserId = sys_User_ThirdUserId;
                
                int sys_User_isEMIUser = [result intForColumn:HTMIABCSYS_User_ISEMIUSER];
                mSYS_User.IsEMIUser= sys_User_isEMIUser;
                
                int sys_User_IsEMPUser = [result intForColumn:HTMIABCSYS_User_ISEMPUSER];
                mSYS_User.IsEMPUser = sys_User_IsEMPUser;
                
                [userArray addObject:mSYS_User];
            }
            
        }@catch (NSException *exception) {
            
            
            HTLog(@"DBError%@",exception.description);
            
        } @finally {
            if (result) {
                [result close];
            }
        }
    }];
    
    return userArray;
}

- (NSString *)getUserCountByDepartemntCode:(NSString *)departemntCode{
    
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    __block NSString * countString = @"0";
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //select count(*) from LoginUser
        //执行查询语句
        NSMutableString *strSqlString = [NSMutableString new];
        [strSqlString appendString:@"select count(*) from (select * from  (select * from SYS_OrgUser where DepartmentCode like '"];
        [strSqlString appendString:departemntCode];
        [strSqlString appendString:@"%') u left join SYS_User on u.UserId = SYS_User.UserId)"];
        NSUInteger count  = 0 ;
        count = [db  intForQuery:strSqlString];
        
        @try {
            
            countString = [NSString stringWithFormat:@"%lu",(unsigned long)count];
            
        } @catch (NSException *exception) {
            
            HTLog(@"DBError%@",exception.description);
        } @finally {
            
        }
    }];
    
    
    return countString;
}


- (BOOL)existDepartmentInDepartment:(NSString *)departmentCode{
    
    __block BOOL exist = NO;
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        
        if (![db open]) {
            [db open];
        }
        
        //执行查询语句
        NSString * strSql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = '%@' ",HTMIABCTABLE_NAME_SYS_Department,HTMIABCPARENTDEPARTMENT,departmentCode];
        NSUInteger count  = 0 ;
        count = [db  intForQuery:strSql];
        
        if (count > 0) {
            exist = YES;
        }
    }];
    
    return exist;
}

- (BOOL)existUserInDepartment:(NSString *)departmentCode{
    
    HTMIWFCFMDatabaseQueue * queue = [self getOneNewQueue];
    
    __block BOOL exist = NO;
    
    [queue inDatabase:^(HTMIWFCFMDatabase *db) {
        
        if (![db open]) {
            [db open];
        }
        
        //select count(*) from LoginUser
        //执行查询语句
        NSMutableString *strSqlString = [NSMutableString new];
        [strSqlString appendString:@"select count(*) from (select * from  (select * from SYS_OrgUser where DepartmentCode like '"];
        [strSqlString appendString:departmentCode];
        [strSqlString appendString:@"%') u left join SYS_User on u.UserId = SYS_User.UserId)"];
        
        NSUInteger count = [db  intForQuery:strSqlString];
        
        
        
        if (count > 0) {
            exist = YES;
        }
    }];
    
    return exist;
}

- (NSString *)synchronizationeventStamp{
    if (!_synchronizationeventStamp) {
        _synchronizationeventStamp = @"";
    }
    return _synchronizationeventStamp;
}


static id _instance = nil;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedYMDBHelperTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}


@end
