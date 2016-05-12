//
//  DBProfileSegmentedControl.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBProfileSegmentedControl <NSObject>

@property(nonatomic) NSInteger selectedSegmentIndex;

- (void)insertSegmentWithTitle:(nullable NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;

- (void)removeAllSegments;

@end

@interface UISegmentedControl (DBProfileSegmentedControl) <DBProfileSegmentedControl>
@end
