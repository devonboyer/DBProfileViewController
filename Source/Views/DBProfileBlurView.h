//
//  DBProfileBlurView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-25.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileAccessoryView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileBlurView
 @abstract The `DBProfileBlurView` class provides utility to blur an image within a specified number of stages.
 */
@interface DBProfileBlurView : DBProfileAccessoryView

@property (nonatomic, strong, readonly) UIImageView *imageView;

/*!
 @abstract YES to allow blurring, NO otherwise
 @discussion The default is YES.
 */
@property (nonatomic, assign, getter=isBlurEnabled) BOOL blurEnabled;

/*!
 @abstract YES to allow interpolation using alpha between stages, NO otherwise
 @discussion The default is YES.
 */
@property (nonatomic, assign) BOOL shouldInterpolateStages;

/*!
 @abstract The number of stages to use when blurring images.
 @discussion The default is 20.
 */
@property (nonatomic, assign) NSUInteger numberOfStages;

/*!
 @abstract The max blur radius to use when blurring images.
 @discussion The default is 20.0.
 */
@property (nonatomic, assign) CGFloat maxBlurRadius;

/*!
 @abstract The percent scrolled used to determine the stage.
 */
@property (nonatomic, assign) CGFloat percentScrolled;

/*!
 @abstract The image to representing stage 0.
 */
@property (nonatomic, strong) UIImage *initialImage;

@end

NS_ASSUME_NONNULL_END