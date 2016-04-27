//
//  DBProfileViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2015-12-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileViewController.h"
#import "DBProfileObserver.h"
#import "DBProfileTitleView.h"
#import "DBProfileSegmentedControlView.h"
#import "DBProfileViewControllerUpdateContext.h"
#import "UIBarButtonItem+DBProfileViewController.h"
#import "NSBundle+DBProfileViewController.h"
#import "DBProfileAccessoryView_Private.h"

static CGFloat DBProfileViewControllerNavigationBarHeightForTraitCollection(UITraitCollection *traitCollection)
{
    switch (traitCollection.verticalSizeClass) {
        case UIUserInterfaceSizeClassCompact:
            return 32;
        default:
            return 64;
    }
}

static const CGFloat DBProfileViewControllerOverlayAnimationDuration = 0.2;

NSString * const DBProfileAccessoryKindAvatar = @"DBProfileAccessoryKindAvatar";
NSString * const DBProfileAccessoryKindHeader = @"DBProfileAccessoryKindHeader";

static const CGFloat DBProfileViewControllerPullToRefreshTriggerDistance = 80.0;

static NSString * const DBProfileViewControllerContentOffsetCacheName = @"DBProfileViewController.contentOffsetCache";

@interface DBProfileViewController () <DBProfileAccessoryViewDelegate, DBProfileScrollViewObserverDelegate>
{
    BOOL _shouldScrollToTop;
    CGPoint _sharedContentOffset;
    UIEdgeInsets _cachedContentInset;
    UIImage *_coverPhotoImage;
    
    NSLayoutConstraint *_detailsViewTopConstraint;
}

// State
@property (nonatomic, assign) NSUInteger indexForDisplayedContentController;
@property (nonatomic, getter=isRefreshing) BOOL refreshing;

// Updates
@property (nonatomic, strong) DBProfileViewControllerUpdateContext *updateContext;
@property (nonatomic, getter=isUpdating) BOOL updating;
@property (nonatomic, assign) BOOL hasAppeared;

// Data
@property (nonatomic, strong) NSMutableArray<DBProfileContentController *> *contentControllers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DBProfileObserver *> *scrollViewObservers;
@property (nonatomic, strong) NSCache *contentOffsetCache;
@property (nonatomic, strong) NSMutableDictionary *registeredAccessoryViews;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DBProfileAccessoryViewLayoutAttributes *> *accessoryViewLayoutAttributes;

// Views
@property (nonatomic) Class segmentedControlClass;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) DBProfileSegmentedControlView *segmentedControlView;
@property (nonatomic) DBProfileHeaderOverlayView *overlayView;

@end

