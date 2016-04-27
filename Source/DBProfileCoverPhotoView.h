//
//  DBProfileCoverPhotoView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileBlurView.h>

@class DBProfileTintView;

NS_ASSUME_NONNULL_BEGIN

/**
 The `DBProfileCoverPhotoView` class provides a default implementation for an accessory view that displays a cover photo.
 
 ## Usage
     
 Initialize this class by registering it as an accessory view of a `DBProfileViewController`.
        
 // Registering with a profile view controller subclass
 [self registerClass:[DBProfileCoverPhotoView class] forAccessoryViewOfKind:DBProfileAccessoryKindHeader];
 
 ## Customization
 
 You can customize the layout-related attributes of this class by accessing the associated layout attributes of a `DBProfileViewController`.
 
 // Customizing layout attributes
 DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
 layoutAttributes.headerStyle = DBProfileHeaderStyleNavigation;
 
 */
@interface DBProfileCoverPhotoView : DBProfileBlurView

/**
 *  The view that displays a tint over the cover photo image.
 */
@property (nonatomic, readonly) DBProfileTintView *tintView;

/**
 *  Whether a tint should be applied to the view. This allows for overlayed bar button items to be more visible.
 * 
 *  Defaults to YES.
 */
@property (nonatomic) BOOL shouldApplyTint;

/**
 *  Whether images should be cropped to the view's frame before blurring.
 *
 *  It is recommended that large images be cropped to improve performance for blurring images. If you would like to handle cropping the cover photo yourself, then set this to NO.
 *
 *  Defaults to YES.
 */
@property (nonatomic) BOOL shouldCropImageBeforeBlurring;

/**
 *  Sets the cover photo image, optionally with animation.
 *
 *  @param avatarImage The image to set as the cover photo image.
 *  @param animated YES if setting the cover photo image should be animated, NO otherwise.
 */
- (void)setCoverPhotoImage:(UIImage *)coverPhotoImage animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END


