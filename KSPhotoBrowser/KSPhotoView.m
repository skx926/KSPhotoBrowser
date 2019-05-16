//
//  KSPhotoView.m
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 12/25/16.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import "KSPhotoView.h"
#import "KSPhotoItem.h"
#import "KSProgressLayer.h"
#import "KSImageManagerProtocol.h"
#import "KSPhotoBrowser.h"
#import "KSSlider.h"

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

const CGFloat kKSPhotoViewPadding = 10;
const CGFloat kKSPhotoViewMaxScale = 3;

@interface KSPhotoView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) KSProgressLayer *progressLayer;
@property (nonatomic, strong, readwrite) KSPhotoItem *item;

// player
@property (nonatomic, strong, readwrite) KSPlayerView *playerView;

@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) KSSlider *progressSlider;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UILabel *currentTimeLabel;

@property (assign, nonatomic) BOOL isDragSlider;
@property (strong, nonatomic) NSTimer *hideControlsTimer;

@end

@implementation KSPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.maximumZoomScale = kKSPhotoViewMaxScale;
        self.multipleTouchEnabled = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _imageView = [[KSPhotoBrowser.imageViewClass  alloc] init];
        _imageView.backgroundColor = [UIColor darkGrayColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self resizeImageView];
        
        _progressLayer = [[KSProgressLayer alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
        
        [self initPlayerToolsView];
    }
    return self;
}

- (void)initPlayerToolsView {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    _playerView = [[KSPlayerView alloc] initWithFrame:CGRectMake(0, 0, width, ceilf(width*9/16))];
    _playerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_playerView];
    
    WeakSelf(self)
    _playerView.playerTimeCallback = ^(BOOL isTotalTime, CGFloat times) {
        [weakself updatePlayerTimes:times isTotalTime:isTotalTime];
    };
    
    UIFont *timeFont = [UIFont systemFontOfSize:12];
    CGFloat timeLabelHeight = timeFont.lineHeight +2;
    CGFloat timeLabelWidth = 38;
    
    CGFloat bottomMargin = 20;
    
    
    CGFloat playButtonWidth = 38;
    _playButton = [[UIButton alloc] init];
    [_playButton setImage:[UIImage imageNamed:@"btn_video_play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"btn_video_pause"] forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.selected = NO;
    [self addSubview:_playButton];
    _playButton.frame = CGRectMake(12, height -playButtonWidth -bottomMargin, playButtonWidth, playButtonWidth);
    
    //时间
    _currentTimeLabel = [[UILabel alloc] init];
    _currentTimeLabel.font = timeFont;
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    _currentTimeLabel.preferredMaxLayoutWidth = 200;
    [self addSubview:_currentTimeLabel];
    [self bringSubviewToFront:_currentTimeLabel];
    _currentTimeLabel.frame = CGRectMake(CGRectGetMaxX(_playButton.frame) +2, height -timeLabelHeight -bottomMargin, timeLabelWidth, timeLabelHeight);
    _playButton.center = CGPointMake(_playButton.center.x, _currentTimeLabel.center.y);
    
    _totalTimeLabel = [[UILabel alloc]init];
    _totalTimeLabel.font = _currentTimeLabel.font;
    _totalTimeLabel.textColor = [UIColor whiteColor];
    _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    _totalTimeLabel.preferredMaxLayoutWidth = 200;
    [self addSubview:_totalTimeLabel];
    [self bringSubviewToFront:_totalTimeLabel];
    _totalTimeLabel.frame = CGRectMake(width -timeLabelWidth -12, CGRectGetMinY(_currentTimeLabel.frame), timeLabelWidth, timeLabelHeight);
    
    
    _progressSlider = [[KSSlider alloc] init];
    [_progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    [_progressSlider setMinimumTrackTintColor:[UIColor redColor]];
    [_progressSlider setMaximumTrackTintColor:[UIColor whiteColor]];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"icon_progress_slider"] forState:UIControlStateNormal];
    [_progressSlider setMinimumValue:0];
    [_progressSlider setMaximumValue:1];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_progressSlider];
    [self bringSubviewToFront:_progressSlider];
    CGFloat sliderWidth = CGRectGetMinX(_totalTimeLabel.frame) -8 -CGRectGetMaxX(_currentTimeLabel.frame) -8;
    _progressSlider.frame = CGRectMake(CGRectGetMaxX(_currentTimeLabel.frame) +8, 0, sliderWidth, 12);
    _progressSlider.center = CGPointMake(_progressSlider.center.x, _currentTimeLabel.center.y);
    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
    [_progressSlider addGestureRecognizer:sliderTap];
    
    _progressSlider.sliderHitCallback = ^(BOOL isHitSlider) {
        weakself.isDragSlider = isHitSlider;
    };
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
    // default hidden player controls
    _playerView.hidden = YES;
    [self hiddenControls:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setItem:(KSPhotoItem *)item determinate:(BOOL)determinate {
    _item = item;
    [KSPhotoBrowser.imageManagerClass cancelImageRequestForImageView:_imageView];
    if (item) {
        if (item.image) {
            _imageView.image = item.image;
            _item.finished = YES;
            [_progressLayer stopSpin];
            _progressLayer.hidden = YES;
            [self resizeImageView];
            return;
        }
        __weak typeof(self) wself = self;
        KSImageManagerProgressBlock progressBlock = nil;
        if (determinate) {
            progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
                __strong typeof(wself) sself = wself;
                double progress = (double)receivedSize / expectedSize;
                sself.progressLayer.hidden = NO;
                sself.progressLayer.strokeEnd = MAX(progress, 0.01);
            };
        } else {
            [_progressLayer startSpin];
        }
        _progressLayer.hidden = NO;
        
        _imageView.image = item.thumbImage;
        [KSPhotoBrowser.imageManagerClass setImageForImageView:_imageView withURL:item.imageUrl placeholder:item.thumbImage progress:progressBlock completion:^(UIImage *image, NSURL *url, BOOL finished, NSError *error) {
            __strong typeof(wself) sself = wself;
            if (finished) {
                [sself resizeImageView];
            }
            [sself.progressLayer stopSpin];
            sself.progressLayer.hidden = YES;
            sself.item.finished = YES;
        }];
    } else {
        [_progressLayer stopSpin];
        _progressLayer.hidden = YES;
        _imageView.image = nil;
    }
    [self resizeImageView];
    
    if ( item.videoUrl ) {
        _playerView.hidden = NO;
        [self hiddenControls:NO];
        [_playerView loadVideoPath:item.videoUrl];
    } else {
        _playerView.hidden = YES;
        [self hiddenControls:YES];
    }
}

