//
//  DBProfileAccessoryViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-15.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>

/*!
 @class DBProfileAccessoryViewLayoutAttributes
 @abstract The `DBProfileAccessoryViewLayoutAttributes` object manages the layout-related attributes for a given accessory view in a profile view controller.
 */
@interface DBProfileAccessoryViewLayoutAttributes : NSObject

+ (instancetype)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

@property (nonatomic, strong, readonly) NSString *representedAccessoryKind;

@property (nonatomic, assign) CGRect frame; // not implemented yet

@property (nonatomic, assign) CGRect bounds; // not implemented yet

@property (nonatomic, assign) BOOL hidden; // not implemented yet

@property (nonatomic, assign) CGSize referenceSize;

@property (nonatomic, assign) CGFloat percentTransitioned; // only implemented for DBProfileAccessoryKindHeader

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *leadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *trailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *centerXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *centerYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *firstBaselineConstraint;
@property (nonatomic, strong) NSLayoutConstraint *lastBaselineConstraint;

@end

typedef NS_ENUM(NSInteger, DBProfileAvatarLayoutAlignment) {
    DBProfileAvatarLayoutAlignmentLeft,
    DBProfileAvatarLayoutAlignmentRight,
    DBProfileAvatarLayoutAlignmentCenter,
};

/*!
 @class DBProfileAvatarViewLayoutAttributes
 @abstract The `DBProfileAvatarViewLayoutAttributes` object manages the layout-related attributes for an avatar view in a profile view controller.
 */
@interface DBProfileAvatarViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

@property (nonatomic, assign) DBProfileAvatarLayoutAlignment alignment;

@property (nonatomic, assign) UIEdgeInsets insets;

@end

typedef NS_ENUM(NSInteger, DBProfileHeaderLayoutStyle) {
    DBProfileHeaderLayoutStyleNone,
    DBProfileHeaderLayoutStyleNavigation,
};

typedef NS_OPTIONS(NSUInteger, DBProfileHeaderLayoutOptions) {
    DBProfileHeaderLayoutOptionNone = (1 << 0),
    DBProfileHeaderLayoutOptionStretch = (1 << 1),
    DBProfileHeaderLayoutOptionExtend = (1 << 2),
};

/*!
 @class DBProfileHeaderViewLayoutAttributes
 @abstract The `DBProfileHeaderViewLayoutAttributes` object manages the layout-related attributes for a header view in a profile view controller.
 */
@interface DBProfileHeaderViewLayoutAttributes : DBProfileAccessoryViewLayoutAttributes

@property (nonatomic, strong, readonly) UINavigationItem *navigationItem;

@property (nonatomic, assign) DBProfileHeaderLayoutStyle style;

@property (nonatomic, assign) DBProfileHeaderLayoutOptions options;

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *navigationConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topLayoutGuideConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topSuperviewConstraint;

@end


