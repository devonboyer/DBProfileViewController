//
//  DBProfileContentOffsetCache.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileContentOffsetCache.h"

@interface DBProfileContentOffsetCache ()

@property (nonatomic) NSCache *cache;

@end

@implementation DBProfileContentOffsetCache

- (instancetype)initWithContentControllers:(NSArray<DBProfileContentController *> *)contentControllers {
    self = [super init];
    if (self) {
        _contentControllers = contentControllers;
        
        self.cache = [[NSCache alloc] init];
        self.cache.name = @"DBProfileContentOffsetCache.cache";
        self.cache.countLimit = 10;
    }
    return self;
}

- (void)dealloc {
    [self.cache removeAllObjects];
}

- (void)setContentOffset:(CGPoint)contentOffset forContentControllerAtIndex:(NSInteger)controllerIndex {
    NSString *key = [self keyForContentControllerAtIndex:controllerIndex];
    [self.cache setObject:[NSValue valueWithCGPoint:contentOffset] forKey:key];
}

- (CGPoint)contentOffsetForContentControllerAtIndex:(NSInteger)controllerIndex {
    NSString *key = [self keyForContentControllerAtIndex:controllerIndex];
    return [[self.cache objectForKey:key] CGPointValue];
}

- (NSString *)keyForContentControllerAtIndex:(NSInteger)controllerIndex {
    NSString *title = [self.contentControllers[controllerIndex] title];
    NSMutableString *key = [[NSMutableString alloc] init];
    if (title.length) [key appendFormat:@"%@-", title];
    [key appendFormat:@"%@", @(controllerIndex)];
    return key;
}

@end
