//
//  HTMIWFCOAMatterFormTableViewController+EditType.h
//  MXClient
//
//  Created by 赵志国 on 16/6/20.
//  Copyright © 2016年 MXClient. All rights reserved.
//

#import "HTMIWFCOAMatterFormTableViewController.h"

#import "HTMIWFCTxtViewProtocol.h"



@interface HTMIWFCOAMatterFormTableViewController (EditType)<HTMIWFCTxtViewProtocol>



- (CGFloat)mytableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

- (void)removeChoiceView;
@end
