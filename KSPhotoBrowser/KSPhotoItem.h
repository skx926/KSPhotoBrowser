//
//  KSPhotoItem.h
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSPhotoItem : NSObject

@property (nonatomic, strong, nullable) UIView *sourceView;
@property (nonatomic, strong, readonly, nullable) UIImage *thumbImage;
@property (nonatomic, strong, readonly, nullable) UIImage *image;
@property (nonatomic, strong, readonly, nullable) NSURL *imageUrl;
// if videoUrl is not nil, It is video.
@property (nonatomic, strong, readonly, nullable) NSURL *videoUrl;

@property (nonatomic, assign) BOOL finished;

- (nonnull instancetype)initWithSourceView:(nullable UIView *)view
                                thumbImage:(nullable UIImage *)image
                                  imageUrl:(nullable NSURL *)url
                                  videoUrl:(nullable NSURL *)videoUrl;
- (nonnull instancetype)initWithSourceView:(nullable UIView * )view
                                  imageUrl:(nullable NSURL *)url
                                  videoUrl:(nullable NSURL *)videoUrl;

- (nonnull instancetype)initWithSourceView:(nullable UIView *)view
                                     image:(nullable UIImage *)image
                                  videoUrl:(nullable NSURL *)videoUrl;


+ (nonnull instancetype)itemWithSourceView:(nullable UIView *)view
                                thumbImage:(nullable UIImage *)image
                                  imageUrl:(nullable NSURL *)url
                                  videoUrl:(nullable NSURL *)videoUrl;

+ (nonnull instancetype)itemWithSourceView:(nullable UIView *)view
                                  imageUrl:(nullable NSURL *)url
                                  videoUrl:(nullable NSURL *)videoUrl;

+ (nonnull instancetype)itemWithSourceView:(nullable UIView *)view
                                     image:(nullable UIImage *)image
                                  videoUrl:(nullable NSURL *)videoUrl;


@end
