//
//  HTMIWFCOADoneTableViewCell.h
//  MXClient
//
//  Created by 朱冲冲、赵志国 on 15/6/9.
//  Copyright (c) 2015年 MXClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMIWFCOADoneEntity.h"
#import "HTMIWFCEGOImageButton.h"
@interface HTMIWFCOADoneTableViewCell : UITableViewCell

- (void)updateDoneCellContentValue:(HTMIWFCOADoneEntity *)done;

@end
