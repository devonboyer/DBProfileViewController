//
//  DBProfileViewController.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2015-12-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
#error "DBProfileViewController doesn't support iOS 6.x and lower. Please, change your minimum deployment target to iOS 7.0"
#endif

#import <DBProfileViewController/DBProfileContentPresenting.h>
#import <DBProfileViewController/DBProfileViewControllerDelegate.h>
#import <DBProfileViewController/DBProfileViewControllerDataSource.h>
#import <DBProfileViewController/DBProfileAccessoryViewLayoutAttributes.h>
#import <DBProfileViewController/DBProfileHeaderViewLayoutAttributes.h>
#import <DBProfileViewController/DBProfileAvatarViewLayoutAttributes.h>
#import <DBProfileViewController/DBProfileAccessoryView.h>
#import <DBProfileViewController/DBProfileAvatarView.h>
#import <DBProfileViewController/DBProfileBlurView.h>
#import <DBProfileViewController/DBProfileCoverPhotoView.h>
#import <DBProfileViewController/DBProfileHeaderOverlayView.h>
#import <DBProfileViewController/DBProfileTitleView.h>
#import <DBProfileViewController/DBProfileTintView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The identifier for the avatar accessory view.
 */
FOUNDATION_EXPORT NSString * const DBProfileAccessoryKindAvatar;

/**
 *  The identifier for the header accessory view.
 */
FOUNDATION_EXPORT NSString * const DBProfileAccessoryKindHeader;

/**
 *  The `DBProfileViewController` class is a view controller that is specialized to display a profile interface.
 *
 *  This class manages and displays a collection of content controllers and customizable accessory views associated with a profile interface.
 */
@interface DBProfileViewController : UIViewController

/**
 *  @name Creating Profile View Controllers
 */

/**
 *  Initializes a profile view controller.
 *  
 *  @param segmentedControlClass Specifies the custom UISegmentedControl subclass you want to use, or specify nil to use the standard UISegmentedControl class.
 *
 *  @return An initialized `DBProfileViewController`.
 */
- (instancetype)initWithSegmentedControlClass:(nullable Class)segmentedControlClass;

/**
 *  The object that acts as the view controller's delegate.
 */
@property (nonatomic, weak, nullable) id<DBProfileViewControllerDelegate> delegate;

/**
 *  The object that acts as the view controller's data source.
 */
@property (nonatomic, weak, nullable) id<DBProfileViewControllerDataSource> dataSource;

/**
 *  @name Configuring the Segmented Control
 */

/**
 *  The segmented control managed by the profile view controller.
 */
@property (nonatomic, readonly) UISegmentedControl *segmentedControl;

/**
 *  Whether the segmented control is hidden when there is only one content controller.
 *
 *  Defaults to YES.
 */
@property (nonatomic) BOOL hidesSegmentedControlForSingleContentController;

/**
 *  @name Configuring the Detail View
 */

/**
 *  An optional view that is displayed above the content controllers.
 */
@property (nonatomic, nullable) __kindof UIView *detailView;

/**
 *  @name Configuring Accessory Views
 */

/**
 *  An array of `DBProfileAccessoryView` instances managed by the profile view controller.
 */
@property (nonatomic, readonly) NSArray<__kindof DBProfileAccessoryView *> *accessoryViews;

/**
 *  Returns the class to use when creating layout attributes objects.
 *
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 *
 *  @return The class to use when creating layout attributes objects.
 */
+ (Class)layoutAttributesClassForAccessoryViewOfKind:(NSString *)accessoryViewKind;

/**
 *  Returns the accessory view for the specified accessory view kind.
 *
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 *
 *  @return The accessory view for the specified accessory view kind.
 */
- (__kindof DBProfileAccessoryView *)accessoryViewOfKind:(NSString *)accessoryViewKind;

/**
 *  Returns the layout attributes for the specified accessory view kind.
 *
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 *
 *  @return The layout attributes for the specified accessory view kind.
 */
- (__kindof DBProfileAccessoryViewLayoutAttributes *)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

/**
 *  Registers a class for use in creating accessory views.
 *
 *  @param viewClass The class to use for the accessory view.
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 */
- (void)registerClass:(Class)viewClass forAccessoryViewOfKind:(NSString *)accessoryViewKind;

/*!
 *  Invalidates the current layout attributes and triggers a layout update.
 *
 *  If any layout attributes are changed after `viewWillAppear:` is called, then this method must be called to trigger an appropriate layout update.
 *
 *  @param accessoryViewKind A string that identifies the type of the accessory view.
 */
- (void)invalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind;

/**
 *  @name Showing Content Controllers
 */

/**
 *  The index of the displayed content controller.
 */
@property (nonatomic, readonly) NSUInteger indexForDisplayedContentController;

/**
 *  The currently displayed content controller.
 */
@property (nonatomic, nullable, readonly) DBProfileContentController *displayedContentController;

/**
 *  Shows the content controller at the specified index.
 *
 *  @param controllerIndex An index identifying a content controller in the profile view controller.
 */
- (void)showContentControllerAtIndex:(NSInteger)controllerIndex;

/**
 *  @name Configuring the Overlay View
 */

/**
 *  The overlay view displayed over the header. Created during `viewDidLoad`.
 */
@property (nonatomic, readonly, nullable) DBProfileHeaderOverlayView *overlayView;

/**
 *  The left bar button item overlaying the header.
 */
@property (nonatomic, nullable) UIBarButtonItem *leftBarButtonItem;

/**
 *  The left bar button items overlaying the header.
 */
@property (nonatomic, copy, nullable) NSArray <UIBarButtonItem *> *leftBarButtonItems;

/**
 *  The right bar button item overlaying the header.
 */
@property (nonatomic, nullable) UIBarButtonItem *rightBarButtonItem;

/**
 *  The right bar button items overlaying the header.
 */
@property (nonatomic, copy, nullable) NSArray <UIBarButtonItem *> *rightBarButtonItems;

/**
 *  @name Configuring Pull-To-Refresh
 */

/**
 *  Whether the pull-to-refresh action is allowed.
 *
 *  Defaults to YES.
 */
@property (nonatomic) BOOL allowsPullToRefresh;

/**
 *  Whether the pull-to-refresh indicator is currently animating.
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

/**
 *  Hides the pull-to-refresh indicator if it is currently animating.
 */
- (void)endRefreshing;

/**
 *  @name Updating and Reloading the Profile View Controller
 */

/**
 *  Begins a series of method calls that modify height calculations for subviews of the profile view controller.
 *
 *  Call this method if you want subsequent height changes to subviews to be animated simultaneously.
 *
 *  @warning This group of methods must conclude with an invocation of endUpdates. You should not call reloadData within the group.
 */
- (void)beginUpdates;

/**
 *  Concludes a series of method calls that modify height calculations for subviews of the profile view controller.
 *
 *  You call this method to bracket a series of method calls that begins with beginUpdates. When you call endUpdates, height changes to subviews are animated simultaneously.
 */
- (void)endUpdates;

/**
 *  Reloads the content controllers of the profile view controller provided by the data source.
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
