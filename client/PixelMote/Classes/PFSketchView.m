//
//  PFSketchView.m
//  PixelMote
//
//  Created by Jeff Verkoeyen on 2013-04-23.
//  Copyright (c) 2013 PixelFactory. All rights reserved.
//

#import "PFSketchView.h"

static const UIEdgeInsets kPadding = {30, 10, 30, 10};
static const NSInteger kNumberOfColumns = 48;
static const NSInteger kNumberOfRows = 32;

@interface PFSketchViewBackground : UIView

- (CGPoint)pixelAtPoint:(CGPoint)point;
- (CGRect)frameForPixel:(CGPoint)pixel;
- (void)setRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue alpha:(uint8_t)alpha atPixel:(CGPoint)pixel;

@end

@implementation PFSketchView {
  PFSketchViewBackground* _bg;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _bg = [[PFSketchViewBackground alloc] initWithFrame:self.bounds];
    _bg.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    [self addSubview:_bg];
    self.multipleTouchEnabled = YES;
  }
  return self;
}

- (void)drawAtPixel:(CGPoint)pixel {
  CGFloat radius = 5;
  CGFloat radiusSq = radius * radius;

  NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
  CGFloat red = sin(t) * 127.0 + 127.0;
  CGFloat green = sin(t * 5) * 127.0 + 127.0;
  CGFloat blue = sin(t * 3) * 127.0 + 127.0;

  for (CGFloat ix = MAX(0, pixel.x - radius); ix < MIN(kNumberOfColumns, pixel.x + radius); ++ix) {
    CGFloat deltaX = pixel.x - ix;
    CGFloat deltaXSq = deltaX * deltaX;
    for (CGFloat iy = MAX(0, pixel.y - radius); iy < MIN(kNumberOfRows, pixel.y + radius); ++iy) {
      CGFloat deltaY = pixel.y - iy;
      CGFloat deltaYSq = deltaY * deltaY;
      CGFloat distanceSq = deltaYSq + deltaXSq;
      if (distanceSq < radiusSq) {

        CGFloat alpha = 1;
        if (distanceSq >= radiusSq * 0.25) {
          alpha = 1 - (distanceSq - radiusSq * 0.25) / radiusSq * 0.75;
        }
        CGPoint pixel = CGPointMake(ix, iy);
        [_bg setRed:red green:green blue:blue alpha:alpha * 255 atPixel:pixel];
        [_bg setNeedsDisplayInRect:[_bg frameForPixel:pixel]];
      }
    }
  }
}

- (void)paintTouches:(NSSet *)touches {
  for (UITouch* touch in touches) {
    CGPoint pixel = [_bg pixelAtPoint:[touch locationInView:_bg]];
    [self drawAtPixel:pixel];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];

  [self paintTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];

  [self paintTouches:touches];
}

@end

@implementation PFSketchViewBackground {
  uint32_t _pixels[kNumberOfColumns * kNumberOfRows];
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.contentMode = UIViewContentModeRedraw;
    bzero(_pixels, sizeof(uint32_t) * kNumberOfRows * kNumberOfColumns);
  }
  return self;
}

- (CGRect)insetBounds {
  return UIEdgeInsetsInsetRect(self.bounds, kPadding);
}

- (CGFloat)pixelSize {
  return self.insetBounds.size.height / (CGFloat)kNumberOfRows;
}

- (CGFloat)width {
  return [self pixelSize] * kNumberOfColumns;
}

- (CGFloat)height {
  return [self pixelSize] * kNumberOfRows;
}

- (CGFloat)leftEdge {
  return self.insetBounds.origin.x;
}

- (CGFloat)topEdge {
  return self.insetBounds.origin.y + (self.insetBounds.size.height - [self height]) / 2;
}

- (CGPoint)pixelAtPoint:(CGPoint)point {
  CGFloat pixelSize = [self pixelSize];
  CGFloat leftEdge = [self leftEdge];
  CGFloat topEdge = [self topEdge];
  return CGPointMake(boundf(floorf((point.x - leftEdge) / pixelSize), 0, kNumberOfColumns - 1),
                     boundf(floorf((point.y - topEdge) / pixelSize), 0, kNumberOfRows - 1));
}

- (CGRect)frameForPixel:(CGPoint)pixel {
  CGFloat pixelSize = [self pixelSize];
  return CGRectMake([self leftEdge] + pixel.x * pixelSize,
                    [self topEdge] + pixel.y * pixelSize,
                    pixelSize,
                    pixelSize);
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  CGContextRef cx = UIGraphicsGetCurrentContext();
  CGContextSetShouldAntialias(cx, NO);
  CGContextSetAllowsAntialiasing(cx, NO);

  CGFloat pixelSize = [self pixelSize];
  CGFloat width = [self width];
  CGFloat leftEdge = [self leftEdge];
  CGFloat topEdge = [self topEdge];
  CGFloat lineWidth = NIIsRetina() ? 0.5 : 1;
  [RGBCOLOR(0x11, 0x11, 0x11) set];
  UIRectFill(self.bounds);

  CGRect pixelFrame = CGRectMake(0, 0, floorf(pixelSize), floorf(pixelSize));
  for (CGFloat ix = 0; ix < kNumberOfColumns; ++ix) {
    pixelFrame.origin.x = leftEdge + ix * pixelSize;

    for (CGFloat iy = 0; iy < kNumberOfRows; ++iy) {
      pixelFrame.origin.y = topEdge + iy * pixelSize;
      NSInteger index = iy * kNumberOfColumns + ix;
      uint32_t color = _pixels[index];
      uint8_t* colorComponents = (uint8_t *)&color;

      CGContextSetFillColorWithColor(cx, RGBACOLOR(colorComponents[0], colorComponents[1], colorComponents[2], colorComponents[3] / 255.0).CGColor);
      CGContextFillRect(cx, pixelFrame);
    }
  }

  [RGBCOLOR(0x33, 0x33, 0x33) set];

  for (CGFloat ix = leftEdge; ix <= leftEdge + width; ix += pixelSize) {
    CGContextFillRect(cx, CGRectMake(floorf(ix), self.insetBounds.origin.y,
                                     lineWidth, self.insetBounds.size.height));
  }
  for (CGFloat iy = topEdge; iy <= CGRectGetMaxY(self.insetBounds); iy += pixelSize) {
    CGContextFillRect(cx, CGRectMake(leftEdge, floorf(iy),
                                     width, lineWidth));
  }
}

- (void)setRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue alpha:(uint8_t)alpha atPixel:(CGPoint)pixel {
  NSInteger index = (NSInteger)pixel.y * kNumberOfColumns + (NSInteger)pixel.x;
  uint32_t color = _pixels[index];
  uint8_t* colorComponents = (uint8_t *)&color;
  CGFloat perc = alpha / 255.0f;
  colorComponents[0] = red * perc + colorComponents[0] * (1 - perc);
  colorComponents[1] = green * perc + colorComponents[1] * (1 - perc);
  colorComponents[2] = blue * perc + colorComponents[2] * (1 - perc);
  colorComponents[3] = 255;
  _pixels[index] = color;
}

@end
