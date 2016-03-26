//
//  DBProfileViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2015-12-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileViewController.h"
#import "DBProfileObserver.h"
#import "DBProfileDetailsView.h"
#import "DBProfileAvatarView.h"
#import "DBProfileAvatarView_Private.h"
#import "DBProfileCoverPhotoView.h"
#import "DBProfileCoverPhotoView_Private.h"
#import "DBProfileTitleView.h"
#import "DBProfileSegmentedControlView.h"
#import "DBProfileCustomNavigationBar.h"
#import "DBProfileViewControllerDefaults.h"
#import "DBProfileViewControllerUpdateContext.h"
#import "UIBarButtonItem+DBProfileViewController.h"

static NSString * const DBProfileViewControllerContentOffsetCacheName = @"DBProfileViewController.contentOffsetCache";

@interface DBProfileViewController () <DBProfileCoverPhotoViewDelegate, DBProfileAvatarViewDelegate, DBProfileScrollViewObserverDelegate>
{
    BOOL _shouldScrollToTop;
    CGPoint _sharedContentOffset;
    UIEdgeInsets _cachedContentInset;
    UIImage *_coverPhotoImage;
}

@property (nonatomic, assign) Class segmentedControlClass;

@property (nonatomic, assign) NSUInteger indexForSelectedContentController;
@property (nonatomic, getter=isRefreshing) BOOL refreshing;

// Updates
@property (nonatomic, strong) DBProfileViewControllerUpdateContext *updateContext;
@property (nonatomic, getter=isUpdating) BOOL updating;
@property (nonatomic, assign) BOOL hasAppeared;

// Data
@property (nonatomic, strong) NSMutableArray<DBProfileContentController *> *contentControllers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DBProfileObserver *> *observers;
@property (nonatomic, strong) NSCache *contentOffsetCache;

// Views
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) DBProfileCustomNavigationBar *customNavigationBar;
@property (nonatomic, strong) DBProfileSegmentedControlView *segmentedControlView;

@end

@implementation DBProfileViewController {
    NSLayoutConstraint *_detailsViewTopConstraint;

    NSLayoutConstraint *_avatarViewSizeConstraint;
    NSLayoutConstraint *_avatarViewTopConstraint;
    NSLayoutConstraint *_avatarViewLeftAlignmentConstraint;
    NSLayoutConstraint *_avatarViewRightAlignmentConstraint;
    NSLayoutConstraint *_avatarViewCenterAlignmentConstraint;
    
    NSLayoutConstraint *_coverPhotoViewHeightConstraint;
    NSLayoutConstraint *_coverPhotoViewMimicNavigationBarConstraint;
    NSLayoutConstraint *_coverPhotoViewTopConstraint;
    NSLayoutConstraint *_coverPhotoViewTopLayoutGuideConstraint;
    NSLayoutConstraint *_coverPhotoViewTopSuperviewConstraint;
}

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (instancetype)initWithSegmentedControlClass:(Class)segmentedControlClass {
    NSAssert([segmentedControlClass isSubclassOfClass:[UISegmentedControl class]], @"segmentedControlClass must inherit from UISegmentedControl");
    self = [self init];
    if (self) {
        self.segmentedControlClass = (segmentedControlClass) ? segmentedControlClass : [UISegmentedControl class];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self db_commonInit];
    }
    return self;
}

- (void)db_commonInit {
    _detailsView = [[DBProfileDetailsView alloc] init];
    _segmentedControlView = [[DBProfileSegmentedControlView alloc] init];
    _avatarView = [[DBProfileAvatarView alloc] init];
    _coverPhotoView = [[DBProfileCoverPhotoView alloc] init];
    _customNavigationBar = [[DBProfileCustomNavigationBar alloc] init];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    NSCache *contentOffsetCache = [[NSCache alloc] init];
    contentOffsetCache.name = DBProfileViewControllerContentOffsetCacheName;
    contentOffsetCache.countLimit = 10;
    _contentOffsetCache = contentOffsetCache;
    
    self.containerView = [[UIView alloc] init];
    self.segmentedControlClass = [UISegmentedControl class];
    
    self.coverPhotoView.delegate = self;
    self.avatarView.delegate = self;
    
    [self configureDefaults];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.contentOffsetCache removeAllObjects];
    self.contentOffsetCache = nil;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.frame = self.view.frame;
    [self.view addSubview:self.containerView];
    
    self.customNavigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.customNavigationBar];

    [self setupCustomNavigationBarConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.segmentedControl addTarget:self
                              action:@selector(changeContentController)
                    forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.hasAppeared) {
        [self reloadData];
        
        [self.view setNeedsUpdateConstraints];
        
        // Scroll displayed content controller to top
        if ([self.contentControllers count]) {
            DBProfileContentController *displayedViewController = [self.contentControllers objectAtIndex:self.indexForSelectedContentController];
            [self scrollContentControllerToTop:displayedViewController animated:NO];
        }
    }
    
    if (self.coverPhotoMimicsNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.hasAppeared = YES;
}

