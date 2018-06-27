//
//  KSPhotoCell.h
//  KSPhotoBrowserDemo
//
//  Created by Kyle Sun on 2017/4/29.
//  Copyright © 2017年 Kyle Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KSPhotoCellType) {
    KSPhotoCellTypeRect,
    KSPhotoCellTypeRoundedRect,
    KSPhotoCellTypeCircular
};
@interface KSPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) KSPhotoCellType type;

@end
