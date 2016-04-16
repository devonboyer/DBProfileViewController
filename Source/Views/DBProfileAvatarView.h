//
//  DBProfileAvatarView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileAccessoryView.h"
#import "DBProfileViewControllerConstants.h"

NS_ASSUME_NONNULL_BEGIN

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

/*!
 @class DBProfileAvatarView
 @abstract The `DBProfileAvatarView` class provides a default implementation for displaying an avatar.

 */
@interface DBProfileAvatarView : DBProfileAccessoryView

@property (nonatomic, strong, readonly) DBProfileAvatarLayoutAttributes *layoutAttributes;

/*!
 @abstract The image view that displays the avatar image.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/*!
 @abstract Specifies the style.
 @discussion The default is `DBProfileAvatarStyleRoundedRect`.
 */
@property (nonatomic, assign) DBProfileAvatarStyle style;

/*!
 @abstract Sets the avatar image.
 @param avatarImage The image to set as the avatar.
 @param animated YES if setting the avatar image should be animated, NO otherwise.
 */
- (void)setAvatarImage:(UIImage *)image animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
