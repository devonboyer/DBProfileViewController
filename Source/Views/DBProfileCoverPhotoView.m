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

@interface DBProfileCoverPhotoOverlayView : UIView

@end

@implementation DBProfileCoverPhotoOverlayView

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

@interface DBProfileCoverPhotoView ()

@property (nonatomic, strong) UIView *overlayView;

@property (nonatomic, strong) NSDictionary *blurredImages;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation DBProfileCoverPhotoView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (void)db_commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIImageView alloc] init];
    _overlayView = [[DBProfileCoverPhotoOverlayView alloc] init];
    
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.frame = self.imageView.frame;
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.imageView];
    [self.imageView addSubview:self.overlayView];

    [self configureImageViewLayoutConstraints];
    [self configureDefaults];
}

#pragma mark - Helpers

- (void)configureDefaults {
    self.userInteractionEnabled = YES;
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
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

#pragma mark - Auto Layout

- (void)configureImageViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

@end
