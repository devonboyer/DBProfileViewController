//
//  DBProfileTitleView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileTitleView.h"

@implementation DBProfileTitleView {
    UIView *_contentView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentView = [[UILabel alloc] init];
        _titleLabel = [[UILabel alloc] init];
        _subtitleLabel = [[UILabel alloc] init];
        
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_contentView];
        [_contentView addSubview:self.titleLabel];
        [_contentView addSubview:self.subtitleLabel];
        
        [self setUpConstraints];
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.subtitleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14];
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;

        self.wantsShadowForLabels = NO;
    }
    return self;
}

- (void)setWantsShadowForLabels:(BOOL)wantsShadowForLabels {
    _wantsShadowForLabels = wantsShadowForLabels;
    
    if (wantsShadowForLabels) {
        UIColor *shadowColor = [UIColor colorWithWhite:0 alpha:0.32];
        self.titleLabel.shadowColor = shadowColor;
        self.titleLabel.shadowOffset = CGSizeMake(1,1);
        self.subtitleLabel.shadowColor = shadowColor;
        self.subtitleLabel.shadowOffset = CGSizeMake(1,1);
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
}

- (void)setUpConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-2]];
    
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

@end
