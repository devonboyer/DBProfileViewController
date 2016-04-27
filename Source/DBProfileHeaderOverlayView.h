//
//  DBProfileHeaderOverlayView.h
//  Pods
//
//  Created by Devon Boyer on 2016-04-26.
//
//

#import <UIKit/UIKit.h>
#import <DBProfileTitleView.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBProfileHeaderOverlayView : UIView

/**
 *  The internal navigation bar used to set the bar button items and title of the overlay.
 */
@property (nonatomic, readonly) UINavigationBar *navigationBar;

@property (nonatomic, readonly) DBProfileTitleView *titleView;

/**
 *  The title of the overlay. Centered between the left and right bar button items.
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 *  The title of the overlay. Centered between the left and right bar button items.
 */
@property (nonatomic, copy, nullable) NSString *subtitle;

/**
 *  The attributes of the overlay's title.
 */
@property(nonatomic, copy, nullable) NSDictionary <NSString *, id> *titleTextAttributes;

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

- (void)setTitleVerticalPositionAdjustment:(CGFloat)adjustment traitCollection:(UITraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
