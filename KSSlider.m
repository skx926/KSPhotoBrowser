//
//  KSSlider.m
//  KSPhotoBrowser
//
//  Created by ml on 2019/5/16.
//

#import "KSSlider.h"

@interface KSSlider ()
{
    CGRect lastBounds;
}

@end

@implementation KSSlider
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    rect.origin.x = rect.origin.x;
    rect.size.width = rect.size.width ;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    lastBounds = result;
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *result = [super hitTest:point withEvent:event];
    
    if (point.x < 0 || point.x > self.bounds.size.width){
        if ( _sliderHitCallback ) {
            _sliderHitCallback(NO);
        }
        return result;
    }
    if ((point.y >= -thumbBound_y) && (point.y < lastBounds.size.height + thumbBound_y)) {
        float value = 0.0;
        value = point.x - self.bounds.origin.x;
        value = value/self.bounds.size.width;
        
        value = value < 0? 0 : value;
        value = value > 1? 1: value;
        
        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
        [self setValue:value animated:YES];
        if ( _sliderHitCallback ) {
            _sliderHitCallback(YES);
        }
    }
    return result;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    if (!result && point.y > -10) {
        if ((point.x >= lastBounds.origin.x - thumbBound_x) && (point.x <= (lastBounds.origin.x + lastBounds.size.width + thumbBound_x)) && (point.y < (lastBounds.size.height + thumbBound_y))) {
            result = YES;
        }
        
    }
    return result;
}

@end

