//
//  JVCollectionViewController.m
//  PuzzleLine
//
//  Created by Jeff Verkoeyen on 4/22/13.
//
//

#import "JVCollectionViewController.h"

@implementation JVCollectionViewController {
  UICollectionViewLayout* _layout;
  NIGroupedCellBackground* _cellBackground;
}

- (id)initWithLayout:(UICollectionViewLayout *)layout {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    _layout = layout;
    _actions = [[NICollectionViewActions alloc] initWithTarget:self];
    _cellBackground = [[NIGroupedCellBackground alloc] init];

    _cellBackground.borderRadius = 0;
    _cellBackground.highlightedInnerGradientColors =
    [@[
     (id)RGBCOLOR(0x22, 0x22, 0x55).CGColor,
     (id)RGBCOLOR(0x22, 0x22, 0x55).CGColor,] mutableCopy];
    _cellBackground.innerBackgroundColor = [UIColor blackColor];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (id)init {
  return [self initWithLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                       collectionViewLayout:_layout];
  _collectionView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  _collectionView.dataSource = self.model ? self.model : self;
  _collectionView.delegate = self;
  [self.view addSubview:_collectionView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

  [self.collectionView flashScrollIndicators];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  for (NSIndexPath* indexPath in _collectionView.indexPathsForSelectedItems) {
    [_collectionView deselectItemAtIndexPath:indexPath animated:animated];
  }
}

#pragma mark - NICollectionViewModelDelegate

- (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                        cellForCollectionView:(UICollectionView *)collectionView
                                  atIndexPath:(NSIndexPath *)indexPath
                                   withObject:(id)object {
  UICollectionViewCell *cell =
      [[NICollectionViewCellFactory class] collectionViewModel:collectionViewModel
                                         cellForCollectionView:collectionView
                                                   atIndexPath:indexPath
                                                    withObject:object];

  BOOL isFirst = YES;
  BOOL isLast = YES;
  NSInteger backgroundTag = ((isFirst ? NIGroupedCellBackgroundFlagIsFirst : 0)
                             | (isLast ? NIGroupedCellBackgroundFlagIsLast : 0)
                             | NIGroupedCellBackgroundFlagInitialized);

  if ([cell respondsToSelector:@selector(backgroundView)]
      && cell.backgroundView.tag != backgroundTag) {
    if ([cell respondsToSelector:@selector(setBackgroundView:)]) {
      cell.backgroundView =
          [[UIImageView alloc] initWithImage:[_cellBackground imageForFirst:isFirst
                                                                       last:isLast
                                                                highlighted:NO]];
    }
    if ([cell respondsToSelector:@selector(setSelectedBackgroundView:)]) {
      cell.selectedBackgroundView =
          [[UIImageView alloc] initWithImage:[_cellBackground imageForFirst:isFirst
                                                                       last:isLast
                                                                highlighted:YES]];
    }
    cell.backgroundView.tag = backgroundTag;
  }
  return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.actions collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self.actions collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

@end
