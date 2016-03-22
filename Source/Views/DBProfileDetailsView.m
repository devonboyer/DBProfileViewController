//
//  DBProfileDetailsView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2015-12-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileDetailsView.h"

@implementation DBProfileDetailsView {
    NSLayoutConstraint *_contentViewTopInsetConstraint;
    NSLayoutConstraint *_contentViewBottomInsetConstraint;
    NSLayoutConstraint *_contentViewRightInsetConstraint;
    NSLayoutConstraint *_contentViewLeftInsetConstraint;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor colorWithRed:33/255.0 green:37/255.0 blue:42/255.0 alpha:1];
        
        _contentView = [[UIView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        _usernameLabel = [[UILabel alloc] init];
        _descriptionLabel = [[UILabel alloc] init];
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.descriptionLabel];
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.nameLabel.numberOfLines = 0;
        self.usernameLabel.numberOfLines = 0;
        self.descriptionLabel.numberOfLines = 0;
        
        [self addSubview:self.contentView];
        
        [self setUpConstraints];
        
        self.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
        self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
        self.usernameLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionLabel.font = [UIFont systemFontOfSize:16];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.nameLabel.textColor = self.tintColor;
    self.usernameLabel.textColor = [self.tintColor colorWithAlphaComponent:0.54];
    self.descriptionLabel.textColor = [self.tintColor colorWithAlphaComponent:0.72];
}

- (void)updateConstraints {
    _contentViewTopInsetConstraint.constant = self.contentInset.top;
    _contentViewLeftInsetConstraint.constant = self.contentInset.left;
    _contentViewRightInsetConstraint.constant = -self.contentInset.right;
    _contentViewBottomInsetConstraint.constant = -self.contentInset.bottom;
    [super updateConstraints];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self updateConstraints];
}

- (void)setUpConstraints {
    _contentViewTopInsetConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    _contentViewLeftInsetConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    _contentViewRightInsetConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    _contentViewBottomInsetConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraints:@[_contentViewTopInsetConstraint, _contentViewLeftInsetConstraint, _contentViewRightInsetConstraint, _contentViewBottomInsetConstraint]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

@end
