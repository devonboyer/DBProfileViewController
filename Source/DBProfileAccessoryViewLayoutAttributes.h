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

+ (instancetype)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

@property (nonatomic, copy, readonly) NSString *representedAccessoryKind;

@property (nonatomic) CGRect frame; // not implemented yet

@property (nonatomic) CGRect bounds; // not implemented yet

@property (nonatomic) BOOL hidden; // not implemented yet

@property (nonatomic) CGSize referenceSize;

@property (nonatomic) CGFloat percentTransitioned; // only implemented for DBProfileAccessoryKindHeader

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
