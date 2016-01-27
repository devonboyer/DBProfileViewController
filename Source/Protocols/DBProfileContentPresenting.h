//
//  DBProfileContentPresenting.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-09.
//
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
 @abstract The title displayed in a segmented control and/or navigation bar.
 @warning The title cannot be nil.
 */
- (NSString *)contentTitle;

@optional

/*!
 @abstract An optional subtitle that is displayed beneath the title in a navigation bar.
 */
- (NSString *)contentSubtitle;

@end
