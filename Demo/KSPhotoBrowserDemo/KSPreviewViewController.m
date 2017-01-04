//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by Kyle Sun on 12/25/15.
//  Copyright © 2015 skx926. All rights reserved.
//

#import "KSPreviewViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YYWebImage.h"

@interface KSPreviewViewController ()

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation KSPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _urls = @[@"http://ww2.sinaimg.cn/thumbnail/712a2410gw1fb7m1cqr09j20zg0qo79w.jpg",
              @"http://ww3.sinaimg.cn/thumbnail/712a2410gw1fb7m1dfq5hj20zg0qoafq.jpg",
              @"http://ww2.sinaimg.cn/thumbnail/712a2410gw1fb7m1d7jvdj20qo0zggpi.jpg",
              @"http://ww1.sinaimg.cn/thumbnail/712a2410gw1fb7m1e1wp1j20qo0zgn0q.jpg",
              @"http://ww4.sinaimg.cn/thumbnail/9f493043jw1f7akk8e0cmj28cj1fcb2f.jpg",
              @"http://ww2.sinaimg.cn/thumbnail/712a2410gw1fb7m1ef04vj20zg0qoad1.jpg",
              @"http://ww1.sinaimg.cn/thumbnail/9e3738f9gw1fb7pd37ux6j20c61jrn4t.jpg",
              @"http://ww3.sinaimg.cn/thumbnail/94dfe97bgw1fag0btw49ej20j60lvgpf.jpg"];
    
    CGFloat top = 64;
    CGFloat gap = 5;
    NSInteger count = 4;
    CGFloat width = (self.view.frame.size.width - gap * (count + 1)) / count;
    CGFloat height = width;
    _imageViews = @[].mutableCopy;
    for (int i = 0; i < _urls.count; i++) {
        CGFloat x = gap + (width + gap) * (i % count);
        CGFloat y = top + gap + (height + gap) * (i / count);
        CGRect rect = CGRectMake( x, y, width, height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.yy_imageURL = [NSURL URLWithString:_urls[i]];
        imageView.clipsToBounds = YES;
        imageView.tag = i;
        imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self.view addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:tap];
        [_imageViews addObject:imageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imageViewTapped:(UITapGestureRecognizer *)tap {
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < _imageViews.count; i++) {
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
        UIImageView *imageView = _imageViews[i];
        KSPhoto *item = [KSPhoto photoWithSourceView:imageView imageUrl:[NSURL URLWithString:url]];
        [items addObject:item];
    }
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:tap.view.tag];
    browser.dismissalStyle = _dismissalStyle;
    browser.backgroundStyle = _backgroundStyle;
    browser.loadingStyle = _loadingStyle;
    browser.pageindicatorStyle = _pageindicatorStyle;
    browser.bounces = _bounces;
    [browser showFromViewController:self];
}

@end
