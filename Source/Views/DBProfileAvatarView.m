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

@implementation DBProfileAvatarView {
    NSLayoutConstraint *_imageViewWidthConstraint;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = 8;
        
        _imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.cornerRadius = 6;
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:self.imageView];
        
        [self setUpConstraints];
        
        self.style = [DBProfileViewControllerDefaults defaultAvatarStyle];
        self.borderWidth = 3;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected && [self.delegate respondsToSelector:@selector(didSelectAvatarView:)]) {
        [self.delegate didSelectAvatarView:self];
    } else if (!selected && [self.delegate respondsToSelector:@selector(didDeselectAvatarView:)]) {
        [self.delegate didDeselectAvatarView:self];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted && [self.delegate respondsToSelector:@selector(didHighlightAvatarView:)]) {
        [self.delegate didHighlightAvatarView:self];
    } else if (!highlighted && [self.delegate respondsToSelector:@selector(didUnhighlightAvatarView:)]) {
        [self.delegate didUnhighlightAvatarView:self];
    }
}

#pragma - Overrides

- (void)updateConstraints {
    _imageViewWidthConstraint.constant = -2*self.borderWidth;
    [super updateConstraints];
}

#pragma mark - Setters

- (void)setStyle:(DBProfileAvatarStyle)style {
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

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self updateConstraints];
}

- (void)setUpConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    _imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self addConstraint:_imageViewWidthConstraint];
}

@end
