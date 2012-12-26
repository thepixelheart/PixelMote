//
//  PFGamepadViewController.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/10/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFGamepadViewController.h"
#import "PFGamepadView.h"
#import "PFNetworkManager.h"
@interface PFGamepadViewController ()

@end

@implementation PFGamepadViewController

- (id)initWithAlias:(NSString *)a;
{
    self = [super init];
    
    if(self) {
        alias = [a copy];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
	// Do any additional setup after loading the view.
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    PFGamepadView *gamepadView = [[PFGamepadView alloc] init];
    gamepadView.frame = mainFrame;
    gamepadView.delegate = self;
    gamepadView.joystickDelegate = self;
    gamepadView.statusLabel.text = [NSString stringWithFormat:@"Hello, %@!", alias];
    [[self view] addSubview:gamepadView];
}

- (void)didMoveWithAngle:(CGFloat)angle velocity:(CGFloat)velocity
{
    NSData *angleData = [NSData dataWithBytes:&angle length:sizeof(angle)];
    NSData *velocityData = [NSData dataWithBytes:&velocity length:sizeof(velocity)];
    NSMutableData *moveData = [[NSMutableData alloc] initWithData:angleData];
    [moveData appendData:velocityData];
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"m" data:moveData];
}

- (void)didEndMove
{
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"e" data:nil];
}

- (void)didPressButton:(GamepadButton)button
{
    NSString *buttonType = button == 0 ? @"a" : @"b";
    NSData *data = [[NSData alloc] initWithData:[buttonType dataUsingEncoding:NSASCIIStringEncoding]];
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"b" data:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
