//
//  DBProfileAvatarView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAvatarView.h"

@implementation DBProfileAvatarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.layoutMargins = UIEdgeInsetsMake(4, 4, 4, 4);

        _imageView = [[UIImageView alloc] init];
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;

        [self.contentView addSubview:self.imageView];
        
        [self setUpConstraints];
        
        self.avatarStyle = DBProfileAvatarStyleRound;
    }
    return self;
}

- (void)setAvatarStyle:(DBProfileAvatarStyle)avatarStyle
{
    _avatarStyle = avatarStyle;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateConstraints];
    
    // Bring the highlighted background view to the front so highlighting dims the view
    [self bringSubviewToFront:self.highlightedBackgroundView];
    
    self.hidden = NO;
    switch (self.avatarStyle) {
        case DBProfileAvatarStyleRound:
            self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
            self.imageView.layer.cornerRadius = (CGRectGetWidth(self.frame) - self.layoutMargins.left - self.layoutMargins.right) / 2;
            break;
        case DBProfileAvatarStyleRoundedRect:
            self.layer.cornerRadius = 6;
            self.imageView.layer.cornerRadius = 4;
            break;
        case DBProfileAvatarStyleHidden:
            self.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)setAvatarImage:(UIImage *)avatarImage animated:(BOOL)animated
{
    if (animated) {
        [UIView transitionWithView:self
                          duration:0.15f
                           options:(UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState)
                        animations:^{
                            self.imageView.image = avatarImage;
                        }
                        completion:nil];
    } else {
        self.imageView.image = avatarImage;
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
