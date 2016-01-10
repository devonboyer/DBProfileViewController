//
//  DBProfileTitleView.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-10.
//
//

#import "DBProfileTitleView.h"

@implementation DBProfileTitleView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _titleLabel = [[UILabel alloc] init];
    _subtitleLabel = [[UILabel alloc] init];

    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.subtitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];

    [self configureTitleLabelLayoutConstraints];
    [self configureSubtitleLabelLayoutConstraints];
    
    [self configureDefaultAppearance];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.subtitleLabel.textColor = [UIColor whiteColor];
    self.subtitleLabel.font = [UIFont systemFontOfSize:14];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;

    self.titleLabel.text = @"Devon Boyer";
    self.subtitleLabel.text = @"60 Tweets";
}

#pragma mark - Auto Layout

- (void)configureTitleLabelLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)configureSubtitleLabelLayoutConstraints {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

@end
