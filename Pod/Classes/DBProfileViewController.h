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
@class DBProfileNavigationView;

extern const CGFloat DBProfileViewControllerProfilePictureSizeNormal;
extern const CGFloat DBProfileViewControllerProfilePictureSizeLarge;
extern const CGFloat DBProfileViewControllerPullToRefreshDistance;

/**
 @abstract The `DBProfileCoverPhotoStyle` defines the types of styles for the cover photo.
 */
typedef NS_ENUM(NSInteger, DBProfileCoverPhotoStyle) {
    DBProfileCoverPhotoStyleNone,
    /* @abstract Specifys the default cover photo style. */
    DBProfileCoverPhotoStyleDefault,
    /* @abstract Specifys that the cover photo should stretch with the scroll view. */
    DBProfileCoverPhotoStyleStretch,
    /** @abstract Specifys that the cover photo should extend beneath the details view. */
    DBProfileCoverPhotoStyleBackdrop,
};

/**
 @abstract The `DBProfilePictureSize` defines the size of the the profile picture.
 */
typedef NS_ENUM(NSInteger, DBProfilePictureSize) {
    /* @abstract Specifys that the profile picture should be the normal size. */
    DBProfilePictureSizeNormal,
    /* @abstract Specifys that the profile picture should be large size. */
    DBProfilePictureSizeLarge,
};

/**
 @abstract The `DBProfilePictureAlignment` defines the alignment of the the profile picture.
 */
