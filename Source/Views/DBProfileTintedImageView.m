//
//  DBProfileTintedImageView.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-21.
//
//

#import "DBProfileTintedImageView.h"

@interface DBProfileTintView : UIView
@end

@implementation DBProfileTintView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
                             (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor];
    
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.2f],
                                [NSNumber numberWithFloat:0.4],
                                [NSNumber numberWithFloat:0.6f],
                                [NSNumber numberWithFloat:1.0f]];
}

@end

@implementation DBProfileTintedImageView {
    DBProfileTintView *_tintView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tintView = [[DBProfileTintView alloc] init];
        _tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tintView.frame = self.frame;
        [self addSubview:_tintView];
    }
    return self;
}

- (void)setShouldApplyTint:(BOOL)shouldApplyTint {
    _shouldApplyTint = shouldApplyTint;
    _tintView.hidden = !shouldApplyTint;
}

@end
