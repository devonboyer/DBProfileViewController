//
//  DBProfileObserver.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-11.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileObserver.h"
#import "DBProfileDefines.h"

@implementation DBProfileObserver

- (instancetype)initWithTarget:(id)target keyPaths:(NSArray *)keyPaths delegate:(id)delegate action:(SEL)action context:(void *)context {
    self = [super init];
    if (self) {
        self.keyPaths = keyPaths;
        self.target = target;
        self.delegate = delegate;
        self.action = action;
        self.context = context;
        [self startObserving];
    }
    return self;
}

- (void)startObserving {
    if (_observing == NO) {
        NSAssert(self.keyPaths, @"");
        NSAssert(self.target, @"");
        NSAssert(self.context, @"");
        NSAssert(self.delegate, @"");
        NSAssert(self.action, @"");
        for (NSString *keyPath in self.keyPaths) {
            [self.target addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptions)0 context:self.context];
        }
        self.observing = YES;
    }
}

- (void)stopObserving {
    if (_observing) {
        for (NSString *keyPath in _keyPaths) {
            [self.target removeObserver:self forKeyPath:keyPath];
        }
        _observing = NO;
    }
}

- (void)dealloc {
    [self stopObserving];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSAssert(context == self.context, @"Unexpected KVO");
    DBProfileSuppressPerformSelectorWarning([self.delegate performSelector:self.action withObject:self.target]);
}

@end

@implementation DBProfileScrollViewObserver

static void *_DBProfileScrollViewObserverContext = &_DBProfileScrollViewObserverContext;

- (instancetype)initWithTargetView:(UIScrollView *)scrollView delegate:(id <DBProfileScrollViewObserverDelegate>)delegate {
    return [super initWithTarget:scrollView
                        keyPaths:@[@"contentOffset"]
                        delegate:delegate
                          action:@selector(observedScrollViewDidScroll:)
                         context:_DBProfileScrollViewObserverContext];
}

@end