- (void)updateViewConstraints {
    [self updateCoverPhotoViewConstraints];
    [self updateAvatarViewConstraints];
    [super updateViewConstraints];
}

- (void)configureDefaults {
    // Set segmented control defaults
    self.segmentedControl.tintColor = [DBProfileViewControllerDefaults defaultSegmentedControlTintColor];

    _hidesSegmentedControlForSingleContentController = [DBProfileViewControllerDefaults defaultHidesSegmentedControlForSingleContentController];
    _coverPhotoOptions = [DBProfileViewControllerDefaults defaultCoverPhotoOptions];
    _coverPhotoHidden = [DBProfileViewControllerDefaults defaultCoverPhotoHidden];
    _coverPhotoMimicsNavigationBar = [DBProfileViewControllerDefaults defaultCoverPhotoMimicsNavigationBar];
    _coverPhotoScrollAnimationStyle = [DBProfileViewControllerDefaults defaultCoverPhotoScrollAnimationStyle];
    _coverPhotoHeightMultiplier = [DBProfileViewControllerDefaults defaultCoverPhotoHeightMultiplier];
    _avatarAlignment = [DBProfileViewControllerDefaults defaultAvatarAlignment];
    _avatarSize = [DBProfileViewControllerDefaults defaultAvatarSize];
    _avatarInset = [DBProfileViewControllerDefaults defaultAvatarInsets];
    _allowsPullToRefresh = [DBProfileViewControllerDefaults defaultAllowsPullToRefresh];
    
    self.coverPhotoMimicsNavigationBarNavigationItem.leftBarButtonItem = [UIBarButtonItem db_backBarButtonItemWithTarget:self action:@selector(back)];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Size Classes

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIScrollView *scrollView = [[self.contentControllers objectAtIndex:self.indexForSelectedContentController] contentScrollView];
    _cachedContentInset = scrollView.contentInset;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // Reset the navigation view constraints to allow the system to determine the height
    [self.customNavigationBar removeFromSuperview];
    [self.view addSubview:self.customNavigationBar];
    [self setupCustomNavigationBarConstraints];
    
    // The scroll view content inset needs to be recalculated for the new size class
    UIScrollView *scrollView = [[self.contentControllers objectAtIndex:self.indexForSelectedContentController] contentScrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self.view setNeedsUpdateConstraints];
    
    [self adjustContentInsetForScrollView:scrollView];
    
    // Preserve the relative contentOffset during size class changes
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y -= MAX(scrollView.contentInset.top - _cachedContentInset.top, 0);
    scrollView.contentOffset = contentOffset;
    
    [self resetTitles];
}

#pragma mark - Getters

- (UISegmentedControl *)segmentedControl {
    return self.segmentedControlView.segmentedControl;
}

- (UINavigationItem *)coverPhotoMimicsNavigationBarNavigationItem {
    return self.customNavigationBar.navigationItem;
}

- (NSMutableArray *)contentControllers {
    if (!_contentControllers) {
        _contentControllers = [NSMutableArray array];
    }
    return _contentControllers;
}

- (NSMutableDictionary *)observers {
    if (!_observers) {
        _observers = [NSMutableDictionary dictionary];
    }
    return _observers;
}

#pragma mark - Setters

- (void)setSegmentedControlClass:(Class)segmentedControlClass {
    _segmentedControlClass = segmentedControlClass;
    
    UISegmentedControl *segmentedControl = [[segmentedControlClass alloc] init];
    self.segmentedControlView.segmentedControl = segmentedControl;
}

- (void)setHidesSegmentedControlForSingleContentController:(BOOL)hidesSegmentedControlForSingleContentController {
    _hidesSegmentedControlForSingleContentController = hidesSegmentedControlForSingleContentController;
    [self reloadData];
}

