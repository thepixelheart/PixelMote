//
//  PFJoystiqView.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/13/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFJoystickDelegate.h"

static const CGFloat kJoystickWidth = 140.0;
static const CGFloat kJoystickHeight = 140.0;
static const CGFloat kJoystickButtonWidth = 90.0;
static const CGFloat kJoystickButtonHeight = 90.0;

@class PFJoystiqBar;

@interface PFJoystiqView : UIView
{
    UIImageView *joystiqButton;
    CGFloat startJbX;
    CGFloat startJbY;
}

@property (nonatomic, strong) id<PFJoystickDelegate> delegate;

@end
