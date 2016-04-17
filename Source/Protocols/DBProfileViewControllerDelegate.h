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
 @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController
       didSelectAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView
       forAccessoryViewOfKind:(NSString *)accessoryViewKind;

/*!
 @abstract Tells the delegate that the accessory view has been deselected.
 @param profileViewController The profile view controller where the selection was made.
 @prarm avatarView The accessory view that was deselected.
 @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController
     didDeselectAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView
       forAccessoryViewOfKind:(NSString *)accessoryViewKind;

/*!
 @abstract Tells the delegate that the accessory view was highlighted.
 @param profileViewController The profile view controller that highlighted the accessory view.
 @prarm avatarView The accessory view that was highlighted.
 @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController
    didHighlightAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView
       forAccessoryViewOfKind:(NSString *)accessoryViewKind;

/*!
 @abstract Tells the delegate that the accessory view was unhighlighted.
 @param profileViewController The profile view controller that unhighlighted the accessory view.
 @prarm avatarView The accessory view that was unhighlighted.
 @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController
  didUnhighlightAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView
       forAccessoryViewOfKind:(NSString *)accessoryViewKind;

/*!
 @abstract Asks the delegate if the accessory view should be highlighted during tracking.
 @param profileViewController The profile view controller that unhighlighted the accessory view.
 @prarm avatarView The accessory view that was unhighlighted.
 @param accessoryViewKind A string that identifies the type of the accessory view
 @return YES if the accessory view should be highlighted during tracking, NO otherwise
 */
- (BOOL)profileViewController:(DBProfileViewController *)profileViewController
 shouldHighlightAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView
       forAccessoryViewOfKind:(NSString *)accessoryViewKind;

- (CGSize)profileViewController:(DBProfileViewController *)profileViewController referenceSizeForAccessoryViewOfKind:(NSString *)accessoryViewKind;

@end

NS_ASSUME_NONNULL_END
