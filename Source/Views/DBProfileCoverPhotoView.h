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

@class DBProfileCoverPhotoView;

@protocol DBProfileCoverPhotoViewDelegate <NSObject>

- (void)didSelectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;
- (void)didDeselectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;
- (void)didHighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;
- (void)didUnhighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;

@end

/*!
 @class DBProfileCoverPhotoView
 @abstract The `DBProfileCoverPhotoView` class displays a cover photo.
 */
@interface DBProfileCoverPhotoView : DBProfileSelectableView

@property (nonatomic, weak) id<DBProfileCoverPhotoViewDelegate> delegate;

/*!
 @abstract The image view that displays the cover photo.
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

/*!
 @abstract The image view that overlays the cover photo.
 */
@property (nonatomic, strong, readonly) UIImageView *overlayImageView;

/*!
 @abstract A gradient view that overlays the cover photo to allow for visibility of any overlayed subviews.
 */
@property (nonatomic, strong, readonly) UIView *overlayView;

@end

NS_ASSUME_NONNULL_END
