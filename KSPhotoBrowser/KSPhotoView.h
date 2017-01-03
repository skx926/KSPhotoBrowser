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

@class KSPhoto;

@interface KSPhotoView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) KSProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) KSPhoto *item;

- (void)setItem:(KSPhoto *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end
