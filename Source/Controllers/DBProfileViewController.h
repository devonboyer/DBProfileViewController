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
#import "DBProfileViewControllerConstants.h"

@class DBProfileViewController;
@class DBProfileCoverPhotoView;
@class DBProfileAccessoryView;

NS_ASSUME_NONNULL_BEGIN

// Accessory Kinds
extern NSString * const DBProfileViewControllerAccessoryKindAvatar;
extern NSString * const DBProfileViewControllerAccessoryKindCoverPhoto;

/*!
 @class DBProfileViewController
 @abstract The `DBProfileViewController` class is a view controller that is specialized to display a profile interface.
 @discussion This class manages and displays a collection of content controllers and customizable accessory views associated with a profile interface.
 */
@interface DBProfileViewController : UIViewController

+ (Class)layoutAttributesClassForAccessoryOfKind:(NSString *)accessoryKind;

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
/// @name Configuring Details Views
///---------------------------------------------

/*!
 @abstract A view that is displayed above the content controllers.
 @discussion The default is an instance of `DBProfileDetailsView`.
 @warning The `detailsView` cannot be nil.
 */
@property (nonatomic, strong) UIView *detailsView;

///---------------------------------------------
/// @name Configuring Accessory Views
///---------------------------------------------

/*!
 @abstract An array of `DBProfileAccessoryView` instances managed by the profile view controller.
 */
@property (nonatomic, strong, readonly) NSArray<DBProfileAccessoryView *> *accessoryViews;

- (void)registerClass:(Class)viewClass forAccessoryViewOfKind:(NSString *)accessoryKind;

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

/*!
 @abstract Selects the accessory view.
 @param animated YES if setting selecting the accessory view should be animated, NO otherwise.
 */
- (void)selectAccessoryView:(DBProfileAccessoryView *)accessoryView animated:(BOOL)animated;

/*!
 @abstract Deselects the accessory view.
 @param animated YES if setting deselecting the accessory view should be animated, NO otherwise.
 */
- (void)deselectAccessoryView:(DBProfileAccessoryView *)accessoryView animated:(BOOL)animated;

// use layout attributes instead
@property (nonatomic, strong, readonly) DBProfileCoverPhotoView *coverPhotoView;
@property (nonatomic, strong, readonly) DBProfileAccessoryView *avatarView;
@property (nonatomic, assign) CGFloat coverPhotoHeightMultiplier;
@property (nonatomic, assign) DBProfileCoverPhotoOptions coverPhotoOptions;
@property (nonatomic, assign) BOOL coverPhotoMimicsNavigationBar;
@property (nonatomic, assign) UIEdgeInsets avatarInset;

@end

NS_ASSUME_NONNULL_END
