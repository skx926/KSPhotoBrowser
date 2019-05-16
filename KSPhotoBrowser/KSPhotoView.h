//
//  KSPhotoView.h
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSProgressLayer.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kKSPhotoViewPadding;

@protocol KSImageManager;
@class KSPhotoItem;
@class KSPlayerView;

typedef void(^DragSliderCallback)(BOOL isDraged);

@interface KSPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) KSProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) KSPhotoItem *item;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setItem:(KSPhotoItem *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

// video player
@property (nonatomic, assign) CGRect playerFrame;
@property (nonatomic, copy) DragSliderCallback sliderDragCallback;

@end

NS_ASSUME_NONNULL_END
