//
//  DBProfileBlurView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-25.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBProfileViewController/DBProfileAccessoryView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `DBProfileBlurView` class is an accessory view that displays an image that can be blurred within a specified number of stages.
 *
 *  This class is intended to be used to blur an image in stages while a user is scrolling a scroll view.
 * 
 *  You should not use this class directly instead see `DBProfileCoverPhotoView` or create your own subclass.
 */
@interface DBProfileBlurView : DBProfileAccessoryView

/**
 *  The image view that displays the blurred images.
 */
@property (nonatomic, readonly) UIImageView *imageView;

/**
 *  The percent scrolled used to determine the current stage.
 */
@property (nonatomic, readonly) CGFloat percentScrolled;

/**
 *  Whether blurring is enabled.
 *
 *  Defaults to YES.
 */
@property (nonatomic, getter=isBlurEnabled) BOOL blurEnabled;

/**
 *  Whether interpolation using alpha between stages is allowed.
 *
 *  This can often create a smoother transition between stages while scrolling.
 *
 *  Defaults to YES.
 */
@property (nonatomic) BOOL shouldInterpolateStages;

/**
 *  The number of stages to use when blurring images.
 *
 *  Defaults to 20.
 */
@property (nonatomic) NSUInteger numberOfStages;

/**
 *  The max blur radius to use when blurring images.
 *
 *  Defaults to 20.
 */
@property (nonatomic) CGFloat maxBlurRadius;

/**
 *  The image representing stage 0.
 */
@property (nonatomic) UIImage *initialImage;

@end

NS_ASSUME_NONNULL_END