//
//  DBProfileViewControllerDataSource.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-04.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DBProfileViewController/DBProfileContentPresenting.h>

@class DBProfileViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `DBProfileViewControllerDataSource` protocol is adopted by classes that act as the data source of a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDataSource <NSObject>

/**
 *  Asks the data source to return the number of content controllers in the profile view controller.
 *
 *  @param controller The profile view controller requesting the information.
 *
 *  @return The number of content controllers in the profile view controller.
 */
- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)controller;

/**
 *  Asks the data source to return the content controller at a particular index in the profile view controller.
 *
 *  @param controller The profile view controller requesting the information.
 *  @prarm controllerIndex The index locating the content controller in the profile view controller.
 *
 *  @return The content controller at a particular index in the profile view controller.
 */
- (DBProfileContentController *)profileViewController:(DBProfileViewController *)controller contentControllerAtIndex:(NSUInteger)controllerIndex;

/**
 *  Asks the data source to return the title for the content controller at a particular index in the profile view controller.
 *
 *  @param controller The profile view controller requesting the information.
 *  @prarm controllerIndex The index locating the content controller in the profile view controller.
 *
 *  @return The title for the content controller at a particular index in the profile view controller.
 */
- (NSString *)profileViewController:(DBProfileViewController *)controller titleForContentControllerAtIndex:(NSUInteger)controllerIndex;

@optional

/**
 *  Asks the data source to return the subtitle for the content controller at a particular index in the profile view controller.
 *
 *  @param controller The profile view controller requesting the information.
 *  @prarm controllerIndex The index locating the content controller in the profile view controller.
 *
 *  @return The subtitle for the content controller at a particular index in the profile view controller.
 */
- (NSString *)profileViewController:(DBProfileViewController *)controller subtitleForContentControllerAtIndex:(NSUInteger)controllerIndex;

@end

NS_ASSUME_NONNULL_END
