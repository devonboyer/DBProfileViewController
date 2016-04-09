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

/*!
 @abstract Tells the delegate that the accessory view has been selected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm avatarView The avatar view that was selected.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectAccessoryView:(DBProfileAccessoryView *)accessoryView;

/*!
 @abstract Tells the delegate that the accessory view has been deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm avatarView The accessory view that was deselected.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didDeselectAccessoryView:(DBProfileAccessoryView *)accessoryView;

/*!
 @abstract Tells the delegate that the accessory view was highlighted.
 @param profileViewController The profile view controller that highlighted the accessory view.
 @prarm avatarView The accessory view that was highlighted.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didHighlightAccessoryView:(DBProfileAccessoryView *)accessoryView;

/*!
 @abstract Tells the delegate that the accessory view was unhighlighted.
 @param profileViewController The profile view controller that unhighlighted the accessory view.
 @prarm avatarView The accessory viewthat was unhighlighted.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didUnhighlightAccessoryView:(DBProfileAccessoryView *)accessoryView;

@end

NS_ASSUME_NONNULL_END
