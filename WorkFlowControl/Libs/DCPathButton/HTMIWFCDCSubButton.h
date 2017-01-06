//
//  HTMIWFCDCSubButton.h
//  HTMIWFCDCPathButton
//
//  Created by Paul on 4/19/13.
//  Copyright (c) 2013 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTMIWFCDCSubButton;
@protocol HTMIWFCDCSubButtonDelegate <NSObject>
- (void)subButtonPress:(HTMIWFCDCSubButton*)button;
@end

@interface HTMIWFCDCSubButton : UIButton

@property (nonatomic, weak) id<HTMIWFCDCSubButtonDelegate> delegate;

@end
