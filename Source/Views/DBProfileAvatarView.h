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
#import "DBProfileViewControllerConstants.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileAvatarView
 @abstract The `DBProfileAvatarView` class displays an avatar image.
 */
@interface DBProfileAvatarView : DBProfileSelectableView

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

/*!
 @abstract Sets the avatar image.
 @param avatarImage The image to set as the avatar.
 @param animated YES if setting the avatar image should be animated, NO otherwise.
 */
- (void)setAvatarImage:(UIImage *)image animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
