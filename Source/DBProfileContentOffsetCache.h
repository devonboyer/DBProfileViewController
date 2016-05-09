//
//  DBProfileContentOffsetCache.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DBProfileViewController/DBProfileContentPresenting.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBProfileContentOffsetCache : NSObject

- (instancetype)initWithContentControllers:(NSArray<DBProfileContentController *> *)contentControllers NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSArray<DBProfileContentController *> *contentControllers;

- (void)setContentOffset:(CGPoint)contentOffset forContentControllerAtIndex:(NSInteger)controllerIndex;

- (CGPoint)contentOffsetForContentControllerAtIndex:(NSInteger)controllerIndex;

- (NSString *)keyForContentControllerAtIndex:(NSInteger)controllerIndex;

@end

NS_ASSUME_NONNULL_END
