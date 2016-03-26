//
//  DBProfileCoverPhotoView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileSelectableView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileCoverPhotoView
 @abstract The `DBProfileCoverPhotoView` class displays a cover photo.
 */
@interface DBProfileCoverPhotoView : DBProfileSelectableView

/*!
 @abstract The image view that displays the cover photo image.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/*!
 @abstract YES if a tint should be applied to the image view, NO otherwise.
 */
@property (nonatomic, assign) BOOL shouldApplyTint;

/*!
 @abstract YES if images should be cropped to the view's frame before blurring, NO otherwise.
 */
@property (nonatomic, assign) BOOL shouldCropImageBeforeBlurring;

/*!
 @abstract Specifies the blur radius for the image.
 */
@property (nonatomic, assign) CGFloat blurRadius;

/*!
 @abstract Sets the cover photo image.
 @param coverPhoto The image to set as the cover photo image.
 @param animated YES if setting the cover photo image should be animated, NO otherwise.
 */
- (void)setCoverPhotoImage:(UIImage *)image animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END


