//
//  DCPathButoon.m
//  HTMIWFCDCPathButton
//
//  Created by Paul on 4/19/13.
//  Copyright (c) 2013 Paul. All rights reserved.
//

#import "HTMIWFCDCPathButton.h"
#import "UIImage+HTMIWFCWM.h"

@interface HTMIWFCDCPathButton (){
    //Declare some basic parameter
    CGPoint kHTMIWFCDCPathButtonSubButtonBirthLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonTag_5_AppearLocation;
    CGPoint kHTMIWFCDCPathButtonSubButtonFinalLocation;
}

@end

@implementation HTMIWFCDCPathButton

@synthesize delegate = _delegate;
@synthesize expanded = _expanded;
@synthesize buttonCount = _buttonCount;

@synthesize totalRaiuds = _totalRaiuds;
@synthesize centerRadius = _centerRadius;
@synthesize subRadius = _subRadius;
@synthesize centerLocationAxisX = _centerLocationAxisX;
@synthesize centerLocationAxisY = _centerLocationAxisY;

@synthesize parentView = _parentView;
@synthesize buttons = _buttons;
@synthesize centerButton, subButton;

//  Sub button offset parameter
static CGFloat const kHTMIWFCDCPathButtonLeftOffSetX = -20.0f;
static CGFloat const kHTMIWFCDCPathButtonRightOffSetX = 20.0f;
static CGFloat const kHTMIWFCDCPathButtonVerticalOffSetX = 20.0f;

//  Sub button angel parameter
static CGFloat const kHTMIWFCDCPathButtonAngel36C = 36.0f;
static CGFloat const kHTMIWFCDCPathButtonAngel45C = 45.0f;
static CGFloat const kHTMIWFCDCPathButtonAngel60C = 60.0f;
static CGFloat const kHTMIWFCDCPathButtonAngel72C = 72.0f;
static CGFloat const kHTMIWFCDCPathButtonDefaultCenterRadius = 15.0f;
static CGFloat const kHTMIWFCDCPathButtonDefaultSubRadius = 20.0f;
static CGFloat const kHTMIWFCDCPathButtonDefaultTotalRadius = 60.0f;
static CGFloat const kHTMIWFCDCPathButtonDefaultRotation = M_PI*2;
static CGFloat const kHTMIWFCDCPathButtonDefaultReverseRotation = -M_PI*2;

#pragma mark - Initialization method
- (id)initHTMIWFCDCPathButtonWithSubButtons:(NSInteger)buttonCount totalRadius:(CGFloat)totalRadius centerRadius:(NSInteger)centerRadius subRadius:(CGFloat)subRadius centerImage:(NSString *)centerImageName centerBackground:(NSString *)centerBackgroundName subImages:(void (^)(HTMIWFCDCPathButton *))imageBlock subImageBackground:(NSString *)subImageBackgroundName inLocationX:(CGFloat)xAxis locationY:(CGFloat)yAxis toParentView:(UIView *)parentView{
    
    parentView == nil? (self.parentView = parentView):(self.parentView = parentView);
    xAxis == 0? (self.centerLocationAxisX = kHTMIWFCDCPathButtonCurrentFrameWidth/2) : (self.centerLocationAxisX = xAxis);
    yAxis == 0? (self.centerLocationAxisY = kHTMIWFCDCPathButtonCurrentFrameHeight/2) : (self.centerLocationAxisY = yAxis);
    self.buttonCount = buttonCount;
    self.totalRaiuds = totalRadius;
    self.subRadius = subRadius;
    _expanded = NO;
    kHTMIWFCDCPathButtonSubButtonBirthLocation = CGPointMake(-kHTMIWFCDCPathButtonCurrentFrameWidth/2, -kHTMIWFCDCPathButtonCurrentFrameHeight/2);
    kHTMIWFCDCPathButtonSubButtonFinalLocation = CGPointMake(self.centerLocationAxisX, self.centerLocationAxisY);
    
    if (self = [super initWithFrame:self.parentView.bounds]) {
        [self configureCenterButton:centerRadius image:centerImageName backgroundImage:centerBackgroundName];
        [self configureTheButtons:buttonCount];
        imageBlock(self);
        [self.parentView addSubview:self];
    }
    return self;
}

#pragma mark - configure the center button and the sub button

