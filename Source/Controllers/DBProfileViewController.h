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

#import "DBProfileViewControllerDelegate.h"
#import "DBProfileViewControllerDataSource.h"

@protocol DBProfileContentPresenting;

@class DBProfileViewController;
@class DBProfileCoverPhotoView;
@class DBProfilePictureView;
@class DBProfileSegmentedControlView;
@class DBProfileNavigationView;

extern const CGFloat DBProfileViewControllerAutomaticDimension;

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
 @discussion This class manages and displays an array of content view controllers as well as a `DBProfileCoverPhotoView`, `DBProfilePictureView` and `DBProfileDetailsView`. There are many ways to customize the cover photo, profile picture and content view controllers of the profile screen.
 */
@interface DBProfileViewController : UIViewController

// Version 1.0.1
- (void)beginUpdates;
- (void)endUpdates;
- (void)reloadData;
@property (nonatomic, assign, readonly) NSUInteger indexForSelectedSegment;

/*!
 @abstract The object that acts as the view controller's delegate.
 */
@property (nonatomic, strong) id<DBProfileViewControllerDelegate> delegate;

/*!
 @abstract The object that acts as the view controller's data source.
 */
@property (nonatomic, strong) id<DBProfileViewControllerDataSource> dataSource;

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
 @discussion The default is 0.2. To hide the cover photo set `coverPhotoHidden` to YES.
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

@interface DBProfileViewController (Deprecated)

- (instancetype)initWithContentViewControllers:(NSArray *)contentViewControllers;

@property (nonatomic, strong, readonly) DBProfileContentViewController *visibleContentViewController;
@property (nonatomic, assign, readonly) NSUInteger visibleContentViewControllerIndex;

- (void)insertContentViewController:(DBProfileContentViewController *)contentViewController atIndex:(NSUInteger)index;
- (void)removeContentViewControllerAtIndex:(NSUInteger)index;
- (void)addContentViewController:(DBProfileContentViewController *)contentViewController __deprecated;
- (void)addContentViewControllers:(NSArray *)contentViewControllers __deprecated;
//- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index __deprecated;

@end
