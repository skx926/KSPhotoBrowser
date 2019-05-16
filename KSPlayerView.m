//
//  KSPlayerView.m
//  KSPhotoBrowser
//
//  Created by ml on 2019/5/16.
//

#import "KSPlayerView.h"

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

@interface KSPlayerView ()
{
    BOOL            _firstLoad;
}

@property (nonatomic, copy) NSString *videoUrlString;

@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, assign) CGFloat duration; //视频总时间
@property (nonatomic, assign) CGFloat current; //当前播放时间

@end

@implementation KSPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        _firstLoad = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    }
    return self;
}


- (UIButton *)playButton {
    if( !_playButton ) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_playButton setImage:[UIImage imageNamed:@"btn_video_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"btn_video_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.selected = NO;
        [self addSubview:_playButton];
        _playButton.frame = CGRectMake(0, 0, 49, 49);
        _playButton.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    }
    return _playButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //    CALayer 默认的隐式动画也可以通过CATransaction来关闭
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _playerLayer.frame = self.bounds;
    [CATransaction commit];
    
    _playButton.frame = CGRectMake(0, 0, 49, 49);
    _playButton.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
}


- (void)loadVideoPath:(NSURL *)urlString {
    if ( [_videoUrlString isEqualToString:urlString.absoluteString] ) {
        return;
    }
    _videoUrlString = urlString.absoluteString;
    
    if ( self.timeObserver ) {
        [self.videoPlayer removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    if ( [urlString.absoluteString containsString:@"http://"] || [urlString.absoluteString containsString:@"https://"] ) {
        self.playerItem = [[AVPlayerItem alloc] initWithURL:urlString];
    } else {
        self.playerItem = [AVPlayerItem playerItemWithURL:urlString];
    }
    _videoPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_videoPlayer];
    
    _playerLayer.frame = self.bounds;
    //    _playerLayer.backgroundColor = WHITECOLOR.CGColor;
    [self.layer addSublayer:_playerLayer];
    
    self.playButton.hidden = NO;
    [self bringSubviewToFront:self.playButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            [self addVideoTimerObserver:playerItem];
        }else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self.videoPlayer pause];
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if( _firstLoad ) {
            [self updatePlayerTimeIsTotalTime:NO timeSeconds:0];
            
            self.duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
            [self updatePlayerTimeIsTotalTime:YES timeSeconds:self.duration];
            _firstLoad = NO;
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if ( playerItem == self.playerItem ) {
        if ( self.playToEndCallback ) {
            self.playToEndCallback(YES);
            self.playButton.hidden = NO;
            self.playButton.selected = NO;
        }
        [playerItem seekToTime:kCMTimeZero];
    }
}

- (void)appWillEnterForeground:(id)sender {
    [_videoPlayer play];
}

- (void)appDidEnterBackground:(id)sender {
    [self pauseAnimate:YES];
}

- (void)playbackFinished:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if ( playerItem != self.playerItem ) {
        return;
    }
    
    if ( self.playToEndCallback ) {
        self.playToEndCallback(YES);
    }
    if ( _playCallback ) {
        _playCallback(NO);
    }
    self.playButton.hidden = NO;
    self.playButton.selected = NO;
    
//    [self.videoPlayer.currentItem seekToTime:kCMTimeZero];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if ( playerItem != self.playerItem ) {
        return;
    }
    [self playAnimate:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if ( playerItem != self.playerItem ) {
        return;
    }
    [self pauseAnimate:YES];
}

- (void)addVideoTimerObserver:(AVPlayerItem *)playerItem {
    WeakSelf(self)
    self.timeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ( weakself.isDragSlider) {
            return ;
        }
        CGFloat current = playerItem.currentTime.value/playerItem.currentTime.timescale;
        weakself.current = current;
        [weakself updatePlayerTimeIsTotalTime:NO timeSeconds:weakself.current];
        
        weakself.duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
        [weakself updatePlayerTimeIsTotalTime:YES timeSeconds:weakself.duration];
        
        // 不相等的时候才更新，并发通知，否则seek时会继续跳动
        if (weakself.current != current) {
            weakself.current = current;
            if (weakself.current > weakself.duration) {
                weakself.duration = weakself.current;
            }
        }
        
//        NSLog(@"当前已经播放%lfs.",current);
        if ( weakself.progressCallback ) {
            weakself.progressCallback(current);
        }
    }];
}

// isTotalTime:YES  times: totalTime
// isTotalTime:NO  times: currentTime
- (void)updatePlayerTimeIsTotalTime:(BOOL)isTotalTime timeSeconds:(CGFloat)times {
    if ( _playerTimeCallback ) {
        _playerTimeCallback(isTotalTime, times);
    }
}

#pragma mark - control play
- (void)seekToStartTime:(CGFloat)startTime {
    CMTime playTime = CMTimeMake(startTime, 1000);
    [_videoPlayer seekToTime:playTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)];
}

- (void)seekToTimeAndPlay:(CGFloat)startTime {
    CMTime playTime = CMTimeMake(startTime, 1000);
    [_videoPlayer seekToTime:playTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)];
    
    [_videoPlayer pause];
    [self playOrPause:nil];
}
- (void)seekToTimeAndStop:(CGFloat)startTime {
    CMTime playTime = CMTimeMake(startTime, 1000);
    [_videoPlayer seekToTime:playTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)];
    
    [self stopPlayAnimate:NO];
}

- (void)stopPlayAnimate:(BOOL)animate {
    if( _videoPlayer.rate == 1 ) {
        [self pauseAnimate:animate];
        self.playButton.hidden = NO;
    }
}

- (void)startPlayAnimate:(BOOL)animate {
    if( _videoPlayer.rate == 0 ) {
        [self playAnimate:animate];
    }
}

- (void)playAnimate:(BOOL)animate {
    if( self.videoPlayer.rate == 0 ) {
        [self.videoPlayer play];
        self.playButton.selected = YES;
        [self hidePlayButtonAnimate:animate];
    }
}

- (void)pauseAnimate:(BOOL)animate {
    if( self.videoPlayer.rate == 1 ) {
        [self.videoPlayer pause];
        self.playButton.selected = NO;
        [self hidePlayButtonAnimate:animate];
    }
}

- (void)hidePlayButtonAnimate:(BOOL)animate {
    if ( animate ) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.playButton.hidden = YES;
                         }];
    } else {
        self.playButton.hidden = YES;
    }
}

- (void)playOrPause:(id)sender {
    if( self.videoPlayer.rate == 0 ) {
        [self playAnimate:YES];
    } else {
        [self pauseAnimate:YES];
    }
    if ( _playCallback ) {
        _playCallback(self.videoPlayer.rate != 0);
    }
}

#pragma mark -
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if ( _playerItem == playerItem ) {
        return;
    }
    if ( _playerItem ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        
        //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        
        [_videoPlayer pause];
        _videoPlayer = nil;
        
        _firstLoad = YES;
    }
    
    _playerItem = playerItem;
    
    if ( playerItem ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)dealloc {
    if ( self.timeObserver ) {
        [self.videoPlayer removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    if ( _playerItem ) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        _playerItem = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
