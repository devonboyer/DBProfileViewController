//
//  DBProfileAccessoryView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-17.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "DBProfileAccessoryViewLayoutAttributes.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileAccessoryView
 @abstract The `DBProfileAvatarView` class provides a customizable accessory view for a profile interface.
 */
@interface DBProfileAccessoryView : UIView

/*!
 @abstract The content view of is the default superview for content displayed by the view.
 */
@property (nonatomic, strong, readonly) UIView *contentView;

/*!
 @abstract The view used as the background of the accessory view.
 */
@property (nonatomic, strong) UIView *backgroundView;

/*!
 @abstract The view used as the background of the accessory view when it is selected.
 */
@property (nonatomic, strong) UIView *selectedBackgroundView;

/*!
 @abstract Specifies whether the accessory view is selected.
 */
@property (nonatomic, assign, getter=isSelected) BOOL selected;

/*!
 @abstract Sets the highlighted state of the accessory view, optionally with animation
 @param selected YES to set the accessory view as selected, NO to deselected.
 @param animated YES if the transition should be animated, NO otherwise.
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

/*!
 @abstract Specifies whether the accessory view is highlighted.
 */
@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

/*!
 @abstract Specifies whether the accessory view is highlighted.
 @param selected YES to set the accessory view as highlighted, NO to set it as unhighlighted.
 @param animated YES if the transition should be animated, NO otherwise.
 */
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

/*!
 @abstract Applies the specified layout attributes to the view.
 @param layoutAttributes The layout attributes to apply.
 */
- (void)applyLayoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes;

@end

NS_ASSUME_NONNULL_END
