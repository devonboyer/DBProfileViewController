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
@property (nonatomic, strong) NSMutableDictionary *accessoryViewLayoutAttributes;

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
    NSAssert([segmentedControlClass isSubclassOfClass:[UISegmentedControl class]], @"segmentedControlClass must inherit from UISegmentedControl");
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
    
    [self configureDefaults];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.contentOffsetCache removeAllObjects];
    self.contentOffsetCache = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.tintColor = [UIColor whiteColor];

    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.frame = self.view.frame;
    [self.view addSubview:self.containerView];
    
    [self addOverlayView];
    [self setupOverlayViewConstraints];

    [self.segmentedControl addTarget:self action:@selector(showContentController:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    if (layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    }
    
    self.automaticallyAdjustsScrollViewInsets = layoutAttributes.headerStyle != DBProfileHeaderStyleNavigation;
    
    if (!self.hasAppeared) {
        [self reloadData];
        
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.hasAppeared = YES;
}

- (void)updateViewConstraints
{
    [self updateAccessoryViewConstraints];
    [super updateViewConstraints];
}

- (void)configureDefaults
{
    [self segmentedControl].tintColor = [UIColor colorWithRed:29/255.0 green:161/255.0 blue:242/255.0 alpha:1];

    _hidesSegmentedControlForSingleContentController = YES;
    _allowsPullToRefresh = YES;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Size Classes

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    UIScrollView *scrollView = [self.currentlyDisplayedContentController contentScrollView];
    _cachedContentInset = scrollView.contentInset;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    // Reset the navigation view constraints to allow the system to determine the height
    [self.overlayView removeFromSuperview];
    [self addOverlayView];
    [self setupOverlayViewConstraints];
    
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

- (DBProfileContentController *)currentlyDisplayedContentController
{
    return self.contentControllers[self.indexForDisplayedContentController];
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

- (DBProfileAccessoryView *)avatarView
{
    return [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
}

- (DBProfileAccessoryView *)headerView
{
    return [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
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
    [self reloadData];
}

- (void)setDetailView:(__kindof UIView *)detailView
{
    _detailView = detailView;
    
    // The detail view should never be nil in order for constraints to be created relative to the detail view.
    if (!_detailView) {
        _detailView = [[UIView alloc] init];
    }
    [self reloadData];
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh
{
    _allowsPullToRefresh = allowsPullToRefresh;
    [self reloadData];
}

#pragma mark - Actions

- (void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showContentController:(id)sender
{
    NSInteger selectedSegmentIndex = [self.segmentedControl selectedSegmentIndex];
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:willShowContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self willShowContentControllerAtIndex:selectedSegmentIndex];
    }
    
    [self showContentControllerAtIndex:selectedSegmentIndex];
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:didShowContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didShowContentControllerAtIndex:selectedSegmentIndex];
    }
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
    
    NSString *overlaySubtitle;
    
    if ([self.delegate respondsToSelector:@selector(profileViewController:titleForContentControllerAtIndex:)]) {
        overlaySubtitle = [self.dataSource profileViewController:self subtitleForContentControllerAtIndex:controllerIndex];
    }
    
    self.overlayView.title = overlayTitle;
    self.overlayView.subtitle = overlaySubtitle;
}

#pragma mark - Public Methods

+ (Class)layoutAttributesClassForAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
        return [DBProfileHeaderViewLayoutAttributes class];
    }
    else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
        return [DBProfileAvatarViewLayoutAttributes class];
    }
    
    return [DBProfileAccessoryViewLayoutAttributes class];
}

- (void)registerClass:(Class)viewClass forAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    NSAssert(accessoryViewKind == DBProfileAccessoryKindAvatar || accessoryViewKind == DBProfileAccessoryKindHeader, @"invalid accessory view kind");
    
    NSAssert([viewClass isSubclassOfClass:[DBProfileAccessoryView class]], @"viewClass must inherit from DBProfileAccessoryView");
    
    [self.registeredAccessoryViews removeObjectForKey:accessoryViewKind];
    [self.accessoryViewLayoutAttributes removeObjectForKey:accessoryViewKind];

    // Register the accessory view
    DBProfileAccessoryView *accessoryView = [[viewClass alloc] init];
    accessoryView.representedAccessoryKind = accessoryViewKind;
    accessoryView.internalDelegate = self;

    [self.registeredAccessoryViews setObject:accessoryView forKey:accessoryViewKind];
    
    Class layoutAttributesClass = [[self class] layoutAttributesClassForAccessoryViewOfKind:accessoryViewKind];
    
    if (accessoryViewKind == DBProfileAccessoryKindHeader) {
        NSAssert([layoutAttributesClass isSubclassOfClass:[DBProfileHeaderViewLayoutAttributes class]], @"layoutAttributesClass must inherit from DBProfileHeaderViewLayoutAttributes");
    }
    else if (accessoryViewKind == DBProfileAccessoryKindAvatar) {
        NSAssert([layoutAttributesClass isSubclassOfClass:[DBProfileAvatarViewLayoutAttributes class]], @"layoutAttributesClass must inherit from DBProfileAvatarViewLayoutAttributes");
    }
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [layoutAttributesClass layoutAttributesForAccessoryViewOfKind:accessoryViewKind];
    [self.accessoryViewLayoutAttributes setObject:layoutAttributes forKey:accessoryViewKind];
    
    [self invalidateLayoutAttributesForAccessoryViewOfKind:accessoryViewKind];
}