- (void)setDetailsView:(UIView *)detailsView {
    NSAssert(detailsView, @"detailsView cannot be nil");
    _detailsView = detailsView;
    [self reloadData];
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh {
    _allowsPullToRefresh = allowsPullToRefresh;
    [self reloadData];
}

- (void)setCoverPhotoHeightMultiplier:(CGFloat)coverPhotoHeightMultiplier {
    NSAssert(coverPhotoHeightMultiplier > 0 && coverPhotoHeightMultiplier <= 1, @"`coverPhotoHeightMultiplier` must be greater than 0 or less than or equal to 1.");
    _coverPhotoHeightMultiplier = coverPhotoHeightMultiplier;
    [self.view setNeedsUpdateConstraints];
}

- (void)setCoverPhotoOptions:(DBProfileCoverPhotoOptions)coverPhotoOptions {
    _coverPhotoOptions = coverPhotoOptions;
    [self.view updateConstraintsIfNeeded];
}

- (void)setCoverPhotoHidden:(BOOL)coverPhotoHidden {
    _coverPhotoHidden = coverPhotoHidden;
    [self.view updateConstraintsIfNeeded];
}

- (void)setCoverPhotoMimicsNavigationBar:(BOOL)coverPhotoMimicsNavigationBar {
    _coverPhotoMimicsNavigationBar = coverPhotoMimicsNavigationBar;
    self.customNavigationBar.hidden = !coverPhotoMimicsNavigationBar;
    self.coverPhotoView.shouldApplyTint = coverPhotoMimicsNavigationBar;
    [self.view updateConstraintsIfNeeded];
}

- (void)setAvatarSize:(DBProfileAvatarSize)avatarSize {
    _avatarSize = avatarSize;
    [self.view setNeedsUpdateConstraints];
}

- (void)setAvatarAlignment:(DBProfileAvatarAlignment)avatarAlignment {
    _avatarAlignment = avatarAlignment;
    [self.view setNeedsUpdateConstraints];
}

- (void)setAvatarInset:(UIEdgeInsets)avatarInset {
    _avatarInset = avatarInset;
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - Action Responders

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeContentController {
    NSInteger selectedSegmentIndex = [self.segmentedControl selectedSegmentIndex];
    
    NSInteger oldIndexForSelectedContentController = self.indexForSelectedContentController;
    
    // Inform delegate that the currently selected content controller will be deselected
    if ([self.delegate respondsToSelector:@selector(profileViewController:willDeselectContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self willDeselectContentControllerAtIndex:oldIndexForSelectedContentController];
    }
    
    // Inform delegate that the chosen content controller will be selected
    if ([self.delegate respondsToSelector:@selector(profileViewController:willSelectContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self willSelectContentControllerAtIndex:selectedSegmentIndex];
    }
    
    self.indexForSelectedContentController = selectedSegmentIndex;
    [self updateViewConstraints];
    
    // Inform delegate that the previously selected content controller is now deselected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didDeselectContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didDeselectContentControllerAtIndex:oldIndexForSelectedContentController];
    }
    
    // Inform delegate that the chosen content controller is now selected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didSelectContentControllerAtIndex:selectedSegmentIndex];
    }
}

#pragma mark - Public Methods

- (void)beginUpdates {
    self.updating = YES;
    self.updateContext = [[DBProfileViewControllerUpdateContext alloc] init];
    self.updateContext.beforeUpdatesDetailsViewHeight = CGRectGetHeight(self.detailsView.frame);
    [self.view invalidateIntrinsicContentSize];
}

- (void)endUpdates {
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self setIndexForSelectedContentController:self.indexForSelectedContentController];
        
        // Calculate the difference between heights of subviews from before updates to after updates
        self.updateContext.afterUpdatesDetailsViewHeight = CGRectGetHeight(self.detailsView.frame);
        
        // Adjust content offset to account for difference in heights of subviews from before updates to after updates
        if (round(self.updateContext.beforeUpdatesDetailsViewHeight) != round(self.updateContext.afterUpdatesDetailsViewHeight)) {
            DBProfileContentController *viewController = [self.contentControllers objectAtIndex:self.indexForSelectedContentController];
            UIScrollView *scrollView = [viewController contentScrollView];
            
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

- (void)reloadData {
    NSInteger numberOfSegments = [self numberOfContentControllers];
    
    [self.observers removeAllObjects];
    
    if ([self.contentControllers count] > 0) {
        [self hideContentController:[self.contentControllers objectAtIndex:self.indexForSelectedContentController]];
    }
    
    [self.contentControllers removeAllObjects];
    [self.segmentedControl removeAllSegments];
    
    for (NSInteger i = 0; i < numberOfSegments; i++) {
        // Reload content view controllers
        DBProfileContentController *contentController = [self contentControllerAtIndex:i];
        [self.contentControllers addObject:contentController];
        
        // Reload segmented control
        NSString *title = [self titleForContentControllerAtIndex:i];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
    }
    
    // Display selected content view controller
    [self setIndexForSelectedContentController:self.indexForSelectedContentController];
}

- (void)endRefreshing {
    self.refreshing = NO;
    [self endRefreshAnimations];
}

- (void)selectContentControllerAtIndex:(NSInteger)index {
    self.indexForSelectedContentController = index;
}

- (void)selectCoverPhotoViewAnimated:(BOOL)animated {
    [self.coverPhotoView setSelected:YES animated:animated];
}

- (void)deselectCoverPhotoViewAnimated:(BOOL)animated {
    [self.coverPhotoView setSelected:NO animated:animated];
}

- (void)selectAvatarViewAnimated:(BOOL)animated {
    [self.avatarView setSelected:YES animated:animated];
}

- (void)deselectAvatarViewAnimated:(BOOL)animated {
    [self.avatarView setSelected:NO animated:animated];
}

#pragma mark - Private Methods

- (void)setIndexForSelectedContentController:(NSUInteger)indexForSelectedContentController {
    if (![self.contentControllers count]) return;
    
    // Hide the currently selected content controller and remove observer
    DBProfileContentController *hideVC = [self.contentControllers objectAtIndex:_indexForSelectedContentController];
    if (hideVC) {
        [self hideContentController:hideVC];
        NSString *key = [self uniqueKeyForContentControllerAtIndex:_indexForSelectedContentController];
        if ([self.observers valueForKey:key]) {
            [self.observers removeObjectForKey:key];
        }
    }
    
    _indexForSelectedContentController = indexForSelectedContentController;
    [self.segmentedControl setSelectedSegmentIndex:indexForSelectedContentController];
    
    // Display the selected content controller and add an observer
    DBProfileContentController *displayVC = [self.contentControllers objectAtIndex:indexForSelectedContentController];
    if (displayVC) {
        [self displayContentViewController:displayVC];
        NSString *key = [self uniqueKeyForContentControllerAtIndex:indexForSelectedContentController];
        DBProfileScrollViewObserver *observer = [[DBProfileScrollViewObserver alloc] initWithTargetView:[displayVC contentScrollView] delegate:self];
        [observer startObserving];
        self.observers[key] = observer;
    }
    
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    
    [self resetTitles];
}

- (void)startRefreshAnimations {
    [self.activityIndicator startAnimating];
}

- (void)endRefreshAnimations {
    [self.activityIndicator stopAnimating];
}

- (void)notifyDelegateOfPullToRefreshForContentControllerAtIndex:(NSInteger)index  {
    // Inform delegate that the user has scrolled past the pull-to-refresh trigger distance
    if ([self respondsToSelector:@selector(profileViewController:didPullToRefreshContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didPullToRefreshContentControllerAtIndex:index];
    }
}

- (NSInteger)numberOfContentControllers {
    NSInteger numberOfContentControllers = [self.dataSource numberOfContentControllersForProfileViewController:self];
    NSAssert(numberOfContentControllers > 0, @"numberOfContentControllers must be greater than 0");
    return numberOfContentControllers;
}

- (DBProfileContentController *)contentControllerAtIndex:(NSInteger)index  {
    DBProfileContentController *contentController = [self.dataSource profileViewController:self contentControllerAtIndex:index];
    NSAssert(contentController, @"contentController cannot be nil");
    return contentController;
}

- (NSString *)titleForContentControllerAtIndex:(NSInteger)index  {
    NSString *title = [self.dataSource profileViewController:self titleForContentControllerAtIndex:index];
    NSAssert([title length], @"title for contentController cannot be nil");
    return title;
}

- (NSString *)subtitleForContentControllerAtIndex:(NSInteger)index  {
    NSString *subtitle = [self.dataSource profileViewController:self subtitleForContentControllerAtIndex:index];
    return subtitle;
}

#pragma mark - Container View Controller

- (CGRect)frameForContentController {
    return self.containerView.frame;
}

- (void)displayContentViewController:(DBProfileContentController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");
    [self addChildViewController:viewController];
    viewController.view.frame = [self frameForContentController];
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.customNavigationBar];
    [self buildContentController:viewController];
}

- (void)hideContentController:(DBProfileContentController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");
    
    UIScrollView *scrollView = [viewController contentScrollView];
    
    // Cache content offset
    CGFloat topInset = CGRectGetMaxY(self.customNavigationBar.frame) + CGRectGetHeight(self.segmentedControlView.frame);
    if (self.automaticallyAdjustsScrollViewInsets) topInset = CGRectGetHeight(self.segmentedControlView.frame);
    _shouldScrollToTop = scrollView.contentOffset.y >= -topInset;
    _sharedContentOffset = scrollView.contentOffset;
    
    [self cacheContentOffset:scrollView.contentOffset forContentControllerAtIndex:self.indexForSelectedContentController];
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)buildContentController:(DBProfileContentController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");
    
    UIScrollView *scrollView = [viewController contentScrollView];
    
    [self.coverPhotoView removeFromSuperview];
    [self.detailsView removeFromSuperview];
    [self.avatarView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    [self.activityIndicator removeFromSuperview];
    
    self.coverPhotoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControlView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self endRefreshing];
    
    [scrollView addSubview:self.detailsView];
    
    // Add segmented control
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
        [scrollView addSubview:self.segmentedControlView];
    } else {
        self.segmentedControlView.frame = CGRectZero;
    }
    
    // Add cover photo
    if (!self.coverPhotoHidden) {
        [scrollView addSubview:self.coverPhotoView];
        
        // Add pull-to-refresh
        if (self.allowsPullToRefresh) {
            [self.coverPhotoView addSubview:self.activityIndicator];
        }
        
        if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) {
            [scrollView insertSubview:self.detailsView aboveSubview:self.coverPhotoView];
        }
    } else {
        self.coverPhotoView.frame = CGRectZero;
    }
    
    [scrollView addSubview:self.avatarView];
    
    [self setUpConstraintsForScrollView:scrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self.view setNeedsUpdateConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:scrollView];
    
    // Reset the content offset
    if (_shouldScrollToTop) {
        [self resetContentOffsetForScrollView:scrollView];
        
        // Restore content offset for scroll view from cache
        CGPoint cachedContentOffset = [self cachedContentOffsetForContentControllerAtIndex:self.indexForSelectedContentController];
        if (cachedContentOffset.y > scrollView.contentOffset.y && !CGPointEqualToPoint(CGPointZero, cachedContentOffset)) {
            [scrollView setContentOffset:cachedContentOffset];
        }
    } else {
        [scrollView setContentOffset:_sharedContentOffset];
    }
    
    if (self.coverPhotoMimicsNavigationBar && !(self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend)) {
        if ((scrollView.contentOffset.y + scrollView.contentInset.top) < CGRectGetHeight(self.coverPhotoView.frame) - _coverPhotoViewMimicNavigationBarConstraint.constant) {
            [scrollView insertSubview:self.avatarView aboveSubview:self.coverPhotoView];
        } else {
            [scrollView insertSubview:self.coverPhotoView aboveSubview:self.avatarView];
        }
    }
    
    scrollView.delaysContentTouches = NO;
}

#pragma mark - Helpers

- (void)cacheContentOffset:(CGPoint)contentOffset forContentControllerAtIndex:(NSInteger)index {
    NSString *key = [self uniqueKeyForContentControllerAtIndex:index];
    [self.contentOffsetCache setObject:[NSValue valueWithCGPoint:contentOffset] forKey:key];
}

- (CGPoint)cachedContentOffsetForContentControllerAtIndex:(NSInteger)index {
    NSString *key = [self uniqueKeyForContentControllerAtIndex:index];
    return [[self.contentOffsetCache objectForKey:key] CGPointValue];
}

- (NSString *)uniqueKeyForContentControllerAtIndex:(NSInteger)index {
    NSMutableString *key = [[NSMutableString alloc] initWithString:[self titleForContentControllerAtIndex:index]];
    [key appendFormat:@"-%@", @(index)];
    return key;
}

- (void)scrollContentControllerToTop:(DBProfileContentController *)viewController animated:(BOOL)animated {
    UIScrollView *scrollView = [viewController contentScrollView];
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:animated];
}

