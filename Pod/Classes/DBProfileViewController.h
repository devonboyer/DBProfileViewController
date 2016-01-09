//
//  DBProfileViewController.h
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import <UIKit/UIKit.h>

@protocol DBProfileContentViewController;

@class DBProfileDetailsView;
@class DBProfileCoverPhotoView;
@class DBProfilePictureView;
@class DBProfileViewController;

extern const CGFloat DBProfileViewControllerCoverPhotoDefaultHeight;
extern const CGFloat DBProfileViewControllerProfilePictureLeftRightMargin;
extern const CGFloat DBProfileViewControllerPullToRefreshDistance;

typedef NS_ENUM(NSInteger, DBProfileCoverPhotoStyle) {
    DBProfileCoverPhotoStyleNone,
    DBProfileCoverPhotoStyleDefault,
    DBProfileCoverPhotoStyleStretch,
};

typedef NS_ENUM(NSInteger, DBProfilePictureAlignment) {
    DBProfilePictureAlignmentLeft,
    DBProfilePictureAlignmentCenter
};

///------------------------------------------------
/// @name DBProfileViewControllerDelegate
///------------------------------------------------

@protocol DBProfileViewControllerDelegate <NSObject>
@optional
- (void)profileViewController:(DBProfileViewController *)viewController didSelectProfilePicture:(UIImageView *)imageView;
- (void)profileViewController:(DBProfileViewController *)viewController didSelectCoverPhoto:(UIImageView *)imageView;
- (void)profileViewControllerDidStartRefreshing:(DBProfileViewController *)viewController;
@end

@interface DBProfileViewController : UIViewController

///----------------------------------------------
/// @name Initializing a Profile View Controller
///----------------------------------------------

- (instancetype)initWithContentViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

@property (nonatomic, strong) id<DBProfileViewControllerDelegate> delegate;

@property (nonatomic, strong) DBProfileDetailsView *detailsView;

///----------------------------------------------
/// @name Configuring Cover Photo
///---------------------------------------------

@property (nonatomic, strong, readonly) DBProfileCoverPhotoView *coverPhotoView;
@property (nonatomic, assign) DBProfileCoverPhotoStyle coverPhotoStyle;

///----------------------------------------------
/// @name Configuring Profile Picture
///---------------------------------------------

@property (nonatomic, strong, readonly) DBProfilePictureView *profilePictureView;
@property (nonatomic, assign) DBProfilePictureAlignment profilePictureAlignment;

///----------------------------------------------
/// @name Managing Content View Controllers
///----------------------------------------------

@property (nonatomic, strong, readonly) NSArray *contentViewControllers;
@property (nonatomic, strong, readonly) UIViewController<DBProfileContentViewController> *visibleContentViewController;

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController withTitle:(NSString *)title;
- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController atIndex:(NSUInteger)index withTitle:(NSString *)title;
- (void)removeContentViewControllerAtIndex:(NSUInteger)index;
- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index;

///----------------------------------------------
/// @name Refreshing Data
///----------------------------------------------

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (void)startRefreshing;
- (void)endRefreshing;

@end