- (DBProfileAccessoryView *)accessoryViewOfKind:(NSString *)accessoryViewKind
{
    NSAssert(accessoryViewKind == DBProfileAccessoryKindAvatar || accessoryViewKind == DBProfileAccessoryKindHeader, @"invalid accessory view kind");
    return [self.registeredAccessoryViews objectForKey:accessoryViewKind];
}

- (DBProfileAccessoryViewLayoutAttributes *)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    NSAssert(accessoryViewKind == DBProfileAccessoryKindAvatar || accessoryViewKind == DBProfileAccessoryKindHeader, @"invalid accessory view kind");
    return [self.accessoryViewLayoutAttributes objectForKey:accessoryViewKind];
}

- (void)invalidateLayoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    DBProfileAccessoryView *accessoryView = [self accessoryViewOfKind:accessoryViewKind];
    [accessoryView applyLayoutAttributes:[self layoutAttributesForAccessoryViewOfKind:accessoryViewKind]];
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
        [self updateViewConstraints];
        
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.updating = NO;
    }];
}

- (void)reloadData
{
    NSInteger numberOfSegments = [self _numberOfContentControllers];
    
    [self.scrollViewObservers removeAllObjects];
    
    if ([self.contentControllers count] > 0) {
        [self hideContentController:self.currentlyDisplayedContentController];
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
    
    // Hide navigation bar
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    self.overlayView.hidden = layoutAttributes.headerStyle != DBProfileHeaderStyleNavigation;
    
    [self invalidateLayoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
}

- (void)endRefreshing
{
    self.refreshing = NO;
    [self endRefreshAnimations];
}

- (void)showContentControllerAtIndex:(NSInteger)index
{
    if (![self.contentControllers count]) return;
    
    // Hide the currently displayed content controller and remove scroll view observer
    DBProfileContentController *hideContentController = self.currentlyDisplayedContentController;
    if (hideContentController) {
        [self hideContentController:hideContentController];
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
        [self displayContentController:displayContentController];
        NSString *key = [self uniqueKeyForContentControllerAtIndex:index];
        DBProfileScrollViewObserver *observer = [[DBProfileScrollViewObserver alloc] initWithTargetView:[displayContentController contentScrollView] delegate:self];
        [observer startObserving];
        self.scrollViewObservers[key] = observer;
    }
    
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    
    [self updateOverlayInformation];
}

#pragma mark - Private Methods

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

#pragma mark - Container View Controller

- (CGRect)frameForContentController
{
    return self.containerView.frame;
}

- (void)displayContentController:(DBProfileContentController *)viewController
{
    NSAssert(viewController, @"viewController cannot be nil");
    [self addChildViewController:viewController];
    viewController.view.frame = [self frameForContentController];
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.overlayView];
    [self setCurrentlyDisplayedContentController:viewController animated:YES];
}

- (void)hideContentController:(DBProfileContentController *)viewController
{
    NSAssert(viewController, @"viewController cannot be nil");
    
    UIScrollView *scrollView = [viewController contentScrollView];
    
    // Cache content offset
    CGFloat topInset = CGRectGetMaxY(self.overlayView.frame) + CGRectGetHeight(self.segmentedControlView.frame);
    if (self.automaticallyAdjustsScrollViewInsets) topInset = CGRectGetHeight(self.segmentedControlView.frame);
    _shouldScrollToTop = scrollView.contentOffset.y >= -topInset;
    _sharedContentOffset = scrollView.contentOffset;
    
    [self cacheContentOffset:scrollView.contentOffset forContentControllerAtIndex:self.indexForDisplayedContentController];
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)setCurrentlyDisplayedContentController:(DBProfileContentController *)controller animated:(BOOL)animated
{
    NSAssert(controller, @"controller cannot be nil");
    
    UIScrollView *scrollView = [controller contentScrollView];
    
    [self.headerView removeFromSuperview];
    [self.avatarView removeFromSuperview];
    [self.detailView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    [self.activityIndicator removeFromSuperview];
    
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailView.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControlView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self endRefreshing];
    
    [scrollView addSubview:self.detailView];
    
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    // Add segmented control
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
        [scrollView addSubview:self.segmentedControlView];
    } else {
        self.segmentedControlView.frame = CGRectZero;
    }
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindHeader]) {
        [scrollView addSubview:self.headerView];
        
        // Add pull-to-refresh
        if (self.allowsPullToRefresh) {
            [self.headerView addSubview:self.activityIndicator];
        }
    }
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindAvatar]) {
        [scrollView addSubview:self.avatarView];
    }
    
    [self setUpConstraintsForScrollView:scrollView];
    
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
    
    if (headerViewLayoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        if ((scrollView.contentOffset.y + scrollView.contentInset.top) < CGRectGetHeight(self.headerView.frame) - headerViewLayoutAttributes.navigationConstraint.constant) {
            [scrollView insertSubview:self.avatarView aboveSubview:self.headerView];
        } else {
            [scrollView insertSubview:self.headerView aboveSubview:self.avatarView];
        }
    }
}

