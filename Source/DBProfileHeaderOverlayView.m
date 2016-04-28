//
//  DBProfileHeaderOverlayView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileHeaderOverlayView.h"
#import "DBProfileTitleView.h"

@interface DBProfileHeaderOverlayView ()

@property (nonatomic) UINavigationItem *navigationItem;
@property (nonatomic) UINavigationBar *navigationBar;
@property (nonatomic) DBProfileTitleView *titleView;

@end

@implementation DBProfileHeaderOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupNavigationBar];
    }
    return self;
}

// Pass the touches down to other views: http://stackoverflow.com/a/8104378
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

- (void)layoutSubviews {
    // The navigation bar has a different intrinsic content size upon rotation, so we must update to that new size.
    // Do it without animation to more closely match the behavior in `UINavigationController`
    [UIView performWithoutAnimation:^{
        [self.navigationBar invalidateIntrinsicContentSize];
        [self.navigationBar layoutIfNeeded];
    }];
    
    [super layoutSubviews];
}

- (void)setupNavigationBar {
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navigationBar.clipsToBounds = YES;

    // Make navigation bar background fully transparent.
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.barTintColor = nil;
    self.navigationBar.translucent = YES;
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    self.navigationBar.items = @[self.navigationItem];
    
    [self addSubview:self.navigationBar];
    
    DBProfileTitleView *titleView = [[DBProfileTitleView alloc] init];
    self.navigationItem.titleView = titleView;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *horizontalPositionConstraint = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self addConstraints:@[topConstraint, widthConstraint, horizontalPositionConstraint, bottomConstraint]];
}

- (DBProfileTitleView *)titleView {
    return (DBProfileTitleView *)self.navigationItem.titleView;
}

- (UIBarButtonItem *)leftBarButtonItem {
    return self.navigationItem.leftBarButtonItem;
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

- (NSArray *)leftBarButtonItems {
    return self.navigationItem.leftBarButtonItems;
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems {
    [self.navigationItem setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

- (UIBarButtonItem *)rightBarButtonItem {
    return self.navigationItem.rightBarButtonItem;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (NSArray *)rightBarButtonItems {
    return self.navigationItem.rightBarButtonItems;
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (NSString *)title {
    return self.titleView.title;
}

- (void)setTitle:(NSString *)title {
    self.titleView.title = title;
}

- (NSDictionary *)titleTextAttributes {
    return self.titleView.titleTextAttributes;
}

- (void)setTitleTextAttributes:(NSDictionary *)titleTextAttributes {
    self.titleView.titleTextAttributes = titleTextAttributes;
}

- (NSString *)subtitle {
    return self.titleView.subtitle;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.titleView.subtitle = subtitle;
}

- (NSDictionary<NSString *,id> *)subtitleTextAttributes {
    return self.titleView.subtitleTextAttributes;
}

- (void)setSubtitleTextAttributes:(NSDictionary<NSString *,id> *)subtitleTextAttributes {
    self.titleView.subtitleTextAttributes = subtitleTextAttributes;
}

@end
