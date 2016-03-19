//
//  DBProfileViewControllerDelegate.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-02-24.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DBProfileViewController;
@class DBProfileAvatarImageView;
@class DBProfileCoverPhotoView;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol DBProfileViewControllerDelegate
 @abstract The `DBProfileViewControllerDelegate` protocol is adopted by classes that act as the delegate of a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDelegate <NSObject>

@optional

/*!
 @abstract Tells the delegate that a specified content controller is about to be selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController willSelectContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that a specified content controller is now selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that a specified content controller is about to be deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController willDeselectContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that a specified content controller is now deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didDeselectContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that the profile picture has been selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm profilePictureView The profile picture view that was selected.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectAvatarView:(DBProfileAvatarImageView *)avatarView;

/*!
 @abstract Tells the delegate that the profile picture photo has been deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm profilePictureView The profile picture view that was deselected.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didDeselectAvatarView:(DBProfileAvatarImageView *)avatarView;

/*!
 @abstract Tells the delegate that the cover photo has been selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm profilePictureView The cover photo view that was selected.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;

/*!
 @abstract Tells the delegate that the cover photo has been deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm profilePictureView The cover photo view that was deselected.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didDeselectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;

/*!
 @abstract Tells the delegate that the user has triggered a pull-to-refresh.
 @param profileViewController The profile view controller that triggered a pull-to-refresh.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didPullToRefreshContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that the profile picture was highlighted.
 @param profileViewController The profile view controller that highlighted the profile picture.
 @prarm profilePictureView The profile picture view that was highlighted.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didHighlightAvatarView:(DBProfileAvatarImageView *)avatarView;

/*!
 @abstract Tells the delegate that the profile picture was unhighlighted.
 @param profileViewController The profile view controller that unhighlighted the profile picture.
 @prarm profilePictureView The profile picture view that was unhighlighted.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didUnhighlightAvatarView:(DBProfileAvatarImageView *)avatarView;

/*!
 @abstract Tells the delegate that the cover photo was highlighted.
 @param profileViewController The profile view controller that highlighted the cover photo.
 @prarm coverPhotoView The cover photo view that was highlighted.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didHighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;

/*!
 @abstract Tells the delegate that the cover photo was unhighlighted.
 @param profileViewController The profile view controller that unhighlighted the cover photo.
 @prarm coverPhotoView The cover photo view that was unhighlighted.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didUnhighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView;

@end

NS_ASSUME_NONNULL_END
