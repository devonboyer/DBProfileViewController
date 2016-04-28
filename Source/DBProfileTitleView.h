//
//  DBProfileTitleView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A view that displays a title and subtitle.
 */
@interface DBProfileTitleView : UIView

/**
 *  A label that displays the title.
 */
@property (nonatomic, readonly) UILabel *titleLabel;

/**
 *  A label that displays the subtitle.
 */
@property (nonatomic, readonly) UILabel *subtitleLabel;

/**
 *  A string representing the title;
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 *  The attributes of the title.
 */
@property(nonatomic, copy, nullable) NSDictionary <NSString *, id> *titleTextAttributes;

/**
 *  A string representing the subtitle;
 */
@property (nonatomic, copy, nullable) NSString *subtitle;

/**
 *  The attributes of the subtitle.
 */
@property(nonatomic, copy, nullable) NSDictionary <NSString *, id> *subtitleTextAttributes;

/**
 *  Whether a shadow should be added to the title and subtitle labels.
 */
@property (nonatomic) BOOL wantsShadowForLabels;

@end

NS_ASSUME_NONNULL_END
