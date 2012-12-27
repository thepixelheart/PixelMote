//
//  PFConnectView.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/23/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFConnectDelegate.h"

@interface PFConnectView : UIView
{
    UIButton *connectButton;
    UIImageView *logoImageView;
}

- (void)doneEditing;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id<PFConnectDelegate>delegate;

@end
