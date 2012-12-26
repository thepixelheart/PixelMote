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

- (id)initWithHost:(NSString *)h port:(NSInteger)p alias:(NSString *)a;
{
    self = [super init];
    
    if(self) {
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
    gamepadView.statusLabel.text = [NSString stringWithFormat:@"Hello, %@!", alias];
    [[self view] addSubview:gamepadView];
    
    [self initNetworkCommunication];
    
    NSString *message  = [NSString stringWithFormat:@"%@", alias];
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [self sendDataWithMessageType:@"h" data:data];
}

- (void)didMoveWithAngle:(CGFloat)angle velocity:(CGFloat)velocity
{
    NSData *angleData = [NSData dataWithBytes:&angle length:sizeof(angle)];
    NSData *velocityData = [NSData dataWithBytes:&velocity length:sizeof(velocity)];
    NSMutableData *moveData = [[NSMutableData alloc] initWithData:angleData];
    [moveData appendData:velocityData];
    [self sendDataWithMessageType:@"m" data:moveData];
}

- (void)didEndMove
{
    [self sendDataWithMessageType:@"e" data:nil];
}

- (void)didPressButton:(GamepadButton)button
{
    short buttonType = button;
    NSData *data = [NSData dataWithBytes:&buttonType length:sizeof(buttonType)];
    [self sendDataWithMessageType:@"b" data:data];
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

- (void)sendDataWithMessageType:(NSString *)type data:(NSData *)data
{
    NSMutableData *message = [[NSMutableData alloc] initWithData:[type dataUsingEncoding:NSASCIIStringEncoding]];
    [message appendData:data];
    NSData *cr = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [message appendData:cr];
    [outputStream write:[message bytes] maxLength:[message length]];
}

@end
