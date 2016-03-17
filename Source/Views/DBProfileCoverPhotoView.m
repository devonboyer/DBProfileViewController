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
@property (nonatomic, strong) UIView *highlightedView;
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
    _overlayImageView = [[UIImageView alloc] init];
    _overlayView = [[DBProfileCoverPhotoOverlayView alloc] init];
    _highlightedView = [[UIView alloc] init];
    
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.frame = self.imageView.frame;
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.imageView];
    [self.imageView addSubview:self.overlayView];
    [self.imageView addSubview:self.overlayImageView];
    
    self.highlightedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.highlightedView.frame = self.frame;
    self.highlightedView.hidden = YES;
    [self addSubview:self.highlightedView];

    [self configureImageViewLayoutConstraints];
    [self configureOverlayImageViewLayoutConstraints];
    [self configureDefaults];
}

#pragma mark - Helpers

- (void)configureDefaults {
    self.userInteractionEnabled = YES;
    
    self.highlightedView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
   // self.overlayImageView.image = [UIImage imageNamed:@"db-profile-camera"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    _highlighted = highlighted;
    
    [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^{
        self.highlightedView.hidden = !highlighted;
    }];
    
    if (highlighted && [self.delegate respondsToSelector:@selector(coverPhotoViewDidHighlight:)]) {
        [self.delegate coverPhotoViewDidHighlight:self];
    } else if (!highlighted && [self.delegate respondsToSelector:@selector(coverPhotoViewDidUnhighlight:)]) {
        [self.delegate coverPhotoViewDidUnhighlight:self];
    }
}

#pragma mark - Auto Layout

- (void)configureImageViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureOverlayImageViewLayoutConstraints {
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.imageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

@end