@implementation DBProfileViewController

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithSegmentedControlClass:(Class)segmentedControlClass
{
    NSAssert([segmentedControlClass isSubclassOfClass:[UISegmentedControl class]], @"segmentedControlClass must inherit from `UISegmentedControl`");
    self = [self init];
    if (self) {
        self.segmentedControlClass = segmentedControlClass ? segmentedControlClass : [UISegmentedControl class];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSCache *contentOffsetCache = [[NSCache alloc] init];
    contentOffsetCache.name = DBProfileViewControllerContentOffsetCacheName;
    contentOffsetCache.countLimit = 10;
    _contentOffsetCache = contentOffsetCache;
    
    _containerView = [[UIView alloc] init];
    _detailView = [[UIView alloc] init];
    _segmentedControlView = [[DBProfileSegmentedControlView alloc] init];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _overlayView = [[DBProfileHeaderOverlayView alloc] initWithFrame:CGRectZero];
    _overlayView.leftBarButtonItem = [UIBarButtonItem db_backBarButtonItemWithTarget:self action:@selector(backButtonTapped:)];
    
    [self setSegmentedControlClass:[UISegmentedControl class]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.contentOffsetCache removeAllObjects];
    
    self.delegate = nil;
    self.dataSource = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.tintColor = [UIColor whiteColor];

    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.frame = self.view.frame;
    [self.view addSubview:self.containerView];
    
    [self addOverlayView];
    [self setupOverlayViewConstraints];
    
    self.segmentedControl.tintColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:242/255.0 alpha:1];
    
#warning - Triggering setters causing crash here
    _hidesSegmentedControlForSingleContentController = YES;
    _allowsPullToRefresh = YES;

    [self.segmentedControl addTarget:self action:@selector(didChangeContentController:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    BOOL showOverlayView = layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation;

    // If header style is `DBProfileHeaderStyleNavigation`, then we need to hide the navigationController's navigation bar in instead use
    // the header overlay view for navigation.
    if (showOverlayView && self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    }
    
    [self setOverlayViewHidden:!showOverlayView animated:NO];
    
    // By default `automaticallyAdjustsScrollViewInsets` is YES. When using `DBProfileHeaderStyleNavigation` we need
    // to prevent this since we are managing the scrollView contentInset manually.
    self.automaticallyAdjustsScrollViewInsets = !showOverlayView;
    
    if (!self.hasAppeared) {
        [self reloadContentControllers];
        
        [self.view setNeedsUpdateConstraints];
        
        // Scroll displayed content controller to top
        if ([self.contentControllers count]) {
            [self scrollContentControllerToTop:self.currentlyDisplayedContentController animated:NO];
        }
        
        // Tempoaray fix for content inset being calculated incorrectly before view appears.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adjustContentInsetForScrollView:self.currentlyDisplayedContentController.contentScrollView];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hasAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    BOOL showOverlayView = layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation;

    // If the navigation bar was hidden when the view appeared, then we need to show the navigation bar again when the view disappears.
    if (showOverlayView && self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)updateViewConstraints {
    [self.registeredAccessoryViews enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull kind, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self invalidateLayoutAttributesForAccessoryViewOfKind:kind];
    }];
    [super updateViewConstraints];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIScrollView *scrollView = [self.currentlyDisplayedContentController contentScrollView];
    _cachedContentInset = scrollView.contentInset;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // The scroll view content inset needs to be recalculated for the new size class
    UIScrollView *scrollView = [self.currentlyDisplayedContentController contentScrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self.view setNeedsUpdateConstraints];
    
    [self adjustContentInsetForScrollView:scrollView];
    
    // Preserve the relative contentOffset during size class changes
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y -= MAX(scrollView.contentInset.top - _cachedContentInset.top, 0);
    scrollView.contentOffset = contentOffset;
    
    [self updateOverlayInformation];
}

#pragma mark - Getters

- (UISegmentedControl *)segmentedControl
{
    return self.segmentedControlView.segmentedControl;
}

- (DBProfileContentController *)currentlyDisplayedContentController {
    DBProfileContentController *controller;
    if ([self.contentControllers count] > 0) return self.contentControllers[self.indexForDisplayedContentController];
    return controller;
}

- (NSMutableArray *)contentControllers
{
    if (!_contentControllers) {
        _contentControllers = [NSMutableArray array];
    }
    return _contentControllers;
}

- (NSMutableDictionary *)registeredAccessoryViews
{
    if (!_registeredAccessoryViews) {
        _registeredAccessoryViews = [NSMutableDictionary dictionary];
    }
    return _registeredAccessoryViews;
}

- (NSMutableDictionary *)accessoryViewLayoutAttributes
{
    if (!_accessoryViewLayoutAttributes) {
        _accessoryViewLayoutAttributes = [NSMutableDictionary dictionary];
    }
    return _accessoryViewLayoutAttributes;
}

- (NSArray<DBProfileAccessoryView *> *)accessoryViews
{
    return [self.registeredAccessoryViews allValues];
}

- (NSMutableDictionary *)scrollViewObservers
{
    if (!_scrollViewObservers) {
        _scrollViewObservers = [NSMutableDictionary dictionary];
    }
    return _scrollViewObservers;
}

#pragma mark - Setters

- (void)setSegmentedControlClass:(Class)segmentedControlClass
{
    _segmentedControlClass = segmentedControlClass;
    
    UISegmentedControl *segmentedControl = [[segmentedControlClass alloc] init];
    self.segmentedControlView.segmentedControl = segmentedControl;
}

- (void)setHidesSegmentedControlForSingleContentController:(BOOL)hidesSegmentedControlForSingleContentController
{
    _hidesSegmentedControlForSingleContentController = hidesSegmentedControlForSingleContentController;
    [self reloadContentControllers];
}

- (void)setDetailView:(__kindof UIView *)detailView
{
    _detailView = detailView;
    
    // The detail view should never be nil in order for constraints to be created relative to the detail view.
    if (!_detailView) {
        _detailView = [[UIView alloc] init];
    }
    [self reloadContentControllers];
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh
{
    _allowsPullToRefresh = allowsPullToRefresh;
    [self reloadContentControllers];
}

#pragma mark - DBProfileViewController

- (UIBarButtonItem *)leftBarButtonItem {
    return self.overlayView.leftBarButtonItem;
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    self.overlayView.leftBarButtonItem = leftBarButtonItem;
}

- (NSArray *)leftBarButtonItems {
    return self.overlayView.leftBarButtonItems;
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems {
    self.overlayView.leftBarButtonItems = leftBarButtonItems;
}

- (UIBarButtonItem *)rightBarButtonItem {
    return self.overlayView.rightBarButtonItem;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    self.overlayView.rightBarButtonItem = rightBarButtonItem;
}

- (NSArray *)rightBarButtonItems {
    return self.overlayView.rightBarButtonItems;
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    self.overlayView.rightBarButtonItems = rightBarButtonItems;
}

- (void)addOverlayView {
    NSAssert(self.overlayView != nil, @"overlayView must be set during initialization, to provide bar button items for this %@", NSStringFromClass([self class]));
    
    UIColor *textColor = self.view.tintColor ?: [UIColor whiteColor];
    self.overlayView.titleTextAttributes = @{NSForegroundColorAttributeName: textColor};
    self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self updateOverlayInformation];
    [self.view addSubview:self.overlayView];
}

- (void)updateOverlayInformation {
    NSString *overlayTitle;
    
    NSUInteger controllerIndex = self.indexForDisplayedContentController;
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:titleForContentControllerAtIndex:)]) {
        overlayTitle = [self.dataSource profileViewController:self titleForContentControllerAtIndex:controllerIndex];
    }
    
    self.overlayView.title = overlayTitle;
    
    NSString *overlaySubtitle;

    if (self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact) {
        
        if ([self.delegate respondsToSelector:@selector(profileViewController:titleForContentControllerAtIndex:)]) {
            overlaySubtitle = [self.dataSource profileViewController:self subtitleForContentControllerAtIndex:controllerIndex];
        }
    }
    
    self.overlayView.subtitle = overlaySubtitle;
}

- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setOverlayViewHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden == self.overlayView.hidden) {
        return;
    }
    
    if (animated) {
        self.overlayView.hidden = NO;
        
        self.overlayView.alpha = hidden ? 1.0 : 0.0;
        
        [UIView animateWithDuration:DBProfileViewControllerOverlayAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.overlayView.alpha = hidden ? 0.0 : 1.0;
        } completion:^(BOOL finished) {
            self.overlayView.alpha = 1.0;
            self.overlayView.hidden = hidden;
        }];
    }
    else {
        self.overlayView.hidden = hidden;
    }
}

- (void)didChangeContentController:(id)sender {
    NSInteger selectedSegmentIndex = [self.segmentedControl selectedSegmentIndex];
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:willShowContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self willShowContentControllerAtIndex:selectedSegmentIndex];
    }
    
    [self showContentControllerAtIndex:selectedSegmentIndex];
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:didShowContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didShowContentControllerAtIndex:selectedSegmentIndex];
    }
}

- (void)showContentControllerAtIndex:(NSInteger)index
{
    if (![self.contentControllers count]) return;
    
    // Hide the currently displayed content controller and remove scroll view observer
    DBProfileContentController *hideContentController = self.currentlyDisplayedContentController;
    if (hideContentController) {
        [self removeContentController:hideContentController];
        NSString *key = [self uniqueKeyForContentControllerAtIndex:_indexForDisplayedContentController];
        if ([self.scrollViewObservers valueForKey:key]) {
            [self.scrollViewObservers removeObjectForKey:key];
        }
    }
    
    self.indexForDisplayedContentController = index;

    [self.segmentedControl setSelectedSegmentIndex:self.indexForDisplayedContentController];
    
    // Display the desired content controller and add scroll view observer
    DBProfileContentController *displayContentController = self.currentlyDisplayedContentController;
    
    if (displayContentController) {
        [self addContentController:displayContentController];
        
        [self setCurrentlyDisplayedContentController:displayContentController animated:YES];

        NSString *key = [self uniqueKeyForContentControllerAtIndex:index];
        DBProfileScrollViewObserver *observer = [[DBProfileScrollViewObserver alloc] initWithTargetView:displayContentController.contentScrollView delegate:self];
        [observer startObserving];
        self.scrollViewObservers[key] = observer;
    }
    
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    
    [self updateOverlayInformation];
    
    // Invalidate the layout attributes for all accessory views
    [self.registeredAccessoryViews enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull kind, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self invalidateLayoutAttributesForAccessoryViewOfKind:kind];
    }];
}

- (CGRect)frameForContentController {
    return self.containerView.frame;
}

- (void)addContentController:(DBProfileContentController *)controller {
    NSAssert(controller, @"controller cannot be nil");
    
    [self addChildViewController:controller];
    controller.view.frame = [self frameForContentController];
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.overlayView];
}

- (void)removeContentController:(DBProfileContentController *)controller {
    NSAssert(controller, @"controller cannot be nil");
    
    // Uninstall constraint-based layout attributes
    [self.registeredAccessoryViews enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull kind, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.accessoryViewLayoutAttributes[kind] uninstallConstraints];
    }];
    
    UIScrollView *scrollView = controller.contentScrollView;
    
    // Cache content offset
    CGFloat topInset = CGRectGetMaxY(self.overlayView.frame) + CGRectGetHeight(self.segmentedControlView.frame);
    if (self.automaticallyAdjustsScrollViewInsets) topInset = CGRectGetHeight(self.segmentedControlView.frame);
    _shouldScrollToTop = scrollView.contentOffset.y >= -topInset;
    _sharedContentOffset = scrollView.contentOffset;
    
    [self cacheContentOffset:scrollView.contentOffset forContentControllerAtIndex:self.indexForDisplayedContentController];
    
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (void)setCurrentlyDisplayedContentController:(DBProfileContentController *)controller animated:(BOOL)animated {
    NSAssert(controller, @"controller cannot be nil");
    
    UIScrollView *scrollView = controller.contentScrollView;
    
    DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    DBProfileAccessoryView *avatarView = [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    [headerView removeFromSuperview];
    [avatarView removeFromSuperview];
    [self.detailView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    [self.activityIndicator removeFromSuperview];
    
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailView.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControlView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self endRefreshing];
    
    [scrollView addSubview:self.detailView];
    
    // Add segmented control
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
        [scrollView addSubview:self.segmentedControlView];
    } else {
        self.segmentedControlView.frame = CGRectZero;
    }
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindHeader]) {
        [scrollView addSubview:headerView];
        
        if (self.allowsPullToRefresh) [headerView addSubview:self.activityIndicator];
    }
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindAvatar]) [scrollView addSubview:avatarView];
    
    [self setupConstraintsForScrollView:scrollView];
    
    // Install constraint-based layout attributes for accessory views
    [self.registeredAccessoryViews enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull kind, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self installConstraintsForLayoutAttributes:self.accessoryViewLayoutAttributes[kind] forAccessoryViewOfKind:kind];
    }];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self.view setNeedsUpdateConstraints];
    [self updateViewConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:scrollView];
    
    // Reset the content offset
    if (_shouldScrollToTop) {
        [self resetContentOffsetForScrollView:scrollView];
        
        // Restore content offset for scroll view from cache
        CGPoint cachedContentOffset = [self cachedContentOffsetForContentControllerAtIndex:self.indexForDisplayedContentController];
        if (cachedContentOffset.y > scrollView.contentOffset.y && !CGPointEqualToPoint(CGPointZero, cachedContentOffset)) {
            [scrollView setContentOffset:cachedContentOffset];
        }
    } else {
        [scrollView setContentOffset:_sharedContentOffset];
    }
    
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    if (headerViewLayoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        if ((scrollView.contentOffset.y + scrollView.contentInset.top) < CGRectGetHeight(headerView.frame) - headerViewLayoutAttributes.navigationConstraint.constant) {
            [scrollView insertSubview:avatarView aboveSubview:headerView];
        } else {
            [scrollView insertSubview:headerView aboveSubview:avatarView];
        }
    }
}