- (void)resetContentOffsetForScrollView:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = -(CGRectGetMaxY(self.customNavigationBar.frame) + CGRectGetHeight(self.segmentedControlView.frame));
    [scrollView setContentOffset:contentOffset];
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.coverPhotoView.frame);
    
    // Calculate scroll view top inset
    UIEdgeInsets contentInset = scrollView.contentInset;
    if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) topInset -= CGRectGetHeight(self.detailsView.frame);
    contentInset.top = (self.automaticallyAdjustsScrollViewInsets) ? topInset + [self.topLayoutGuide length] : topInset;
    
    // Calculate scroll view bottom inset
    CGFloat minimumContentSizeHeight = CGRectGetHeight(scrollView.frame) - CGRectGetHeight(self.segmentedControlView.frame) - DBProfileViewControllerNavigationBarHeightForTraitCollection(self.traitCollection);
    
    if (scrollView.contentSize.height < minimumContentSizeHeight && ([self.contentControllers count] > 1 ||
                                                                     ([self.contentControllers count] == 1 && !self.hidesSegmentedControlForSingleContentController))) {
        contentInset.bottom = minimumContentSizeHeight - scrollView.contentSize.height;
    }
    
    scrollView.contentInset = contentInset;
    
    // Calculate cover photo inset
    _coverPhotoViewTopConstraint.constant = -topInset;
    
    // Calculate details view inset
    if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) {
        topInset -= (CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetHeight(self.detailsView.frame));
        [scrollView insertSubview:self.detailsView aboveSubview:self.coverPhotoView];
    } else {
        topInset -= CGRectGetHeight(self.coverPhotoView.frame);
    }
    _detailsViewTopConstraint.constant = -topInset;
}

