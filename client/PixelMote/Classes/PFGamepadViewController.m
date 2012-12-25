//
//  PFGamepadViewController.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/10/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFGamepadViewController.h"
#import "PFGamepadView.h"

@interface PFGamepadViewController ()

@end

@implementation PFGamepadViewController

- (id)initWithUniqueId:(NSString *)uid host:(NSString *)h port:(NSInteger)p alias:(NSString *)a;
{
    self = [super init];
    
    if(self) {
        uniqueId = [uid copy];
        host = [h copy];
        port = p;
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
    [[self view] addSubview:gamepadView];
    
    [self initNetworkCommunication];
    
    [self sendDataWithPrefix:@"hi" content:[NSString stringWithFormat:@"%@,%@", uniqueId, alias]];
}

- (void)didMoveWithAngle:(CGFloat)angle velocity:(CGFloat)velocity
{
    [self sendDataWithPrefix:@"mv" content:[NSString stringWithFormat:@"%f,%f",angle,velocity]];
}

- (void)didEndMove
{
    [self sendDataWithPrefix:@"emv" content:@""];
}

- (void)didPressButton:(GamepadButton)button
{
    [self sendDataWithPrefix:@"bp" content:[NSString stringWithFormat:@"%d",button]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host,port, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

-(void)sendDataWithPrefix:(NSString *)prefix content:(NSString *)content
{
    NSString *response  = [NSString stringWithFormat:@"%@:%@:%@", prefix, content, uniqueId];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

@end
