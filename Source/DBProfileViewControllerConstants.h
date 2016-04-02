//
//  DBProfileViewControllerConstants.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-19.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>

NSBundle *DBProfileViewControllerBundle();

CGFloat DBProfileViewControllerNavigationBarHeightForTraitCollection(UITraitCollection *traitCollection);

/*!
 @abstract A constant value representing the size of the avatar when using `DBProfileAvatarSizeNormal`.
 */
extern const CGFloat DBProfileViewControllerAvatarSizeNormal;

/*!
 @abstract A constant value representing the size of the avatar when using `DBProfileAvatarSizeLarge`.
 */
extern const CGFloat DBProfileViewControllerAvatarSizeLarge;

/*!
 @abstract The `DBProfileCoverPhotoOptions` defines options for changing the behaviour of the cover photo.
 */
typedef NS_OPTIONS(NSUInteger, DBProfileCoverPhotoOptions) {
    /*!
     @abstract No options are specified.
     */
    DBProfileCoverPhotoOptionNone = (1 << 0),
    /*!
     @abstract The cover photo will stretch with the scroll view.
     */
    DBProfileCoverPhotoOptionStretch = (1 << 1),
    /*!
     @abstract The cover photo will extend beneath the details view.
     */
    DBProfileCoverPhotoOptionExtend = (1 << 2),
};

/*!
 @abstract The `DBProfileAvatarSize` defines the size of the the avatar.
 */
typedef NS_ENUM(NSInteger, DBProfileAvatarSize) {
    /*!
     @abstract Specifys that the avatar should be the normal size.
     */
    DBProfileAvatarSizeNormal,
    /*!
     @abstract Specifys that the avatar should be large size.
     */
    DBProfileAvatarSizeLarge,
};

/*!
 @abstract The `DBProfileAvatarAlignment` defines the alignment of the the avatar.
 */
typedef NS_ENUM(NSInteger, DBProfileAvatarAlignment) {
    /*!
     @abstract Specifys that the avatar should be left aligned.
     */
    DBProfileAvatarAlignmentLeft,
    /*!
     @abstract Specifys that the avatar should be right aligned.
     */
    DBProfileAvatarAlignmentRight,
    /*!
     @abstract Specifys that the avatar should be center aligned.
     */
    DBProfileAvatarAlignmentCenter,
};

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