- (void)resetTitles {
    [self.customNavigationBar setTitle:self.title];
    [self.customNavigationBar setSubtitle:[self subtitleForContentControllerAtIndex:self.indexForSelectedContentController]
                          traitCollection:self.traitCollection];
}

#pragma mark - DBProfileCoverPhotoViewDelegate

- (void)didSelectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was selected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectCoverPhotoView:)]) {
        [self.delegate profileViewController:self didSelectCoverPhotoView:coverPhotoView];
    }
    
    if (self.avatarView.isSelected) [self.avatarView setSelected:NO animated:YES];
}

- (void)didDeselectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was deselected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didDeselectCoverPhotoView:)]) {
        [self.delegate profileViewController:self didDeselectCoverPhotoView:coverPhotoView];
    }
}

- (void)didHighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was highlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didHighlightCoverPhotoView:)]) {
        [self.delegate profileViewController:self didHighlightCoverPhotoView:coverPhotoView];
    }
    
    if (self.avatarView.isSelected) [self.avatarView setSelected:NO animated:YES];
}

- (void)didUnhighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was unhighlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didUnhighlightCoverPhotoView:)]) {
        [self.delegate profileViewController:self didUnhighlightCoverPhotoView:coverPhotoView];
    }
}

#pragma mark - DBProfileAvatarViewDelegate

