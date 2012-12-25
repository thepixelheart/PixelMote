//
//  PFJoystickDelegate.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/23/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFJoystickDelegate <NSObject>
- (void)didMoveWithAngle:(CGFloat)angle velocity:(CGFloat)velocity;
- (void)didEndMove;
@end