- (void)configureCenterButton:(CGFloat)centerRadius image:(NSString *)imageName backgroundImage:(NSString *)backgroundImageName{
    self.centerButton = [[UIButton alloc]init];
    //红色按钮大小
    self.centerButton.frame = CGRectMake(0, 0, centerRadius * 2, centerRadius * 2);
    //红色按钮位置
    self.centerButton.center = CGPointMake(self.centerLocationAxisX, self.centerLocationAxisY);
    if (imageName == nil) {
        imageName = @"dc-center";
    }
    if (backgroundImageName == nil) {
        backgroundImageName = @"dc-background";
    }
    [self.centerButton setImage:[UIImage getPNGImageHTMIWFC:imageName] forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage getPNGImageHTMIWFC:backgroundImageName] forState:UIControlStateNormal];
    [self.centerButton addTarget:self action:@selector(centerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.centerButton.layer.zPosition = 1;
    [self addSubview:self.centerButton];
}

- (void)centerButtonPress{
    if (![self isExpanded]) {
        switch (self.buttonCount) {
            case 3:
            {
                [self button:[self.buttons objectAtIndex:0] appearAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation withDalay:0.5 duration:0.35];
                [self button:[self.buttons objectAtIndex:1] appearAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation withDalay:0.55 duration:0.4];
                [self button:[self.buttons objectAtIndex:2] appearAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation withDalay:0.6 duration:0.45];
            }
                break;
            case 4:
            {
                [self button:[self.buttons objectAtIndex:0] appearAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation withDalay:0.5 duration:0.35];
                [self button:[self.buttons objectAtIndex:1] appearAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation withDalay:0.55 duration:0.4];
                [self button:[self.buttons objectAtIndex:2] appearAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation withDalay:0.6 duration:0.45];
                [self button:[self.buttons objectAtIndex:3] appearAt:kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation withDalay:0.65 duration:0.5];
            }
                break;
            case 5:
            {
                [self button:[self.buttons objectAtIndex:0] appearAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation withDalay:0.5 duration:0.35];
                [self button:[self.buttons objectAtIndex:1] appearAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation withDalay:0.55 duration:0.4];
                [self button:[self.buttons objectAtIndex:2] appearAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation withDalay:0.6 duration:0.45];
                [self button:[self.buttons objectAtIndex:3] appearAt:kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation withDalay:0.65 duration:0.5];
                [self button:[self.buttons objectAtIndex:4] appearAt:kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation withDalay:0.7 duration:0.55];
            }
                break;
            case 6:
            {
                [self button:[self.buttons objectAtIndex:0] appearAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation withDalay:0.5 duration:0.35];
                [self button:[self.buttons objectAtIndex:1] appearAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation withDalay:0.55 duration:0.4];
                [self button:[self.buttons objectAtIndex:2] appearAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation withDalay:0.6 duration:0.45];
                [self button:[self.buttons objectAtIndex:3] appearAt:kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation withDalay:0.65 duration:0.5];
                [self button:[self.buttons objectAtIndex:4] appearAt:kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation withDalay:0.7 duration:0.55];
                [self button:[self.buttons objectAtIndex:5] appearAt:kHTMIWFCDCPathButtonSubButtonTag_5_AppearLocation withDalay:0.75 duration:0.6];
            }
                break;
            default:
                break;
        }
        self.expanded = YES;
    }
    else{
        switch (self.buttonCount) {
            case 3:
            {
                [self button:[self.buttons objectAtIndex:0]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel60C]
                   withDelay:0.4
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1];
                [self button:[self.buttons objectAtIndex:1]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:-[self offsetAxisY:kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel60C] withDelay:0.5
             rotateDirection:kHTMIWFCDCPathButtonRotationReverse animationDuration:1.2];
                [self button:[self.buttons objectAtIndex:2]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation
                 offsetAxisX:0 offSEtAxisY:kHTMIWFCDCPathButtonVerticalOffSetX
                   withDelay:0.6
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.4];
            }
                break;
            case 4:
            {
                [self button:[self.buttons objectAtIndex:0]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel45C]
                   withDelay:0.4
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1];
                [self button:[self.buttons objectAtIndex:1]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:[self offsetAxisY:-kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel45C]
                   withDelay:0.45
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.1];
                [self button:[self.buttons objectAtIndex:2]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:-kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel45C]
                   withDelay:0.5
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.2];
                [self button:[self.buttons objectAtIndex:3]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel45C]
                   withDelay:0.55
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.3];
            }
                break;
            case 5:
            {
                [self button:[self.buttons objectAtIndex:0]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel36C]
                   withDelay:0.4
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1];
                [self button:[self.buttons objectAtIndex:1]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:[self offsetAxisY:-kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel36C]
                   withDelay:0.44
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.2];
                [self button:[self.buttons objectAtIndex:2]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:-kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel72C]
                   withDelay:0.48
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.3];
                [self button:[self.buttons objectAtIndex:3]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation
                 offsetAxisX:0 offSEtAxisY:kHTMIWFCDCPathButtonVerticalOffSetX
                   withDelay:0.52
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.1];
                [self button:[self.buttons objectAtIndex:4]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel72C]
                   withDelay:0.55
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.4];
            }
                break;
            case 6:
            {
                [self button:[self.buttons objectAtIndex:0]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel60C]
                   withDelay:0.4
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1];
                [self button:[self.buttons objectAtIndex:1]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation
                 offsetAxisX:0 offSEtAxisY:-kHTMIWFCDCPathButtonVerticalOffSetX
                   withDelay:0.43
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.1];
                [self button:[self.buttons objectAtIndex:2]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:[self offsetAxisY:-kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel60C]
                   withDelay:0.46
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.2];
                [self button:[self.buttons objectAtIndex:3]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonLeftOffSetX
                 offSEtAxisY:[self offsetAxisY:-kHTMIWFCDCPathButtonLeftOffSetX withAngel:kHTMIWFCDCPathButtonAngel60C]
                   withDelay:0.49
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.3];
                [self button:[self.buttons objectAtIndex:4]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation
                 offsetAxisX:0 offSEtAxisY:kHTMIWFCDCPathButtonVerticalOffSetX
                   withDelay:0.52
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.3];
                [self button:[self.buttons objectAtIndex:5]
                    shrinkAt:kHTMIWFCDCPathButtonSubButtonTag_5_AppearLocation
                 offsetAxisX:kHTMIWFCDCPathButtonRightOffSetX
                 offSEtAxisY:[self offsetAxisY:kHTMIWFCDCPathButtonRightOffSetX withAngel:kHTMIWFCDCPathButtonAngel60C]
                   withDelay:0.55
             rotateDirection:kHTMIWFCDCPathButtonRotationNormal animationDuration:1.4];
            }
            default:
                break;
        }
        [self centerButtonAnimation];
        self.expanded = NO;
    }
}

