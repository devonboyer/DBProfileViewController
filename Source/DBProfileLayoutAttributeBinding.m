//
//  DBProfileLayoutAttributeBinding.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileLayoutAttributeBinding.h"

static void * DBProfileLayoutAttributeBindingContext = &DBProfileLayoutAttributeBindingContext;

@implementation DBProfileLayoutAttributeBinding

- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = [keyPath copy];
    }
    return self;
}

- (void)dealloc
{
    if (self.isBound) {
        [self unbind];
    }
}

#pragma mark - KVO

- (id)value
{
    return [self.object valueForKeyPath:self.keyPath];
}

- (void)bind
{
    if (!self.isBound) {
        [self.object addObserver:self
                      forKeyPath:self.keyPath
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                         context:&DBProfileLayoutAttributeBindingContext];

        _bound = YES;
    }
}

- (void)unbind
{
    if (self.isBound) {
        [self.object removeObserver:self forKeyPath:self.keyPath context:&DBProfileLayoutAttributeBindingContext];
        _bound = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != DBProfileLayoutAttributeBindingContext || object != self.object || ![keyPath isEqual:self.keyPath]) {
        return;
    }
    
    id newValue = change[NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) {
        newValue = nil;
    }
    
    id oldValue = change[NSKeyValueChangeOldKey];
    if (oldValue == [NSNull null]) {
        oldValue = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(binding:valueDidChange:fromValue:)]) {
        [self.delegate binding:self valueDidChange:newValue fromValue:oldValue];
    }
}

@end
