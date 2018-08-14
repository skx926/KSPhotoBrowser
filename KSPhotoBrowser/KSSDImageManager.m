//
//  KSSDWebImage.m
//  KSPhotoBrowserDemo
//
//  Created by Kyle Sun on 22/05/2017.
//  Copyright © 2017 Kyle Sun. All rights reserved.
//

#import "KSSDImageManager.h"

#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#else
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "SDWebImageManager.h"
#import "FLAnimatedImageView.h"
#endif

@implementation KSSDImageManager

+ (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL *)imageURL
                 placeholder:(UIImage *)placeholder
                    progress:(KSImageManagerProgressBlock)progress
                  completion:(KSImageManagerCompletionBlock)completion
{
    SDWebImageDownloaderProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    };
    SDExternalCompletionBlock completionBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completion) {
            completion(image, imageURL, !error, error);
        }
    };
    [imageView sd_setImageWithURL:imageURL placeholderImage:placeholder options:SDWebImageRetryFailed progress:progressBlock completed:completionBlock];
}

+ (void)cancelImageRequestForImageView:(UIImageView *)imageView {
    [imageView sd_cancelCurrentImageLoad];
}

+ (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.imageCache imageFromMemoryCacheForKey:key];
}

+ (UIImage *)imageForURL:(NSURL *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.imageCache imageFromCacheForKey:key];
}

@end
