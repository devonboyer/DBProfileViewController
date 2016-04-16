//
//  DBProfileCoverPhotoView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileBlurView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileCoverPhotoView
 @abstract The `DBProfileCoverPhotoView` class displays a cover photo.
 */
@interface DBProfileCoverPhotoView : DBProfileBlurView

/*!
 @abstract YES if tint should be applied, NO otherwise
 @discussion The default is YES
 */
@property (nonatomic, assign) BOOL shouldApplyTint;

/*!
 @abstract YES if images should be cropped to the view's frame before blurring, NO otherwise.
 @discussion The default is YES
 */
@property (nonatomic, assign) BOOL shouldCropImageBeforeBlurring;

/*!
 @abstract Sets the cover photo image.
 @param coverPhoto The image to set as the cover photo image.
 @param animated YES if setting the cover photo image should be animated, NO otherwise.
 */
- (void)setCoverPhotoImage:(UIImage *)image animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END