typedef NS_ENUM(NSInteger, DBProfilePictureAlignment) {
    /* @abstract Specifys that the profile picture should be left aligned. */
    DBProfilePictureAlignmentLeft,
    /* @abstract Specifys that the profile picture should be right aligned. */
    DBProfilePictureAlignmentRight,
    /* @abstract Specifys that the profile picture should be center aligned. */
    DBProfilePictureAlignmentCenter,
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

/*!
 @class DBProfileViewController
 @abstract The `DBProfileViewController` class is a view controller that is specialized to display a profile interface.
 @discussion This class manages and displays an array of content view controllers as well as a `DBProfileCoverPhotoView`, `DBProfilePictureView` and `DBProfileDetailsView`. There are many ways to customize the cover photo, profile picture and content view controllers of the profile screen.
 @note When using `coverPhotoMimicsNavigationBar` you should set `automaticallyAdjustsScrollViewInsets` to NO. Otherwise set `automaticallyAdjustsScrollViewInsets` to YES when using a navigation controller's UINavigationBar.
 */
@interface DBProfileViewController : UIViewController

@property (nonatomic, strong, readonly) DBProfileNavigationView *navigationView;


///----------------------------------------------
/// @name Initializing a Profile View Controller
///----------------------------------------------

/**
 @abstract Creates and returns a new profile view controller.
 @param viewControllers An array of content view controllers.
 @param titles An array of titles for the associated content view controllers.
 @return A newly created profile view controller.
 */
- (instancetype)initWithContentViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

/*!
 @abstract The object that acts as the view controller's delegate.
 */
@property (nonatomic, strong) id<DBProfileViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *subtitle;

///---------------------------------------------
/// @name Configuring Profile Details
///---------------------------------------------

/*!
 @abstract A view that is displayed under the cover photo and above the content views. This is where you might include details such as name, username, or description.
 */
@property (nonatomic, strong) DBProfileDetailsView *detailsView;

///---------------------------------------------
/// @name Configuring Cover Photo
///---------------------------------------------

/*!
 @abstract Specifies the height of the cover photo relative to the height of the screen.
 @discussion The default is 0.24. To hide the cover photo set the `coverPhotoStyle` to `DBProfileCoverPhotoStyleNone`.
 @warning `coverPhotoHeightMultiplier` must be greater than 0 or less that or equal to 1.
 */
@property (nonatomic, assign) CGFloat coverPhotoHeightMultiplier;


/*!
 @abstract A view that is displays a cover photo.
 */
@property (nonatomic, strong, readonly) DBProfileCoverPhotoView *coverPhotoView;

/*!
 @abstract Specifies the style for the cover photo.
 @discussion The default is `DBProfileCoverPhotoStyleStretch`.
 @warning `DBProfileCoverPhotoStyleNone` is mutually exclusive with `coverPhotoMimicsNavigationBar` and `allowsPullToRefresh`.
 */
@property (nonatomic, assign) DBProfileCoverPhotoStyle coverPhotoStyle;

/*!
 @abstract YES if the cover photo should be mimic a navigation bar when the view is scrolled, NO otherwise.
 @discussion The default is YES. When this property is set to YES you should set `automaticallyAdjustsScrollViewInsets` to NO, otherwise set `automaticallyAdjustsScrollViewInsets` to YES.
 */
@property (nonatomic, assign) BOOL coverPhotoMimicsNavigationBar;

/*!
 @abstract Sets the cover photo.
 @param coverPhoto The image to set as the cover photo.
 @param animated YES if setting the cover photo should be animated, NO otherwise.
 */
- (void)setCoverPhoto:(UIImage *)coverPhoto animated:(BOOL)animated;

///---------------------------------------------
/// @name Configuring Profile Picture
///---------------------------------------------

/*!
 @abstract A view that is displays a profile picture.
 */
@property (nonatomic, strong, readonly) DBProfilePictureView *profilePictureView;

/*!
 @abstract Specifies the alignment for the profile picture.
 @discussion The default is `DBProfilePictureAlignmentLeft`.
 */
@property (nonatomic, assign) DBProfilePictureAlignment profilePictureAlignment;

/*!
 @abstract Specifies the size for the profile picture.
 @discussion The default is `DBProfilePictureSizeNormal`.
 */
@property (nonatomic, assign) DBProfilePictureSize profilePictureSize;

/*!
 @abstract The distance that the profile picture is inset from the alignment.
 */
@property (nonatomic, assign) UIEdgeInsets profilePictureInset;

/*!
 @abstract Sets the profile picture.
 @param profilePicture The image to set as the profile picture.
 @param animated YES if setting the cover photo should be animated, NO otherwise.
 */
- (void)setProfilePicture:(UIImage *)profilePicture animated:(BOOL)animated;

///----------------------------------------------
/// @name Managing Content View Controllers
///----------------------------------------------

/*!
 @abstract The array of content view controllers that this profile manages.
 */
@property (nonatomic, strong, readonly) NSArray *contentViewControllers;

/*!
 @abstract Adds a content view controller to the profile.
 @discussion Content view controllers must conform to `DBProfileContentViewController`.
 @param viewController The view controller to add.
 @param title The title of the view controller to add.
 @see DBProfileContentViewController
 */
- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController
                       withTitle:(NSString *)title;

/*!
 @abstract Adds a content view controller to the profile.
 @discussion Content view controllers must conform to `DBProfileContentViewController`.
 @param viewController The view controller to add.
 @param title The title of the view controller to add.
 @param index The index at which to insert the view controller.
 @see DBProfileContentViewController
 */
- (void)insertContentViewController:(UIViewController<DBProfileContentViewController> *)viewController
                          withTitle:(NSString *)title
                            atIndex:(NSUInteger)index;

/*!
 @abstract Removes a content view controller the profile.
 @param index The index at which to remove the view controller.
 */
- (void)removeContentViewControllerAtIndex:(NSUInteger)index;

/*!
 @abstract Sets the view controller at the specified index as the visible view controller.
 @param index The index of the view controller to set as the visible view controller.
 */
- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index;

///--------------------------------------------------
/// @name Getting Content View Controller Information
///--------------------------------------------------

/*!
 @abstract The content view controller that is currently visible.
 */
@property (nonatomic, strong, readonly) UIViewController<DBProfileContentViewController> *visibleContentViewController;

/*!
 @abstract The index of the content view controller that is currently visible.
 */
@property (nonatomic, assign, readonly) NSUInteger visibleContentViewControllerIndex;

/*!
 @abstract Returns the title of the view controller at the specified index.
 @param index The index of the view controller.
 */
- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index;

/*!
 @abstract Returns the index of the view controller with the specified title.
 @param title The title of the view controller.
 */
- (NSUInteger)indexForContentViewControllerWithTitle:(NSString *)title;

///----------------------------------------------
/// @name Refreshing Data
///----------------------------------------------

/*!
 @abstract YES if the pull-to-refresh indicator is currently animating, NO otherwise.
 */
@property (nonatomic, assign, readonly, getter=isRefreshing) BOOL refreshing;

/*!
 @abstract YES to enable pull-to-refresh, NO otherwise.
  @discussion The default is YES.
 @warning `DBProfileCoverPhotoStyleNone` is mutually exclusive with `allowsPullToRefresh`
 */
@property (nonatomic, assign) BOOL allowsPullToRefresh;

/*!
 @abstract Hides the pull-to-refresh indicator if it is currently animating.
 */
- (void)endRefreshing;

@end
