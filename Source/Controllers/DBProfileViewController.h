//
//  DBProfileViewController.h
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import <UIKit/UIKit.h>

@protocol DBProfileContentPresenting;

@class DBProfileViewController;
@class DBProfileCoverPhotoView;
@class DBProfilePictureView;
@class DBProfileSegmentedControlView;
@class DBProfileNavigationView;

/*!
 @abstract A constant value representing the size of the profile picture when using `DBProfilePictureSizeNormal`.
 */
extern const CGFloat DBProfileViewControllerProfilePictureSizeNormal;

/*!
 @abstract A constant value representing the size of the profile picture when using `DBProfilePictureSizeLarge`.
 */
extern const CGFloat DBProfileViewControllerProfilePictureSizeLarge;

/*!
 @abstract The `DBProfileCoverPhotoOptions` defines options for changing the behaviour of the cover photo.
 */
typedef NS_OPTIONS(NSUInteger, DBProfileCoverPhotoOptions) {
    /*!
     @abstract No options are specified
     */
    DBProfileCoverPhotoOptionNone      = 1 << 0,
    /*!
     @abstract The cover photo will strech with the scroll view.
     */
    DBProfileCoverPhotoOptionStretch   = 1 << 1,
    /*!
     @abstract The cover photo will extend beneath the details view.
     */
    DBProfileCoverPhotoOptionExtend    = 1 << 2,
};

/*!
 @abstract The `DBProfilePictureSize` defines the size of the the profile picture.
 */
typedef NS_ENUM(NSInteger, DBProfilePictureSize) {
    /*!
     @abstract Specifys that the profile picture should be the normal size. 
     */
    DBProfilePictureSizeNormal,
    /*!
     @abstract Specifys that the profile picture should be large size. 
     */
    DBProfilePictureSizeLarge,
};

/*!
 @abstract The `DBProfilePictureAlignment` defines the alignment of the the profile picture.
 */
typedef NS_ENUM(NSInteger, DBProfilePictureAlignment) {
    /*!
     @abstract Specifys that the profile picture should be left aligned. 
     */
    DBProfilePictureAlignmentLeft,
    /*!
     @abstract Specifys that the profile picture should be right aligned. 
     */
    DBProfilePictureAlignmentRight,
    /*!
     @abstract Specifys that the profile picture should be center aligned. 
     */
    DBProfilePictureAlignmentCenter,
};

///------------------------------------------------
/// @name DBProfileViewControllerDelegate
///------------------------------------------------

/*!
 @protocol DBProfileViewControllerDelegate
 @abstract The `DBProfileViewControllerDelegate` protocol defines methods for interacting with a `DBProfileViewController`.
 */
@protocol DBProfileViewControllerDelegate <NSObject>

@optional

/*!
 @abstract Called after the profile picture has been selected by the user.
 @param viewController The profile view controller where the selection was made.
 @prarm imageView The selected image view.
 */
- (void)profileViewController:(DBProfileViewController *)viewController didSelectProfilePicture:(UIImageView *)imageView;

/*!
 @abstract Called after the cover photo has been selected by the user.
 @param viewController The profile view controller where the selection was made.
 @prarm imageView The selected image view.
 */
- (void)profileViewController:(DBProfileViewController *)viewController didSelectCoverPhoto:(UIImageView *)imageView;

/*!
 @abstract Called after the user has triggered a pull-to-refresh.
 @param viewController The profile view controller that triggered a pull-to-refresh.
 */
- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController;

@end

/*!
 @class DBProfileViewController
 @abstract The `DBProfileViewController` class is a view controller that is specialized to display a profile interface.
 @discussion This class manages and displays an array of content view controllers as well as a `DBProfileCoverPhotoView`, `DBProfilePictureView` and `DBProfileDetailsView`. There are many ways to customize the cover photo, profile picture and content view controllers of the profile screen.
 */
@interface DBProfileViewController : UIViewController

///----------------------------------------------
/// @name Creating a Profile View Controller
///----------------------------------------------

