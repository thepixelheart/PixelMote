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

@interface PFGamepadViewController : UIViewController <PFGamepadDelegate, PFJoystickDelegate, NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *host;
    NSInteger port;
    NSString *alias;
}

- (id)initWithHost:(NSString*)h port:(NSInteger)p alias:(NSString*)a;

@end
