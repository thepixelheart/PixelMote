//
//  PFConnectView.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/23/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFConnectView.h"
#import "ELCTextfieldCell.h"

@implementation PFConnectView
@synthesize tableView, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"640x1136-main-bg.png"]];
        tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [self addSubview:tableView];
        tableView.alpha = 0.0;
        
        connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [connectButton addTarget:self action:@selector(connectPressed:) forControlEvents:UIControlEventTouchUpInside];
        connectButton.alpha = 0.0;
        
        [self addSubview:connectButton];
        
        logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        [self addSubview:logoImageView];
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    // Configure logo
    
    CGFloat logoWidth = 213.0;
    CGFloat logoHeight = 63.0;
    CGFloat logoX = frame.size.width / 2.0 - logoWidth / 2.0;
    CGFloat logoY = 170.0;
    logoImageView.frame = CGRectMake(logoX, logoY, logoWidth, logoHeight);
    
    [self animateLogo];
}

- (void)animateLogo
{
    [UIView animateWithDuration:0.75 delay:0.15 options:UIViewAnimationCurveEaseIn animations:^{
        CGRect logoFrame = logoImageView.frame;
        logoFrame.origin.y = 35.0;
        logoImageView.frame = logoFrame;
    } completion:^(BOOL finished) {
        [self layoutInputFields];
        [self animateInputFields];
    }];
}

- (void) animateInputFields
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        tableView.alpha = 1.0;
        connectButton.alpha = 1.0;
    } completion:^(BOOL finished) {

    }];
}

- (void)layoutInputFields
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect logoFrame = logoImageView.frame;
    CGFloat logoHeight = logoFrame.size.height;
    CGFloat logoY = logoFrame.origin.y;
    
    // Configure table view
    
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;
    CGRect tableViewFrame = tableView.frame;
    CGFloat tableViewWidth = 235.0;
    tableViewFrame.size.width = tableViewWidth;
    tableViewFrame.size.height = 175.0;
    tableViewFrame.origin.x = frame.size.width / 2.0 - tableViewWidth / 2.0;
    tableViewFrame.origin.y = logoY + logoHeight + 15.0;
    tableView.frame = tableViewFrame;
    
    // Configure connect button
    CGFloat buttonWidth = 215.0;
    CGFloat buttonHeight = 51.0;
    CGFloat buttonX = frame.size.width / 2.0 - buttonWidth / 2.0;
    CGFloat buttonY = tableViewFrame.size.height + tableViewFrame.origin.y;
    [connectButton setBackgroundImage:[UIImage imageNamed:@"standard-button.png"] forState:UIControlStateNormal];
    connectButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
}

- (void)connectPressed:(id)sender
{
    ELCTextfieldCell *hostCell = (ELCTextfieldCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *host = [hostCell rightTextField].text;
    
    ELCTextfieldCell *portCell = (ELCTextfieldCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *port = [portCell rightTextField].text;
    
    ELCTextfieldCell *aliasCell = (ELCTextfieldCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *alias = [aliasCell rightTextField].text;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(makeConnectionWithHost:port:alias:)]) {
        [self.delegate makeConnectionWithHost:host port:[port intValue] alias:alias];
    }
}

@end
