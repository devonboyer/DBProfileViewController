//
//  DBProfileCoverPhotoView.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-08.
//
//

#import "DBProfileCoverPhotoView.h"

@implementation DBProfileCoverPhotoView

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
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:self.imageView];
    [self addSubview:self.activityIndicator];

    [self configureImageViewLayoutConstraints];
    [self configureActivityIndicatorLayoutConstraints];
    [self configureDefaultAppearance];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
}

#pragma mark - Refresh

- (void)startRefreshing {
    [self.activityIndicator startAnimating];
    
    self.activityIndicator.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.activityIndicator.alpha = 1;
    }];
}

- (void)endRefreshing {
    [UIView animateWithDuration:0.2 animations:^{
        self.activityIndicator.alpha = 0;
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - Auto Layout

- (void)configureImageViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureActivityIndicatorLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
