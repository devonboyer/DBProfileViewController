//
//  DBProfileContentViewController.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-09.
//
//

#import <Foundation/Foundation.h>

/**
 @abstract The `DBProfileContentViewController` protocol is adopted by classes that are be displayed as content view controllers of a `DBProfileViewController`.
 */
@protocol DBProfileContentViewController <NSObject>

/**
 @abstract The scroll view which will be used to track scrolling.
 */
@property (nonatomic, strong,readonly) UIScrollView *contentScrollView;

@end
