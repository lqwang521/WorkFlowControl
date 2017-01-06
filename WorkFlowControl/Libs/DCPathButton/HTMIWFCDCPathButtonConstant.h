//
//  HTMIWFCDCPathButtonConstant.h
//  HTMIWFCDCPathButton
//
//  Created by Paul on 4/19/13.
//  Copyright (c) 2013 Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHTMIWFCDCPathButtonParentView self.parentView
#define kHTMIWFCDCPathButtonCurrentFrameWidth kHTMIWFCDCPathButtonParentView.frame.size.width
#define kHTMIWFCDCPathButtonCurrentFrameHeight kHTMIWFCDCPathButtonParentView.frame.size.height

#define kDCCovertAngelToRadian(x) ((x)*M_PI)/180

@interface HTMIWFCDCPathButtonConstant : NSObject

@end
