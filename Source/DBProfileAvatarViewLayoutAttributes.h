//
//  DBProfileAvatarViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileAccessoryViewLayoutAttributes.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DBProfileAvatarLayoutAlignment) {
    DBProfileAvatarLayoutAlignmentLeft,
    DBProfileAvatarLayoutAlignmentRight,
    DBProfileAvatarLayoutAlignmentCenter,
};

/**
 *  The `DBProfileHeaderViewLayoutAttributes` object manages the layout-related attributes for `DBProfileAccessoryKindAvatar` in a profile view controller.
 */
@interface DBProfileAvatarViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

@property (nonatomic) DBProfileAvatarLayoutAlignment alignment;

@property (nonatomic) UIEdgeInsets insets;

@end

NS_ASSUME_NONNULL_END
