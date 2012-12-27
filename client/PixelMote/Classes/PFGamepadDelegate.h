//
//  PFGamepadDelegate.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/15/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    AButton,
    BButton
}GamepadButton;

@protocol PFGamepadDelegate <NSObject>
- (void)didReleaseButton:(GamepadButton)button;
- (void)didPressButton:(GamepadButton)button;
@end
