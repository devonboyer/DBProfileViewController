//
//  DBProfileAccessoryView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-17.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryView.h"
#import "DBProfileAccessoryView_Private.h"
#import "DBProfileAccessoryViewLayoutAttributes.h"

@interface DBProfileAccessoryView () <UIGestureRecognizerDelegate>

@end

@implementation DBProfileAccessoryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layoutMargins = UIEdgeInsetsZero;

        _contentView = [[UIView alloc] init];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.contentView];
        
        self.highlightedBackgroundView = [[UIView alloc] init];
        self.highlightedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        
        // Setup gesture recognizers
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        self.longPressGestureRecognizer.minimumPressDuration = 0.6;
        self.longPressGestureRecognizer.cancelsTouchesInView = NO;
        self.longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.longPressGestureRecognizer];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTopMargin
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottomMargin
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeftMargin
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRightMargin
                                                             multiplier:1
                                                               constant:0]];
        [self addConstraints:constraints];
    }
    return self;
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (!backgroundView) return;
    _backgroundView = backgroundView;
    
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.highlightedBackgroundView) {
        [self insertSubview:backgroundView belowSubview:self.highlightedBackgroundView];
    }
    else {
        [self insertSubview:backgroundView belowSubview:self.contentView];
    }
}

- (void)setHighlightedBackgroundView:(UIView *)highlightedBackgroundView
{
    if (!highlightedBackgroundView) return;
    _highlightedBackgroundView = highlightedBackgroundView;
    
    highlightedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    highlightedBackgroundView.alpha = 0.0;
    
    if (self.backgroundView) {
        [self insertSubview:highlightedBackgroundView aboveSubview:self.backgroundView];
    }
    else {
        [self insertSubview:highlightedBackgroundView belowSubview:self.contentView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:YES animated:YES];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:NO animated:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:NO animated:YES];
}

#pragma mark - Actions

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.internalDelegate respondsToSelector:@selector(accessoryViewWasLongPressed:)]) {
                [self.internalDelegate accessoryViewWasLongPressed:self];
            }
            break;
        default:
            break;
    }
}

- (void)handleTapGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([self.internalDelegate respondsToSelector:@selector(accessoryViewWasTapped:)]) {
        [self.internalDelegate accessoryViewWasTapped:self];
    }
}

#pragma mark - Highlighting

- (void)setHighlighted:(BOOL)highlighted
{
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (_highlighted == highlighted || ![self.internalDelegate accessoryViewShouldHighlight:self]) return;
    _highlighted = highlighted;
    
    void (^animationBlock)() = ^void() {
        if (highlighted && self.highlightedBackgroundView.alpha == 0) {
            self.highlightedBackgroundView.alpha = 1;
        } else if (!highlighted && self.highlightedBackgroundView.alpha == 1) {
            self.highlightedBackgroundView.alpha = 0;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.12 animations:animationBlock];
    }
    else {
        [UIView performWithoutAnimation:animationBlock];
    }
    
    if (highlighted && [self.internalDelegate respondsToSelector:@selector(accessoryViewDidHighlight:)]) {
        [self.internalDelegate accessoryViewDidHighlight:self];
    }
    else if (!highlighted && [self.internalDelegate respondsToSelector:@selector(accessoryViewDidUnhighlight:)]) {
        [self.internalDelegate accessoryViewDidUnhighlight:self];
    }
}

- (void)applyLayoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes {
    self.hidden = layoutAttributes.hidden;
    self.alpha = layoutAttributes.alpha;
    self.transform = layoutAttributes.transform;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return otherGestureRecognizer == self.longPressGestureRecognizer || otherGestureRecognizer == self.tapGestureRecognizer;
}

@end
