//
//  PFGamepadViewController.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/10/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFGamepadViewController.h"
#import "PFGamepadView.h"
#import "PFSketchView.h"
#import "PFNetworkManager.h"
#import "AnimationCatalogController.h"

@interface PFGamepadViewController ()

@end

@implementation PFGamepadViewController {
  PFGamepadView *_gamepadView;
  PFSketchView *_sketchView;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (id)initWithAlias:(NSString *)a;
{
    self = [super init];
    
    if(self) {
        alias = [a copy];

      NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
      [nc addObserver:self selector:@selector(didRemoveServer) name:PHNetworkManagerDidRemoveServerNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _gamepadView = [[PFGamepadView alloc] init];
  _gamepadView.frame = self.view.bounds;
  _gamepadView.autoresizesSubviews = UIViewAutoresizingFlexibleDimensions;
  _gamepadView.delegate = self;
  _gamepadView.joystickDelegate = self;
  _gamepadView.statusLabel.text = [NSString stringWithFormat:@"Hello, %@!", alias];
  [[self view] addSubview:_gamepadView];

  _sketchView = [[PFSketchView alloc] initWithFrame:self.view.bounds];
  _sketchView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  _sketchView.userInteractionEnabled = NO;
  _sketchView.alpha = 0;
  [self.view addSubview:_sketchView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
  [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didMoveWithAngle:(CGFloat)angle velocity:(CGFloat)velocity
{
    NSData *angleData = [NSData dataWithBytes:&angle length:sizeof(angle)];
    NSData *velocityData = [NSData dataWithBytes:&velocity length:sizeof(velocity)];
    NSMutableData *moveData = [[NSMutableData alloc] initWithData:angleData];
    [moveData appendData:velocityData];
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"m" data:moveData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskAll;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"c" data:[@"+" dataUsingEncoding:NSASCIIStringEncoding]];
    _sketchView.alpha = 1;
    _gamepadView.alpha = 0;
  } else {
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"c" data:[@"-" dataUsingEncoding:NSASCIIStringEncoding]];
    _sketchView.alpha = 0;
    _gamepadView.alpha = 1;
  }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  if (UIInterfaceOrientationIsLandscape(NIInterfaceOrientation())) {
    _sketchView.userInteractionEnabled = YES;
    _gamepadView.userInteractionEnabled = NO;
  } else {
    _sketchView.userInteractionEnabled = NO;
    _gamepadView.userInteractionEnabled = YES;
  }
}

- (void)didEndMove
{
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"e" data:nil];
}

- (void)didReleaseButton:(GamepadButton)button
{
    [self sendButtonDataWithMessageType:@"r" buttonType:button];
}

- (void)didPressButton:(GamepadButton)button
{
    [self sendButtonDataWithMessageType:@"p" buttonType:button];
}

- (void)didPressMenuButton:(UIButton *)button {
  AnimationCatalogController* animationController = [[AnimationCatalogController alloc] init];
  [self.navigationController pushViewController:animationController animated:YES];
}

- (void)sendButtonDataWithMessageType:(NSString *)messageType buttonType:(GamepadButton)button
{
    NSString *buttonType = button == 0 ? @"a" : @"b";
    NSData *data = [[NSData alloc] initWithData:[buttonType dataUsingEncoding:NSASCIIStringEncoding]];
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:messageType data:data];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRemoveServer {
  [[PFNetworkManager sharedInstance] closeNetworkConnection];
  [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
