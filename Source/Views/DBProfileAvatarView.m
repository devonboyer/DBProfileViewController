//
//  DBProfileAvatarView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileAvatarView.h"
#import "DBProfileViewControllerDefaults.h"

@implementation DBProfileAvatarView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.layoutMargins = UIEdgeInsetsMake(4, 4, 4, 4);

        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;

        [self.contentView addSubview:self.imageView];
        
        [self setUpConstraints];
        
        self.style = [DBProfileViewControllerDefaults defaultAvatarStyle];
    }
    return self;
}

- (void)setStyle:(DBProfileAvatarStyle)style
{
    _style = style;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.hidden = NO;
    switch (self.style) {
        case DBProfileAvatarStyleRound:
            self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
            self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) / 2;
            break;
        case DBProfileAvatarStyleRoundedRect:
            // FIXME: Corner radius should depend on border width
            self.layer.cornerRadius = 6;
            self.imageView.layer.cornerRadius = 4;
            break;
        case DBProfileAvatarStyleNone:
            self.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)setAvatarImage:(UIImage *)image animated:(BOOL)animated
{
    if (!image) return;
    self.imageView.image = image;
    
    if (animated) {
        self.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.imageView.alpha = 1;
        }];
    }
}

- (void)setUpConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

@end
