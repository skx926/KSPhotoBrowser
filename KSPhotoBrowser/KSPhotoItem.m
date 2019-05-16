//
//  KSPhotoItem.m
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSPhotoItem.h"

@interface KSPhotoItem ()

@property (nonatomic, strong, readwrite) UIImage *thumbImage;
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, readwrite) NSURL *imageUrl;

@end

@implementation KSPhotoItem

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url
                          videoUrl:(nullable NSURL *)videoUrl {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image ? :[UIImage imageNamed:@"edit_personal_placeholder"];
        _imageUrl = url;
        _videoUrl = videoUrl;
    }
    return self;
}

- (instancetype)initWithSourceView:(UIView *)view
                          imageUrl:(NSURL *)url
                          videoUrl:(nullable NSURL *)videoUrl {
    return [self initWithSourceView:view
                         thumbImage:[view isKindOfClass:[UIImageView class]] ? [(UIImageView *)view image] ? : [UIImage imageNamed:@"edit_personal_placeholder"] : [UIImage imageNamed:@"edit_personal_placeholder"]
                           imageUrl:url
                           videoUrl:videoUrl];
    
}

- (instancetype)initWithSourceView:(UIView *)view
                             image:(UIImage *)image
                          videoUrl:(nullable NSURL *)videoUrl {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = nil;
        _image = image;
        _videoUrl = videoUrl;
    }
    return self;
}

+ (instancetype)itemWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url
                          videoUrl:(nullable NSURL *)videoUrl {
    return [[KSPhotoItem alloc] initWithSourceView:view
                                        thumbImage:image
                                          imageUrl:url
                                          videoUrl:videoUrl];
}

+ (instancetype)itemWithSourceView:(UIView *)view
                          imageUrl:(NSURL *)url
                          videoUrl:(nullable NSURL *)videoUrl {
    return [[KSPhotoItem alloc] initWithSourceView:view
                                          imageUrl:url
                                          videoUrl:videoUrl];
    
}

+ (instancetype)itemWithSourceView:(UIView *)view
                             image:(UIImage *)image
                          videoUrl:(nullable NSURL *)videoUrl {
    return [[KSPhotoItem alloc] initWithSourceView:view
                                             image:image
                                          videoUrl:videoUrl];
}

@end
