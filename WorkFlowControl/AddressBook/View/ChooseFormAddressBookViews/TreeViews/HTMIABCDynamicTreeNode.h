
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "HTMIABCChooseType.h"

@interface HTMIABCDynamicTreeNode : NSObject
/** 坐标x */
@property (nonatomic, assign) CGFloat originX;
/** 名称 */
@property (nonatomic, copy) NSString *name;
/** 父节点的id */
@property (nonatomic, copy) NSString *fatherNodeId;
/** 当前节点id */
@property (nonatomic, copy) NSString  *nodeId;
/** 是否是部门 */
@property (nonatomic, assign) BOOL isDepartment;
/** 是否展开的 */
@property (nonatomic, assign) BOOL isOpen;
/** 节点详细模型，可能是userModel 可能是departmentModel */
@property (nonatomic, strong) NSObject *model;
/** 子节点用户个数 */
@property (nonatomic, copy) NSString *userCount;
/** 子节点已经选择的用户个数 */
@property (nonatomic, copy) NSString *selectedUserCount;
/** 存放父节点 */
@property (nonatomic, strong) HTMIABCDynamicTreeNode *praentTreeNode;

/**
 *  选择类型
 */
@property (nonatomic,assign)ChooseType chooseType;

@property (nonatomic, assign) BOOL isCheck;

/**
 *  检查是否根节点
 *
 *  @return 是否为根节点
 */
- (BOOL)isRoot;

@end