- (void)didSelectAvatarView:(DBProfileAvatarView *)avatarView {
    // Inform delegate that the profile picture was selected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectAvatarView:)]) {
        [self.delegate profileViewController:self didSelectAvatarView:avatarView];
    }
    
    if (self.coverPhotoView.isSelected) [self.coverPhotoView setSelected:NO animated:YES];
}

- (void)didDeselectAvatarView:(DBProfileAvatarView *)avatarView {
    // Inform delegate that the profile picture was deselected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didDeselectAvatarView:)]) {
        [self.delegate profileViewController:self didDeselectAvatarView:avatarView];
    }
}

- (void)didHighlightAvatarView:(DBProfileAvatarView *)avatarView {
    // Inform delegate that the profile picture was highlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didHighlightAvatarView:)]) {
        [self.delegate profileViewController:self didHighlightAvatarView:avatarView];
    }
    
    if (self.coverPhotoView.isSelected) [self.coverPhotoView setSelected:NO animated:YES];
}

- (void)didUnhighlightAvatarView:(DBProfileAvatarView *)avatarView {
    // Inform delegate that the profile picture was unhighlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didUnhighlightAvatarView:)]) {
        [self.delegate profileViewController:self didUnhighlightAvatarView:avatarView];
    }
}

#pragma mark - DBProfileScrollViewObserverDelegate

- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y += scrollView.contentInset.top;
    [self updateSubviewsWithContentOffset:contentOffset];
    [self handlePullToRefreshWithScrollView:scrollView];
    
    if (self.coverPhotoMimicsNavigationBar && !(self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend)) {
        if (contentOffset.y < CGRectGetHeight(self.coverPhotoView.frame) - _coverPhotoViewMimicNavigationBarConstraint.constant) {
            [scrollView insertSubview:self.avatarView aboveSubview:self.coverPhotoView];
        } else {
            [scrollView insertSubview:self.coverPhotoView aboveSubview:self.avatarView];
        }
    }
}

#pragma mark - Scroll Animatons

