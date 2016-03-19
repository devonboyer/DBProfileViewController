//
//  DBProfileAvatarView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileSelectableView.h"

NS_ASSUME_NONNULL_BEGIN

@class DBProfileAvatarImageView;

/*!
 @abstract The `DBProfileAvatarStyle` defines the types of styles for the avatar.
 */
typedef NS_ENUM(NSInteger, DBProfileAvatarStyle) {
    /*!
     @abstract Specifys that no avatar should be displayed.
     */
    DBProfileAvatarStyleNone,
    /*!
     @abstract Specifys that no avatar should be cropped to a circle.
     */
    DBProfileAvatarStyleRound,
    /*!
     @abstract Specifys that no avatar should be cropped to a rounded rect.
     */
    DBProfileAvatarStyleRoundedRect,
};

@protocol DBProfileAvatarViewDelegate <NSObject>

- (void)didSelectAvatarView:(DBProfileAvatarImageView *)avatarView;
- (void)didDeselectAvatarView:(DBProfileAvatarImageView *)avatarView;
- (void)didHighlightAvatarView:(DBProfileAvatarImageView *)avatarView;
- (void)didUnhighlightAvatarView:(DBProfileAvatarImageView *)avatarView;

@end

/*!
 @class DBProfileAvatarView
 @abstract The `DBProfileAvatarView` class displays an avatar image.
 */
@interface DBProfileAvatarView : DBProfileSelectableView

/*!
 @abstract The The object that acts as the view's delegate.
 */
@property (nonatomic, weak) id<DBProfileAvatarViewDelegate> delegate;

/*!
 @abstract Specifies the style.
 @discussion The default is `DBProfileAvatarStyleRoundedRect`.
 */
@property (nonatomic, assign) DBProfileAvatarStyle style;

/*!
 @abstract The border width for the avatar.
 */
@property (nonatomic, assign) CGFloat borderWidth;

/*!
 @abstract The border color for the avatar.
 */
@property (nonatomic, strong) UIColor *borderColor;

/*!
 @abstract The image view that displays the avatar image.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
