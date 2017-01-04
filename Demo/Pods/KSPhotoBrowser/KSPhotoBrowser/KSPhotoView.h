//
//  KSPhotoView.h
//  AVPlayerDemo
//
//  Created by Kyle Sun on 12/25/15.
//  Copyright © 2015 skx926. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSProgressLayer.h"

extern const CGFloat kKSPhotoViewPadding;

@class KSPhoto, YYAnimatedImageView;

@interface KSPhotoView : UIScrollView

@property (nonatomic, strong, readonly) YYAnimatedImageView *imageView;
@property (nonatomic, strong, readonly) KSProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) KSPhoto *item;

- (void)setItem:(KSPhoto *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end