- (void)beginUpdates
{
    self.updating = YES;
    self.updateContext = [[DBProfileViewControllerUpdateContext alloc] init];
    self.updateContext.beforeUpdatesDetailsViewHeight = CGRectGetHeight(self.detailView.frame);
    [self.view invalidateIntrinsicContentSize];
}

- (void)endUpdates
{
    self.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self showContentControllerAtIndex:self.indexForDisplayedContentController];

        // Calculate the difference between heights of subviews from before updates to after updates
        self.updateContext.afterUpdatesDetailsViewHeight = CGRectGetHeight(self.detailView.frame);
        
        // Adjust content offset to account for difference in heights of subviews from before updates to after updates
        if (round(self.updateContext.beforeUpdatesDetailsViewHeight) != round(self.updateContext.afterUpdatesDetailsViewHeight)) {
            UIScrollView *scrollView = [self.currentlyDisplayedContentController contentScrollView];
            
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y += (self.updateContext.beforeUpdatesDetailsViewHeight - self.updateContext.afterUpdatesDetailsViewHeight);
            scrollView.contentOffset = contentOffset;
        }
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.updating = NO;
    }];
}

- (void)reloadContentControllers
{
    NSInteger numberOfSegments = [self _numberOfContentControllers];
    
    [self.scrollViewObservers removeAllObjects];
    
    if ([self.contentControllers count] > 0) {
        [self removeContentController:self.currentlyDisplayedContentController];
    }
    
    [self.contentControllers removeAllObjects];
    [self.segmentedControl removeAllSegments];
    
    for (NSInteger i = 0; i < numberOfSegments; i++) {
        // Reload content view controllers
        DBProfileContentController *contentController = [self _contentControllerAtIndex:i];
        [self.contentControllers addObject:contentController];
        
        // Reload segmented control
        NSString *title = [self _titleForContentControllerAtIndex:i];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
    }
    
    // Display selected content view controller
    [self showContentControllerAtIndex:self.indexForDisplayedContentController];
}

- (void)startRefreshAnimations
{
    [self.activityIndicator startAnimating];
}

- (void)endRefreshAnimations
{
    [self.activityIndicator stopAnimating];
}

- (void)notifyDelegateOfPullToRefreshForContentControllerAtIndex:(NSInteger)index
{
    if ([self respondsToSelector:@selector(profileViewController:didPullToRefreshContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didPullToRefreshContentControllerAtIndex:index];
    }
}

- (void)endRefreshing
{
    self.refreshing = NO;
    [self endRefreshAnimations];
}

- (void)cacheContentOffset:(CGPoint)contentOffset forContentControllerAtIndex:(NSInteger)controllerIndex
{
    NSString *key = [self uniqueKeyForContentControllerAtIndex:controllerIndex];
    [self.contentOffsetCache setObject:[NSValue valueWithCGPoint:contentOffset] forKey:key];
}

- (CGPoint)cachedContentOffsetForContentControllerAtIndex:(NSInteger)controllerIndex {
    NSString *key = [self uniqueKeyForContentControllerAtIndex:controllerIndex];
    return [[self.contentOffsetCache objectForKey:key] CGPointValue];
}

- (NSString *)uniqueKeyForContentControllerAtIndex:(NSInteger)controllerIndex
{
    NSString *overlayTitle;
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:titleForContentControllerAtIndex:)]) {
        overlayTitle = [self.dataSource profileViewController:self titleForContentControllerAtIndex:controllerIndex];
    }
    
    NSMutableString *key = [[NSMutableString alloc] initWithString:overlayTitle];
    [key appendFormat:@"-%@", @(controllerIndex)];
    return key;
}

- (void)scrollContentControllerToTop:(DBProfileContentController *)viewController animated:(BOOL)animated
{
    UIScrollView *scrollView = [viewController contentScrollView];
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:animated];
}

- (void)resetContentOffsetForScrollView:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = -(CGRectGetMaxY(self.overlayView.frame) + CGRectGetHeight(self.segmentedControlView.frame));
    [scrollView setContentOffset:contentOffset];
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView
{
    DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailView.frame) + CGRectGetHeight(headerView.frame);
    
    // Calculate scroll view top inset
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = (self.automaticallyAdjustsScrollViewInsets) ? topInset + [self.topLayoutGuide length] : topInset;
    
    // Calculate scroll view bottom inset
    CGFloat minimumContentSizeHeight = CGRectGetHeight(scrollView.frame) - CGRectGetHeight(self.segmentedControlView.frame) - DBProfileViewControllerNavigationBarHeightForTraitCollection(self.traitCollection);
    
    if (scrollView.contentSize.height < minimumContentSizeHeight && ([self.contentControllers count] > 1 ||
                                                                     ([self.contentControllers count] == 1 && !self.hidesSegmentedControlForSingleContentController))) {
        contentInset.bottom = minimumContentSizeHeight - scrollView.contentSize.height;
    }
    
    scrollView.contentInset = contentInset;
    
    // Calculate cover photo inset
    headerViewLayoutAttributes.topConstraint.constant = -topInset;
    
    // Calculate details view inset
    topInset -= CGRectGetHeight(headerView.frame);
    _detailsViewTopConstraint.constant = -topInset;
}

