//
//  DBProfileAccessoryView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-17.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileAccessoryView
 */
@interface DBProfileAccessoryView : UIView

@property (nonatomic, strong, readonly) UIView *selectedBackgroundView;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
