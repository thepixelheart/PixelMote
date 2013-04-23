//
//  LevelCell.h
//  PuzzleLine
//
//  Created by Jeffrey Verkoeyen on 12-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationCellObject : NSObject <NICollectionViewCellObject>
@property (nonatomic, readwrite, copy) NSString* filename;
@end

@interface AnimationCell : UICollectionViewCell <NICollectionViewCell>
@end
