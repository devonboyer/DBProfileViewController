//
//  DBProfileSegmentedControlView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileSegmentedControlView.h"

@interface DBProfileSegmentedControlView ()

@property (nonatomic) UIView *topBorderView;
@property (nonatomic) UIView *bottomBorderView;

@end

@implementation DBProfileSegmentedControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 12);

        _topBorderView = [[UIView alloc] init];
        _bottomBorderView = [[UIView alloc] init];
        
        [self addSubview:self.topBorderView];
        [self addSubview:self.bottomBorderView];
        
        self.topBorderView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomBorderView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
        
        UIColor *borderColor = [UIColor colorWithWhite:0 alpha:0.38];
        self.topBorderView.backgroundColor = borderColor;
        self.bottomBorderView.backgroundColor = borderColor;
        
        self.showsTopBorder = NO;
    }
    return self;
}

- (void)setShowsTopBorder:(BOOL)showsTopBorder {
    _showsTopBorder = showsTopBorder;
    self.topBorderView.hidden = !showsTopBorder;
}

- (void)setShowsBottomBorder:(BOOL)showsBottomBorder {
    _showsBottomBorder = showsBottomBorder;
    self.bottomBorderView.hidden = !showsBottomBorder;
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topBorderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0.5]];
}

@end
