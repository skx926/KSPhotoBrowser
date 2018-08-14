//
//  KSPhotoCell.m
//  KSPhotoBrowserDemo
//
//  Created by Kyle Sun on 2017/4/29.
//  Copyright © 2017年 Kyle Sun. All rights reserved.
//

#import "KSPhotoCell.h"

@implementation KSPhotoCell

- (void)setType:(KSPhotoCellType)type {
    _type = type;
    if (type == KSPhotoCellTypeRect) {
        self.imageView.layer.cornerRadius = 0;
    } else if (type == KSPhotoCellTypeRoundedRect) {
        self.imageView.layer.cornerRadius = 40;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.type == KSPhotoCellTypeCircular) {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    }
}

@end
