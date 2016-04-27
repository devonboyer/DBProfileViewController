//
//  DBProfileTintView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileTintView.h"

@implementation DBProfileTintView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        self.endColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    }
    return self;
}

- (void)setStartColor:(UIColor *)startColor {
    _startColor = startColor;
    [self updateTintLayer];
}

- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    [self updateTintLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateTintLayer];
}

- (void)updateTintLayer {
    if (!self.startColor || !self.endColor) return;
    
    CAGradientLayer *tintLayer = (CAGradientLayer *)self.layer;

    tintLayer.colors = @[(id)self.startColor.CGColor, (id)self.endColor.CGColor];
    tintLayer.locations = @[@0, @1];
}

@end
