//
//  KSPhotoBrowser.m
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSPhotoBrowser.h"
#import "KSPhotoView.h"
#import "UIImage+KS.h"
#import "KSSDImageManager.h"

static const NSTimeInterval kAnimationDuration = 0.33;
static const NSTimeInterval kSpringAnimationDuration = 0.5;
static const CGFloat kPageControlHeight = 20;
static const CGFloat kPageControlBottomSpacing = 40;

static Class ImageManagerClass = nil;

@interface KSPhotoBrowser () <UIScrollViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *photoItems;
@property (nonatomic, strong) NSMutableSet *reusableItemViews;
@property (nonatomic, strong) NSMutableArray *visibleItemViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, assign) BOOL presented;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGRect startFrame;

@end

@implementation KSPhotoBrowser

// MAKR: - Initializer

+ (instancetype)browserWithPhotoItems:(NSArray<KSPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex {
    KSPhotoBrowser *browser = [[KSPhotoBrowser alloc] initWithPhotoItems:photoItems selectedIndex:selectedIndex];
    return browser;
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithMediaItems: instead.");
    return nil;
}

- (instancetype)initWithPhotoItems:(NSArray<KSPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _photoItems = [NSMutableArray arrayWithArray:photoItems];
        _currentPage = selectedIndex;
        
        _dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleRotation;
        _pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleDot;
        _backgroundStyle = KSPhotoBrowserBackgroundStyleBlurPhoto;
        _loadingStyle = KSPhotoBrowserImageLoadingStyleIndeterminate;
        
        _reusableItemViews = [[NSMutableSet alloc] init];
        _visibleItemViews = [[NSMutableArray alloc] init];
        
        if (ImageManagerClass == nil) {
            ImageManagerClass = KSSDImageManager.class;
        }
    }
    return self;
}

// MARK: - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.alpha = 0;
    [self.view addSubview:self.backgroundView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    if (_pageindicatorStyle == KSPhotoBrowserPageIndicatorStyleDot) {
        if (_photoItems.count > 1) {
            _pageControl = [[UIPageControl alloc] init];
            _pageControl.numberOfPages = _photoItems.count;
            _pageControl.currentPage = _currentPage;
            [self.view addSubview:_pageControl];
        }
    } else {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont systemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self configPageLabelWithPage:_currentPage];
        [self.view addSubview:_pageLabel];
    }
    
    [self setupFrames];
    
    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    KSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (_delegate && [_delegate respondsToSelector:@selector(ks_photoBrowser:didSelectItem:atIndex:)]) {
        [_delegate ks_photoBrowser:self didSelectItem:item atIndex:_currentPage];
    }
    
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    photoView.imageView.image = item.thumbImage;
    [photoView resizeImageView];
    
    if (_backgroundStyle == KSPhotoBrowserBackgroundStyleBlur) {
        [self blurBackgroundWithImage:[self screenshot] animated:NO];
    } else if (_backgroundStyle == KSPhotoBrowserBackgroundStyleBlurPhoto) {
        [self blurBackgroundWithImage:item.thumbImage animated:NO];
    }
    
    if (item.sourceView == nil) {
        photoView.alpha = 0;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.view.backgroundColor = [UIColor blackColor];
            self.backgroundView.alpha = 1;
            photoView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            self.presented = YES;
            [self setStatusBarHidden:YES];
        }];
        return;
    }
    
    CGRect endRect = photoView.imageView.frame;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    photoView.imageView.frame = sourceRect;
    
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.frame = endRect;
            self.view.backgroundColor = [UIColor blackColor];
            self.backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            self.presented = YES;
            [self setStatusBarHidden:YES];
        }];
    } else {
        CGRect startBounds = CGRectMake(0, 0, sourceRect.size.width, sourceRect.size.height);
        CGRect endBounds = CGRectMake(0, 0, endRect.size.width, endRect.size.height);
        UIBezierPath *startPath = [UIBezierPath bezierPathWithRoundedRect:startBounds cornerRadius:MAX(item.sourceView.layer.cornerRadius, 0.1)];
        UIBezierPath *endPath = [UIBezierPath bezierPathWithRoundedRect:endBounds cornerRadius:0.1];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = endBounds;
        photoView.imageView.layer.mask = maskLayer;
        
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.duration = kAnimationDuration;
        maskAnimation.fromValue = (__bridge id _Nullable)startPath.CGPath;
        maskAnimation.toValue = (__bridge id _Nullable)endPath.CGPath;
        maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [maskLayer addAnimation:maskAnimation forKey:nil];
        maskLayer.path = endPath.CGPath;
        
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.frame = endRect;
            self.view.backgroundColor = [UIColor blackColor];
            self.backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            self.presented = YES;
            [self setStatusBarHidden:YES];
            photoView.imageView.layer.mask = nil;
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupFrames];
}

