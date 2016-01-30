//
//  DBProfileDetailsView.m
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import "DBProfileDetailsView.h"

@interface DBProfileDetailsView ()

@property (nonatomic, strong) NSLayoutConstraint *contentViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewLeftConstraint;

@end

@implementation DBProfileDetailsView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (void)db_commonInit {
    _contentView = [[UIView alloc] init];
    _nameLabel = [[UILabel alloc] init];
    _usernameLabel = [[UILabel alloc] init];
    _descriptionLabel = [[UILabel alloc] init];
    _editProfileButton = [[UIButton alloc] init];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.descriptionLabel];

    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.usernameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.editProfileButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.nameLabel.numberOfLines = 0;
    self.usernameLabel.numberOfLines = 0;
    self.descriptionLabel.numberOfLines = 0;

    [self addSubview:self.contentView];
    [self addSubview:self.editProfileButton];

    [self configureContentViewLayoutConstraints];
    [self configureNameLabelLayoutConstraints];
    [self configureUsernameLabelLayoutConstraints];
    [self configureDescriptionLabelLayoutConstraints];
    [self configureEditProfileButtonLayoutConstraints];
    
    [self configureDefaults];
}

#pragma mark - Overrides

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.nameLabel.textColor = self.tintColor;
    self.usernameLabel.textColor = [self.tintColor colorWithAlphaComponent:0.54];
    self.descriptionLabel.textColor = [self.tintColor colorWithAlphaComponent:0.72];
}

- (void)updateConstraints {
    self.contentViewTopConstraint.constant = self.contentInset.top;
    self.contentViewLeftConstraint.constant = self.contentInset.left;
    self.contentViewRightConstraint.constant = -self.contentInset.right;
    self.contentViewBottomConstraint.constant = -self.contentInset.bottom;
    [super updateConstraints];
}

#pragma mark - Setters

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self updateConstraints];
}

#pragma mark - Helpers

- (void)configureDefaults {
    self.tintColor = [UIColor colorWithRed:33/255.0 green:37/255.0 blue:42/255.0 alpha:1];
    
    self.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
    self.usernameLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.font = [UIFont systemFontOfSize:16];
    
    UIColor *editProfileButtonColor = [UIColor colorWithRed:135/255.0 green:153/255.0 blue:166/255.0 alpha:1];
    [self.editProfileButton setTitle:@"Edit profile" forState:UIControlStateNormal];
    [self.editProfileButton setTitleColor:editProfileButtonColor forState:UIControlStateNormal];
    self.editProfileButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.editProfileButton.clipsToBounds = YES;
    self.editProfileButton.layer.cornerRadius = 6;
    self.editProfileButton.layer.borderWidth = 1;
    self.editProfileButton.layer.borderColor = editProfileButtonColor.CGColor;
}

#pragma mark - Auto Layout

- (void)configureContentViewLayoutConstraints {
    self.contentViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    self.contentViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.contentViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    self.contentViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraints:@[self.contentViewTopConstraint, self.contentViewLeftConstraint, self.contentViewRightConstraint, self.contentViewBottomConstraint]];
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