- (void)handlePullToRefreshWithScrollView:(UIScrollView *)scrollView {
    if (!self.allowsPullToRefresh) return;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y += scrollView.contentInset.top;
    if (scrollView.isDragging && contentOffset.y < 0) {
        [self startRefreshAnimations];
    } else if (!scrollView.isDragging && !self.refreshing && contentOffset.y < -[DBProfileViewControllerDefaults defaultPullToRefreshTriggerDistance]) {
        self.refreshing = YES;
        [self notifyDelegateOfPullToRefreshForContentControllerAtIndex:self.indexForSelectedContentController];
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

- (void)updateSubviewsWithContentOffset:(CGPoint)contentOffset {
    [self updateCoverPhotoViewWithContentOffset:contentOffset];
    [self updateAvatarViewWithContentOffset:contentOffset];
    [self updateTitleViewWithContentOffset:contentOffset];
}

- (void)updateCoverPhotoViewWithContentOffset:(CGPoint)contentOffset {
    if (self.isUpdating) return;
    
    CGFloat distance = (CGRectGetHeight(self.view.frame) * self.coverPhotoHeightMultiplier) - CGRectGetMaxY(self.customNavigationBar.frame);
    
    if (contentOffset.y <= 0) {
        if (self.coverPhotoOptions & DBProfileCoverPhotoOptionStretch) {
            _coverPhotoViewHeightConstraint.constant = -contentOffset.y;
        }
    }
    
    if (self.coverPhotoScrollAnimationStyle == DBProfileCoverPhotoScrollAnimationStyleBlur) {
        if (self.automaticallyAdjustsScrollViewInsets) distance += [self.topLayoutGuide length];
        CGFloat percent = MAX(MIN(1 - (distance - fabs(contentOffset.y))/distance, 1), 0);
        self.coverPhotoView.blurView.stage = round(percent * self.coverPhotoView.blurView.numberOfStages);
    }
}

- (void)updateAvatarViewWithContentOffset:(CGPoint)contentOffset {
    if (self.coverPhotoHidden || self.isUpdating) return;
    CGFloat coverPhotoOffset = CGRectGetHeight(self.coverPhotoView.frame);
    CGFloat coverPhotoOffsetPercent = 0;
    if (self.coverPhotoMimicsNavigationBar) {
        coverPhotoOffset -= CGRectGetMaxY(self.customNavigationBar.frame);
    }
    coverPhotoOffsetPercent = MIN(1, contentOffset.y / coverPhotoOffset);

    if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) {
        CGFloat alpha = 1 - coverPhotoOffsetPercent * 1.10;
        self.avatarView.alpha = self.detailsView.alpha = alpha;
    } else {
        CGFloat avatarScaleFactor = MIN(1 - coverPhotoOffsetPercent * 0.3, 1);
        CGAffineTransform avatarTransform = CGAffineTransformMakeScale(avatarScaleFactor, avatarScaleFactor);
        CGFloat avatarOffset = self.avatarInset.bottom + self.avatarInset.top;
        avatarTransform = CGAffineTransformTranslate(avatarTransform, 0, MAX(avatarOffset * coverPhotoOffsetPercent, 0));
        self.avatarView.transform = avatarTransform;
    }
}

- (void)updateTitleViewWithContentOffset:(CGPoint)contentOffset {
    if (!self.coverPhotoMimicsNavigationBar) return;
    CGFloat titleViewOffset = ((CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetMaxY(self.customNavigationBar.frame)) + CGRectGetHeight(self.segmentedControlView.frame));
    
    if (!(self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend)) {
        const CGFloat padding = 30.0;
        CGFloat avatarOffset = self.avatarInset.top - self.avatarInset.bottom;
        titleViewOffset += (CGRectGetHeight(self.avatarView.frame) + avatarOffset + padding);
    }
    
    CGFloat titleViewOffsetPercent = 1 - contentOffset.y / titleViewOffset;
    [self.customNavigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, 0) traitCollection:self.traitCollection];
}

#pragma mark - Auto Layout

- (void)updateCoverPhotoViewConstraints {
    if (_coverPhotoViewMimicNavigationBarConstraint &&
        _coverPhotoViewTopSuperviewConstraint &&
        _coverPhotoViewTopLayoutGuideConstraint) {
        
        _coverPhotoViewMimicNavigationBarConstraint.constant = DBProfileViewControllerNavigationBarHeightForTraitCollection(self.traitCollection);

        if (self.coverPhotoMimicsNavigationBar) {
            [NSLayoutConstraint activateConstraints:@[_coverPhotoViewMimicNavigationBarConstraint, _coverPhotoViewTopSuperviewConstraint]];
            [NSLayoutConstraint deactivateConstraints:@[_coverPhotoViewTopLayoutGuideConstraint]];
        } else {
            [NSLayoutConstraint activateConstraints:@[_coverPhotoViewTopLayoutGuideConstraint]];
            [NSLayoutConstraint deactivateConstraints:@[_coverPhotoViewMimicNavigationBarConstraint, _coverPhotoViewTopSuperviewConstraint]];
        }
    }
}