- (void)dealloc {
    
}

// MARK: - Public

- (void)showFromViewController:(UIViewController *)vc {
    [vc presentViewController:self animated:NO completion:nil];
}

- (UIImage *)imageForItem:(KSPhotoItem *)item {
    return [ImageManagerClass imageForURL:item.imageUrl];
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    KSPhotoItem *item = [_photoItems objectAtIndex:index];
    return [ImageManagerClass imageForURL:item.imageUrl];
}

// MARK: - Private

- (void)setupFrames {
    CGRect rect = self.view.bounds;
    _backgroundView.frame = rect;
    
    rect.origin.x -= kKSPhotoViewPadding;
    rect.size.width += 2 * kKSPhotoViewPadding;
    _scrollView.frame = rect;
    
    CGRect pageRect = CGRectMake(0, self.view.bounds.size.height - kPageControlBottomSpacing, self.view.bounds.size.width, kPageControlHeight);
    _pageControl.frame = pageRect;
    _pageLabel.frame = pageRect;
    
    for (KSPhotoView *photoView in _visibleItemViews) {
        CGRect rect = _scrollView.bounds;
        rect.origin.x = photoView.tag * _scrollView.bounds.size.width;
        photoView.frame = rect;
        [photoView resizeImageView];
    }
    
    CGPoint contentOffset = CGPointMake(_scrollView.frame.size.width * _currentPage, 0);
    [_scrollView setContentOffset:contentOffset animated:false];
    if (contentOffset.x == 0) {
        [self scrollViewDidScroll:_scrollView];
    }
    
    CGSize contentSize = CGSizeMake(rect.size.width * _photoItems.count, rect.size.height);
    _scrollView.contentSize = contentSize;
}

- (void)setStatusBarHidden:(BOOL)hidden {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (hidden) {
        window.windowLevel = UIWindowLevelStatusBar + 1;
    } else {
        window.windowLevel = UIWindowLevelNormal;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (KSPhotoView *)photoViewForPage:(NSUInteger)page {
    for (KSPhotoView *photoView in _visibleItemViews) {
        if (photoView.tag == page) {
            return photoView;
        }
    }
    return nil;
}

- (KSPhotoView *)dequeueReusableItemView {
    KSPhotoView *photoView = [_reusableItemViews anyObject];
    if (photoView == nil) {
        photoView = [[KSPhotoView alloc] initWithFrame:_scrollView.bounds];
    } else {
        [_reusableItemViews removeObject:photoView];
    }
    photoView.tag = -1;
    return photoView;
}

- (void)updateReusableItemViews {
    NSMutableArray *itemsForRemove = @[].mutableCopy;
    for (KSPhotoView *photoView in _visibleItemViews) {
        if (photoView.frame.origin.x + photoView.frame.size.width < _scrollView.contentOffset.x - _scrollView.frame.size.width ||
            photoView.frame.origin.x > _scrollView.contentOffset.x + 2 * _scrollView.frame.size.width) {
            [photoView removeFromSuperview];
            [self configPhotoView:photoView withItem:nil];
            [itemsForRemove addObject:photoView];
            [_reusableItemViews addObject:photoView];
        }
    }
    [_visibleItemViews removeObjectsInArray:itemsForRemove];
}

- (void)configItemViews {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i < 0 || i >= _photoItems.count) {
            continue;
        }
        KSPhotoView *photoView = [self photoViewForPage:i];
        if (photoView == nil) {
            photoView = [self dequeueReusableItemView];
            CGRect rect = _scrollView.bounds;
            rect.origin.x = i * _scrollView.bounds.size.width;
            photoView.frame = rect;
            photoView.tag = i;
            [_scrollView addSubview:photoView];
            [_visibleItemViews addObject:photoView];
        }
        if (photoView.item == nil && self.presented) {
            KSPhotoItem *item = [_photoItems objectAtIndex:i];
            [self configPhotoView:photoView withItem:item];
        }
    }
    
    if (page != _currentPage && self.presented && (page >= 0 && page < _photoItems.count)) {
        KSPhotoItem *item = [_photoItems objectAtIndex:page];
        if (_backgroundStyle == KSPhotoBrowserBackgroundStyleBlurPhoto) {
            [self blurBackgroundWithImage:item.thumbImage animated:YES];
        }
        _currentPage = page;
        if (_pageindicatorStyle == KSPhotoBrowserPageIndicatorStyleDot) {
            _pageControl.currentPage = page;
        } else {
            [self configPageLabelWithPage:_currentPage];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(ks_photoBrowser:didSelectItem:atIndex:)]) {
            [_delegate ks_photoBrowser:self didSelectItem:item atIndex:page];
        }
    }
}

