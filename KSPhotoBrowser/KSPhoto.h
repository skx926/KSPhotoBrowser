//
//  KSPhoto.h
//  AVPlayerDemo
//
//  Created by Kyle Sun on 12/25/15.
//  Copyright © 2015 skx926. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSPhoto : NSObject

@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, assign) BOOL finished;

@end
