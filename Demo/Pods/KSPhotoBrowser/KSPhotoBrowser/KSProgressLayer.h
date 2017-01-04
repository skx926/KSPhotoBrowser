//
//  KSProgressLayer.h
//  KSPhotoBrowser
//
//  Created by Kyle Sun on 30/12/2016.
//  Copyright © 2016 Kyle Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSProgressLayer : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startSpin; 
- (void)stopSpin;

@end
