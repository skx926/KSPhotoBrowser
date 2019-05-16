//
//  KSSlider.h
//  KSPhotoBrowser
//
//  Created by ml on 2019/5/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define thumbBound_x 30
#define thumbBound_y 30

typedef void(^HitSliderCallback)(BOOL isHitSlider);

@interface KSSlider : UISlider

@property (nonatomic, copy)HitSliderCallback sliderHitCallback;
@end

NS_ASSUME_NONNULL_END
