//
//  DBProfileCoverPhotoView.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-08.
//
//

#import "DBProfileCoverPhotoView.h"

@interface DBProfileCoverPhotoView ()
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIView *overlayView;
@end

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
    _overlayView = [[UIView alloc] init];
    _blurView = [[UIView alloc] init];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.frame = self.imageView.frame;
    [self.imageView addSubview:self.overlayView];
    
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurView.frame = self.imageView.frame;
    [self.imageView addSubview:self.blurView];
    
    self.visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.visualEffectView.frame = self.blurView.frame;
    [self.blurView addSubview:self.visualEffectView];
    
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
    
    self.blurView.alpha = 0;
    
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0.15;
}

#pragma mark - Refresh

- (void)startRefreshing {
    [self.activityIndicator startAnimating];
}

- (void)endRefreshing {
    [self.activityIndicator stopAnimating];
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
