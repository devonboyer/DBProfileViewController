//
//  DBProfileViewControllerDelegate.h
//  Pods
//
//  Created by Devon Boyer on 2016-02-24.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DBProfileViewController;

@protocol DBProfileViewControllerDelegate <NSObject>

- (CGFloat)profileViewController:(DBProfileViewController *)viewController heightForDetailsViewAtIndex:(NSInteger)index;

@optional

/*!
 @abstract Called after the profile picture has been selected by the user.
 @param viewController The profile view controller where the selection was made.
 @prarm imageView The selected image view.
 */
- (void)profileViewController:(DBProfileViewController *)viewController didSelectProfilePicture:(UIImageView *)imageView;

/*!
 @abstract Called after the cover photo has been selected by the user.
 @param viewController The profile view controller where the selection was made.
 @prarm imageView The selected image view.
 */
- (void)profileViewController:(DBProfileViewController *)viewController didSelectCoverPhoto:(UIImageView *)imageView;

/*!
 @abstract Called after the user has triggered a pull-to-refresh.
 @param viewController The profile view controller that triggered a pull-to-refresh.
 */
- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController;

@end
