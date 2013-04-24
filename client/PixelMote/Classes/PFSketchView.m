//
//  PFSketchView.m
//  PixelMote
//
//  Created by Jeff Verkoeyen on 2013-04-23.
//  Copyright (c) 2013 PixelFactory. All rights reserved.
//

#import "PFSketchView.h"

#import "PFNetworkManager.h"
#import <QuartzCore/QuartzCore.h>

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

    uint16_t bits = (((uint8_t)pixel.x) << 8) | ((uint8_t)pixel.y);
    NSData *data = [NSData dataWithBytes:&bits length:sizeof(bits)];
    [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"x" data:data];
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
  UIImageView* _imageView;
  uint32_t _pixels[kNumberOfColumns * kNumberOfRows];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _imageView = [[UIImageView alloc] init];
    _imageView.layer.magnificationFilter = kCAFilterNearest;
    [self addSubview:_imageView];

    self.contentMode = UIViewContentModeRedraw;
    bzero(_pixels, sizeof(uint32_t) * kNumberOfRows * kNumberOfColumns);

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didStreamNotification:) name:PHNetworkManagerStreamNotification object:nil];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  _imageView.frame = CGRectMake([self leftEdge], [self topEdge], [self width], [self height]);
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

#pragma mark - NSNotification

- (void)didStreamNotification:(NSNotification *)notification {
  UIImage* image = notification.userInfo[PHNetworkManagerStreamImageKey];
  _imageView.image = image;
  [_imageView sizeToFit];
}

@end
