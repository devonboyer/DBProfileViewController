//
//  DBProfileSelectableView.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-17.
//
//

#import "DBProfileSelectableView.h"

@interface DBProfileSelectableView ()

@property (nonatomic, strong) UILongPressGestureRecognizer *highlightedLongPressGestureRecognizer;
@property (nonatomic, strong) UIView *highlightedView;

@end

@implementation DBProfileSelectableView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.highlightedView = [[UIView alloc] init];
        self.highlightedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.highlightedView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        self.highlightedView.frame = self.frame;
        self.highlightedView.hidden = YES;
        [self addSubview:self.highlightedView];
        
        self.highlightedLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHighlightedLongPressGesture:)];
        self.highlightedLongPressGestureRecognizer.minimumPressDuration = 0.0;
        [self addGestureRecognizer:self.highlightedLongPressGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.highlightedView];
}

- (void)handleHighlightedLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.highlighted = YES;
            break;
        default:
            self.highlighted = NO;
            break;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    _highlighted = highlighted;
    
    [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^{
        self.highlightedView.hidden = !highlighted;
    }];
}

@end
