//
//  ViewController.m
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSPreviewViewController.h"
#import "YYWebImage.h"
#import "KSPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "KSYYImageManager.h"

static NSString * const kAvatarUrl = @"https://tvax2.sinaimg.cn/crop.0.0.750.750.180/a15bd3a5ly8fqkp954lyyj20ku0kugn1.jpg";

@interface KSPreviewViewController ()<KSPhotoBrowserDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *urls;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation KSPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *urls = @[@"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f12r9ku6wjj20u00mhn22.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg",
                      @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f01hhs2omoj20u00jzwh9.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1exkkw984e3j20u00miacm.jpg",
                      @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1ezvdc5dt1pj20ku0kujt7.jpg",
                      @"http://ww3.sinaimg.cn/bmiddle/a15bd3a5jw1ew68tajal7j20u011iacr.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
                      @"http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg"];
    _urls = @[].mutableCopy;
    for (int i = 0; i < 10; i++) {
        [_urls addObjectsFromArray:urls];
    }
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [KSPhotoBrowser setImageManagerClass:KSSDImageManager.class];
    } else {
        [KSPhotoBrowser setImageManagerClass:KSYYImageManager.class];
    }
    
    self.avatarImageView.layer.cornerRadius = 40;
    self.avatarImageView.layer.masksToBounds = true;
    self.avatarImageView.userInteractionEnabled = true;
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:kAvatarUrl]];
    } else {
        self.avatarImageView.yy_imageURL = [NSURL URLWithString:kAvatarUrl];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    tap.numberOfTapsRequired = 1;
    [self.avatarImageView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)avatarTapped:(UITapGestureRecognizer *)tap {
    KSPhotoItem *item = [KSPhotoItem itemWithSourceView:self.avatarImageView imageUrl:[NSURL URLWithString:kAvatarUrl]];
    [self showBrowserWithPhotoItems:@[item] selectedIndex:0];
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
    if (_imageManagerType == KSImageManagerTypeSDWebImage) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_urls[indexPath.row]]];
    } else {
        cell.imageView.yy_imageURL = [NSURL URLWithString:_urls[indexPath.row]];
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
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"bmiddle" withString:@"large"];
        KSPhotoItem *item = [KSPhotoItem itemWithSourceView:cell.imageView imageUrl:[NSURL URLWithString:url]];
        [items addObject:item];
    }
    [self showBrowserWithPhotoItems:items selectedIndex:indexPath.item];
}

@end