- (void)configureTheButtons:(NSInteger)buttonCount{
    //  Limit the button amount
    if (buttonCount < 3) {
        buttonCount = 3;
        self.buttonCount = buttonCount;
    }
    else if (buttonCount > 6) {
        buttonCount = 6;
    }
    //  Configure out the sub button's location parameter
    switch (buttonCount) {
        case 3:
        {
            //位置
            kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)));
            kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)));
            kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX ,
                                                                     self.centerLocationAxisY +self.totalRaiuds);
        }
            break;
        case 4:
        {
            kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)));
            kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)));
            kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)),
                                                                     self.centerLocationAxisY + self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)));
            kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)),
                                                                     self.centerLocationAxisY + self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel45C)));
        }
            break;
        case 5:
        {
            kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel36C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel36C)));
            kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel36C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel36C)));
            kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel72C)),
                                                                     self.centerLocationAxisY + self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel72C)));
            kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX,
                                                                     self.centerLocationAxisY + self.totalRaiuds);
            kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel72C)),
                                                                     self.centerLocationAxisY + self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel72C)));
        }
            break;
        case 6:
        {
            kHTMIWFCDCPathButtonSubButtonTag_0_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)));
            kHTMIWFCDCPathButtonSubButtonTag_1_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX,
                                                                     self.centerLocationAxisY - self.totalRaiuds);
            kHTMIWFCDCPathButtonSubButtonTag_2_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)),
                                                                     self.centerLocationAxisY - self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)));
            kHTMIWFCDCPathButtonSubButtonTag_3_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX - self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)),
                                                                     self.centerLocationAxisY + self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)));
            kHTMIWFCDCPathButtonSubButtonTag_4_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX,
                                                                     self.centerLocationAxisY + self.totalRaiuds);
            kHTMIWFCDCPathButtonSubButtonTag_5_AppearLocation = CGPointMake(
                                                                     self.centerLocationAxisX + self.totalRaiuds * sinf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)),
                                                                     self.centerLocationAxisY + self.totalRaiuds * cosf(kDCCovertAngelToRadian(kHTMIWFCDCPathButtonAngel60C)));
        }
            break;
        default:
            break;
    }
    self.buttons = [NSMutableArray array];
    for (NSInteger i = 0; i<buttonCount; i++) {
        subButton = [[HTMIWFCDCSubButton alloc]init];
        subButton.delegate = self;
        subButton.frame = CGRectMake(0, 0, self.subRadius * 2, self.subRadius * 2);
        subButton.center = kHTMIWFCDCPathButtonSubButtonBirthLocation;
        NSString *imageFormat = [NSString stringWithFormat:@"dc-button_%d",i];
        [subButton setImage:[UIImage getPNGImageHTMIWFC:imageFormat] forState:UIControlStateNormal];
        
        [self addSubview:subButton];
        [self.buttons addObject:subButton];
    }
}

