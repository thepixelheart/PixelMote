//
//  PFAppDelegate.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/9/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFConnectViewController;

@interface PFAppDelegate : UIResponder <UIApplicationDelegate>
{
    PFConnectViewController *connectViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