- (void)dismissAnimated:(BOOL)animated {
    for (KSPhotoView *photoView in _visibleItemViews) {
        [photoView cancelCurrentImageLoad];
    }
    KSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            item.sourceView.alpha = 1;
        }];
    } else {
        item.sourceView.alpha = 1;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)performRotationWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat angle = 0;
            CGFloat height = MAX(photoView.imageView.frame.size.height, photoView.frame.size.height);
            if (_startLocation.x < self.view.frame.size.width/2) {
                angle = -(M_PI / 2) * (point.y / height);
            } else {
                angle = (M_PI / 2) * (point.y / height);
            }
            CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, point.y);
            CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
            photoView.imageView.transform = transform;
            
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            self.backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showRotationCompletionAnimationFromPoint:point velocity:velocity];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performScaleWithPan:(UIPanGestureRecognizer *)pan {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:photoView];
    CGPoint velocity = [pan velocityInView:self.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            self.startFrame = photoView.imageView.frame;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            double s = MAX(percent, 0.3);
            
            CGFloat width = self.startFrame.size.width * s;
            CGFloat height = self.startFrame.size.height * s;
            
            CGFloat rateX = (_startLocation.x - self.startFrame.origin.x) / self.startFrame.size.width;
            CGFloat x = location.x - width * rateX;
            
            CGFloat rateY = (_startLocation.y - self.startFrame.origin.y) / self.startFrame.size.height;
            CGFloat y = location.y - height * rateY;
            
            NSLog(@"%f", rateY);
            
            photoView.imageView.frame = CGRectMake(x, y, width, height);
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            self.backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 100 || fabs(velocity.y) > 500) {
                [self showDismissalAnimation];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performSlideWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            self.backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSlideCompletionAnimationFromPoint:point velocity:velocity];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)screenshot {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, [UIScreen mainScreen].scale);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)blurBackgroundWithImage:(UIImage *)image animated:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurImage = [image ks_imageByBlurDark];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (animated) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    self.backgroundView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.backgroundView.image = blurImage;
                    [UIView animateWithDuration:kAnimationDuration animations:^{
                        self.backgroundView.alpha = 1;
                    } completion:nil];
                }];
            } else {
                self.backgroundView.image = blurImage;
            }
        });
    });
}

- (void)configPhotoView:(KSPhotoView *)photoView withItem:(KSPhotoItem *)item {
    [photoView setItem:item determinate:(_loadingStyle == KSPhotoBrowserImageLoadingStyleDeterminate)];
}

- (void)configPageLabelWithPage:(NSUInteger)page {
    _pageLabel.text = [NSString stringWithFormat:@"%lu / %lu", page+1, _photoItems.count];
}

- (void)handlePanBegin {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    KSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    [self setStatusBarHidden:NO];
    photoView.progressLayer.hidden = YES;
    item.sourceView.alpha = 0;
}

// MARK: - Gesture Recognizer

- (void)addGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didSingleTap:(UITapGestureRecognizer *)tap {
    [self showDismissalAnimation];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    KSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (!item.finished) {
        return;
    }
    if (photoView.zoomScale > 1) {
        [photoView setZoomScale:1 animated:YES];
    } else {
        CGPoint location = [tap locationInView:self.view];
        CGFloat maxZoomScale = photoView.maximumZoomScale;
        CGFloat width = self.view.bounds.size.width / maxZoomScale;
        CGFloat height = self.view.bounds.size.height / maxZoomScale;
        [photoView zoomToRect:CGRectMake(location.x - width/2, location.y - height/2, width, height) animated:YES];
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    UIImage *image = photoView.imageView.image;
    if (!image) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(ks_photoBrowser:didLongPressItem:atIndex:)]) {
        [_delegate ks_photoBrowser:self didLongPressItem:_photoItems[_currentPage] atIndex:_currentPage];
        return;
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        activityViewController.popoverPresentationController.sourceView = longPress.view;
        CGPoint point = [longPress locationInView:longPress.view];
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(point.x, point.y, 1, 1);
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)didPan:(UIPanGestureRecognizer *)pan {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    if (photoView.zoomScale > 1.1) {
        return;
    }
    
    switch (_dismissalStyle) {
        case KSPhotoBrowserInteractiveDismissalStyleRotation:
            [self performRotationWithPan:pan];
            break;
        case KSPhotoBrowserInteractiveDismissalStyleScale:
            [self performScaleWithPan:pan];
            break;
        case KSPhotoBrowserInteractiveDismissalStyleSlide:
            [self performSlideWithPan:pan];
            break;
        default:
            break;
    }
}

// MARK: - Animation

