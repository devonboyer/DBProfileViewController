//
//  DBProfileSegmentedControlView.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-08.
//
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
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _segmentedControl = [[UISegmentedControl alloc] init];
    _topBorderView = [[UIView alloc] init];
    _bottomBorderView = [[UIView alloc] init];
    
    [self addSubview:self.segmentedControl];
    [self addSubview:self.topBorderView];
    [self addSubview:self.bottomBorderView];

    [self.segmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.topBorderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBorderView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self configureSegmentedControlLayoutConstraints];
    [self configureTopBorderViewLayoutConstraints];
    [self configureBottomBorderViewLayoutConstraints];
    
    [self configureDefaultAppearance];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    UIColor *borderColor = [UIColor colorWithWhite:0 alpha:0.12];
    
    self.topBorderView.backgroundColor = borderColor;
    self.bottomBorderView.backgroundColor = borderColor;
    
    self.topBorderView.hidden = YES;
    
    self.segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
}

#pragma mark - Auto Layout

- (void)configureSegmentedControlLayoutConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
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
