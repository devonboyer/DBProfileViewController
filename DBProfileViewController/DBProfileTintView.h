//
//  DBProfileTintView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A view that displays a vertical gradient with two colors.
 */
@interface DBProfileTintView : UIView

/**
 *  The color of the top part of the gradient
 */
@property (nonatomic) UIColor *startColor;

/**
 *  The color of the bottom part of the gradient
 */
@property (nonatomic) UIColor *endColor;

@end

NS_ASSUME_NONNULL_END
