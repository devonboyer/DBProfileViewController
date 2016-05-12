//
//  DBProfileObserver.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-11.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBProfileObserver;

NS_ASSUME_NONNULL_BEGIN

@protocol DBProfileObserverDelegate <NSObject>

- (void)observer:(DBProfileObserver *)observer valueDidChange:(id)newValue fromValue:(id)oldValue;

@end

@interface DBProfileObserver : NSObject

@property (nonatomic, strong) NSArray *keyPaths;
@property (nonatomic, strong) id target;
@property (nonatomic) BOOL observing;
@property (nonatomic) void *context;

@property (nonatomic, weak, nullable) id<DBProfileObserverDelegate> delegate;
@property (nonatomic) SEL action;

- (instancetype)initWithTarget:(id)target keyPaths:(NSArray *)keyPaths delegate:(id<DBProfileObserverDelegate>)delegate context:(void *)context NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithTarget:(id)target keyPaths:(NSArray *)keyPaths delegate:(id<DBProfileObserverDelegate>)delegate action:(SEL)action context:(void *)context NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)startObserving;

@end

@protocol DBProfileScrollViewObserverDelegate <DBProfileObserverDelegate>

- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView;

@end


@interface DBProfileScrollViewObserver : DBProfileObserver

- (instancetype)initWithTargetView:(UIScrollView *)scrollView delegate:(id <DBProfileScrollViewObserverDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
