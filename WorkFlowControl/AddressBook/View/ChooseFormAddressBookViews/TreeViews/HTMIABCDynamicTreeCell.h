

#import <UIKit/UIKit.h>
#import "HTMIABCDynamicTreeNode.h"
#import "HTMIABCChooseType.h"
//@class <#name#>

typedef enum {
    CellType_Department = 1, //目录
    CellType_Employee   //雇员
}CellType;



@interface HTMIABCDynamicTreeCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *plusImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIView *underLine;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

typedef void (^CheckBlock)(HTMIABCDynamicTreeCell *returnCell);

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic,strong)HTMIABCDynamicTreeNode * htmiDynamicTreeNode;
/**
 *  选中状态改变回调方法
 */
@property (nonatomic,copy)CheckBlock checkBlock;

- (void)fillWithNode:(HTMIABCDynamicTreeNode*)node;

@end
