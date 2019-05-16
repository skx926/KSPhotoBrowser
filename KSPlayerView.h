//
//  KSPlayerView.h
//  KSPhotoBrowser
//
//  Created by ml on 2019/5/16.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PlayProgressCallback)(CGFloat progress);
typedef void(^PlayToEndCallback)(BOOL playEnd);

// isTotalTime:YES  times: totalTime
// isTotalTime:NO  times: currentTime
typedef void(^PlayerTimeCallback)(BOOL isTotalTime, CGFloat times);

@interface KSPlayerView : UIView

@property (nonatomic, copy) PlayProgressCallback progressCallback;
@property (nonatomic, copy) PlayToEndCallback playToEndCallback;

@property (nonatomic, copy) PlayerTimeCallback playerTimeCallback;

@property (nonatomic, assign) BOOL isDragSlider;
@property (nonatomic, assign, readonly) CGFloat duration; //视频总时间
@property (nonatomic, assign, readonly) CGFloat current; //当前播放时间
@property (nonatomic, strong, readonly) AVPlayer *videoPlayer;


- (void)loadVideoPath:(NSURL *)urlString;

- (void)stopPlayAnimate:(BOOL)animate;

- (void)startPlayAnimate:(BOOL)animate;

- (void)seekToStartTime:(CGFloat)startTime;

- (void)seekToTimeAndPlay:(CGFloat)startTime;
- (void)seekToTimeAndStop:(CGFloat)startTime;

@end
NS_ASSUME_NONNULL_END
