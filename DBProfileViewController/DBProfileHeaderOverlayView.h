//
//  DBProfileHeaderOverlayView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBProfileTitleView;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A view that overlays `DBProfileAccessoryKindHeader`, and houses the left and right bar button items, and a title view.
 */
@interface DBProfileHeaderOverlayView : UIView

/**
 *  The internal navigation bar used to set the bar button items and title of the overlay.
 */
@property (nonatomic, readonly) UINavigationBar *navigationBar;

/**
 *  The view that displays the title and subtitle of the overlay. Centered between the left and right bar button items.
 */
@property (nonatomic, readonly) DBProfileTitleView *titleView;

/**
 *  The title of the overlay.
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 *  The attributes of the overlay's title.
 */
@property(nonatomic, copy, nullable) NSDictionary <NSString *, id> *titleTextAttributes;

/**
 *  The subtitle of the overlay.
 */
@property (nonatomic, copy, nullable) NSString *subtitle;

/**
 *  The attributes of the overlay's subtitle.
 */
@property(nonatomic, copy, nullable) NSDictionary <NSString *, id> *subtitleTextAttributes;

/**
 *  The bar button item appearing at the top left of the overlay.
 */
@property (nonatomic, nullable) UIBarButtonItem *leftBarButtonItem;

/**
 *  The bar button items appearing at the top left of the overlay.
 */
@property (nonatomic, copy, nullable) NSArray <UIBarButtonItem *> *leftBarButtonItems;

/**
 *  The bar button item appearing at the top right of the overlay.
 */
@property (nonatomic, nullable) UIBarButtonItem *rightBarButtonItem;

/**
 *  The bar button items appearing at the top right of the overlay.
 */
@property (nonatomic, copy, nullable) NSArray <UIBarButtonItem *> *rightBarButtonItems;

@end

NS_ASSUME_NONNULL_END
