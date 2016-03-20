//
//  DBProfileSegmentedControlView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileSegmentedControlView.h"

@interface DBProfileSegmentedControlView ()

@property (nonatomic, strong) UIView *topBorderView;
@property (nonatomic, strong) UIView *bottomBorderView;

@end

@implementation DBProfileSegmentedControlView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (void)db_commonInit {
    _topBorderView = [[UIView alloc] init];
    _bottomBorderView = [[UIView alloc] init];
    
    [self addSubview:self.topBorderView];
    [self addSubview:self.bottomBorderView];

    [self.topBorderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBorderView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self configureTopBorderViewLayoutConstraints];
    [self configureBottomBorderViewLayoutConstraints];
    
    [self configureDefaults];
}

- (void)configureDefaults {
    UIColor *borderColor = [UIColor colorWithWhite:0 alpha:0.38];
    self.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = [UIColor grayColor];
    
    self.topBorderView.backgroundColor = borderColor;
    self.bottomBorderView.backgroundColor = borderColor;
    self.topBorderView.hidden = YES;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.segmentedControl.tintColor = self.tintColor;
}

- (void)setSegmentedControl:(UISegmentedControl *)segmentedControl {
    NSAssert(segmentedControl, @"segmented control cannot be nil");
    [self.segmentedControl removeFromSuperview];
    _segmentedControl = segmentedControl;
    
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    [self addSubview:self.segmentedControl];
    [self configureSegmentedControlLayoutConstraints];
}

#pragma mark - Auto Layout

- (void)configureSegmentedControlLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.9 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
}

- (void)configureTopBorderViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
}

- (void)configureBottomBorderViewLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
}

@end