#pragma mark - Helpers

- (void)cacheContentOffset:(CGPoint)contentOffset forContentControllerAtIndex:(NSInteger)index
{
    NSString *key = [self uniqueKeyForContentControllerAtIndex:index];
    [self.contentOffsetCache setObject:[NSValue valueWithCGPoint:contentOffset] forKey:key];
}

- (CGPoint)cachedContentOffsetForContentControllerAtIndex:(NSInteger)index {
    NSString *key = [self uniqueKeyForContentControllerAtIndex:index];
    return [[self.contentOffsetCache objectForKey:key] CGPointValue];
}

- (NSString *)uniqueKeyForContentControllerAtIndex:(NSInteger)index
{
    NSMutableString *key = [[NSMutableString alloc] initWithString:[self _titleForContentControllerAtIndex:index]];
    [key appendFormat:@"-%@", @(index)];
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
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailView.frame) + CGRectGetHeight(self.headerView.frame);
    
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
    topInset -= CGRectGetHeight(self.headerView.frame);
    _detailsViewTopConstraint.constant = -topInset;
}

- (BOOL)hasRegisteredAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    return [self.registeredAccessoryViews objectForKey:accessoryViewKind];
}

- (CGFloat)_headerViewOffset
{
    return CGRectGetHeight(self.headerView.frame);
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

#pragma mark - DBProfielAccessoryViewDelegate

- (BOOL)accessoryViewShouldHighlight:(DBProfileAccessoryView *)accessoryView 
{
    if ([self.delegate respondsToSelector:@selector(profileViewController:shouldHighlightAccessoryView:ofKind:)]) {
        return [self.delegate profileViewController:self shouldHighlightAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
    return YES;
}

- (void)accessoryViewDidHighlight:(DBProfileAccessoryView *)accessoryView
{
    if ([self.delegate respondsToSelector:@selector(profileViewController:didHighlightAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didHighlightAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

- (void)accessoryViewDidUnhighlight:(DBProfileAccessoryView *)accessoryView
{
    if ([self.delegate respondsToSelector:@selector(profileViewController:didUnhighlightAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didUnhighlightAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

- (void)accessoryViewWasTapped:(DBProfileAccessoryView *)accessoryView
{
    if ([self.delegate respondsToSelector:@selector(profileViewController:didTapAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didTapAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

- (void)accessoryViewWasLongPressed:(DBProfileAccessoryView *)accessoryView
{
    if ([self.delegate respondsToSelector:@selector(profileViewController:didLongPressAccessoryView:ofKind:)]) {
        [self.delegate profileViewController:self didLongPressAccessoryView:accessoryView ofKind:accessoryView.representedAccessoryKind];
    }
}

#pragma mark - Scroll Animations

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

- (void)updateAccessoryViewsWithContentOffset:(CGPoint)contentOffset
{
    if (self.isUpdating) return;
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindHeader]) {
        [self updateHeaderViewWithContentOffset:contentOffset];
    }
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindAvatar]) {
        [self updateAvatarViewWithContentOffset:contentOffset];
    }
}

- (void)updateHeaderViewWithContentOffset:(CGPoint)contentOffset
{
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
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
    
    [self.headerView applyLayoutAttributes:layoutAttributes];
}

- (void)updateAvatarViewWithContentOffset:(CGPoint)contentOffset
{
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileAvatarViewLayoutAttributes *avatarViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    CGFloat headerOffset = [self _headerViewOffset];
    CGFloat percentScrolled = 0;
    
    if (headerViewLayoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        headerOffset -= CGRectGetMaxY(self.overlayView.frame);
    }
    
    percentScrolled = MIN(1, contentOffset.y / headerOffset);

    CGFloat avatarScaleFactor = MIN(1 - percentScrolled * 0.3, 1);
    CGAffineTransform avatarTransform = CGAffineTransformMakeScale(avatarScaleFactor, avatarScaleFactor);
    CGFloat avatarOffset = avatarViewLayoutAttributes.edgeInsets.bottom + avatarViewLayoutAttributes.edgeInsets.top;
    avatarTransform = CGAffineTransformTranslate(avatarTransform, 0, MAX(avatarOffset * percentScrolled, 0));
    
    // The avatar transform only needs to be applied if the avatar's frame is overlaying the header.
    if (avatarOffset > 0) {
        self.avatarView.transform = avatarTransform;
    }
}

- (void)updateTitleViewWithContentOffset:(CGPoint)contentOffset
{
    DBProfileHeaderViewLayoutAttributes *headerViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileAvatarViewLayoutAttributes *avatarViewLayoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];

    if (headerViewLayoutAttributes.headerStyle != DBProfileHeaderStyleNavigation) return;
    
    CGFloat titleViewOffset = [self _titleViewOffset];
    
    const CGFloat padding = 30.0;
    CGFloat avatarOffset = avatarViewLayoutAttributes.edgeInsets.top - avatarViewLayoutAttributes.edgeInsets.bottom;
    titleViewOffset += (CGRectGetHeight(self.avatarView.frame) + avatarOffset + padding);
    
    CGFloat percentScrolled = 1 - contentOffset.y / titleViewOffset;
    [self.overlayView setTitleVerticalPositionAdjustment:MAX(titleViewOffset * percentScrolled, 0) traitCollection:self.traitCollection];
}

- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y += scrollView.contentInset.top;
    
    [self updateAccessoryViewsWithContentOffset:contentOffset];
    [self updateTitleViewWithContentOffset:contentOffset];
    [self handlePullToRefreshWithScrollView:scrollView];
    
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    if (layoutAttributes.headerStyle == DBProfileHeaderStyleNavigation) {
        if (contentOffset.y < CGRectGetHeight(self.headerView.frame) - layoutAttributes.navigationConstraint.constant) {
            [scrollView insertSubview:self.avatarView aboveSubview:self.headerView];
        } else {
            [scrollView insertSubview:self.headerView aboveSubview:self.avatarView];
        }
    }
}

#pragma mark - Auto Layout

- (void)updateAccessoryViewConstraints
{
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindHeader]) {
        [self updateHeaderViewConstraints];
    }
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindAvatar]) {
        [self updateAvatarViewConstraints];
    }
}

- (void)updateHeaderViewConstraints
{
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    if (layoutAttributes.navigationConstraint &&
        layoutAttributes.topSuperviewConstraint &&
        layoutAttributes.topLayoutGuideConstraint) {
        
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

- (void)updateAvatarViewConstraints
{
    DBProfileAvatarViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];

    if (layoutAttributes.leftConstraint && layoutAttributes.rightConstraint && layoutAttributes.centerXConstraint) {
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
    }
    
    CGSize referenceSize = [self _referenceSizeForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
        
    layoutAttributes.widthConstraint.constant = MAX(referenceSize.width, referenceSize.height);
    layoutAttributes.leftConstraint.constant = layoutAttributes.edgeInsets.left - layoutAttributes.edgeInsets.right;
    layoutAttributes.rightConstraint.constant = -(layoutAttributes.edgeInsets.left - layoutAttributes.edgeInsets.right);
    layoutAttributes.topConstraint.constant = layoutAttributes.edgeInsets.top - layoutAttributes.edgeInsets.bottom;
}

- (void)setupOverlayViewConstraints
{
    NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:self.overlayView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:[self topLayoutGuide]
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:self.overlayView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0],
                             [NSLayoutConstraint constraintWithItem:self.overlayView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraints:constraints];
}

- (void)setUpConstraintsForScrollView:(UIScrollView *)scrollView
{
    NSAssert(scrollView, @"scrollView cannot be nil");
    
    if (self.segmentedControlView.superview) {
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                   
                                                               attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:0]];
        
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                  toItem:self.detailView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:[self topLayoutGuide]
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0]];
    }
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:scrollView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1
                                                            constant:0]];
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:scrollView
                                                           attribute:NSLayoutAttributeWidth
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
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindHeader]) {
        [self setUpHeaderViewConstraintsForScrollView:scrollView];
        
        DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
        
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
    
    if ([self hasRegisteredAccessoryViewOfKind:DBProfileAccessoryKindAvatar]) {
        [self setUpAvatarViewConstraintsForScrollView:scrollView];
    }
}

