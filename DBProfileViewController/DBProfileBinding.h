//
//  DBProfileBinding.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBProfileBinding;

NS_ASSUME_NONNULL_BEGIN

@protocol DBProfileBindingDelegate <NSObject>

@optional

- (void)binding:(DBProfileBinding *)binding valueDidChange:(id)newValue fromValue:(id)oldValue;

@end

@interface DBProfileBinding : NSObject

+ (instancetype)bindingWithObject:(NSObject *)object keyPath:(NSString *)keyPath delegate:(id<DBProfileBindingDelegate>)delegate;

- (instancetype)initWithObject:(NSObject *)object keyPath:(NSString *)keyPath delegate:(id<DBProfileBindingDelegate>)delegate;

@property (nonatomic, weak) id<DBProfileBindingDelegate> delegate;

@property (nonatomic, readonly) NSObject *object;

@property (nonatomic, copy, readonly) NSString *keyPath;

@property (nonatomic, readonly, getter=isBound) BOOL bound;

- (id)value;

- (void)bind;

- (void)unbind;

@end

NS_ASSUME_NONNULL_END