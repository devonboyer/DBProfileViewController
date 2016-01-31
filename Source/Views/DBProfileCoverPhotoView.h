//
//  DBProfileCoverPhotoView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

/*!
 @class DBProfileCoverPhotoView
 @abstract The `DBProfileCoverPhotoView` class displays a cover photo.
 */
@interface DBProfileCoverPhotoView : UIView

/*!
 @abstract The image view that displays the cover photo.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong, readonly) UIView *overlayView;

@end
