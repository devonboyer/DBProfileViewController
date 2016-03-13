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

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol DBProfileViewControllerDelegate
 @abstract The `DBProfileViewControllerDelegate` protocol is adopted by classes that act as the delegate of a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDelegate <NSObject>

@optional

/*!
 @abstract Called after the selected content controller changes.
 @param profileViewController The profile view controller where the selection was made.
 @prarm index The index of the selected content controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectContentControllerAtIndex:(NSInteger)index;

/*!
 @abstract Called after the profile picture has been selected by the user.
 @param profileViewController The profile view controller where the selection was made.
 @prarm imageView The selected image view.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectProfilePicture:(UIImageView *)imageView;

/*!
 @abstract Called after the cover photo has been selected by the user.
 @param profileViewController The profile view controller where the selection was made.
 @prarm imageView The selected image view.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectCoverPhoto:(UIImageView *)imageView;

/*!
 @abstract Called after the user has triggered a pull-to-refresh.
 @param profileViewController The profile view controller that triggered a pull-to-refresh.
 @prarm index The index of the selected content controller.
 */
- (void)profileViewController:(DBProfileViewController *)profileViewController didPullToRefreshContentControllerAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
