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

@implementation DBProfileSegmentedControlView {
    UIView *_topBorderView;
    UIView *_bottomBorderView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 12);

        _topBorderView = [[UIView alloc] init];
        _bottomBorderView = [[UIView alloc] init];
        
        [self addSubview:_topBorderView];
        [self addSubview:_bottomBorderView];
        
        _topBorderView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBorderView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
        
        UIColor *borderColor = [UIColor colorWithWhite:0 alpha:0.38];
        _topBorderView.backgroundColor = borderColor;
        _bottomBorderView.backgroundColor = borderColor;
        
        self.showsTopBorder = NO;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.segmentedControl.tintColor = self.tintColor;
}

- (void)setShowsTopBorder:(BOOL)showsTopBorder {
    _showsTopBorder = showsTopBorder;
    _topBorderView.hidden = !showsTopBorder;
}

- (void)setShowsBottomBorder:(BOOL)showsBottomBorder {
    _showsBottomBorder = showsBottomBorder;
    _bottomBorderView.hidden = !showsBottomBorder;
}

- (void)setSegmentedControl:(UISegmentedControl *)segmentedControl {
    NSAssert(segmentedControl, @"segmented control cannot be nil");
    [self.segmentedControl removeFromSuperview];
    _segmentedControl = segmentedControl;
    
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    [self addSubview:self.segmentedControl];
    
    switch ([UIDevice currentDevice].userInterfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeftMargin multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRightMargin multiplier:1 constant:0]];
            break;
        default:
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0]];
            break;
    }

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
}

- (void)setUpConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBorderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBorderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBorderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topBorderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
}

@end
