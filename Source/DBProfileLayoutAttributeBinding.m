//
//  DBProfileLayoutAttributeBinding.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileLayoutAttributeBinding.h"
#import "DBProfileObserver.h"

static void * DBProfileLayoutAttributeBindingContext = &DBProfileLayoutAttributeBindingContext;

@interface DBProfileLayoutAttributeBinding () <DBProfileObserverDelegate>

@property (nonatomic) DBProfileObserver *observer;

@end

@implementation DBProfileLayoutAttributeBinding

+ (instancetype)bindingWithObject:(NSObject *)object keyPath:(NSString *)keyPath delegate:(id<DBProfileLayoutAttributeBindingDelegate>)delegate
{
    return [[self alloc] initWithObject:object keyPath:keyPath delegate:delegate];
}

- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath delegate:(id<DBProfileLayoutAttributeBindingDelegate>)delegate
{
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = [keyPath copy];
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    if (self.isBound) {
        [self unbind];
    }
}

- (id)value
{
    return [self.object valueForKeyPath:self.keyPath];
}

#pragma mark - Binding

- (BOOL)isBound
{
    return self.observer.observing;
}

- (void)bind
{
    if (!self.isBound) {
        self.observer = [[DBProfileObserver alloc] initWithTarget:self.object
                                                         keyPaths:@[self.keyPath]
                                                         delegate:self
                                                          context:DBProfileLayoutAttributeBindingContext];
    }
}

- (void)unbind
{
    if (self.isBound) {
        self.observer = nil;
    }
}

#pragma mark - DBProfileObserverDelegate

- (void)observer:(DBProfileObserver *)observer valueDidChange:(id)newValue fromValue:(id)oldValue
{
    if ([self.delegate respondsToSelector:@selector(binding:valueDidChange:fromValue:)]) {
        [self.delegate binding:self valueDidChange:newValue fromValue:oldValue];
    }
}

@end
