//
//  DBProfilePictureView.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-08.
//
//

#import "DBProfilePictureView.h"

@implementation DBProfilePictureView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _imageView = [[UIImageView alloc] init];
    
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.imageView];
    
    [self configureImageViewLayoutConstraints];
    [self configureDefaultAppearance];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 6;
}

#pragma mark - Auto Layout

- (void)configureImageViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.9 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.9 constant:0]];
}

@end