- (void)setUpHeaderViewConstraintsForScrollView:(UIScrollView *)scrollView
{
    NSAssert(scrollView, @"scrollView cannot be nil");
    
    DBProfileAccessoryView *headerView = [self accessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    layoutAttributes.leftConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:scrollView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:0];
    
    layoutAttributes.widthConstraint = [NSLayoutConstraint constraintWithItem:headerView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:scrollView
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
                                                                     toItem:scrollView
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
    
    [scrollView addConstraints:@[layoutAttributes.leftConstraint,
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
}

- (void)setUpAvatarViewConstraintsForScrollView:(UIScrollView *)scrollView
{
    NSAssert(scrollView, @"scrollView cannot be nil");
    
    DBProfileAccessoryView *avatarView = [self accessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    DBProfileAvatarViewLayoutAttributes *layoutAttributes = [self layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
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
                                                                      toItem:scrollView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:0];
    layoutAttributes.leftConstraint.priority = UILayoutPriorityDefaultLow;
    
    layoutAttributes.rightConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:scrollView
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1
                                                                     constant:0];
    
    layoutAttributes.rightConstraint.priority = UILayoutPriorityDefaultLow;
    
    layoutAttributes.centerXConstraint = [NSLayoutConstraint constraintWithItem:avatarView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:scrollView
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
    
    [scrollView addConstraints:@[layoutAttributes.heightConstraint,
                                 layoutAttributes.widthConstraint,
                                 layoutAttributes.leftConstraint,
                                 layoutAttributes.rightConstraint,
                                 layoutAttributes.centerXConstraint,
                                 layoutAttributes.topConstraint]];
}

@end