- (CGFloat)_headerViewOffset
{
    DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    return CGRectGetHeight(headerView.frame);
}

- (CGFloat)_titleViewOffset
{
    return (([self _headerViewOffset] - CGRectGetMaxY(self.overlayView.frame)) + CGRectGetHeight(self.segmentedControlView.frame));
}

- (NSInteger)_numberOfContentControllers
{
    if ([self.dataSource respondsToSelector:@selector(numberOfContentControllersForProfileViewController:)]) {
        NSInteger numberOfContentControllers = [self.dataSource numberOfContentControllersForProfileViewController:self];
        NSAssert(numberOfContentControllers > 0, @"numberOfContentControllers must be greater than zero");
        return numberOfContentControllers;
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"dataSource must implement `numberOfContentControllersForProfileViewController:`"
                                     userInfo:nil];
    }

}

- (DBProfileContentController *)_contentControllerAtIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(profileViewController:contentControllerAtIndex:)]) {
        DBProfileContentController *contentController = [self.dataSource profileViewController:self contentControllerAtIndex:index];
        NSAssert(contentController, @"contentController cannot be nil");
        return contentController;
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"dataSource must implement `profileViewController:contentControllerAtIndex:`"
                                     userInfo:nil];
    }
}

- (NSString *)_titleForContentControllerAtIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(profileViewController:titleForContentControllerAtIndex:)]) {
        NSString *title = [self.dataSource profileViewController:self titleForContentControllerAtIndex:index];
        NSAssert([title length], @"title for contentController cannot be nil");
        return title;
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"dataSource must implement `profileViewController:titleForContentControllerAtIndex:`"
                                     userInfo:nil];
    }
}

- (CGSize)_referenceSizeForAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    CGSize referenceSize;
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:referenceSizeForAccessoryViewOfKind:)]) {
        referenceSize = [self.delegate profileViewController:self referenceSizeForAccessoryViewOfKind:accessoryViewKind];
    }
    else {
        DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:accessoryViewKind];
        referenceSize = layoutAttributes.referenceSize;
    }
    
    return referenceSize;
}

- (void)handlePullToRefreshWithScrollView:(UIScrollView *)scrollView
{
    if (!self.allowsPullToRefresh) return;
    
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y += scrollView.contentInset.top;
    if (scrollView.isDragging && contentOffset.y < 0) {
        [self startRefreshAnimations];
    } else if (!scrollView.isDragging && !self.refreshing && contentOffset.y < -DBProfileViewControllerPullToRefreshTriggerDistance) {
        self.refreshing = YES;
        [self notifyDelegateOfPullToRefreshForContentControllerAtIndex:self.indexForDisplayedContentController];
    }
    
    BOOL shouldEndRefreshAnimations = !self.refreshing && self.activityIndicator.isAnimating;
    if (!scrollView.isDragging && contentOffset.y >= 0 && shouldEndRefreshAnimations) {
        [self endRefreshAnimations];
    }

    if (contentOffset.y > 0 && shouldEndRefreshAnimations) {
        [self endRefreshAnimations];
    }
    self.activityIndicator.alpha = (contentOffset.y > 0) ? 1 - contentOffset.y / 20 : 1;
}

- (void)updateTitleViewWithContentOffset:(CGPoint)contentOffset
{
    DBProfileAccessoryView *avatarView = [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];

    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileAvatarViewLayoutAttributes *avatarViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];

    if (headerViewLayoutAttributes.headerStyle != DBProfileHeaderStyleNavigation) return;
    
    CGFloat titleViewOffset = [self _titleViewOffset];
    
    const CGFloat padding = 30.0;
    CGFloat avatarOffset = avatarViewLayoutAttributes.edgeInsets.top - avatarViewLayoutAttributes.edgeInsets.bottom;
    titleViewOffset += (CGRectGetHeight(avatarView.frame) + avatarOffset + padding);
    
    CGFloat percentScrolled = 1 - contentOffset.y / titleViewOffset;
    [self.overlayView setTitleVerticalPositionAdjustment:MAX(titleViewOffset * percentScrolled, 0) traitCollection:self.traitCollection];
}

