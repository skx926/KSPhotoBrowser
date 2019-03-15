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
@property (nonatomic, assign, readwrite) KSItemType type;

@end

@implementation KSPhotoItem

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url
                              type:(KSItemType)type {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = url;
        _type = type;
    }
    return self;
}

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url {
    return [self initWithSourceView:view thumbImage:image imageUrl:url type:KSItemTypeImage];
}

- (instancetype)initWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url
{
    return [self initWithSourceView:view
                         thumbImage:view.image
                           imageUrl:url];
}

- (instancetype)initWithSourceView:(UIImageView *)view
                             image:(UIImage *)image {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = nil;
        _image = image;
    }
    return self;
}

+ (instancetype)itemWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url
{
    return [[KSPhotoItem alloc] initWithSourceView:view
                                    thumbImage:image
                                      imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIView *)view thumbImage:(UIImage *)image imageUrl:(NSURL *)url type:(KSItemType)type {
    return [[KSPhotoItem alloc] initWithSourceView:view thumbImage:image imageUrl:url type:type];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url
{
    return [[KSPhotoItem alloc] initWithSourceView:view
                                          imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                             image:(UIImage *)image
{
    return [[KSPhotoItem alloc] initWithSourceView:view
                                             image:image];
}

@end
