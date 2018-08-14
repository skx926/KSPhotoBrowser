//
//  ViewController.m
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSPreviewViewController.h"
#import "KSPhotoCell.h"
#import "KSYYImageManager.h"
#import <KSPhotoBrowser/KSSDImageManager.h>
#import <YYWebImage/YYWebImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>

static NSString * const kAvatarUrl = @"https://tvax2.sinaimg.cn/crop.0.0.750.750.180/a15bd3a5ly8fqkp954lyyj20ku0kugn1.jpg";

@interface KSPreviewViewController ()<KSPhotoBrowserDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *urls;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KSPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *urls =  @[
                       @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                       @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                       @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                       @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                       @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
                       @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg",
                       @"http://ww4.sinaimg.cn/thumbnail/a15bd3a5jw1f12r9ku6wjj20u00mhn22.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg",
                       @"http://ww4.sinaimg.cn/thumbnail/a15bd3a5jw1f01hhs2omoj20u00jzwh9.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/a15bd3a5jw1exkkw984e3j20u00miacm.jpg",
                       @"http://ww4.sinaimg.cn/thumbnail/a15bd3a5jw1ezvdc5dt1pj20ku0kujt7.jpg",
                       @"http://ww3.sinaimg.cn/thumbnail/a15bd3a5jw1ew68tajal7j20u011iacr.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
                       @"http://ww2.sinaimg.cn/thumbnail/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg",
                       ];
    _urls = @[].mutableCopy;
    for (int i = 0; i < 10; i++) {
        [_urls addObjectsFromArray:urls];
    }
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [KSPhotoBrowser setImageManagerClass:KSSDImageManager.class];
        [KSPhotoBrowser setImageViewClass:FLAnimatedImageView.class];
    } else {
        [KSPhotoBrowser setImageManagerClass:KSYYImageManager.class];
        [KSPhotoBrowser setImageViewClass:YYAnimatedImageView.class];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBrowserWithPhotoItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex {
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:selectedIndex];
    browser.delegate = self;
    browser.dismissalStyle = _dismissalStyle;
    browser.backgroundStyle = _backgroundStyle;
    browser.loadingStyle = _loadingStyle;
    browser.pageindicatorStyle = _pageindicatorStyle;
    browser.bounces = _bounces;
    [browser showFromViewController:self];
}

// MARK: - KSPhotoBrowserDelegate

- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index {
    NSLog(@"selected index: %ld", index);
}

- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didLongPressItem:(KSPhotoItem *)item atIndex:(NSUInteger)index {
    UIImage *image = [browser imageForItem:item];
    NSLog(@"long pressed image:%@", image);
}

// MARK: - CollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    NSString *url = _urls[indexPath.row];
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    } else {
        cell.imageView.yy_imageURL = [NSURL URLWithString:url];
    }
    if (indexPath.item % 3 == 0) {
        cell.type = KSPhotoCellTypeRect;
    } else if (indexPath.item % 3 == 1) {
        cell.type = KSPhotoCellTypeRoundedRect;
    } else {
        cell.type = KSPhotoCellTypeCircular;
    }
    return cell;
}

// MARK: - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < _urls.count; i++) {
        KSPhotoCell *cell = (KSPhotoCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        KSPhotoItem *item = [KSPhotoItem itemWithSourceView:cell.imageView imageUrl:[NSURL URLWithString:url]];
        [items addObject:item];
    }
    [self showBrowserWithPhotoItems:items selectedIndex:indexPath.item];
}

@end
