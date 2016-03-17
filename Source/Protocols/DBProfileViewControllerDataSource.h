//
//  DBProfileViewControllerDataSource.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-04.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DBProfileContentPresenting.h"

@class DBProfileViewController;

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol DBProfileViewControllerDataSource
 @abstract The `DBProfileViewControllerDataSource` protocol is adopted by classes that act as the data source of a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDataSource <NSObject>

/*!
 @abstract Asks the data source to return the number of content controllers in the profile view controller.
 @param profileViewController The profile view controller requesting the information.
 @return The number of content controllers in the profile view controller.
 @warning The number of content controllers must be greater than 0.
 */
- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController;

/*!
 @abstract Asks the data source to return the content controller at a particular index in the profile view controller.
 @param profileViewController The profile view controller requesting the information.
 @prarm index The index locating the content controller in the profile view controller.
 @return The content controller at a particular index in the profile view controller.
 @warning The content controller cannot be nil.
 */
- (DBProfileContentController *)profileViewController:(DBProfileViewController *)profileViewController contentControllerAtIndex:(NSUInteger)index;

/*!
 @abstract Asks the data source to return the title for the content controller at a particular index in the profile view controller.
 @param profileViewController The profile view controller requesting the information.
 @prarm index The index locating the content controller in the profile view controller.
 @return The title for the content controller at a particular index in the profile view controller.
 @warning The title cannot be nil.
 */
- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)index;

@optional

/*!
 @abstract Asks the data source to return the subtitle for the content controller at a particular index in the profile view controller.
 @param profileViewController The profile view controller requesting the information.
 @prarm index The index locating the content controller in the profile view controller.
 @return The subtitle for the content controller at a particular index in the profile view controller.
 */
- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
