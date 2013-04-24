//
//  PFSketchView.m
//  PixelMote
//
//  Created by Jeff Verkoeyen on 2013-04-23.
//  Copyright (c) 2013 PixelFactory. All rights reserved.
//

#import "PFSketchView.h"

@implementation PFSketchView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  [RGBCOLOR(0x11, 0x11, 0x11) set];
  UIRectFill(self.bounds);
  CGContextRef cx = UIGraphicsGetCurrentContext();
  CGContextSetShouldAntialias(cx, NO);
  CGContextSetAllowsAntialiasing(cx, NO);

  [RGBCOLOR(0x33, 0x33, 0x33) set];

  CGFloat space = 10;
  CGFloat lineWidth = NIIsRetina() ? 0.5 : 1;
  for (CGFloat ix = 5; ix < self.bounds.size.width; ix += space) {
    CGContextFillRect(cx, CGRectMake(ix, 0, lineWidth, self.bounds.size.height));
  }
  for (CGFloat iy = 5; iy < self.bounds.size.height; iy += space) {
    CGContextFillRect(cx, CGRectMake(0, iy, self.bounds.size.width, lineWidth));
  }
}

@end
