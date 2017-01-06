
#import <UIKit/UIKit.h>

@protocol HTMIABCReOrderTableViewDelegate <NSObject>

@optional

- (void)updateDataSource:(NSMutableArray *)dataArrays;
- (void)mergeRowsInSection:(NSInteger)section splitRowIdentifier:(NSString *)identifier;

@end

@interface HTMIABCReOrderTableView : UIView

@property (nonatomic,strong) NSMutableArray *objects;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,weak) id <HTMIABCReOrderTableViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withObjects:(NSMutableArray *)objects;

- (instancetype)initWithFrame:(CGRect)frame withObjects:(NSMutableArray *)objects canReorder:(BOOL)reOrder;


@end
