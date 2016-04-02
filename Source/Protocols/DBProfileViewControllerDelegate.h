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
@class DBProfileAccessoryView;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol DBProfileViewControllerDelegate
 @abstract The `DBProfileViewControllerDelegate` protocol is adopted by classes that act as the delegate of a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDelegate <NSObject>

@optional

/*!
 @abstract Tells the delegate that a specified content controller is about to be displayed.
 @param profileViewController The profile view controller that is showing the content controller.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController willShowContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that a specified content controller is now displayed.
 @param profileViewController The profile view controller that is showing the content controller.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didShowContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Tells the delegate that the user has triggered a pull-to-refresh.
 @param profileViewController The profile view controller that triggered a pull-to-refresh.
 @prarm index The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didPullToRefreshContentControllerAtIndex:(NSInteger)index;


- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectAccessoryView:(DBProfileAccessoryView *)accessoryView;
- (void)profileViewController:(DBProfileViewController *)profileViewController didDeselectAccessoryView:(DBProfileAccessoryView *)accessoryView;
- (void)profileViewController:(DBProfileViewController *)profileViewController didHighlightAccessoryView:(DBProfileAccessoryView *)accessoryView;
- (void)profileViewController:(DBProfileViewController *)profileViewController didUnhighlightAccessoryView:(DBProfileAccessoryView *)accessoryView;


/*!
 @abstract Tells the delegate that the avatar has been selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm avatarView The avatar view that was selected.
 */

/*!
 @abstract Tells the delegate that the avatar photo has been deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm avatarView The avatar view that was deselected.
 */

/*!
 @abstract Tells the delegate that the cover photo has been selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm profilePictureView The cover photo view that was selected.
 */

/*!
 @abstract Tells the delegate that the cover photo has been deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm profilePictureView The cover photo view that was deselected.
 */

/*!
 @abstract Tells the delegate that the avatar was highlighted.
 @param profileViewController The profile view controller that highlighted the avatar.
 @prarm avatarView The avatar view that was highlighted.
 */

/*!
 @abstract Tells the delegate that the avatar was unhighlighted.
 @param profileViewController The profile view controller that unhighlighted the avatar.
 @prarm avatarView The avatar view that was unhighlighted.
 */

/*!
 @abstract Tells the delegate that the cover photo was highlighted.
 @param profileViewController The profile view controller that highlighted the cover photo.
 @prarm coverPhotoView The cover photo view that was highlighted.
 */

/*!
 @abstract Tells the delegate that the cover photo was unhighlighted.
 @param profileViewController The profile view controller that unhighlighted the cover photo.
 @prarm coverPhotoView The cover photo view that was unhighlighted.
 */

@end

NS_ASSUME_NONNULL_END
