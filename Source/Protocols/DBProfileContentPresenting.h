//
//  DBProfileContentPresenting.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-09.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>

@protocol DBProfileContentPresenting;

typedef UIViewController<DBProfileContentPresenting> DBProfileContentController;

/*!
 @protocol DBProfileContentPresenting
 @abstract The `DBProfileContentPresenting` protocol is adopted by classes that are to be displayed as content view controllers of a `DBProfileViewController`.
 */
@protocol DBProfileContentPresenting <NSObject>

/*!
 @abstract The scroll view which will be used to track scrolling.
 */
- (UIScrollView *)contentScrollView;

@optional

- (NSString *)contentTitle __deprecated;
- (NSString *)contentSubtitle __deprecated;

@end
