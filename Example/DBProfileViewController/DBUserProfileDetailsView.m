//
//  DBUserProfileDetailsView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-21.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBUserProfileDetailsView.h"

@interface DBUserProfileDetailsView ()

@property (nonatomic, strong, readonly) UIButton *editProfileButton;
@property (nonatomic, strong) UIView *supplementaryView;
@property (nonatomic, strong) NSLayoutConstraint *supplementaryViewHeightConstraint;
@property (nonatomic, assign) BOOL showingSupplementaryView;

@end

@implementation DBUserProfileDetailsView

- (instancetype)init {
    self = [super init];
    if (self) {
        _editProfileButton = [[UIButton alloc] init];
        _supplementaryView = [[UIView alloc] init];
        _contentView = [[UIView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        _usernameLabel = [[UILabel alloc] init];
        _descriptionLabel = [[UILabel alloc] init];

        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.descriptionLabel];
        
        self.supplementaryView.translatesAutoresizingMaskIntoConstraints = NO;
        self.editProfileButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.nameLabel.numberOfLines = 0;
        self.usernameLabel.numberOfLines = 0;
        self.descriptionLabel.numberOfLines = 0;
        
        [self addSubview:self.editProfileButton];
        [self addSubview:self.supplementaryView];
        [self addSubview:self.contentView];
        
        [self configureEditProfileButtonLayoutConstraints];
        [self configureSupplementaryViewLayoutConstraints];
        [self configureContentViewLayoutConstraints];
        [self configureNameLabelLayoutConstraints];
        [self configureUsernameLabelLayoutConstraints];
        [self configureDescriptionLabelLayoutConstraints];
        
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor colorWithRed:33/255.0 green:37/255.0 blue:42/255.0 alpha:1];
                
        self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
        self.usernameLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionLabel.font = [UIFont systemFontOfSize:16];
        
        self.supplementaryView.backgroundColor = [UIColor colorWithRed:245/255.0 green:248/255.0 blue:250/255.0 alpha:1.0];
        
        UIColor *editProfileButtonColor = [UIColor colorWithRed:135/255.0 green:153/255.0 blue:166/255.0 alpha:1];
        [self.editProfileButton setTitle:@"Edit profile" forState:UIControlStateNormal];
        [self.editProfileButton setTitleColor:editProfileButtonColor forState:UIControlStateNormal];
        self.editProfileButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.editProfileButton.clipsToBounds = YES;
        self.editProfileButton.layer.cornerRadius = 6;
        self.editProfileButton.layer.borderWidth = 1;
        self.editProfileButton.layer.borderColor = editProfileButtonColor.CGColor;
        [self.editProfileButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)edit {
    self.showingSupplementaryView = !self.showingSupplementaryView;
    [self showSupplementaryView];
    [self.delegate userProfileDetailsView:self didShowSupplementaryView:self.supplementaryView];
}

- (void)showSupplementaryView {
    self.supplementaryViewHeightConstraint.constant = self.showingSupplementaryView ? 200 : 0;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.nameLabel.textColor = self.tintColor;
    self.usernameLabel.textColor = [self.tintColor colorWithAlphaComponent:0.54];
    self.descriptionLabel.textColor = [self.tintColor colorWithAlphaComponent:0.72];
}

#pragma mark - Auto Layout

- (void)configureSupplementaryViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.supplementaryView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:54]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.supplementaryView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.supplementaryView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    self.supplementaryViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.supplementaryView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self addConstraint:self.supplementaryViewHeightConstraint];
}

- (void)configureContentViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.supplementaryView attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:15]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
}

- (void)configureNameLabelLayoutConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)configureUsernameLabelLayoutConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)configureDescriptionLabelLayoutConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureEditProfileButtonLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:92]];
}


@end
