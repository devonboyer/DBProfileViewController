//
//  DBProfileAccessoryViewModel.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBProfileAccessoryViewModel;
@class DBProfileAccessoryView;
@class DBProfileAccessoryViewLayoutAttributes;
@class DBProfileBinding;

NS_ASSUME_NONNULL_BEGIN

@protocol DBProfileAccessoryViewModelUpdating <NSObject>

- (void)updateLayoutAttributeFromValue:(id)fromValue toValue:(id)toValue forAccessoryViewModel:(DBProfileAccessoryViewModel *)viewModel;

@end

@interface DBProfileAccessoryViewModel : NSObject

- (instancetype)initWithAccessoryView:(DBProfileAccessoryView *)accessoryView
                     layoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id<DBProfileAccessoryViewModelUpdating> updater;

@property (nonatomic, readonly) NSString *representedAccessoryKind;

@property (nonatomic, readonly) DBProfileAccessoryView *accessoryView;

@property (nonatomic, readonly) DBProfileAccessoryViewLayoutAttributes *layoutAttributes;

@property (nonatomic, readonly) NSArray<DBProfileBinding *> *bindings;

- (void)addBinding:(DBProfileBinding *)binding;

- (void)addBindings:(NSArray<DBProfileBinding *> *)bindings;

@end

NS_ASSUME_NONNULL_END