/**
 @abstract Creates and returns a new profile view controller.
 @param viewControllers An array of content view controllers.
 @return A newly created profile view controller.
 */
- (instancetype)initWithContentViewControllers:(NSArray *)contentViewControllers;

/*!
 @abstract The object that acts as the view controller's delegate.
 */
@property (nonatomic, strong) id<DBProfileViewControllerDelegate> delegate;

/*!
 @abstract A view that displays a navigation bar when `coverPhotoMimicsNavigationBar` is set to YES.
 */
@property (nonatomic, strong, readonly) DBProfileNavigationView *navigationView;

/*!
 @abstract A view that is displayed under the cover photo and above the content view controllers.
 @discussion The default is an instance of `DBProfileDetailsView`.
 @warning The `detailsView` cannot be nil.
 */
@property (nonatomic, strong) UIView *detailsView;

/*!
 @abstract A view that contains a segmented control and is displayed above the content view controllers.
 */
@property (nonatomic, strong, readonly) DBProfileSegmentedControlView *segmentedControlView;

///---------------------------------------------
/// @name Configuring Cover Photo
///---------------------------------------------

/*!
 @abstract Specifies the height of the cover photo relative to the height of the screen.
 @discussion The default is 0.2. To hide the cover photo set the `coverPhotoStyle` to `DBProfileCoverPhotoStyleNone`.
 @warning `coverPhotoHeightMultiplier` must be greater than 0 or less than or equal to 1.
 */
@property (nonatomic, assign) CGFloat coverPhotoHeightMultiplier;


/*!
 @abstract A view that is displays a cover photo.
 */
@property (nonatomic, strong, readonly) DBProfileCoverPhotoView *coverPhotoView;

/*!
 @abstract YES if the cover photo should hidden, NO otherwise.
 @discussion The default is `NO`.
 */
@property (nonatomic, assign) BOOL coverPhotoHidden;

/*!
 @abstract The options that specify the behaviour of the covere photo.
 @discussion The default is `DBProfileCoverPhotoOptionStretch`.
 */
@property (nonatomic, assign) DBProfileCoverPhotoOptions coverPhotoOptions;

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

///--------------------------------------------------
/// @name Accessing Content View Controllers
///--------------------------------------------------

/*!
 @abstract The array of content view controllers that this profile manages.
 */
@property (nonatomic, strong, readonly) NSArray *contentViewControllers;

/*!
 @abstract The content view controller that is currently visible.
 */
@property (nonatomic, strong, readonly) UIViewController<DBProfileContentPresenting> *visibleContentViewController;

/*!
 @abstract The index of the content view controller that is currently visible.
 */
@property (nonatomic, assign, readonly) NSUInteger visibleContentViewControllerIndex;

///---------------------------------------------------
/// @name Adding and Removing Content View Controllers
///---------------------------------------------------

/*!
 @abstract Adds a content view controller to the profile.
 @discussion Content view controllers must conform to `DBProfileContentPresenting`.
 @param contentViewController The view controller to add.
 @see DBProfileContentPresenting
 */
- (void)addContentViewController:(UIViewController<DBProfileContentPresenting> *)contentViewController;

/*!
 @abstract Adds an array of content view controller to the profile.
 @discussion Content view controllers must conform to `DBProfileContentPresenting`.
 @param contentViewControllers An array of view controllers to add.
 @see DBProfileContentPresenting
 */
- (void)addContentViewControllers:(NSArray *)contentViewControllers;

/*!
 @abstract Inserts a content view controller to the profile at the specified index.
 @discussion Content view controllers must conform to `DBProfileContentPresenting`.
 @param viewController The view controller to insert.
 @param index The index at which to insert the view controller.
 @see DBProfileContentPresenting
 */
- (void)insertContentViewController:(UIViewController<DBProfileContentPresenting> *)contentViewController atIndex:(NSUInteger)index;

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

///----------------------------------------------
/// @name Configuring Pull-To-Refresh
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
