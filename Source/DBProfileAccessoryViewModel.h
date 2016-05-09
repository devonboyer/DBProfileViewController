//
//  DBProfileAccessoryViewModel.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBProfileAccessoryView;
@class DBProfileAccessoryViewLayoutAttributes;

NS_ASSUME_NONNULL_BEGIN

@interface DBProfileAccessoryViewModel : NSObject

- (instancetype)initWithAccessoryView:(DBProfileAccessoryView *)accessoryView layoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *representedAccessoryKind;

@property (nonatomic, readonly) DBProfileAccessoryView *accessoryView;

@property (nonatomic, readonly) DBProfileAccessoryViewLayoutAttributes *layoutAttributes;

@end

NS_ASSUME_NONNULL_END