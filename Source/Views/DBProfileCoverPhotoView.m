//
//  DBProfileCoverPhotoView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileCoverPhotoView.h"
#import "DBProfileTintedImageView.h"
#import "DBProfileCoverPhotoView_Private.h"

@implementation DBProfileCoverPhotoView {
    DBProfileTintedImageView *_imageView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        _imageView = [[DBProfileTintedImageView alloc] init];
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected && [self.delegate respondsToSelector:@selector(didSelectCoverPhotoView:)]) {
        [self.delegate didSelectCoverPhotoView:self];
    } else if (!selected && [self.delegate respondsToSelector:@selector(didDeselectCoverPhotoView:)]) {
        [self.delegate didDeselectCoverPhotoView:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted && [self.delegate respondsToSelector:@selector(didHighlightCoverPhotoView:)]) {
        [self.delegate didHighlightCoverPhotoView:self];
    } else if (!highlighted && [self.delegate respondsToSelector:@selector(didUnhighlightCoverPhotoView:)]) {
        [self.delegate didUnhighlightCoverPhotoView:self];
    }
}

- (BOOL)shouldApplyTint {
    return _imageView.shouldApplyTint;
}

- (BOOL)shouldCropImageBeforeBlurring {
    return _imageView.shouldCropImageBeforeBlurring;
}

- (CGFloat)blurRadius {
    return _imageView.blurRadius;
}

- (void)setShouldApplyTint:(BOOL)shouldApplyTint {
    _imageView.shouldApplyTint = shouldApplyTint;
}

- (void)setShouldCropImageBeforeBlurring:(BOOL)shouldCropImageBeforeBlurring {
    _imageView.shouldCropImageBeforeBlurring = shouldCropImageBeforeBlurring;
}

- (void)setBlurRadius:(CGFloat)blurRadius {
    _imageView.blurRadius = blurRadius;
}

- (void)setCoverPhotoImage:(UIImage *)image animated:(BOOL)animated {
    if (!image) return;
    
    self.imageView.image = image;
    
    if (animated) {
        self.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.imageView.alpha = 1;
        }];
    }
}

- (void)setUpConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

@end
