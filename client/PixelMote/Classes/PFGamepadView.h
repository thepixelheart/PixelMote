//
//  PFGamepadView.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/10/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFGamepadDelegate.h"
#import "PFJoystickDelegate.h"
#import "PFJoystiqView.h"

@interface PFGamepadView : UIView
{
    UIButton *aButton;
    UIButton *bButton;
    PFJoystiqView *joystick;
    BOOL isMovingJoystick;
    UIView *statusView;
}

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) id<PFGamepadDelegate> delegate;
@property (nonatomic, strong) id <PFJoystickDelegate> joystickDelegate;
@end
