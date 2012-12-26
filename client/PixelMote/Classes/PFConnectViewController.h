//
//  PFConnectViewController.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/23/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFConnectDelegate.h"

@class PFConnectView;

@interface PFConnectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PFConnectDelegate>
{
    PFConnectView *connectView;
    NSArray *images;
    NSArray *labels;
    NSArray *defaults;
}
@end
