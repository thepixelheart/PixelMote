//
//  PFConnectDelegate.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/23/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFConnectDelegate <NSObject>
- (void)makeConnectionWithHost:(NSString *)host port:(NSInteger)port alias:(NSString *)alias;
@end
