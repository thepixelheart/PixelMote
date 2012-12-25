//
//  PFJoystiqView.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/13/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFJoystiqView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation PFJoystiqView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        [self initAssets];
    }
    return self;
}

- (void)initAssets
{
    CGRect frame = self.frame;
    CGFloat jWidth = kJoystickWidth;
    CGFloat jHeight = kJoystickHeight;
    
    UIImageView *joystiqBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"205x205-joystiq-border.png"]];

    CGFloat jbrx = frame.size.width / 2.0 - jWidth / 2.0;
    CGFloat jbry = frame.size.height / 2.0 - jHeight / 2.0;
    joystiqBorder.frame = CGRectMake(jbrx, jbry, jWidth, jHeight);
    [self addSubview:joystiqBorder];
    
    CGFloat jbWidth = kJoystickButtonWidth;
    CGFloat jbHeight = kJoystickButtonHeight;
    CGFloat jbX = self.frame.size.width / 2.0f - jbWidth / 2.0f;
    CGFloat jbY = self.frame.size.height / 2.0 - jbHeight / 2.0f;
    startJbX = jbX;
    startJbY = jbY;
    
    joystiqButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"90x90-joystiq-button.png"]];
    joystiqButton.frame = CGRectMake(jbX, jbY, jbWidth, jbHeight);
    [self addSubview:joystiqButton];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat centerX = self.frame.size.width / 2.0;
    CGFloat centerY = self.frame.size.height / 2.0;
    CGFloat radius = kJoystickButtonWidth / 1.75;
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    CGRect newJoystiqFrame = joystiqButton.frame;
    
    CGFloat newX = locationPoint.x - centerX;
    CGFloat newY = locationPoint.y - centerY;
    CGFloat rad = atan2f(newY, newX);
    
    if ([self inBoundsCenterX:0 centerY:0 pointX:newX pointY:newY radius:radius]) {
        newJoystiqFrame.origin.x = (newX + centerX) - kJoystickButtonWidth / 2.0;
        newJoystiqFrame.origin.y = (newY + centerY) - kJoystickButtonHeight / 2.0;
    } else {
        CGFloat mx = radius * cosf(rad);
        CGFloat my = radius * sinf(rad);
        newJoystiqFrame.origin.x = (mx + centerX) - kJoystickButtonWidth / 2.0;
        newJoystiqFrame.origin.y = (my + centerY) - kJoystickButtonHeight / 2.0;
    }
    
    joystiqButton.frame = newJoystiqFrame;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMoveWithAngle:velocity:)]) {
        [self.delegate didMoveWithAngle:[self degreesWithRad:rad] velocity:[self velocityForCenterX:0 centerY:0 pointX:newX pointY:newY maxRadius:radius]];
    }
}

- (CGFloat)degreesWithRad:(CGFloat)rad
{
    CGFloat degrees = rad * 180.0f / M_PI;
    return degrees < 0 ? 360.0f + degrees : degrees;
}

- (BOOL)inBoundsCenterX:(CGFloat)cx centerY:(CGFloat)cy pointX:(CGFloat)px pointY:(CGFloat)py radius:(CGFloat)r
{
    return pow(px - cx, 2) + pow(py - cy, 2)  < pow(r, 2);
}

- (CGFloat)velocityForCenterX:(CGFloat)cx centerY:(CGFloat)cy pointX:(CGFloat)px pointY:(CGFloat)py maxRadius:(CGFloat)maxRadius
{
    CGFloat radius = sqrt(pow(px - cx, 2) + pow(py - cy, 2));
    return MIN(radius / maxRadius, 1.0 );
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndMove)]) {
        [self.delegate didEndMove];
    }
    
    [UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        CGRect startFrame = joystiqButton.frame;
        startFrame.origin.x = startJbX;
        startFrame.origin.y = startJbY;
        joystiqButton.frame = startFrame;
    } completion:^(BOOL finished) {
        [self playJoystickSound];
        [self animateJoystickButton];
    }];
}

- (void)animateJoystickButton
{
    CAKeyframeAnimation *scaleAnimationX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleAnimationX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimationX.duration = 0.8;
    CAKeyframeAnimation *scaleAnimationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleAnimationY.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimationY.duration = 0.8;
    
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    NSMutableArray *scaleValues = [NSMutableArray arrayWithCapacity:steps];
    
    double value = 0;
    double scaleValue = 0;
    
    float e = 2.71;
    for (int t = 0; t < steps; t++) {
        NSInteger maxDegrees = 15;
        CGFloat bounceFactor = pow(e, -0.055*t) * cos(0.25*t);
        value = maxDegrees * bounceFactor;
        scaleValue  = 1 + bounceFactor * 0.05;
        [values addObject:[NSNumber numberWithFloat:value * M_PI / 180.0f]];
        [scaleValues addObject:[NSNumber numberWithFloat:scaleValue]];
    }
    
    scaleAnimationX.values = scaleValues;
    scaleAnimationX.removedOnCompletion = NO;
    scaleAnimationX.fillMode = kCAFillModeForwards;
    scaleAnimationX.delegate = self;
    
    scaleAnimationY.values = scaleValues;
    scaleAnimationY.removedOnCompletion = NO;
    scaleAnimationY.fillMode = kCAFillModeForwards;
    scaleAnimationY.delegate = self;
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = [NSArray arrayWithObjects:scaleAnimationX, scaleAnimationY, nil];
    [joystiqButton.layer addAnimation:group forKey:@"jiggle"];
}

- (void)playJoystickSound
{
    SystemSoundID sounds[10];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"mp3"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
    AudioServicesPlaySystemSound(sounds[0]);
}

@end
