//
//  DBProfileAvatarView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileAccessoryView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Styles the can be applied to the avatar.
 */
typedef NS_ENUM(NSInteger, DBProfileAvatarStyle) {
    
    /**
     * Specifys that the avatar should be hidden.
     */
    DBProfileAvatarStyleHidden,
    
    /**
     *  Specifys that the avatar should be cropped to a circle.
     */
    DBProfileAvatarStyleRound,
    
    /**
     *  Specifys that the avatar should be cropped to a rounded rect.
     */
    DBProfileAvatarStyleRoundedRect,
};

/**
 The `DBProfileAvatarView` class provides a default implementation for an accessory view that displays an avatar.
 
 ## Usage
 
 Initialize this class by registering it as an accessory view of a `DBProfileViewController`.
 
 // Registering with a profile view controller subclass
 [self registerClass:[DBProfileAvatarView class] forAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
 
 ## Customization
 
 You can customize the layout-related attributes of this class by accessing the associated layout attributes of a `DBProfileViewController`.
 
 // Customizing layout attributes
 DBProfileAvatarViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
 layoutAttributes.avatarAlignment = DBProfileAvatarAlignmentLeft;
 
 */
@interface DBProfileAvatarView : DBProfileAccessoryView

/**
 *  The image view that displays the avatar image.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/**
 *  Specifies the avatar style.
 *
 *  Defaults to `DBProfileAvatarStyleRoundedRect`.
 */
@property (nonatomic, assign) DBProfileAvatarStyle avatarStyle;

/**
 *  Sets the avatar image, optionally with animation.
 *
 *  @param avatarImage The image to set as the avatar.
 *  @param animated YES if setting the avatar image should be animated, NO otherwise.
 */
- (void)setAvatarImage:(UIImage *)avatarImage animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
