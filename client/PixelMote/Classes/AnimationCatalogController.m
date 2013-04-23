//
//  AnimationCatalogController.m
//  PixelMote
//
//  Created by Jeff Verkoeyen on 2013-04-23.
//  Copyright (c) 2013 PixelFactory. All rights reserved.
//

#import "AnimationCatalogController.h"

@implementation AnimationCatalogController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end
