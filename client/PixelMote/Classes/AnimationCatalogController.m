//
//  AnimationCatalogController.m
//  PixelMote
//
//  Created by Jeff Verkoeyen on 2013-04-23.
//  Copyright (c) 2013 PixelFactory. All rights reserved.
//

#import "AnimationCatalogController.h"

#import "AnimationCell.h"
#import "PFNetworkManager.h"

static const UIEdgeInsets kSectionInsets = {10, 10, 10, 10};
static const CGFloat kDistanceBetweenItems = 10;

@implementation AnimationCatalogController

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithLayout:(UICollectionViewFlowLayout *)layout {
  layout = [[UICollectionViewFlowLayout alloc] init];
  if ((self = [super initWithLayout:layout])) {
    self.title = @"Animations";

    [self.actions attachToClass:[AnimationCellObject class]
             navigationSelector:@selector(didTapLevelObject:atIndexPath:)];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didDownloadAnimations) name:PHNetworkManagerDidLoadAnimationsServerNotification object:nil];

    [self updateModel];
  }
  return self;
}

- (void)updateModel {
  NSMutableArray* cellObjects = [NSMutableArray array];
  NSArray* animations = [[PFNetworkManager sharedInstance] animations];
  for (NSDictionary* animation in animations) {
    AnimationCellObject* object = [[AnimationCellObject alloc] init];
    object.name = animation[@"name"];
    NSData* imageData = animation[@"image"];
    UIImage* image = [UIImage imageWithData:imageData];
    object.image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDownMirrored];
    [cellObjects addObject:object];
  }
  self.model = [[NICollectionViewModel alloc] initWithSectionedArray:cellObjects
                                                            delegate:self];
  self.collectionView.dataSource = self.model;
  [self.collectionView reloadData];
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

  // c for control
  // l for list
  [[PFNetworkManager sharedInstance] sendDataWithMessageType:@"c" data:[@"l" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)updateLayoutWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  UICollectionViewFlowLayout* flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

  CGFloat viewWidth = self.view.bounds.size.width;
  CGFloat totalColumnWidth = viewWidth - kSectionInsets.left - kSectionInsets.right;
  NSInteger numberOfColumns = UIInterfaceOrientationIsLandscape(interfaceOrientation) ? 3 : 2;
  totalColumnWidth -= MAX(numberOfColumns - 1, 0) * kDistanceBetweenItems;
  CGFloat colWidth = totalColumnWidth / numberOfColumns;
  flow.itemSize = CGSizeMake(colWidth, colWidth * 32 / 48);
  flow.sectionInset = kSectionInsets;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self updateLayoutWithInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - User Actions

- (void)didTapLevelObject:(AnimationCellObject *)levelObject atIndexPath:(NSIndexPath *)indexPath {
}

- (void)didDownloadAnimations {
  [self updateModel];
}

@end
