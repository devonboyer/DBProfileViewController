//
//  DBProfileContentControllerObserver.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-11.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//


#import "DBProfileContentControllerObserver.h"

static void * DBProfileContentControllerObserverKVOContext = &DBProfileContentControllerObserverKVOContext;
static NSString * const DBProfileContentControllerObserverContentOffsetKeyPath = @"contentOffset";

@interface DBProfileContentControllerObserver ()
@property (nonatomic, weak) DBProfileContentViewController *contentController;
@property (nonatomic, assign, getter=isObserving) BOOL observing;
@end

@implementation DBProfileContentControllerObserver

- (instancetype)initWithContentController:(DBProfileContentViewController *)contentController delegate:(id<DBProfileContentControllerObserverDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.contentController = contentController;
    }
    return self;
}

- (void)dealloc {
    if (self.isObserving) {
        [self stopObserving];
    }
}

- (void)startObserving {
    if (self.isObserving) return;

    self.observing = YES;
    
    UIScrollView *scrollView = [self.contentController contentScrollView];
    
    if (scrollView) {
        [scrollView addObserver:self
                     forKeyPath:DBProfileContentControllerObserverContentOffsetKeyPath
                        options:0
                        context:&DBProfileContentControllerObserverKVOContext];
    }
}

- (void)stopObserving {
    if (!self.isObserving) return;
    
    self.observing = NO;
    
    UIScrollView *scrollView = [self.contentController contentScrollView];
    
    if (scrollView) {
        [scrollView removeObserver:self
                        forKeyPath:DBProfileContentControllerObserverContentOffsetKeyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:DBProfileContentControllerObserverContentOffsetKeyPath] && context == DBProfileContentControllerObserverKVOContext) {
        UIScrollView *scrollView = (UIScrollView *)object;
        [self.delegate contentControllerObserver:self contentControllerScrollViewDidScroll:scrollView];
    }
}

@end
