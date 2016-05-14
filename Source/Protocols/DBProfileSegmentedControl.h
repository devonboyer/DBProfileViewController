//
//  DBProfileSegmentedControl.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBProfileSegmentedControl;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The type for a control that can be used as a segmented control of a `DBProfileViewController`.
 */
typedef UIControl<DBProfileSegmentedControl> DBProfileSegmentedControl;

/**
 *  The `DBProfileSegmentedControl` protocol is adopted by classes that can be used as a segmented control of a `DBProfileViewController`.
 */
@protocol DBProfileSegmentedControl <NSObject>

/**
 *  The currently selected segment index.
 */
@property (nonatomic) NSInteger selectedSegmentIndex;

/**
 *  Inserts a segment at a specific position in the control and gives it a title as content.
 *
 *  @param title A string to use as the segment’s title.
 *  @param segment An index number identifying a segment in the control.
 *  @param animated YES if the insertion of the new segment should be animated, otherwise NO.
 */
- (void)insertSegmentWithTitle:(nullable NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;

/**
 *  Removes all segments of the control.
 */
- (void)removeAllSegments;

@end

@interface UISegmentedControl (DBProfileSegmentedControl) <DBProfileSegmentedControl>
@end

NS_ASSUME_NONNULL_END
