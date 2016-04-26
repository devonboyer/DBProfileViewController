//
//  DBProfileHeaderViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileAccessoryViewLayoutAttributes.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DBProfileHeaderLayoutStyle) {
    DBProfileHeaderLayoutStyleNone,
    DBProfileHeaderLayoutStyleNavigation,
};

typedef NS_OPTIONS(NSUInteger, DBProfileHeaderLayoutOptions) {
    DBProfileHeaderLayoutOptionNone = (1 << 0),
    DBProfileHeaderLayoutOptionStretch = (1 << 1),
    DBProfileHeaderLayoutOptionExtend = (1 << 2),
};

/**
 *  The `DBProfileHeaderViewLayoutAttributes` object manages the layout-related attributes for `DBProfileAccessoryKindHeader` in a profile view controller.
 */
@interface DBProfileHeaderViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

@property (nonatomic, readonly) UINavigationItem *navigationItem;

@property (nonatomic) DBProfileHeaderLayoutStyle style;

@property (nonatomic) DBProfileHeaderLayoutOptions options;

@property (nonatomic, nullable) NSLayoutConstraint *navigationConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *topLayoutGuideConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *topSuperviewConstraint;

@end

NS_ASSUME_NONNULL_END
