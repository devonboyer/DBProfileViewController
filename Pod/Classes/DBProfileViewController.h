//
//  DBProfileViewController.h
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import <UIKit/UIKit.h>

@class DBProfileDetailsView;

extern const CGFloat DBProfileViewControllerCoverImageDefaultHeight;

typedef NS_ENUM(NSInteger, DBProfileCoverImageStyle) {
    DBProfileCoverImageStyleNone,
    DBProfileCoverImageStyleDefault,
    DBProfileCoverImageStyleStretch,
};

typedef NS_ENUM(NSInteger, DBProfileImageAlignment) {
    DBProfileImageAlignmentLeft,
    DBProfileImageAlignmentCenter
};

@interface DBProfileViewController : UIViewController

///----------------------------------------------
/// @name Initializing a Profile View Controller
///----------------------------------------------

- (instancetype)initWithContentViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

@property (nonatomic, strong) DBProfileDetailsView *detailsView;

///----------------------------------------------
/// @name Configuring Cover Image
///---------------------------------------------

@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, assign) DBProfileCoverImageStyle coverImageStyle;

///----------------------------------------------
/// @name Configuring Profile Image
///---------------------------------------------

@property (nonatomic, strong, readonly) UIImageView *profileImageView;
@property (nonatomic, assign) DBProfileImageAlignment profileImageAlignment;

///----------------------------------------------
/// @name Managing Content View Controllers
///----------------------------------------------

@property (nonatomic, strong, readonly) UISegmentedControl *contentSegmentedControl;
@property (nonatomic, strong, readonly) NSArray *contentViewControllers;
@property (nonatomic, strong, readonly) UIViewController *visibleContentViewController;

- (void)addContentViewController:(UIViewController *)viewController withTitle:(NSString *)title;
- (void)addContentViewController:(UIViewController *)viewController atIndex:(NSUInteger)index withTitle:(NSString *)title;
- (void)removeContentViewControllerAtIndex:(NSUInteger)index;
- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index;

///----------------------------------------------
/// @name Refreshing Data
///----------------------------------------------

@property (nonatomic, strong, readonly) UIRefreshControl *refreshControl;

- (void)startRefreshing;
- (void)endRefreshing;

@end
