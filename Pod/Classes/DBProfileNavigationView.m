//
//  DBProfileNavigationView.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-13.
//
//

#import "DBProfileNavigationView.h"
#import "DBProfileTitleView.h"

@interface DBProfileNavigationView () <UINavigationBarDelegate>
@end

@implementation DBProfileNavigationView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _navigationItem = [[UINavigationItem alloc] init];
    _navigationBar = [[UINavigationBar alloc] init];
    _titleView = [[DBProfileTitleView alloc] init];

    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = YES;
    self.navigationBar.clipsToBounds = YES;
    self.navigationBar.delegate = self;
    self.navigationBar.items = @[self.navigationItem];
    [self addSubview:self.navigationBar];
    
    [self.navigationBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self configureNavigationBarLayoutConstraints];
    
    self.titleView.frame = CGRectMake(0, 0, 200, 50);
    self.navigationItem.titleView = self.titleView;
}

#pragma mark - UINavigationBarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Auto Layout

- (void)configureNavigationBarLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:64]];
}

@end
