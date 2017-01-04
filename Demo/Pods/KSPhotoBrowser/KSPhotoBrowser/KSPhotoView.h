//
//  KSPhotoView.h
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSProgressLayer.h"

extern const CGFloat kKSPhotoViewPadding;

@class KSPhotoItem, YYAnimatedImageView;

@interface KSPhotoView : UIScrollView

@property (nonatomic, strong, readonly) YYAnimatedImageView *imageView;
@property (nonatomic, strong, readonly) KSProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) KSPhotoItem *item;

- (void)setItem:(KSPhotoItem *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end
