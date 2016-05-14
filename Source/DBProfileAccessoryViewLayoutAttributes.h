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

+ (NSArray<NSString *> *)keyPathsForBindings;

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
 *  The percent that the associated accessory view has transitioned within its visible bounds.
 */
@property (nonatomic) CGFloat percentTransitioned;

@end

NS_ASSUME_NONNULL_END