- (void)setupOverlayViewConstraints
{
    [self.view addConstraints:
    @[[NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
      [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
      [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]]];
}

- (void)setupConstraintsForScrollView:(UIScrollView *)scrollView
{
    NSAssert(scrollView, @"scrollView cannot be nil");
    
    if (self.segmentedControlView.superview) {
        [scrollView addConstraints:
         @[[NSLayoutConstraint constraintWithItem:self.segmentedControlView  attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
           [NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
           [NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.detailView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]]];
    }
    
    [scrollView addConstraints:
     @[[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
       [NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:[self topLayoutGuide]
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    
    _detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:scrollView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0];
    [scrollView addConstraint:_detailsViewTopConstraint];
}

#pragma mark - DBProfileViewController(InstallingConstraints)

- (void)installConstraintsForLayoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes forAccessoryViewOfKind:(NSString *)accessoryViewKind {
    NSAssert([self hasRegisteredAccessoryViewOfKind:accessoryViewKind], @"no accessory view has been registered for accessory kind '%@'", accessoryViewKind);
    
    DBProfileAccessoryView *accessoryView = [self accessoryViewOfKind:accessoryViewKind];
    
    NSAssert(accessoryView.superview, @"accessoryView must have a superview");
    
    [layoutAttributes uninstallConstraints];
    
    if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
        [self installConstraintsForAvatarViewWithLayoutAttributes:layoutAttributes];
    }
    else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
        [self installConstraintsForHeaderViewWithLayoutAttributes:layoutAttributes];
    }
    
    layoutAttributes.hasInstalledConstraints = YES;
    
    [self invalidateLayoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
}

- (void)installConstraintsForHeaderViewWithLayoutAttributes:(DBProfileHeaderViewLayoutAttributes *)layoutAttributes {
    
    DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    layoutAttributes.leftConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:headerView.superview
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:0];
    
    layoutAttributes.widthConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:headerView.superview
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1
                                                                     constant:0];
    
    CGSize referenceSize = [self _referenceSizeForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    layoutAttributes.heightConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:referenceSize.height];
    
    layoutAttributes.topConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:headerView.superview
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:0];
    
    layoutAttributes.topConstraint.priority = UILayoutPriorityDefaultHigh;
    
    layoutAttributes.navigationConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:0];
    
    layoutAttributes.topLayoutGuideConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                toItem:[self topLayoutGuide]
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:0];
    
    layoutAttributes.topLayoutGuideConstraint.priority = UILayoutPriorityDefaultHigh+1;
    
    layoutAttributes.topSuperviewConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationLessThanOrEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1
                                                                            constant:0];
    
    layoutAttributes.topSuperviewConstraint.priority = UILayoutPriorityDefaultHigh+1;
    
    [headerView.superview addConstraints:@[layoutAttributes.leftConstraint,
                                           layoutAttributes.widthConstraint,
                                           layoutAttributes.topConstraint]];
    
    [self.view addConstraints:@[layoutAttributes.heightConstraint,
                                layoutAttributes.topLayoutGuideConstraint,
                                layoutAttributes.topSuperviewConstraint,
                                layoutAttributes.navigationConstraint]];
    
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:headerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0]];
    }
    
    if (self.allowsPullToRefresh) {
        
        NSArray *activityIndicatorConstraints = @[[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                               attribute:NSLayoutAttributeCenterX
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:headerView
                                                                               attribute:NSLayoutAttributeCenterX
                                                                              multiplier:1
                                                                                constant:0],
                                                  [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                               attribute:NSLayoutAttributeCenterY
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:headerView
                                                                               attribute:NSLayoutAttributeCenterY
                                                                              multiplier:1
                                                                                constant:0]];
        [headerView addConstraints:activityIndicatorConstraints];
    }
}

- (void)installConstraintsForAvatarViewWithLayoutAttributes:(DBProfileAvatarViewLayoutAttributes *)layoutAttributes {
    
    DBProfileAccessoryView *avatarView = [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    layoutAttributes.heightConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:avatarView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1
                                                                      constant:0];
    
    layoutAttributes.widthConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:72];
    
    layoutAttributes.leftConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:avatarView.superview
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:0];
    layoutAttributes.leftConstraint.priority = UILayoutPriorityDefaultLow;
    
    layoutAttributes.rightConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:avatarView.superview
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1
                                                                     constant:0];
    
    layoutAttributes.rightConstraint.priority = UILayoutPriorityDefaultLow;
    
    layoutAttributes.centerXConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:avatarView.superview
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1
                                                                       constant:0];
    layoutAttributes.centerXConstraint.priority = UILayoutPriorityDefaultLow;
    
    layoutAttributes.topConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.detailView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:0];
    
    [avatarView.superview addConstraints:@[layoutAttributes.heightConstraint,
                                           layoutAttributes.widthConstraint,
                                           layoutAttributes.leftConstraint,
                                           layoutAttributes.rightConstraint,
                                           layoutAttributes.centerXConstraint,
                                           layoutAttributes.topConstraint]];
}

#pragma mark - DBProfileViewController(AccessoryViews)

+ (Class)layoutAttributesClassForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
        return [DBProfileHeaderViewLayoutAttributes class];
    }
    else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
        return [DBProfileAvatarViewLayoutAttributes class];
    }
    
    return [DBProfileAccessoryViewLayoutAttributes class];
}

- (void)registerClass:(Class)viewClass forAccessoryViewOfKind:(NSString *)accessoryViewKind {
    NSAssert([viewClass isSubclassOfClass:[DBProfileAccessoryView class]], @"viewClass must inherit from `DBProfileAccessoryView`");
    
    // Unregister any existing accessory view for the specified accessory kind
    [self.registeredAccessoryViews removeObjectForKey:accessoryViewKind];
    [self.accessoryViewLayoutAttributes removeObjectForKey:accessoryViewKind];
    
    // Register the accessory view for the specified accessory kind
    DBProfileAccessoryView *accessoryView = [[viewClass alloc] init];
    accessoryView.representedAccessoryKind = accessoryViewKind;
    accessoryView.internalDelegate = self;
    
    [self.registeredAccessoryViews setObject:accessoryView forKey:accessoryViewKind];
    
    Class layoutAttributesClass = [[self class] layoutAttributesClassForAccessoryViewOfKind:accessoryViewKind];
    
    if (accessoryViewKind == DBProfileAccessoryKindHeader) {
        NSAssert([layoutAttributesClass isSubclassOfClass:[DBProfileHeaderViewLayoutAttributes class]],
                 @"layoutAttributesClass must inherit from `DBProfileHeaderViewLayoutAttributes`");
    }
    else if (accessoryViewKind == DBProfileAccessoryKindAvatar) {
        NSAssert([layoutAttributesClass isSubclassOfClass:[DBProfileAvatarViewLayoutAttributes class]],
                 @"layoutAttributesClass must inherit from `DBProfileAvatarViewLayoutAttributes`");
    }
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [layoutAttributesClass layoutAttributesForAccessoryViewOfKind:accessoryViewKind];
    [self.accessoryViewLayoutAttributes setObject:layoutAttributes forKey:accessoryViewKind];
}

