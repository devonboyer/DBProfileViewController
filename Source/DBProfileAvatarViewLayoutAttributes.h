//
//  DBProfileAvatarViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileAccessoryViewLayoutAttributes.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Specifies the horizontal alignment of the avatar view.
 */
typedef NS_ENUM(NSInteger, DBProfileAvatarAlignment) {
    
    /**
     *  Left aligned.
     */
    DBProfileAvatarAlignmentLeft,
    
    /**
     *  Right aligned.
     */
    DBProfileAvatarAlignmentRight,
    
    /**
     *  Center aligned.
     */
    DBProfileAvatarAlignmentCenter,
};

/**
 *  The `DBProfileAvatarViewLayoutAttributes` object manages the layout-related attributes for `DBProfileAccessoryKindAvatar` in a profile view controller.
 */
@interface DBProfileAvatarViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

/**
 *  The horizontal of the associated avatar view.
 *
 *  Defaults to `DBProfileAvatarAlignmentLeft`
 */
@property (nonatomic) DBProfileAvatarAlignment avatarAlignment;

/**
 *  The edge insets used to make fine-tune adjustments to the associated avatar view's frame.
 */
@property (nonatomic) UIEdgeInsets edgeInsets;

@end

NS_ASSUME_NONNULL_END
