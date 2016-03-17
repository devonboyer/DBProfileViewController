//
//  DBProfilePictureView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfilePictureView.h"
#import "DBProfileViewControllerDefaults.h"

@interface DBProfilePictureView ()

@property (nonatomic, strong) NSLayoutConstraint *imageViewWidthConstraint;

@end

@implementation DBProfilePictureView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (void)db_commonInit {
    _imageView = [[UIImageView alloc] init];
    _overlayImageView = [[UIImageView alloc] init];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.imageView];
    [self.imageView addSubview:self.overlayImageView];

    [self configureImageViewLayoutConstraints];
    [self configureOverlayImageViewLayoutConstraints];
    [self configureDefaults];
}

- (void)configureDefaults {
    self.userInteractionEnabled = YES;
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 6;
    
    self.style = [[DBProfileViewControllerDefaults sharedDefaults] defaultProfilePictureStyle];
    self.borderWidth = 3;
    
    //self.overlayImageView.image = [UIImage imageNamed:@"db-profile-camera"];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted && [self.delegate respondsToSelector:@selector(profilePictureViewDidHighlight:)]) {
        [self.delegate profilePictureViewDidHighlight:self];
    } else if (!highlighted && [self.delegate respondsToSelector:@selector(profilePictureViewUnhighlight:)]) {
        [self.delegate profilePictureViewDidUnhighlight:self];
    }
}

#pragma - Overrides

- (void)updateConstraints {
    self.imageViewWidthConstraint.constant = -2*self.borderWidth;
    [super updateConstraints];
}

#pragma mark - Setters

- (void)setStyle:(DBProfilePictureStyle)style {
    _style = style;
    [self layoutSubviews];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.backgroundColor = borderColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.hidden = NO;
    switch (self.style) {
        case DBProfilePictureStyleRound:
            self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
            self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) / 2;
            break;
        case DBProfilePictureStyleRoundedRect:
            // FIXME: Corner radius should depend on border width
            self.layer.cornerRadius = 6;
            self.imageView.layer.cornerRadius = 4;
            break;
        case DBProfilePictureStyleNone:
            self.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self updateConstraints];
}

#pragma mark - Auto Layout

- (void)configureImageViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    self.imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self addConstraint:self.imageViewWidthConstraint];
}

- (void)configureOverlayImageViewLayoutConstraints {
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.imageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

@end