- (DBProfileAccessoryView *)accessoryViewOfKind:(NSString *)accessoryViewKind {
    NSAssert([self hasRegisteredAccessoryViewOfKind:accessoryViewKind], @"no accessory view has been registered for accessory kind '%@'", accessoryViewKind);
    return [self.registeredAccessoryViews objectForKey:accessoryViewKind];
}

- (BOOL)hasRegisteredAccessoryViewOfKind:(NSString *)accessoryViewKind {
    return [self.registeredAccessoryViews objectForKey:accessoryViewKind];
}

#pragma mark - DBProfileViewController(Layout)

- (BOOL)shouldInvalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind forBoundsChange:(CGRect)newBounds {
    return [accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader] ||
           [accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar];
}

- (CGPoint)contentOffsetForCurrentlyDisplayedContentController {
    CGPoint contentOffset = CGPointZero;
    if (self.currentlyDisplayedContentController) {
        UIScrollView *scrollView = self.currentlyDisplayedContentController.contentScrollView;
        contentOffset = scrollView.contentOffset;
        contentOffset.y += scrollView.contentInset.top;
    }
    return contentOffset;
}

- (DBProfileAccessoryViewLayoutAttributes *)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    
    NSAssert([self hasRegisteredAccessoryViewOfKind:accessoryViewKind], @"no accessory view has been registered for accessory kind '%@'", accessoryViewKind);

    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = self.accessoryViewLayoutAttributes[accessoryViewKind];
    
    return layoutAttributes;
}

- (void)configureLayoutAttributes:(DBProfileAccessoryViewLayoutAttributes *)layoutAttributes forAccessoryViewOfKind:(NSString *)accessoryViewKind {
    
    CGPoint contentOffset = [self contentOffsetForCurrentlyDisplayedContentController];
    
    // Configure the layout attributes that are common to all accessory views
    DBProfileAccessoryView *accessoryView = [self accessoryViewOfKind:accessoryViewKind];
    layoutAttributes.frame = accessoryView.frame;
    layoutAttributes.bounds = accessoryView.bounds;
    layoutAttributes.hidden = accessoryView.hidden;
    layoutAttributes.transform = accessoryView.transform;
    
#warning - Update percent transitioned which should be calculatable based on the frame for all accessory views
    
    if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
        [self configureAvatarViewLayoutAttributes:layoutAttributes];
    }
    else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
        [self configureHeaderViewLayoutAttributes:layoutAttributes];
    }
}

- (void)configureHeaderViewLayoutAttributes:(DBProfileHeaderViewLayoutAttributes *)layoutAttributes
{
    DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileAccessoryView *avatarView = [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    CGPoint contentOffset = [self contentOffsetForCurrentlyDisplayedContentController];

    BOOL showOverlayView = layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation;
    [self setOverlayViewHidden:!showOverlayView animated:NO];
    
    if (layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        if (contentOffset.y < CGRectGetHeight(headerView.frame) - layoutAttributes.navigationConstraint.constant) {
            [headerView.superview insertSubview:avatarView aboveSubview:headerView];
        } else {
            [headerView.superview insertSubview:headerView aboveSubview:avatarView];
        }
    }
    
    CGSize referenceSize = [self _referenceSizeForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    if (contentOffset.y < 0 && layoutAttributes.headerOptions & DBProfileHeaderOptionStretch) {
        layoutAttributes.heightConstraint.constant = referenceSize.height - contentOffset.y;
    }
    else {
        layoutAttributes.heightConstraint.constant = referenceSize.height;
    }
    
    CGFloat maxBlurOffset = [self _headerViewOffset] - CGRectGetMaxY(self.overlayView.frame);
    
    if (self.automaticallyAdjustsScrollViewInsets) maxBlurOffset += [self.topLayoutGuide length];
    
    CGFloat percentScrolled = 0;
    
    if (contentOffset.y <= 0) {
        percentScrolled = MAX(MIN(1 - (maxBlurOffset - fabs(contentOffset.y))/maxBlurOffset, 1), 0);
    }
    else if (contentOffset.y >= [self _titleViewOffset]) {
        percentScrolled = MAX(MIN(1 - (50 - fabs(contentOffset.y - [self _titleViewOffset]))/50, 1), 0);
    }
    
    layoutAttributes.percentTransitioned = percentScrolled;
    
    if (layoutAttributes.hasInstalledConstraints) {
        
        layoutAttributes.navigationConstraint.constant = DBProfileViewControllerNavigationBarHeightForTraitCollection(self.traitCollection);
        
        if (layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
            [NSLayoutConstraint activateConstraints:@[layoutAttributes.navigationConstraint, layoutAttributes.topSuperviewConstraint]];
            [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.topLayoutGuideConstraint]];
        }
        else {
            [NSLayoutConstraint activateConstraints:@[layoutAttributes.topLayoutGuideConstraint]];
            [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.navigationConstraint, layoutAttributes.topSuperviewConstraint]];
        }
    }
}

