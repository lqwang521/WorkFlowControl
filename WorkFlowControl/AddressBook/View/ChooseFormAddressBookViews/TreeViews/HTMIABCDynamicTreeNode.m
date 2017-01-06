

#import "HTMIABCDynamicTreeNode.h"

@implementation HTMIABCDynamicTreeNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        //注册通知，选中状态改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkStateChange:) name:@"HTMI_AddressBook_CheckStateChange" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkStateChangeForUpdateiIsCheck:) name:@"HTMI_AddressBook_CheckStateChangeForUpdateIsCheck" object:nil];
    }
    return self;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isRoot
{
    return self.fatherNodeId == nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@",self.name];
}

- (void)checkStateChangeForUpdateiIsCheck:(NSNotification *)note{
    
    NSDictionary * checkStateDic = (NSDictionary *)note.userInfo;
    NSString *checkStateString = checkStateDic[@"checkState"];
    NSString *nodeIdString = checkStateDic[@"nodeId"];
    
    if ([self.nodeId isEqualToString:nodeIdString]) {
       self.isCheck = [checkStateString boolValue];
    }
}

/**
 *  处理选中状态改变事件
 *
 *  @param note 通知对象
 */
- (void)checkStateChange:(NSNotification *)note{
    
    if (self.isDepartment == YES) {
        
        //判断是不是他的父部门
        if (self.selectedUserCount) {

            NSDictionary * checkStateDic = (NSDictionary *)note.userInfo;
            NSString *checkStateString = checkStateDic[@"checkState"];
            NSString *departmentCodeString = checkStateDic[@"departmentCode"];
            
            if ([checkStateString isEqualToString:@"-1"]) {//清除全部
                self.selectedUserCount = @"0";
            }
            else{
                //可能是父部门的
                if (departmentCodeString.length >= self.nodeId.length) {
                    
                    NSString * strCut = [departmentCodeString substringToIndex:self.nodeId.length];
                    
                    //一定是父部门
                    if ([strCut isEqualToString:self.nodeId]) {
                        
                        int currentCount = [self.selectedUserCount intValue];
                        
                        if ([checkStateString isEqualToString:@"1"]) {
                            //加
                            self.selectedUserCount = [NSString stringWithFormat:@"%d",currentCount + 1];
                        }
                        else{
                            //减
                            self.selectedUserCount = [NSString stringWithFormat:@"%d",currentCount - 1];
                        }
                    }
                }
            }
        }
    }
}

- (void)setIsCheck:(BOOL)isCheck{
    
    _isCheck = isCheck;
    
    
}

//默认为0
- (NSString *)selectedUserCount{
    if (!_selectedUserCount) {
        _selectedUserCount = @"0";
    }
    return _selectedUserCount;
}

@end
