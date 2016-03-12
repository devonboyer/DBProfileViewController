//
//  DBProfileContentControllerObserver.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-11.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//


#import <Foundation/Foundation.h>

#import "DBProfileContentPresenting.h"

@class DBProfileContentControllerObserver;

@protocol DBProfileContentControllerObserverDelegate <NSObject>

- (void)contentControllerObserver:(DBProfileContentControllerObserver *)observer contentControllerScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface DBProfileContentControllerObserver : NSObject

- (instancetype)initWithContentController:(DBProfileContentViewController *)contentController delegate:(id<DBProfileContentControllerObserverDelegate>)delegate;

@property (nonatomic, weak) id<DBProfileContentControllerObserverDelegate> delegate;
@property (nonatomic, weak, readonly) DBProfileContentViewController *contentController;
@property (nonatomic, assign, getter=isObserving, readonly) BOOL observing;

- (void)startObserving;
- (void)stopObserving;

@end
