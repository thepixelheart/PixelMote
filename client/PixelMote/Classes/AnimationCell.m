//
//  LevelCell.m
//  PuzzleLine
//
//  Created by Jeffrey Verkoeyen on 12-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnimationCell.h"

@implementation AnimationCellObject

- (Class)collectionViewCellClass {
  return [AnimationCell class];
}

@end

@implementation AnimationCell {
  UILabel* _label;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32];
    _label.numberOfLines = 0;
    _label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_label];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  self.contentView.frame = CGRectInset(self.bounds, 10, 10);
  _label.frame = self.contentView.bounds;
  CGSize size = [_label sizeThatFits:self.contentView.bounds.size];
  _label.frame = CGRectMake(0, self.contentView.bounds.size.height - size.height, size.width, size.height);
}

- (BOOL)shouldUpdateCellWithObject:(AnimationCellObject *)object {
  _label.text = object.filename;
  [self setNeedsLayout];
  return YES;
}

@end
