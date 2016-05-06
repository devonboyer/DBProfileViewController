//
//  UIView+DBProfileConstraintBasedLayout.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-06.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "UIView+DBProfileConstraintBasedLayout.h"

@implementation UIView (DBProfileConstraintBasedLayout)

- (instancetype)initForAutoLayout {
    self = [self init];
    if (self) {
        [self configureForAutoLayout];
    }
    return self;
}

- (void)configureForAutoLayout {
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (NSLayoutConstraint *)db_pinEdgeToSuperviewEdge:(NSLayoutAttribute)attribute {
    return [self addConstraintWithAttribute:attribute relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:attribute multiplier:1.0 constant:0.0 autoInstall:YES];
}

- (NSLayoutConstraint *)db_pinEdgeToSuperviewEdge:(NSLayoutAttribute)attribute priority:(NSUInteger)priority {
    NSLayoutConstraint *constraint = [self db_pinEdgeToSuperviewEdge:attribute];
    constraint.priority = priority;
    return constraint;
}

- (NSLayoutConstraint *)pinToTopLayoutGuideOfViewController:(UIViewController *)viewController relatedBy:(NSLayoutRelation)relation {
    return nil;
}

- (NSLayoutConstraint *)pinToBottomLayoutGuideOfViewController:(UIViewController *)viewController relatedBy:(NSLayoutRelation)relation {
    return nil;
}


- (NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView *)otherView {
    return [self pinEdge:edge toEdge:toEdge ofView:otherView relatedBy:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView *)otherView relatedBy:(NSLayoutRelation)relation {
    return nil;
}

- (NSLayoutConstraint *)addConstraintWithAttribute:(NSLayoutAttribute)attr1
                                         relatedBy:(NSLayoutRelation)relation
                                            toItem:(id)otherView
                                         attribute:(NSLayoutAttribute)attr2
                                        multiplier:(CGFloat)multiplier
                                          constant:(CGFloat)constant
                                       autoInstall:(BOOL)autoInstall {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attr1 relatedBy:relation toItem:otherView attribute:attr2 multiplier:multiplier constant:constant];
    
    if (autoInstall) {
        [self addConstraint:constraint];
    }
    
    return constraint;
}

@end
