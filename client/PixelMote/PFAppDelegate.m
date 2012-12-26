//
//  PFAppDelegate.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/9/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFAppDelegate.h"
#import "PFConnectViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "PFNetworkManager.h"
@implementation PFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    connectViewController = [[PFConnectViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:connectViewController];
    navigationController.navigationBarHidden = YES;
    
    [self.window setRootViewController:navigationController];
    
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[PFNetworkManager sharedInstance] closeNetworkConnection];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[PFNetworkManager sharedInstance] initNetworkConnectionWithPreviousHostAndPort];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[PFNetworkManager sharedInstance] closeNetworkConnection];
}
@end