- (void)configureAvatarViewLayoutAttributes:(DBProfileAvatarViewLayoutAttributes *)layoutAttributes {
    
    CGPoint contentOffset = [self contentOffsetForCurrentlyDisplayedContentController];
    
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    CGFloat headerOffset = [self _headerViewOffset];
    CGFloat percentScrolled = 0;
    
    if (headerViewLayoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        headerOffset -= CGRectGetMaxY(self.overlayView.frame);
    }
    
    percentScrolled = MIN(1, contentOffset.y / headerOffset);
    
    CGFloat avatarScaleFactor = MIN(1 - percentScrolled * 0.3, 1);
    CGAffineTransform avatarTransform = CGAffineTransformMakeScale(avatarScaleFactor, avatarScaleFactor);
    CGFloat avatarOffset = layoutAttributes.edgeInsets.bottom + layoutAttributes.edgeInsets.top;
    avatarTransform = CGAffineTransformTranslate(avatarTransform, 0, MAX(avatarOffset * percentScrolled, 0));
    
    // The avatar transform only needs to be applied if the avatar's offset would cause the avatar's frame to overlay the header.
    if (avatarOffset > 0 && !self.isUpdating) {
        layoutAttributes.transform = avatarTransform;
    }
    
    if (layoutAttributes.hasInstalledConstraints) {
        
        switch (layoutAttributes.avatarAlignment) {
            case DBProfileAvatarAlignmentLeft:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.leftConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.rightConstraint, layoutAttributes.centerXConstraint]];
                break;
            case DBProfileAvatarAlignmentRight:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.rightConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.leftConstraint, layoutAttributes.centerXConstraint]];
                break;
            case DBProfileAvatarAlignmentCenter:
                [NSLayoutConstraint activateConstraints:@[layoutAttributes.centerXConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[layoutAttributes.leftConstraint, layoutAttributes.rightConstraint]];
                break;
            default:
                break;
        }
        
        CGSize referenceSize = [self _referenceSizeForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
        
        layoutAttributes.widthConstraint.constant = MAX(referenceSize.width, referenceSize.height);
        layoutAttributes.leftConstraint.constant = layoutAttributes.edgeInsets.left - layoutAttributes.edgeInsets.right;
        layoutAttributes.rightConstraint.constant = -(layoutAttributes.edgeInsets.left - layoutAttributes.edgeInsets.right);
        layoutAttributes.topConstraint.constant = layoutAttributes.edgeInsets.top - layoutAttributes.edgeInsets.bottom;
    }
}

- (void)invalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind {
    NSAssert([self hasRegisteredAccessoryViewOfKind:accessoryViewKind], @"no accessory view has been registered for accessory kind '%@'", accessoryViewKind);

    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:accessoryViewKind];
    
    // The layout attributes have been marked as invalid and must be reconfigured and applied to the associated accessory view.
#warning - There should be a cleaner solution to handle invalidation cycles, i.e. allow for batching the updates to accessory views.
    [self configureLayoutAttributes:layoutAttributes forAccessoryViewOfKind:accessoryViewKind];
    
    [[self accessoryViewOfKind:accessoryViewKind] applyLayoutAttributes:layoutAttributes];
}

#pragma mark - DBProfileScrollViewObserverDelegate

- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.registeredAccessoryViews enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull kind, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self shouldInvalidateLayoutAttributesForAccessoryViewOfKind:kind forBoundsChange:scrollView.bounds]) {
            [self invalidateLayoutAttributesForAccessoryViewOfKind:kind];
        }
    }];
    
    // Other controller related stuff
    CGPoint contentOffset = [self contentOffsetForCurrentlyDisplayedContentController];
    [self updateTitleViewWithContentOffset:contentOffset];
    [self handlePullToRefreshWithScrollView:scrollView];
}

#pragma mark - DBProfielAccessoryViewDelegate

- (BOOL)accessoryViewShouldHighlight:(DBProfileAccessoryView *)accessoryView {
    if ([self.delegate respondsToSelector:@selector(profileViewController:shouldHighlightAccessoryView:ofKind:)]) {
        return [self.delegate profileViewController:self shouldHighlightAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
    return YES;
}

- (void)accessoryViewDidHighlight:(DBProfileAccessoryView *)accessoryView {
    if ([self.delegate respondsToSelector:@selector(profileViewController:didHighlightAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didHighlightAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

- (void)accessoryViewDidUnhighlight:(DBProfileAccessoryView *)accessoryView {
    if ([self.delegate respondsToSelector:@selector(profileViewController:didUnhighlightAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didUnhighlightAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

- (void)accessoryViewWasTapped:(DBProfileAccessoryView *)accessoryView {
    if ([self.delegate respondsToSelector:@selector(profileViewController:didTapAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didTapAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

- (void)accessoryViewWasLongPressed:(DBProfileAccessoryView *)accessoryView {
    if ([self.delegate respondsToSelector:@selector(profileViewController:didLongPressAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didLongPressAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

@end