- (void)setPlayerFrame:(CGRect)playerFrame {
    _playerFrame = playerFrame;
    CGFloat yOffset = 0;
    if ( playerFrame.size.height > ceilf(playerFrame.size.width*9/16) ) {
        yOffset = playerFrame.size.height/2 -ceilf(playerFrame.size.width*9/16)/2;
    }
    // center player view
    _playerView.frame = CGRectMake(playerFrame.origin.x, playerFrame.origin.y +yOffset, playerFrame.size.width, ceilf(playerFrame.size.width*9/16));
    [_playerView setNeedsLayout];
    [self setNeedsLayout];
}

- (void)resizeImageView {
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = self.frame.size.width - 2 * kKSPhotoViewPadding;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        
        _imageView.frame = rect;
        
        // If image is very high, show top content.
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // If image is very wide, make sure user can zoom to fullscreen.
        if (width / height > 2) {
            self.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        CGFloat width = self.frame.size.width - 2 * kKSPhotoViewPadding;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    self.contentSize = _imageView.frame.size;
}

- (void)cancelCurrentImageLoad {
    [KSPhotoBrowser.imageManagerClass cancelImageRequestForImageView:_imageView];
    [_progressLayer stopSpin];
}

- (BOOL)isScrollViewOnTopOrBottom {
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    if (translation.y > 0 && self.contentOffset.y <= 0) {
        return YES;
    }
    CGFloat maxOffsetY = floor(self.contentSize.height - self.bounds.size.height);
    if (translation.y < 0 && self.contentOffset.y >= maxOffsetY) {
        return YES;
    }
    return NO;
}

#pragma mark - ScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            if ([self isScrollViewOnTopOrBottom]) {
                return NO;
            }
        }
    }
    return YES;
}


