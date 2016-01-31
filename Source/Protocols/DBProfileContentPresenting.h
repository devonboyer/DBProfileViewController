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

/*!
 @protocol DBProfileContentPresenting
 @abstract The `DBProfileContentPresenting` protocol is adopted by classes that are be displayed as content view controllers of a `DBProfileViewController`.
 */
@protocol DBProfileContentPresenting <NSObject>

/*!
 @abstract The scroll view which will be used to track scrolling.
 */
- (UIScrollView *)contentScrollView;

/*!
 @abstract The title displayed in the segmented control.
 @warning The title cannot be nil.
 */
- (NSString *)contentTitle;

@optional

/*!
 @abstract An optional subtitle that is displayed beneath the profile's title in a navigation bar.
 */
- (NSString *)contentSubtitle;

@end
