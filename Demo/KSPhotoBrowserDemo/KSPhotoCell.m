//
//  KSPhotoCell.m
//  KSPhotoBrowserDemo
//
//  Created by Kyle Sun on 2017/4/29.
//  Copyright © 2017年 Kyle Sun. All rights reserved.
//

#import "KSPhotoCell.h"

@implementation KSPhotoCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.type == KSPhotoCellTypeRect) {
        self.imageView.layer.cornerRadius = 0;
    } else if (self.type == KSPhotoCellTypeCircular) {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    } else if (self.type == KSPhotoCellTypeRoundedRect) {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 4;
    }
}

@end
