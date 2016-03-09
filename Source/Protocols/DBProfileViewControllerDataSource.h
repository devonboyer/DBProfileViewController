//
//  DBProfileViewControllerDataSource.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-04.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DBProfileContentPresenting.h"

@class DBProfileViewController;

@protocol DBProfileViewControllerDataSource <NSObject>

- (NSUInteger)numberOfSegmentsForProfileViewController:(DBProfileViewController *)profileViewController;

- (DBProfileContentViewController *)profileViewController:(DBProfileViewController *)profileViewController contentViewControllerAtIndex:(NSUInteger)index;

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentAtIndex:(NSUInteger)index;

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentAtIndex:(NSUInteger)index;

@optional

@end