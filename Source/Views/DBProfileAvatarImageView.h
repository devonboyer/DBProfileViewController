//
//  DBProfileAvatarImageView.h
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

@protocol DBProfileAvatarImageViewDelegate <NSObject>

- (void)didSelectAvatarImageView:(DBProfileAvatarImageView *)avatarImageView;
- (void)didDeselectAvatarImageView:(DBProfileAvatarImageView *)avatarImageView;
- (void)didHighlightAvatarImageView:(DBProfileAvatarImageView *)avatarImageView;
- (void)didUnhighlightAvatarImageView:(DBProfileAvatarImageView *)avatarImageView;

@end

/*!
 @class DBProfileAvatarImageView
 @abstract The `DBProfileAvatarImageView` class displays an avatar image.
 */
@interface DBProfileAvatarImageView : DBProfileSelectableView

/*!
 @abstract The The object that acts as the view's delegate.
 */
@property (nonatomic, weak) id<DBProfileAvatarImageViewDelegate> delegate;

/*!
 @abstract Specifies the style.
 @discussion The default is `DBProfileAvatarStyleRoundedRect`.
 */
@property (nonatomic, assign) DBProfileAvatarStyle style;

/*!
 @abstract The border width for the profile picture.
 */
@property (nonatomic, assign) CGFloat borderWidth;

/*!
 @abstract The border color for the profile picture.
 */
@property (nonatomic, strong) UIColor *borderColor;

/*!
 @abstract The image view that displays the profile picture.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;



/*!
 @abstract The image view that overlays the profile picture.
 */
@property (nonatomic, strong, readonly) UIImageView *overlayImageView;

@end

NS_ASSUME_NONNULL_END
