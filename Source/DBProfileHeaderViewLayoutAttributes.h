//
//  DBProfileHeaderViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewLayoutAttributes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Styles the can be applied to the header view.
 */
typedef NS_ENUM(NSInteger, DBProfileHeaderStyle) {
    
    /**
     *  Use the default style.
     */
    DBProfileHeaderStyleDefault,
    
    /**
     *  The header view will act as a navigation bar when the view is scrolled.
     */
    DBProfileHeaderStyleNavigation,
};

/**
 *  Scroll effects the can be applied to the header view.
 */
typedef NS_OPTIONS(NSUInteger, DBProfileHeaderScrollEffects) {
    
    /**
     *  No options will be applied.
     */
    DBProfileHeaderScrollEffectNone = (1 << 0),
    
    /**
     *  The header view will stretch when the view is scrolled.
     */
    DBProfileHeaderScrollEffectStretch = (1 << 1),
    
    /**
     *  IN DEVELOPMENT
     */
    DBProfileHeaderScrollEffectParallax = (1 << 2),
};

/**
 *  The `DBProfileHeaderViewLayoutAttributes` object manages the layout-related attributes for `DBProfileAccessoryKindHeader` in a profile view controller.
 */
@interface DBProfileHeaderViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes <NSCopying>

+ (instancetype)layoutAttributes;

/**
 *  The style of the associated header view.
 *
 *  Defaults to `DBProfileHeaderStyleNavigation`
 */
@property (nonatomic) DBProfileHeaderStyle headerStyle;

/**
 *  The scroll effects to apply to the associated header view.
 *
 *  Defaults to `DBProfileHeaderScrollEffectStretch`
 */
@property (nonatomic) DBProfileHeaderScrollEffects scrollEffects;

@end

NS_ASSUME_NONNULL_END
