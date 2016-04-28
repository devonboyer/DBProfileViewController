//
//  DBProfileAccessoryViewLayoutAttributes.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-15.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `DBProfileAccessoryViewLayoutAttributes` object manages the layout-related attributes for an accessory view in a profile view controller.
 */
@interface DBProfileAccessoryViewLayoutAttributes : NSObject

/**
 *  Creates and returns a layout attributes object that represents the specified accessory view kind.
 *
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 *
 *  @return A new layout attributes object for the the specified accessory view kind.
 */
+ (instancetype)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

/**
 *  Initializes a layout attributes object that represents the specified accessory view kind.
 *
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 *
 *  @return A new layout attributes object for the the specified accessory view kind.
 */
- (instancetype)initWithAccessoryViewKind:(NSString *)accessoryViewKind;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  The accessory kind represented by the layout attributes.
 */
@property (nonatomic, copy, readonly) NSString *representedAccessoryKind;

/**
 *  The frame rectangle of the associated accessory view.
 */
@property (nonatomic) CGRect frame;

/**
 *  The bounds rectangle of the associated accessory view.
 */
@property (nonatomic) CGRect bounds;

/**
 *  The size of the associated accessory view.
 */
@property (nonatomic) CGSize size;

/**
 *  The center point of the associated accessory view.
 */
@property (nonatomic) CGPoint center;

/**
 *  The The affine transform of the associated accessory view.
 */
@property (nonatomic) CGAffineTransform transform;

/**
 *  Whether the accessory view is hidden of the associated accessory view.
 */
@property (nonatomic) BOOL hidden;

/**
 *  The alpha of the associated accessory view.
 */
@property (nonatomic) CGFloat alpha;

/**
 *  The associated accessory view’s position on the z axis.
 *
 *  This property is used to determine the front-to-back ordering of accessory views during layout. Items with higher index values appear on top of items with lower values. Items with the same value have an undetermined order.
 *
 *  Defaults to 0.
 */
@property (nonatomic) NSInteger zIndex;

/**
 *  The size of the the associated accessory view's frame.
 */
@property (nonatomic) CGSize referenceSize;

/**
 *  The percent that the associated accessory view has transitioned within its visible bounds.
 */
@property (nonatomic) CGFloat percentTransitioned;

/**
 *  @name Constraint-Based Layout Attributes
 */

/**
 *  Whether the associated accessory view has had its constraint-based layout attributes installed.
 */
@property (nonatomic) BOOL hasInstalledConstraints;

/**
 *  Uninstalls constraint-based layout attributes.
 */
- (void)uninstallConstraints;

@property (nonatomic, nullable) NSLayoutConstraint *leadingConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *trailingConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *leftConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *rightConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *topConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *widthConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *heightConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *centerXConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *centerYConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *firstBaselineConstraint;
@property (nonatomic, nullable) NSLayoutConstraint *lastBaselineConstraint;

@end

NS_ASSUME_NONNULL_END