- (void)updateAvatarViewConstraints {
    if (_avatarViewLeftAlignmentConstraint && _avatarViewCenterAlignmentConstraint) {
        switch (self.avatarAlignment) {
            case DBProfileAvatarAlignmentLeft:
                [NSLayoutConstraint activateConstraints:@[_avatarViewLeftAlignmentConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[_avatarViewRightAlignmentConstraint, _avatarViewCenterAlignmentConstraint]];
                break;
            case DBProfileAvatarAlignmentRight:
                [NSLayoutConstraint activateConstraints:@[_avatarViewRightAlignmentConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[_avatarViewLeftAlignmentConstraint, _avatarViewCenterAlignmentConstraint]];
                break;
            case DBProfileAvatarAlignmentCenter:
                [NSLayoutConstraint activateConstraints:@[_avatarViewCenterAlignmentConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[_avatarViewLeftAlignmentConstraint, _avatarViewRightAlignmentConstraint]];
                break;
            default:
                break;
        }
    }
    
    CGFloat avatarSize;
    
    switch (self.avatarSize) {
        case DBProfileAvatarSizeNormal:
            avatarSize = DBProfileViewControllerAvatarSizeNormal;
            break;
        case DBProfileAvatarSizeLarge:
            avatarSize = DBProfileViewControllerAvatarSizeLarge;
            break;
        default:
            break;
    }
    
    _avatarViewRightAlignmentConstraint.constant = CGRectGetWidth(self.view.bounds) - avatarSize + self.avatarInset.left - self.avatarInset.right;
    _avatarViewLeftAlignmentConstraint.constant = self.avatarInset.left - self.avatarInset.right;
    _avatarViewSizeConstraint.constant = avatarSize;
    _avatarViewTopConstraint.constant = self.avatarInset.top - self.avatarInset.bottom;
}

- (void)setupCustomNavigationBarConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.customNavigationBar
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:[self topLayoutGuide]
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.customNavigationBar
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.customNavigationBar
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
}

- (void)setUpConstraintsForScrollView:(UIScrollView *)scrollView {
    NSAssert(scrollView, @"");
    
    if (self.segmentedControlView.superview) {
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    _detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [scrollView addConstraint:_detailsViewTopConstraint];
    
    if (self.coverPhotoView.superview) {
        [self setUpCoverPhotoViewConstraintsForScrollView:scrollView];
        
        [self.coverPhotoView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.coverPhotoView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0]];
        
        [self.coverPhotoView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.coverPhotoView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1
                                                                         constant:0]];
    }
    
    [self setUpAvatarViewConstraintsForScrollView:scrollView];
}

- (void)setUpCoverPhotoViewConstraintsForScrollView:(UIScrollView *)scrollView {
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:scrollView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1
                                                            constant:0]];
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:scrollView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1
                                                            constant:0]];
    
    _coverPhotoViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:self.coverPhotoHeightMultiplier
                                                                    constant:0];
    [self.view addConstraint:_coverPhotoViewHeightConstraint];
    
    _coverPhotoViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:scrollView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0];
    _coverPhotoViewTopConstraint.priority = UILayoutPriorityDefaultHigh;
    [scrollView addConstraints:@[_coverPhotoViewTopConstraint]];
    
    _coverPhotoViewMimicNavigationBarConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                  toItem:self.view attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:0];
    [self.view addConstraint:_coverPhotoViewMimicNavigationBarConstraint];
    
    _coverPhotoViewTopLayoutGuideConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationLessThanOrEqual
                                                                              toItem:[self topLayoutGuide]
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1
                                                                            constant:0];
    _coverPhotoViewTopLayoutGuideConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self.view addConstraint:_coverPhotoViewTopLayoutGuideConstraint];
    
    _coverPhotoViewTopSuperviewConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1
                                                                          constant:0];
    _coverPhotoViewTopSuperviewConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self.view addConstraint:_coverPhotoViewTopSuperviewConstraint];
    
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self.coverPhotoView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0]];
    }
}

- (void)setUpAvatarViewConstraintsForScrollView:(UIScrollView *)scrollView {
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.avatarView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1
                                                            constant:0]];
    
    _avatarViewSizeConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:DBProfileViewControllerAvatarSizeNormal];

    _avatarViewLeftAlignmentConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:scrollView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:0];
    _avatarViewLeftAlignmentConstraint.priority = UILayoutPriorityDefaultLow;

    _avatarViewRightAlignmentConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:scrollView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:0];
    _avatarViewRightAlignmentConstraint.priority = UILayoutPriorityDefaultLow;

    _avatarViewCenterAlignmentConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0];
    _avatarViewCenterAlignmentConstraint.priority = UILayoutPriorityDefaultLow;

    _avatarViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.detailsView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1
                                                             constant:0];
    
    [scrollView addConstraints:@[_avatarViewTopConstraint, _avatarViewSizeConstraint]];
}

@end

@implementation DBProfileViewController (Deprecated)

- (void)setCoverPhotoImage:(UIImage *)coverPhotoImage animated:(BOOL)animated {
    [self.coverPhotoView setCoverPhotoImage:coverPhotoImage animated:animated];
}

- (void)setAvatarImage:(UIImage *)avatarImage animated:(BOOL)animated {
    [self.avatarView setAvatarImage:avatarImage animated:animated];
}

@end
