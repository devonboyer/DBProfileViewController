//
//  DBProfileAccessoryView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-17.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBProfileAccessoryViewLayoutAttributes;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `DBProfileAvatarView` class provides a customizable accessory view for a profile interface.
 */
@interface DBProfileAccessoryView : UIView

/**
 *  The content view of is the default superview for content displayed by the view.
 */
@property (nonatomic, readonly) UIView *contentView;

/**
 *  The view used as the background of the accessory view.
 */
@property (nonatomic) UIView *backgroundView;

/**
 *  The view used as the background of the accessory view when it is highlighted.
 */
@property (nonatomic) UIView *highlightedBackgroundView;

/**
 *  Whether the accessory view is highlighted.
 */
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

/**
 *  Sets the highlighted state of the accessory view, optionally with animation.
 *
 *  @param highlighted YES to set the accessory view as highlighted, NO to set it as unhighlighted.
 *  @param animated YES if the transition should be animated, NO otherwise.
 */
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

/**
 *  @name Managing Layout Attributes
 */

/**
 *  Applies the specified layout attributes to the view.
 *
 *  @param layoutAttributes The layout attributes to apply.
 */
- (void)applyLayoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes;

/**
 *  @name Configuring Gesture Recognizers
 */

/**
 *  The gesture recognizer responsible for detecting when the to the accessory view receives a long press.
 */
@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 *  The gesture recognizer responsible for detecting when the to the accessory view is tapped.
 */
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
