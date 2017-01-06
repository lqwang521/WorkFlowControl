

#import <UIKit/UIKit.h>
@class HTMIABCDynamicTreeNode;

@class HTMIABCSYS_UserModel;
@class HTMIABCSYS_DepartmentModel;

@interface HTMIABCSelectedFromAddressBookTableViewCell : UITableViewCell

typedef void (^DeleteBlock)(HTMIABCSelectedFromAddressBookTableViewCell *returnCell);

@property (nonatomic,copy)DeleteBlock deleteBlock;

@property (nonatomic,strong)HTMIABCDynamicTreeNode *htmiDynamicTreeNode;

@property (nonatomic,strong)HTMIABCSYS_UserModel * sys_UserModel;

@property (nonatomic,strong)HTMIABCSYS_DepartmentModel * sys_DepartmentModel;

/**
 *  设置分割线隐藏
 *
 *  @param hiden 是否需要隐藏
 */
- (void)setSpliteViewHiden:(BOOL)hiden;

@end
