

#import "HTMIABCReOrderTableView.h"
#import "HTMIABCSelectedFromAddressBookTableViewCell.h"

@interface HTMIABCReOrderTableView()

@end

@implementation HTMIABCReOrderTableView

- (instancetype)initWithFrame:(CGRect)frame withObjects:(NSMutableArray *)objects
{
    return [self initWithFrame:frame withObjects:objects canReorder:NO];
}

- (instancetype)initWithFrame:(CGRect)frame withObjects:(NSMutableArray *)objects canReorder:(BOOL)reOrder
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.objects = [NSMutableArray arrayWithArray:objects];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI
{
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.bounces = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
}

#pragma mark - setter
- (void) setObjects:(NSMutableArray *)objects
{
    _objects = objects;
}


@end
