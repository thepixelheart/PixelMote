//
//  PFGamepadViewController.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/10/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFGamepadDelegate.h"
#import "PFJoystickDelegate.h"

@interface PFGamepadViewController : UIViewController <PFGamepadDelegate, PFJoystickDelegate>
{
    NSString *alias;
}

- (id)initWithAlias:(NSString*)a;

@end
