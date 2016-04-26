//
//  DBProfileContentPresenting.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-09.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBProfileContentPresenting;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The type for a view controller that can be used as a content controller of a `DBProfileViewController`.
 */
typedef UIViewController<DBProfileContentPresenting> DBProfileContentController;

/**
 *  The `DBProfileContentPresenting` protocol is adopted by classes that are to be displayed as content controllers of a `DBProfileViewController`.
 */
@protocol DBProfileContentPresenting <NSObject>

/**
 *  The scroll view which will be used to track scrolling.
 *
 *  @warning The content scroll view cannot be nil and must have a frame equal to that of the conforming view controller's view.
 */
- (UIScrollView *)contentScrollView;

@end

NS_ASSUME_NONNULL_END