- (void)showCancellationAnimation {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    KSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    item.sourceView.alpha = 1;
    if (!item.finished) {
        photoView.progressLayer.hidden = NO;
    }
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            if (self.dismissalStyle == KSPhotoBrowserInteractiveDismissalStyleScale) {
                photoView.imageView.frame = self.startFrame;
            } else {
                photoView.imageView.transform = CGAffineTransformIdentity;
            }
            self.view.backgroundColor = [UIColor blackColor];
            self.backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self setStatusBarHidden:YES];
            [self configPhotoView:photoView withItem:item];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            if (self.dismissalStyle == KSPhotoBrowserInteractiveDismissalStyleScale) {
                photoView.imageView.frame = self.startFrame;
            } else {
                photoView.imageView.transform = CGAffineTransformIdentity;
            }
            self.view.backgroundColor = [UIColor blackColor];
            self.backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self setStatusBarHidden:YES];
            [self configPhotoView:photoView withItem:item];
        }];
    }
}

- (void)showRotationCompletionAnimationFromPoint:(CGPoint)point velocity:(CGPoint)velocity {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL startFromLeft = _startLocation.x < self.view.frame.size.width / 2;
    BOOL throwToTop = point.y < 0;
    CGFloat angle, toTranslationY;
    CGFloat height = MAX(photoView.imageView.frame.size.height, photoView.frame.size.height);
    
    if (throwToTop) {
        angle = startFromLeft ? (M_PI / 2) : -(M_PI / 2);
        toTranslationY = -height;
    } else {
        angle = startFromLeft ? -(M_PI / 2) : (M_PI / 2);
        toTranslationY = height;
    }
    
    CGFloat angle0 = 0;
    if (_startLocation.x < self.view.frame.size.width/2) {
        angle0 = -(M_PI / 2) * (point.y / height);
    } else {
        angle0 = (M_PI / 2) * (point.y / height);
    }
    
    NSTimeInterval duration = MIN(500 / fabs(velocity.y), kAnimationDuration);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(angle0);
    rotationAnimation.toValue = @(angle);
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationAnimation.fromValue = @(point.y);
    translationAnimation.toValue = @(toTranslationY);
    CAAnimationGroup *throwAnimation = [CAAnimationGroup animation];
    throwAnimation.duration = duration;
    throwAnimation.delegate = self;
    throwAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    throwAnimation.animations = @[rotationAnimation, translationAnimation];
    [throwAnimation setValue:@"throwAnimation" forKey:@"id"];
    [photoView.imageView.layer addAnimation:throwAnimation forKey:@"throwAnimation"];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, toTranslationY);
    CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
    photoView.imageView.transform = transform;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 0;
    } completion:nil];
}

- (void)showDismissalAnimation {
    KSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    [self setStatusBarHidden:NO];
    
    if (item.sourceView == nil) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
        return;
    }
    
    photoView.progressLayer.hidden = YES;
    item.sourceView.alpha = 0;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.frame = sourceRect;
            self.view.backgroundColor = [UIColor clearColor];
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
    } else {
        CGRect startRect = photoView.imageView.frame;
        CGRect endBounds = CGRectMake(0, 0, sourceRect.size.width, sourceRect.size.height);
        CGRect startBounds = CGRectMake(0, 0, startRect.size.width, startRect.size.height);
        UIBezierPath *startPath = [UIBezierPath bezierPathWithRoundedRect:startBounds cornerRadius:0.1];
        UIBezierPath *endPath = [UIBezierPath bezierPathWithRoundedRect:endBounds cornerRadius:MAX(item.sourceView.layer.cornerRadius, 0.1)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = endBounds;
        photoView.imageView.layer.mask = maskLayer;
        
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.duration = kAnimationDuration;
        maskAnimation.fromValue = (__bridge id _Nullable)startPath.CGPath;
        maskAnimation.toValue = (__bridge id _Nullable)endPath.CGPath;
        maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [maskLayer addAnimation:maskAnimation forKey:nil];
        maskLayer.path = endPath.CGPath;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.frame = sourceRect;
            self.view.backgroundColor = [UIColor clearColor];
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
    }
}

- (void)showSlideCompletionAnimationFromPoint:(CGPoint)point velocity:(CGPoint)velocity {
    KSPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = -self.view.frame.size.height;
    } else {
        toTranslationY = self.view.frame.size.height;
    }
    NSTimeInterval duration = MIN(500 / fabs(velocity.y), kAnimationDuration);
    [UIView animateWithDuration:duration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:YES];
    }];
}

// MARK: - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
        [self dismissAnimated:YES];
    }
}

// MARK: - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateReusableItemViews];
    [self configItemViews];
}

// MARK: - Setter

+ (void)setImageManagerClass:(Class)imageManagerClass {
    ImageManagerClass = imageManagerClass;
}

+ (void)setImageViewBackgroundColor:(UIColor *)imageViewBackgroundColor {
    KSPhotoView.backgroundColor = imageViewBackgroundColor;
}

// MARK: - Getter

+ (Class)imageManagerClass {
    return ImageManagerClass;
}

+ (UIColor *)imageViewBackgroundColor {
    return KSPhotoView.backgroundColor;
}

@end
