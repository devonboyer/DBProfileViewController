//
//  DBProfileTitleView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileTitleView.h"

@interface DBProfileTitleView ()

@property (nonatomic) UIView *contentView;

@end

@implementation DBProfileTitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentView = [[UILabel alloc] init];
        _titleLabel = [[UILabel alloc] init];
        _subtitleLabel = [[UILabel alloc] init];
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subtitleLabel];
        
        self.wantsShadowForLabels = NO;

        [self setupConstraints];
    
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14];

        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
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
    _title = title;
    [self updateTitleInformation];
}

- (void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes {
    _titleTextAttributes = titleTextAttributes;
    [self updateTitleInformation];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    [self updateTitleInformation];
}

- (void)setSubtitleTextAttributes:(NSDictionary<NSString *,id> *)subtitleTextAttributes {
    _subtitleTextAttributes = subtitleTextAttributes;
    [self updateTitleInformation];
}

- (void)updateTitleInformation {
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.title ?: @"" attributes:self.titleTextAttributes];
    self.subtitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.subtitle ?: @"" attributes:self.subtitleTextAttributes];
}

- (void)setupConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

@end
