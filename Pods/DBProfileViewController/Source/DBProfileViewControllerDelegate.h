//
//  DBProfileViewControllerDelegate.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-02-24.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DBProfileViewController;
@class DBProfileAccessoryView;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `DBProfileViewControllerDelegate` protocol is adopted by classes that act as the delegate of a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDelegate <NSObject>

@optional

/**
 *  Tells the delegate that a specified content controller is about to be displayed.
 *
 *  @param controller The profile view controller that is showing the content controller.
 *  @prarm controllerIndex The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)controller willShowContentControllerAtIndex:(NSInteger)controllerIndex;

/**
 *  Tells the delegate that a specified content controller is now displayed.
 *
 *  @param controller The profile view controller that is showing the content controller.
 *  @prarm controllerIndex The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)controller didShowContentControllerAtIndex:(NSInteger)controllerIndex;

/**
 *  Tells the delegate that the user has triggered a pull-to-refresh.
 *
 *  @param controller The profile view controller that triggered a pull-to-refresh.
 *  @prarm controllerIndex The index locating the content controller in the profile view controller.
 */
- (void)profileViewController:(DBProfileViewController *)controller didPullToRefreshContentControllerAtIndex:(NSInteger)controllerIndex;

/**
 *  Asks the delegate for the size of the accessory view kind.
 *
 *  @param controller The profile view controller that unhighlighted the accessory view.
 *  @param accessoryViewKind A string that identifies the type of the accessory view
 *
 *  @return The size of the header.
 */
- (CGSize)profileViewController:(DBProfileViewController *)controller referenceSizeForAccessoryViewOfKind:(NSString *)accessoryViewKind;

/**
 *  Tells the delegate that the accessory view has been long pressed.
 *
 *  @param controller The profile view controller where the event occurred.
 *  @prarm accessoryView The accessoryView view that received a long press.
 *  @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)controller didLongPressAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind;

/**
 *  Tells the delegate that the accessory view has been tapped.
 *
 *  @param controller The profile view controller where the event occurred.
 *  @prarm accessoryView The accessoryView view that was tapped.
 *  @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)controller didTapAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind;

/**
 *  Tells the delegate that the accessory view was highlighted.
 *
 *  @param controller The profile view controller where the event occurred.
 *  @prarm accessoryView The accessoryView view that was highlighted.
 *  @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)controller didHighlightAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind;

/**
 *  Tells the delegate that the accessory view was unhighlighted.
 *
 *  @param controller The profile view controller where the event occurred.
 *  @prarm accessoryView The accessoryView view that was unhighlighted.
 *  @param accessoryViewKind A string that identifies the type of the accessory view
 */
- (void)profileViewController:(DBProfileViewController *)controller didUnhighlightAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind;

/**
 *  Asks the delegate if the accessory view should be highlighted during tracking.
 *
 *  @param controller The profile view controller where the event occurred.
 *  @prarm accessoryView The accessoryView view that should be highlighted.
 *  @param accessoryViewKind A string that identifies the type of the accessory view
 *
 *  @return YES if the accessory view should be highlighted during tracking, NO otherwise
 */
- (BOOL)profileViewController:(DBProfileViewController *)controller shouldHighlightAccessoryView:(__kindof DBProfileAccessoryView *)accessoryView ofKind:(NSString *)accessoryViewKind;

@end

NS_ASSUME_NONNULL_END
