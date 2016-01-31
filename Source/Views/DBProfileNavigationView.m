//
//  DBProfileNavigationView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-13.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileNavigationView.h"
#import "DBProfileTitleView.h"

@interface DBProfileNavigationView ()
@end

@implementation DBProfileNavigationView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (void)db_commonInit {
    _navigationItem = [[UINavigationItem alloc] init];
    _navigationBar = [[UINavigationBar alloc] init];
    _titleView = [[DBProfileTitleView alloc] init];

    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = YES;
    self.navigationBar.clipsToBounds = YES;
    self.navigationBar.items = @[self.navigationItem];
    [self addSubview:self.navigationBar];
    
    [self.navigationBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self configureNavigationBarLayoutConstraints];
    
    self.navigationItem.titleView = self.titleView;
}

#pragma mark - Auto Layout

- (void)configureNavigationBarLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

@end
