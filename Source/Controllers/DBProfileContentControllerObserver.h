//
//  DBProfileContentControllerObserver.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-11.
//
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
@property (nonatomic, strong, readonly) DBProfileContentViewController *contentController;
@property (nonatomic, assign, getter=isObserving, readonly) BOOL observing;

- (void)startObserving;
- (void)stopObserving;

@end
