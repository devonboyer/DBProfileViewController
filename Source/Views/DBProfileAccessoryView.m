//
//  DBProfileAccessoryView.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-17.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
#import "DBProfileAccessoryView.h"
#import "DBProfileAccessoryView_Private.h"

@interface DBProfileAccessoryView () <UIGestureRecognizerDelegate> {
    UILongPressGestureRecognizer *_highlightedLongPressGestureRecognizer;
}
@end

@implementation DBProfileAccessoryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layoutMargins = UIEdgeInsetsZero;

        _contentView = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];

        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        
        _highlightedLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHighlightedLongPressGesture:)];
        _highlightedLongPressGestureRecognizer.minimumPressDuration = 0.0;
        _highlightedLongPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_highlightedLongPressGestureRecognizer];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTopMargin
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottomMargin
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeftMargin
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRightMargin
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self bringSubviewToFront:self.selectedBackgroundView];
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (!backgroundView) return;
    _backgroundView = backgroundView;
    
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:backgroundView belowSubview:_contentView];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
    if (!selectedBackgroundView) return;
    _selectedBackgroundView = selectedBackgroundView;
    
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    selectedBackgroundView.alpha = 0.0;
    [self insertSubview:selectedBackgroundView aboveSubview:_contentView];
}

- (void)handleHighlightedLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self setHighlighted:YES animated:YES];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            self.highlighted = NO;
            self.selected = !self.isSelected;
            break;
        default:
            break;
    }
}

#pragma mark - Selection

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selected == selected) return;
    _selected = selected;

    void (^animationBlock)() = ^void() {
        if (selected && self.selectedBackgroundView.alpha == 0)
        {
            self.selectedBackgroundView.alpha = 1;
        } else if (!selected && self.selectedBackgroundView.alpha == 1) {
            self.selectedBackgroundView.alpha = 0;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.12 animations:animationBlock];
    }
    else {
        [UIView performWithoutAnimation:animationBlock];
    }
    
    if (selected && [self.delegate respondsToSelector:@selector(accessoryViewWasSelected:)]) {
        [self.delegate accessoryViewWasSelected:self];
    }
    else if (!selected && [self.delegate respondsToSelector:@selector(accessoryViewWasDeselected:)]) {
        [self.delegate accessoryViewWasDeselected:self];
    }
}

#pragma mark - Highlighting

- (void)setHighlighted:(BOOL)highlighted
{
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (_highlighted == highlighted) return;
    _highlighted = highlighted;
    
    if (self.isSelected) return;
    
    void (^animationBlock)() = ^void() {
        if (highlighted && self.selectedBackgroundView.alpha == 0) {
            self.selectedBackgroundView.alpha = 1;
        } else if (!highlighted && self.selectedBackgroundView.alpha == 1) {
            self.selectedBackgroundView.alpha = 0;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.12 animations:animationBlock];
    } else {
        [UIView performWithoutAnimation:animationBlock];
    }
    
    if (highlighted && [self.delegate respondsToSelector:@selector(accessoryViewDidHighlight:)]) {
        [self.delegate accessoryViewDidHighlight:self];
    }
    else if (!highlighted && [self.delegate respondsToSelector:@selector(accessoryViewDidUnhighlight:)]) {
        [self.delegate accessoryViewDidUnhighlight:self];
    }
}

- (void)applyLayoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes
{
    _layoutAttributes = layoutAttributes;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
