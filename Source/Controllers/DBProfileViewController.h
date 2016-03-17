//
//  DBProfileViewController.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2015-12-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

#import "DBProfileContentPresenting.h"
#import "DBProfileViewControllerDelegate.h"
#import "DBProfileViewControllerDataSource.h"

@class DBProfileViewController;
@class DBProfileCoverPhotoView;
@class DBProfilePictureView;
@class DBProfileSegmentedControlView;
@class DBProfileNavigationView;

NS_ASSUME_NONNULL_BEGIN

/*!
 @abstract A constant value representing the size of the profile picture when using `DBProfilePictureSizeEditProfile`.
 */
extern const CGFloat DBProfileViewControllerProfilePictureSizeEditProfile;

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
     @abstract No options are specified.
     */
    DBProfileCoverPhotoOptionNone      = 1 << 0,
    /*!
     @abstract The cover photo will stretch with the scroll view.
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
     @abstract The profile picture size for `DBEditProfileViewController`
     */
    DBProfilePictureSizeEditProfile,
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

/*!
 @class DBProfileViewController
 @abstract The `DBProfileViewController` class is a view controller that is specialized to display a profile interface.
 @discussion This class manages and displays a collection of content controllers as well as a `DBProfileCoverPhotoView`, `DBProfilePictureView` and `DBProfileDetailsView`.
 */
@interface DBProfileViewController : UIViewController

///---------------------------------------------
/// @name Creating Profile View Controllers
///---------------------------------------------

/*!
 @abstract Initializes a newly created profile view controller.
 @param segmentedControlClass Specify the custom UISegmentedControl subclass you want to use, or specify nil to use the standard UISegmentedControl class.
*/
- (instancetype)initWithSegmentedControlClass:(nullable Class)segmentedControlClass;

/*!
 @abstract The object that acts as the view controller's delegate.
 */
@property (nonatomic, weak, nullable) id<DBProfileViewControllerDelegate> delegate;

/*!
 @abstract The object that acts as the view controller's data source.
 */
@property (nonatomic, weak, nullable) id<DBProfileViewControllerDataSource> dataSource;

/*!
 @abstract A view that is displayed under the cover photo and above the content controllers.
 @discussion The default is an instance of `DBProfileDetailsView`.
 @warning The `detailsView` cannot be nil.
 */
@property (nonatomic, strong) UIView *detailsView;

/*!
 @abstract The navigation item used to represent the profile view controller's navigation bar when using `coverPhotoMimicsNavigationBar`
 */
@property (nonatomic, strong, readonly) UINavigationItem *coverPhotoMimicsNavigationBarNavigationItem;

///---------------------------------------------
/// @name Reloading the Profile View Controller
///---------------------------------------------

/*!
 @abstract Begins a series of method calls that modify height calculations for subviews of the profile view controller.
 @discussion Call this method if you want subsequent height changes to subviews to be animated simultaneously. 
 @warning This group of methods must conclude with an invocation of endUpdates. You should not call reloadData within the group.
 */
- (void)beginUpdates;

/*!
 @abstract Concludes a series of method calls that modify height calculations for subviews of the profile view controller.
 @discussion You call this method to bracket a series of method calls that begins with beginUpdates. When you call endUpdates, height changes to subviews are animated simultaneously.
 */
- (void)endUpdates;

/*!
 @abstract Reloads the content controllers of the profile view controller by rebuilding the view heirarchy.
 */
- (void)reloadData;

///---------------------------------------------
/// @name Configuring Segmented Control
///---------------------------------------------

/*!
 @abstract The segmented control managed by the profile view controller.
 */
@property (nonatomic, assign, readonly) UISegmentedControl *segmentedControl;

/*!
 @abstract YES if the segmented control is hidden when there is only one content controller, NO otherwise.
 @discussion The default is YES
 */
@property (nonatomic, assign) BOOL hidesSegmentedControlForSingleContentController;

///---------------------------------------------
/// @name Managing Selections
///---------------------------------------------

/*!
 @abstract The index of the selected content controller.
 */
@property (nonatomic, assign, readonly) NSUInteger indexForSelectedContentController;

/*!
 @abstract Selects a content controller in the profile view controller at the specified index.
 @param index An index identifying a content controller in the profile view controller.
 */
- (void)selectContentControllerAtIndex:(NSInteger)index;

///---------------------------------------------
/// @name Configuring Cover Photo
///---------------------------------------------

/*!
 @abstract Specifies the height of the cover photo relative to the height of the screen.
 @discussion The default is 0.18. To hide the cover photo set `coverPhotoHidden` to YES. When using `coverPhotoMimicsNavigationBar` is important that this value results in the height of the cover photo being greater than the height of a navigation bar.
 @warning `coverPhotoHeightMultiplier` must be greater than 0 or less than or equal to 1.
 */
@property (nonatomic, assign) CGFloat coverPhotoHeightMultiplier;

/*!
 @abstract A view that is displays a cover photo.
 */
@property (nonatomic, strong, readonly) DBProfileCoverPhotoView *coverPhotoView;

/*!
 @abstract YES if the cover photo should be hidden, NO otherwise.
 @discussion The default is `NO`.
 */
@property (nonatomic, assign) BOOL coverPhotoHidden;

/*!
 @abstract The options that specify the behaviour of the covere photo.
 @discussion The default is `DBProfileCoverPhotoOptionStretch`.
 */
@property (nonatomic, assign) DBProfileCoverPhotoOptions coverPhotoOptions;

/*!
 @abstract YES if the cover photo should mimic a navigation bar when the view is scrolled, NO otherwise.
 @discussion The default is YES. When this property is set to YES you should set `automaticallyAdjustsScrollViewInsets` to NO, otherwise set `automaticallyAdjustsScrollViewInsets` to YES.
 */
@property (nonatomic, assign) BOOL coverPhotoMimicsNavigationBar;

/*!
 @abstract The gesture recognizer for when user taps the cover photo.
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *coverPhotoTapGestureRecognizer;

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
 @abstract The gesture recognizer for when user taps the profile picture.
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *profilePictureTapGestureRecognizer;

/*!
 @abstract Sets the profile picture.
 @param profilePicture The image to set as the profile picture.
 @param animated YES if setting the profile picture should be animated, NO otherwise.
 */
- (void)setProfilePicture:(UIImage *)profilePicture animated:(BOOL)animated;

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
 */
@property (nonatomic, assign) BOOL allowsPullToRefresh;

/*!
 @abstract Hides the pull-to-refresh indicator if it is currently animating.
 */
- (void)endRefreshing;

@end

///----------------------------------------------
/// @name Version 1.0.2
///----------------------------------------------

typedef NS_ENUM(NSInteger, DBProfileCoverPhotoScrollAnimationStyle) {
    DBProfileCoverPhotoScrollAnimationStyleNone,
    DBProfileCoverPhotoScrollAnimationStyleBlur
};

@interface DBProfileViewController ()

@property (nonatomic, assign) DBProfileCoverPhotoScrollAnimationStyle coverPhotoScrollAnimationStyle;
@property (nonatomic, assign) BOOL rememberIndexForSelectedContentController;

- (void)selectCoverPhotoAnimated:(BOOL)animated;
- (void)deselectCoverPhotoAnimated:(BOOL)animated;
- (void)selectProfilePictureAnimated:(BOOL)animated;
- (void)deselectProfilePictureAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
