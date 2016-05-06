//
//  UIView+DBProfileConstraintBasedLayout.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-06.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

// Convenience methods for creating and installing constraints
@interface UIView (DBProfileConstraintBasedLayout)

- (instancetype)initForAutoLayout;

- (void)configureForAutoLayout;


- (NSLayoutConstraint *)db_pinEdge:(NSLayoutAttribute)attribute toSuperviewEdge:(NSLayoutAttribute)attribute priority:(NSUInteger)priority;

- (NSLayoutConstraint *)db_pinEdgeToSuperviewEdge:(NSLayoutAttribute)attribute;

- (NSLayoutConstraint *)db_pinEdgeToSuperviewEdge:(NSLayoutAttribute)attribute priority:(NSUInteger)priority;

- (NSLayoutConstraint *)pinToTopLayoutGuideOfViewController:(UIViewController *)viewController relatedBy:(NSLayoutRelation)relation;

- (NSLayoutConstraint *)pinToBottomLayoutGuideOfViewController:(UIViewController *)viewController relatedBy:(NSLayoutRelation)relation;


- (NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView *)otherView;

- (NSLayoutConstraint *)pinEdge:(NSLayoutAttribute)edge toEdge:(NSLayoutAttribute)toEdge ofView:(UIView *)otherView relatedBy:(NSLayoutRelation)relation;

@end
