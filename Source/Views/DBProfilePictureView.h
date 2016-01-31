//
//  DBProfilePictureView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

/*!
 @abstract The `DBProfilePictureStyle` defines the types of styles for the profile picture.
 */
typedef NS_ENUM(NSInteger, DBProfilePictureStyle) {
    /*!
     @abstract Specifys that no profile picture should be displayed. 
     */
    DBProfilePictureStyleNone,
    /*!
     @abstract Specifys that no profile picture should be cropped to a circle.
     */
    DBProfilePictureStyleRound,
    /*!
     @abstract Specifys that no profile picture should be cropped to a rounded rect.
     */
    DBProfilePictureStyleRoundedRect,
};

/*!
 @class DBProfilePictureView
 @abstract The `DBProfilePictureView` class displays a profile picture.
 */
@interface DBProfilePictureView : UIView

/*!
 @abstract The image view that displays the profile picture.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/*!
 @abstract The border width for the profile picture.
 */
@property (nonatomic, assign) CGFloat borderWidth;

/*!
 @abstract Specifies the style.
 @discussion The default is `DBProfilePictureStyleRoundedRect`.
 */
@property (nonatomic, assign) DBProfilePictureStyle style;

@end
