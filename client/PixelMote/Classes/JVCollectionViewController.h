//
//  JVCollectionViewController.h
//  PuzzleLine
//
//  Created by Jeff Verkoeyen on 4/22/13.
//
//

#import <UIKit/UIKit.h>

@interface JVCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, NICollectionViewModelDelegate>

// Designated initializer.
- (id)initWithLayout:(UICollectionViewLayout *)layout;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NICollectionViewModel* model;
@property (nonatomic, strong) NICollectionViewActions* actions;

@end