#pragma mark - Add image to sub button, only use in the block

- (void)subButtonImage:(NSString *)imageName withTag:(NSInteger)tag{
    if (tag > self.buttonCount) {
        tag = self.buttonCount;
    }
    HTMIWFCDCSubButton *currentButton = [self.buttons objectAtIndex:tag];
    [currentButton setImage:[UIImage getPNGImageHTMIWFC:imageName] forState:UIControlStateNormal];
}

#pragma mark - Set a sign to judge the animation state

- (BOOL)isExpanded{
    return _expanded;
}

#pragma mark - The center button and the sub button's animations

- (void)button:(HTMIWFCDCSubButton *)button appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration{
    button.center = location;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration = duration;
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    scaleAnimation.calculationMode = kCAAnimationLinear;
    scaleAnimation.keyTimes = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:delay],[NSNumber numberWithFloat:1.0f]];
    button.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    [button.layer addAnimation:scaleAnimation forKey:@"buttonAppear"];
}

- (void)button:(HTMIWFCDCSubButton *)button shrinkAt:(CGPoint)location offsetAxisX:(CGFloat)axisX offSEtAxisY:(CGFloat)axisY withDelay:(CGFloat)delay rotateDirection:(HTMIWFCDCPathButtonRotationOrientation)orientation animationDuration:(CGFloat)duration{
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.duration = duration * delay;
    rotation.values = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:[self matchRotationOrientation:orientation]],[NSNumber numberWithFloat:0.0f]];
    rotation.keyTimes = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:delay],[NSNumber numberWithFloat:1.0f]];
    
    CAKeyframeAnimation *shrink = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    shrink.duration = duration * (1 - delay);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, location.x, location.y);
    CGPathAddLineToPoint(path, NULL, location.x + axisX, location.y + axisY);
    //收回位置
    CGPathAddLineToPoint(path, NULL, kHTMIWFCDCPathButtonSubButtonFinalLocation.x, kHTMIWFCDCPathButtonSubButtonFinalLocation.y);
    shrink.path = path;
    
    CGPathRelease(path);
    
    CAAnimationGroup *totalAnimation = [CAAnimationGroup animation];
    totalAnimation.duration = 1.0f;
    totalAnimation.animations = @[rotation,shrink];
    totalAnimation.fillMode = kCAFillModeForwards;
    totalAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    totalAnimation.delegate = self;
    
    button.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    button.center = kHTMIWFCDCPathButtonSubButtonBirthLocation;
    [button.layer addAnimation:totalAnimation forKey:@"buttonDismiss"];
}

- (void)centerButtonAnimation{
    CAKeyframeAnimation *centerZoom = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    centerZoom.duration = 1.0f;
    centerZoom.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    centerZoom.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [centerButton.layer addAnimation:centerZoom forKey:@"buttonScale"];
}

#pragma mark - Some math method

- (CGFloat)matchRotationOrientation:(HTMIWFCDCPathButtonRotationOrientation)orientation{
    if (orientation == kHTMIWFCDCPathButtonRotationNormal) {
        return kHTMIWFCDCPathButtonDefaultRotation;
    }
    return kHTMIWFCDCPathButtonDefaultReverseRotation;
}

- (CGFloat)offsetAxisY:(CGFloat)axisX withAngel:(CGFloat)angel{
    return (axisX / tanf(kDCCovertAngelToRadian(angel)));
}


#pragma HTMIWFCDCSubButton Delegate

- (void)subButtonPress:(HTMIWFCDCSubButton *)button{
    if ([_delegate respondsToSelector:@selector(button_0_action)] &&
        button == [self.buttons objectAtIndex:0]) {
        [_delegate button_0_action];
    }
    else if ([_delegate respondsToSelector:@selector(button_1_action)] &&
             button == [self.buttons objectAtIndex:1]){
        [_delegate button_1_action];
    }
    else if ([_delegate respondsToSelector:@selector(button_2_action)] &&
             button == [self.buttons objectAtIndex:2]){
        [_delegate button_2_action];
    }
    else if ([_delegate respondsToSelector:@selector(button_3_action)] &&
             button == [self.buttons objectAtIndex:3]){
        [_delegate button_3_action];
    }
    else if ([_delegate respondsToSelector:@selector(button_4_action)] &&
             button == [self.buttons objectAtIndex:4]){
        [_delegate button_4_action];
    }
    else if ([_delegate respondsToSelector:@selector(button_5_action)] &&
             button == [self.buttons objectAtIndex:5]){
        [_delegate button_5_action];
    }
}

@end