#pragma mark - Player
- (void)playOrPause:(id)sender {
    if( _playerView.videoPlayer.rate == 0 ) {
        [_playerView startPlayAnimate:YES];
        _playButton.selected = YES;
    } else {
        [_playerView stopPlayAnimate:YES];
        _playButton.selected = NO;
    }
    [self addHidePlayControlsTimer];
}

- (void)updatePlayerTimes:(CGFloat)times isTotalTime:(BOOL)isTotalTime {
    if ( isTotalTime ) {
        [self updateTotolTime:times];
    } else {
        [self updateCurrentTime:times];
        
        CGFloat sliderProgress = _playerView.current/_playerView.duration;
        [_progressSlider setValue:sliderProgress animated:YES];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if ( !_item.videoUrl ) {
        return;
    }
    CGPoint location = [tap locationInView:self];
    if( CGRectContainsPoint(self.bounds, location) ) {
        [self switchControlShown];
    }
}

- (void)switchControlShown {
    [self stopTimer];
    [self hiddenControls:!_progressSlider.hidden];
    [self addHidePlayControlsTimer];
}


- (void)stopTimer {
    if( _hideControlsTimer ) {
        [_hideControlsTimer invalidate];
        _hideControlsTimer = nil;
    }
}

- (void)addHidePlayControlsTimer {
    [self stopTimer];
    _hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                          target:self
                                                        selector:@selector(startHideControlsAnimation:)
                                                        userInfo:nil
                                                         repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_hideControlsTimer forMode:NSRunLoopCommonModes];
}

- (void)startHideControlsAnimation:(id)sender {
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self hiddenControls:YES];
                     }];
}

- (void)hiddenControls:(BOOL)hidden {
    _progressSlider.hidden = hidden;
    _currentTimeLabel.hidden = hidden;
    _totalTimeLabel.hidden = hidden;
    _playButton.hidden = hidden;
}

// slider
- (void)setIsDragSlider:(BOOL)isDragSlider {
    _isDragSlider = isDragSlider;
    _playerView.isDragSlider = isDragSlider;
    
    self.scrollEnabled = !isDragSlider;
    if ( [self.superview isKindOfClass:[UIScrollView class]] ) {
        UIScrollView *superScroll = (UIScrollView *)self.superview;
        superScroll.scrollEnabled = !isDragSlider;
    }
    if ( _sliderDragCallback ) {
        _sliderDragCallback(isDragSlider);
    }
}


- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        
        CGFloat total = _playerView.duration;
        CMTime dragedCMTime  = CMTimeMake(tapValue *total, 1);
        [self endSlideTheVideo:dragedCMTime];
    }
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    self.isDragSlider = YES;
}

- (void)progressSliderValueChanged:(UISlider *)sender {
    CGFloat changetime = sender.value *_playerView.duration;
    [self updateCurrentTime:changetime];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    //计算出拖动的当前秒数
    CGFloat total = _playerView.duration;
    
    NSInteger dragedSeconds = floorf(total * slider.value);
    CMTime dragedCMTime  = CMTimeMake(dragedSeconds, 1);
    
    [self endSlideTheVideo:dragedCMTime];
}

- (void)endSlideTheVideo:(CMTime)dragedCMTime {
    WeakSelf(self)
    [_playerView.videoPlayer seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finish){
        weakself.isDragSlider = NO;
    }];
}


- (void)updateCurrentTime:(CGFloat)time {
    long videocurrent = ceil(time);
    
    NSString *str =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    _currentTimeLabel.text = str;
}

- (void)updateTotolTime:(CGFloat)time {
    long videoLenth = ceil(time);
    NSString *strtotal = [NSString stringWithFormat:@"%02li:%02li",lround(floor(videoLenth/60.f)),lround(floor(videoLenth/1.f))%60];
    _totalTimeLabel.text = strtotal;
}

@end
