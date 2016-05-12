//
//  DBProfileLayoutAttributeBinding.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBProfileLayoutAttributeBinding;

@protocol DBProfileLayoutAttributeBindingDelegate <NSObject>

@optional

- (void)binding:(DBProfileLayoutAttributeBinding *)binding valueDidChange:(id)newValue fromValue:(id)oldValue;

@end

@interface DBProfileLayoutAttributeBinding : NSObject

+ (instancetype)bindingWithObject:(NSObject *)object keyPath:(NSString *)keyPath delegate:(id<DBProfileLayoutAttributeBindingDelegate>)delegate;

- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath delegate:(id<DBProfileLayoutAttributeBindingDelegate>)delegate;

@property (nonatomic, weak) id<DBProfileLayoutAttributeBindingDelegate> delegate;

@property (nonatomic, readonly) NSObject *object;

@property (nonatomic, copy, readonly) NSString *keyPath;

@property (nonatomic, readonly, getter=isBound) BOOL bound;

- (id)value;

- (void)bind;

- (void)unbind;

@end
