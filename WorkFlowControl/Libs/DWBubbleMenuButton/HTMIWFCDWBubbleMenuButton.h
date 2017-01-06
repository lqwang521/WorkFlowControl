//
//  HTMIWFCDWBubbleMenuButton.h
//  HTMIWFCDWBubbleMenuButtonExample
//
//  Created by Derrick Walker on 10/8/14.
//  Copyright (c) 2014 Derrick Walker. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ExpansionDirection) {
    DirectionLeft = 0,
    DirectionRight,
    DirectionUp,
    DirectionDown
};


@class HTMIWFCDWBubbleMenuButton;

@protocol DWBubbleMenuViewDelegate <NSObject>

-(void)changeViewImage:(NSString *)name;

@optional
- (void)bubbleMenuButtonWillExpand:(HTMIWFCDWBubbleMenuButton *)expandableView;
- (void)bubbleMenuButtonDidExpand:(HTMIWFCDWBubbleMenuButton *)expandableView;
- (void)bubbleMenuButtonWillCollapse:(HTMIWFCDWBubbleMenuButton *)expandableView;
- (void)bubbleMenuButtonDidCollapse:(HTMIWFCDWBubbleMenuButton *)expandableView;

@end

@interface HTMIWFCDWBubbleMenuButton : UIView <UIGestureRecognizerDelegate>
@property(nonatomic,assign)BOOL isOn;
@property (nonatomic, weak, readonly) NSArray *buttons;
@property (nonatomic, strong) UIView *homeButtonView;
@property (nonatomic, readonly) BOOL isCollapsed;
@property (nonatomic, weak) id <DWBubbleMenuViewDelegate> delegate;

@property(nonatomic,assign)CGRect newFrame;

// The direction in which the menu expands
@property (nonatomic) enum ExpansionDirection direction;

// Indicates whether the home button will animate it's touch highlighting, this is enabled by default
@property (nonatomic) BOOL animatedHighlighting;

// Indicates whether menu should collapse after a button selection, this is enabled by default
@property (nonatomic) BOOL collapseAfterSelection;

// The duration of the expand/collapse animation
@property (nonatomic) float animationDuration;

// The default alpha of the homeButtonView when not tapped
@property (nonatomic) float standbyAlpha;

// The highlighted alpha of the homeButtonView when tapped
@property (nonatomic) float highlightAlpha;

// The spacing between menu buttons when expanded
@property (nonatomic) float buttonSpacing;

// Initializers
- (id)initWithFrame:(CGRect)frame expansionDirection:(ExpansionDirection)direction;

// Public Methods
- (void)addButtons:(NSArray *)buttons;
- (void)addButton:(UIButton *)button;
- (void)showButtons;
- (void)dismissButtons;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 