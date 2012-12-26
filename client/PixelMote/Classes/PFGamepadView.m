//
//  PFGamepadView.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/10/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFGamepadView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PFJoystiqView.h"

@implementation PFGamepadView
@synthesize delegate, joystickDelegate, statusLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 3.0f;
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"640x1136-main-bg.png"]]];
        
        [self initStatusView];
        [self initButtonLayout];
    }
    return self;
}

- (void)initStatusView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat statusViewHeight = 25.0f;
    CGFloat margin = 5.0f;
    statusView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, frame.size.width - margin * 2.0f, statusViewHeight)];
    statusView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.80];
    statusView.layer.cornerRadius = 3.0f;
    [self addSubview:statusView];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 25.0)];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [statusView addSubview:statusLabel];
}

- (void)initButtonLayout
{
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    
    CGFloat buttonWidth = 95.0f;
    CGFloat buttonHeight = 95.0f;
    CGFloat aX = mainFrame.size.width / 2.0f - buttonWidth / 2.0f;
    CGFloat aY = 50.0f;
    CGFloat buttonMargin = 70.0f;
    
    CGRect frame = CGRectMake(aX, aY, buttonWidth, buttonHeight);
    
    aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self createAndAddButton:aButton frame:frame imageName:@"95x95-A-button.png" tag:AButton];
    
    frame.origin.y = buttonHeight + buttonMargin;
    bButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self createAndAddButton:bButton frame:frame imageName:@"95x95-B-button.png" tag:BButton];
    
    CGFloat jWidth = mainFrame.size.width;
    CGFloat jHeight = mainFrame.size.height / 2.0;
    CGFloat jX = mainFrame.size.width / 2.0f - jWidth / 2.0;
    CGFloat jY = mainFrame.size.height - jHeight;

    joystick = [[PFJoystiqView alloc] initWithFrame:CGRectMake(jX, jY, jWidth, jHeight)];
    [self addSubview:joystick];
}

- (void)createAndAddButton:(UIButton *)button frame:(CGRect)frame imageName:(NSString *)imageName tag:(GamepadButton)tag
{
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.frame = frame;
    button.tag = tag;
    [button addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)playButtonSound
{
    SystemSoundID sounds[10];  
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"CL" ofType:@"mp3"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
    AudioServicesPlaySystemSound(sounds[0]);
}

- (void)didPressButton:(id)sender
{
    [self playButtonSound];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPressButton:)]) {
        [self.delegate didPressButton:[sender tag]];
    }
}

- (void)setJoystickDelegate:(id<PFJoystickDelegate>)jd
{
    joystick.delegate = jd;
}

- (id<PFJoystickDelegate>)joystickDelegate
{
    return joystick.delegate;
}

@end
