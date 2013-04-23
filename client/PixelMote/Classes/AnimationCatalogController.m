//
//  AnimationCatalogController.m
//  PixelMote
//
//  Created by Jeff Verkoeyen on 2013-04-23.
//  Copyright (c) 2013 PixelFactory. All rights reserved.
//

#import "AnimationCatalogController.h"

#import "AnimationCell.h"

static const UIEdgeInsets kSectionInsets = {10, 10, 10, 10};
static const CGFloat kDistanceBetweenItems = 10;

@implementation AnimationCatalogController

- (id)initWithLayout:(UICollectionViewFlowLayout *)layout {
  layout = [[UICollectionViewFlowLayout alloc] init];
  if ((self = [super initWithLayout:layout])) {
    self.title = @"Animations";

    NSMutableArray* cellObjects = [NSMutableArray array];
    AnimationCellObject* obj = [[AnimationCellObject alloc] init];
    obj.filename = @"Test";
    [cellObjects addObject:obj];
    self.model = [[NICollectionViewModel alloc] initWithSectionedArray:cellObjects
                                                              delegate:self];
    [self.actions attachToClass:[AnimationCellObject class]
             navigationSelector:@selector(didTapLevelObject:atIndexPath:)];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.collectionView.backgroundColor = RGBCOLOR(0x11, 0x11, 0x11);
  self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.navigationController setNavigationBarHidden:NO animated:animated];
  [self updateLayoutWithInterfaceOrientation:NIInterfaceOrientation()];
}

- (void)updateLayoutWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  UICollectionViewFlowLayout* flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

  CGFloat viewWidth = self.view.bounds.size.width;
  CGFloat totalColumnWidth = viewWidth - kSectionInsets.left - kSectionInsets.right;
  NSInteger numberOfColumns = UIInterfaceOrientationIsLandscape(interfaceOrientation) ? 3 : 2;
  totalColumnWidth -= MAX(numberOfColumns - 1, 0) * kDistanceBetweenItems;
  CGFloat colWidth = totalColumnWidth / numberOfColumns;
  flow.itemSize = CGSizeMake(colWidth, colWidth);
  flow.sectionInset = kSectionInsets;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self updateLayoutWithInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - User Actions

- (void)didTapLevelObject:(AnimationCellObject *)levelObject atIndexPath:(NSIndexPath *)indexPath {
}

@end
