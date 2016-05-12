//
//  DBProfileHeaderViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileAccessoryViewLayoutAttributes.h>

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
 *  Options the can be applied to the header view.
 */
typedef NS_OPTIONS(NSUInteger, DBProfileHeaderOptions) {
    
    /**
     *  No options will be applied.
     */
    DBProfileHeaderOptionNone = (1 << 0),
    
    /**
     *  The header view will stretch when the view is scrolled.
     */
    DBProfileHeaderOptionStretch = (1 << 1),
};

/**
 *  The `DBProfileHeaderViewLayoutAttributes` object manages the layout-related attributes for `DBProfileAccessoryKindHeader` in a profile view controller.
 */
@interface DBProfileHeaderViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

/**
 *  The style of the associated header view.
 *
 *  Defaults to `DBProfileHeaderStyleNavigation`
 */
@property (nonatomic) DBProfileHeaderStyle headerStyle;

/**
 *  The options to apply to the associated header view.
 *
 *  Defaults to `DBProfileHeaderOptionStretch`
 */
@property (nonatomic) DBProfileHeaderOptions headerOptions;

@property (nonatomic, nullable) NSLayoutConstraint *navigationConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *topLayoutGuideConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *topSuperviewConstraint;

@end

NS_ASSUME_NONNULL_END
