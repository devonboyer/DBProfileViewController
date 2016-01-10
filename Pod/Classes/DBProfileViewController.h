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

typedef NS_ENUM(NSInteger, DBProfileCoverPhotoStyle) {
    DBProfileCoverPhotoStyleNone,
    DBProfileCoverPhotoStyleDefault,
    DBProfileCoverPhotoStyleStretch,
};

typedef NS_ENUM(NSInteger, DBProfilePictureAlignment) {
    DBProfilePictureAlignmentLeft,
    DBProfilePictureAlignmentRight,
    DBProfilePictureAlignmentCenter,
};

typedef NS_ENUM(NSInteger, DBProfilePictureSize) {
    DBProfilePictureSizeDefault,
    DBProfilePictureSizeLarge,
};

///------------------------------------------------
/// @name DBProfileViewControllerDelegate
///------------------------------------------------

@protocol DBProfileViewControllerDelegate <NSObject>
@optional
- (void)profileViewController:(DBProfileViewController *)viewController didSelectProfilePicture:(UIImageView *)imageView;
- (void)profileViewController:(DBProfileViewController *)viewController didSelectCoverPhoto:(UIImageView *)imageView;
- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController;
@end

@interface DBProfileViewController : UIViewController

///----------------------------------------------
/// @name Initializing a Profile View Controller
///----------------------------------------------

- (instancetype)initWithContentViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

@property (nonatomic, strong) id<DBProfileViewControllerDelegate> delegate;

///---------------------------------------------
/// @name Configuring Profile Details
///---------------------------------------------

@property (nonatomic, strong) DBProfileDetailsView *detailsView;

///---------------------------------------------
/// @name Configuring Cover Photo
///---------------------------------------------

@property (nonatomic, strong, readonly) DBProfileCoverPhotoView *coverPhotoView;
@property (nonatomic, assign) DBProfileCoverPhotoStyle coverPhotoStyle;
@property (nonatomic, assign) BOOL coverPhotoMimicsNavigationBar;

- (void)setCoverPhoto:(UIImage *)image animated:(BOOL)animated;

///---------------------------------------------
/// @name Configuring Profile Picture
///---------------------------------------------

@property (nonatomic, strong, readonly) DBProfilePictureView *profilePictureView;
@property (nonatomic, assign) DBProfilePictureAlignment profilePictureAlignment;
@property (nonatomic, assign) DBProfilePictureSize profilePictureSize;
@property (nonatomic, assign) UIEdgeInsets profilePictureInset;

- (void)setProfilePicture:(UIImage *)image animated:(BOOL)animated;

///----------------------------------------------
/// @name Managing Content View Controllers
///----------------------------------------------

@property (nonatomic, strong, readonly) NSArray *contentViewControllers;

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController
                       withTitle:(NSString *)title;

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController
                       withTitle:(NSString *)title
                         atIndex:(NSUInteger)index;

- (void)removeContentViewControllerAtIndex:(NSUInteger)index;
- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index;

///--------------------------------------------------
/// @name Getting Content View Controller Information
///--------------------------------------------------

@property (nonatomic, strong, readonly) UIViewController<DBProfileContentViewController> *visibleContentViewController;
@property (nonatomic, assign, readonly) NSUInteger selectedContentViewControllerIndex;

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexForContentViewControllerWithTitle:(NSString *)title;

///----------------------------------------------
/// @name Refreshing Data
///----------------------------------------------

@property (nonatomic, assign, readonly, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign) BOOL allowsPullToRefresh;

- (void)endRefreshing;

@end
