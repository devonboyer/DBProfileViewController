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
#import "DBProfileDetailsView.h"
#import "DBProfilePictureView.h"
#import "DBProfileCoverPhotoView.h"
#import "DBProfileTitleView.h"
#import "DBProfileSegmentedControlView.h"
#import "DBProfileNavigationView.h"
#import "DBProfileContentPresenting.h"
#import "DBProfileImageEffects.h"
#import "NSBundle+DBProfileViewController.h"

const CGFloat DBProfileViewControllerProfilePictureSizeNormal = 72.0;
const CGFloat DBProfileViewControllerProfilePictureSizeLarge = 92.0;

static const CGFloat DBProfileViewControllerPullToRefreshDistance = 80.0;
static const CGFloat DBProfileViewControllerNavigationBarHeightRegular = 64.0;
static const CGFloat DBProfileViewControllerNavigationBarHeightCompact = 44.0;

static NSString * const DBProfileViewControllerContentOffsetCacheName = @"DBProfileViewController.contentOffsetCache";
static NSString * const DBProfileViewControllerBlurredImageCacheName = @"DBProfileViewController.blurredImageCache";

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;
static NSString * const DBProfileViewControllerContentOffsetKeyPath = @"contentOffset";

static void * DBProfileViewControllerUpdatesAnimationContext = &DBProfileViewControllerUpdatesAnimationContext;

@interface DBProfileViewController ()
{
    BOOL _shouldScrollToTop;
    CGPoint _sharedContentOffset;
    UIEdgeInsets _cachedContentInset;
}

@property (nonatomic, getter=isUpdating) BOOL updating;

@property (nonatomic, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, strong) NSMutableArray *contentViewControllers;
@property (nonatomic, strong) NSCache *contentOffsetCache;
@property (nonatomic, strong) NSCache *blurredImageCache;

// Views
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) DBProfileNavigationView *navigationView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *detailsViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewRightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewTopLayoutGuideConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewTopSuperviewConstraint;

// Gestures
@property (nonatomic, strong) UITapGestureRecognizer *coverPhotoTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *profilePictureTapGestureRecognizer;

// New!!
@property (nonatomic, assign) NSUInteger indexForSelectedSegment;

@property (nonatomic, assign) CGFloat oldDetailsViewHeight;

@end

@implementation DBProfileViewController

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _segmentedControlView = [[DBProfileSegmentedControlView alloc] init];
    _detailsView = [[DBProfileDetailsView alloc] init];
    _profilePictureView = [[DBProfilePictureView alloc] init];
    _coverPhotoView = [[DBProfileCoverPhotoView alloc] init];
    _navigationView = [[DBProfileNavigationView alloc] init];
    _profilePictureTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfilePictureTapGesture:)];
    _coverPhotoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverPhotoTapGesture:)];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    NSCache *contentOffsetCache = [[NSCache alloc] init];
    contentOffsetCache.name = DBProfileViewControllerContentOffsetCacheName;
    contentOffsetCache.countLimit = 10;
    _contentOffsetCache = contentOffsetCache;
    
    NSCache *blurredImageCache = [[NSCache alloc] init];
    blurredImageCache.name = DBProfileViewControllerBlurredImageCacheName;
    blurredImageCache.countLimit = 30;
    _blurredImageCache = blurredImageCache;
    
    self.containerView = [[UIView alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.visibleContentViewController) {
        UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
        [self endObservingContentOffsetForScrollView:scrollView];
    }
    
    [self.blurredImageCache removeAllObjects];
    self.blurredImageCache = nil;
    
    [self.contentOffsetCache removeAllObjects];
    self.contentOffsetCache = nil;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    self.containerView.frame = self.view.frame;
    [self.view addSubview:self.containerView];
    
    [self.view addSubview:self.navigationView];

    [self.navigationView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Auto Layout
    [self configureNavigationViewLayoutConstraints];
    
    // Gestures
    [self.coverPhotoView addGestureRecognizer:self.coverPhotoTapGestureRecognizer];
    self.coverPhotoView.userInteractionEnabled = YES;
    
    [self.profilePictureView addGestureRecognizer:self.profilePictureTapGestureRecognizer];
    self.profilePictureView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [self.segmentedControlView.segmentedControl addTarget:self
                                                   action:@selector(segmentChanged:)
                                         forControlEvents:UIControlEventValueChanged];
    
    [self configureDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    // Scroll displayed content controller to top
    if ([self.contentViewControllers count]) {
        DBProfileContentViewController *displayedViewController = [self.contentViewControllers objectAtIndex:self.indexForSelectedSegment];
        [self scrollContentViewControllerToTop:displayedViewController];
    }
    
    if (self.coverPhotoMimicsNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    }
}

- (void)updateViewConstraints {
    [self updateCoverPhotoViewLayoutConstraints];
    [self updateProfilePictureViewLayoutConstraints];
    [super updateViewConstraints];
}

- (void)configureDefaults {
    // Cover photo
    self.coverPhotoOptions = DBProfileCoverPhotoOptionStretch;
    self.coverPhotoHidden = NO;
    self.coverPhotoMimicsNavigationBar = YES;
    self.coverPhotoHeightMultiplier = 0.2;
    // Profile picture
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeNormal;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, DBProfileViewControllerProfilePictureSizeNormal/2.0 - 10, 0);
    self.allowsPullToRefresh = YES;
    // Navigation
    self.navigationView.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"db-profile-chevron" inBundle:[NSBundle db_resourcesBundle] compatibleWithTraitCollection:self.traitCollection] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Size Classes

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
    _cachedContentInset = scrollView.contentInset;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // The scroll view content inset needs to be recalculated for the new size class
    UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self.view setNeedsUpdateConstraints];
    
    [self adjustContentInsetForScrollView:scrollView];
    
    // Preserve the relative contentOffset during size class changes
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y -= MAX(scrollView.contentInset.top - _cachedContentInset.top, 0);
    scrollView.contentOffset = contentOffset;
}

#pragma mark - Getters

- (NSMutableArray *)contentViewControllers {
    if (!_contentViewControllers) {
        _contentViewControllers = [NSMutableArray array];
    }
    return _contentViewControllers;
}

#pragma mark - Setters

- (void)setCoverPhotoHeightMultiplier:(CGFloat)coverPhotoHeightMultiplier {
    NSAssert(coverPhotoHeightMultiplier > 0 && coverPhotoHeightMultiplier <= 1, @"`coverPhotoHeightMultiplier` must be greater than 0 or less than or equal to 1.");
    if (_coverPhotoHeightMultiplier == coverPhotoHeightMultiplier) return;
    _coverPhotoHeightMultiplier = coverPhotoHeightMultiplier;
    [self.view setNeedsUpdateConstraints];
}

- (void)setCoverPhotoOptions:(DBProfileCoverPhotoOptions)coverPhotoOptions {
    if (_coverPhotoOptions == coverPhotoOptions) return;
    _coverPhotoOptions = coverPhotoOptions;
    [self.view setNeedsUpdateConstraints];
}

- (void)setCoverPhotoHidden:(BOOL)coverPhotoHidden {
    if (_coverPhotoHidden == coverPhotoHidden) return;
    _coverPhotoHidden = coverPhotoHidden;
    [self.view setNeedsUpdateConstraints];
}

- (void)setProfilePictureInset:(UIEdgeInsets)profilePictureInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_profilePictureInset, profilePictureInset)) return;
    _profilePictureInset = profilePictureInset;
    [self.view setNeedsUpdateConstraints];
}

- (void)setProfilePictureAlignment:(DBProfilePictureAlignment)profilePictureAlignment {
    if (_profilePictureAlignment == profilePictureAlignment) return;
    _profilePictureAlignment = profilePictureAlignment;
    [self.view setNeedsUpdateConstraints];
}

- (void)setProfilePictureSize:(DBProfilePictureSize)profilePictureSize {
    if (_profilePictureSize == profilePictureSize) return;
    _profilePictureSize = profilePictureSize;
    [self.view setNeedsUpdateConstraints];
}

- (void)setCoverPhotoMimicsNavigationBar:(BOOL)coverPhotoMimicsNavigationBar {
    _coverPhotoMimicsNavigationBar = coverPhotoMimicsNavigationBar;
    self.navigationView.hidden = !coverPhotoMimicsNavigationBar;
    self.coverPhotoView.overlayView.hidden = !coverPhotoMimicsNavigationBar;
    [self.view setNeedsUpdateConstraints];
}

- (void)setDetailsView:(UIView *)detailsView {
    NSAssert(detailsView, @"detailsView cannot be nil");
    _detailsView = detailsView;
    //[self reloadData];
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh {
    if (_allowsPullToRefresh == allowsPullToRefresh) return;
    _allowsPullToRefresh = allowsPullToRefresh;
    //[self reloadData];
}

#pragma mark - Actions

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentChanged:(id)sender {
    NSInteger selectedSegmentIndex = [self.segmentedControlView.segmentedControl selectedSegmentIndex];
    
    DBProfileContentViewController *viewControllerToDisplay = [self.contentViewControllers objectAtIndex:self.indexForSelectedSegment];
    UIScrollView *scrollView = [viewControllerToDisplay contentScrollView];
    [self endObservingContentOffsetForScrollView:scrollView];
    
    self.indexForSelectedSegment = selectedSegmentIndex;
    [self updateViewConstraints];
    
    [self notifyDelegateOfContentControllerSelectionAtIndex:self.indexForSelectedSegment];
}

- (void)handleProfilePictureTapGesture:(UITapGestureRecognizer *)sender {
    [self notifyDelegateOfProfilePictureSelection:self.profilePictureView.imageView];
}

- (void)handleCoverPhotoTapGesture:(UITapGestureRecognizer *)sender {
    [self notifyDelegateOfCoverPhotoSelection:self.coverPhotoView.imageView];
}

#pragma mark - Configuring Cover Photo

- (void)setCoverPhoto:(UIImage *)coverPhoto animated:(BOOL)animated {
    
    UIImage *croppedImage = [DBProfileImageEffects imageByCroppingImage:coverPhoto withSize:self.coverPhotoView.frame.size];
    
    self.coverPhotoView.imageView.image = croppedImage;
    
    if (animated) {
        self.coverPhotoView.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.coverPhotoView.imageView.alpha = 1;
        }];
    }
    
    if (croppedImage) {
        // FIXME: Is there a way we can cancel this in viewWillDissappear: if necessary?
        __weak DBProfileViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf fillBlurredImageCacheWithImage:croppedImage];
        });
    }
}

#pragma mark - Blurring

- (UIImage *)blurredImageAt:(CGFloat)percent {
    NSNumber *keyNumber = @(round(percent * 20));
    return [self.blurredImageCache objectForKey:keyNumber];
}

- (void)fillBlurredImageCacheWithImage:(UIImage *)image {
    NSAssert(![NSThread isMainThread], @"fillBlurredImageCacheWithImage: should not be called on main thread");
    CGFloat maxBlurRadius = 30;
    [self.blurredImageCache removeAllObjects];
    for (int i = 0; i <= 20; i++) {
        CGFloat radius = maxBlurRadius * i/20;
        [self.blurredImageCache setObject:[DBProfileImageEffects imageByApplyingBlurToImage:image withRadius:radius] forKey:@(i)];
    }
}

#pragma mark - Configuring Profile Picture

- (void)setProfilePicture:(UIImage *)profilePicture animated:(BOOL)animated {
    self.profilePictureView.imageView.image = profilePicture;

    if (animated) {
        self.profilePictureView.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.profilePictureView.imageView.alpha = 1;
        }];
    }
}

#pragma mark - Inserting, Deleting, and Moving Segments

- (void)beginUpdates {
    self.updating = YES;
    
    self.oldDetailsViewHeight = [self.detailsView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [self.view invalidateIntrinsicContentSize];

    [UIView beginAnimations:@"DBProfileViewController.updates" context:&DBProfileViewControllerUpdatesAnimationContext];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.25];
}

- (void)endUpdates {
    [self setIndexForSelectedSegment:self.indexForSelectedSegment];

    CGFloat oldHeight = self.oldDetailsViewHeight;
    CGFloat newHeight = [self.detailsView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    if (round(oldHeight) != round(newHeight)) {
        DBProfileContentViewController *viewController = [self.contentViewControllers objectAtIndex:self.indexForSelectedSegment];
        UIScrollView *scrollView = [viewController contentScrollView];
        
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y += (oldHeight - newHeight);
        scrollView.contentOffset = contentOffset;
    }
    
    [self.view layoutIfNeeded];
    [self updateViewConstraints];

    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    if (context == DBProfileViewControllerUpdatesAnimationContext) {
        self.updating = NO;
    }
}

#pragma mark - Reloading Data

- (void)reloadData {
    NSInteger numberOfSegments = [self.dataSource numberOfContentControllersForProfileViewController:self];
    
    if ([self.contentViewControllers count] > 0) {
        [self hideContentViewController:[self.contentViewControllers objectAtIndex:self.indexForSelectedSegment]];
    }
    
    [self.contentViewControllers removeAllObjects];
    [self.segmentedControlView.segmentedControl removeAllSegments];
    
    for (NSInteger i = 0; i < numberOfSegments; i++) {
        // Reload content view controllers
        DBProfileContentViewController *contentViewController = [self.dataSource profileViewController:self contentViewControllerAtIndex:i];
        [self.contentViewControllers addObject:contentViewController];
        
        // Reload segmented control
        NSString *title = [self.dataSource profileViewController:self titleForContentControllerAtIndex:i];
        [self.segmentedControlView.segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
    }
    
    // Display selected content view controller
    [self setIndexForSelectedSegment:self.indexForSelectedSegment];
}

- (void)setIndexForSelectedSegment:(NSUInteger)indexForSelectedSegment {
    if (![self.contentViewControllers count]) return;
    
    DBProfileContentViewController *viewControllerToHide = [self.contentViewControllers objectAtIndex:_indexForSelectedSegment];
    if (viewControllerToHide) [self hideContentViewController:viewControllerToHide];
    
    _indexForSelectedSegment = indexForSelectedSegment;
    [self.segmentedControlView.segmentedControl setSelectedSegmentIndex:indexForSelectedSegment];
    
    DBProfileContentViewController *viewControllerToDisplay = [self.contentViewControllers objectAtIndex:indexForSelectedSegment];
    if (viewControllerToDisplay) [self displayContentViewController:viewControllerToDisplay];
    
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    
    // Update titles
    self.navigationView.titleView.titleLabel.text = self.title;
    self.navigationView.titleView.subtitleLabel.text = [self.dataSource profileViewController:self subtitleForContentControllerAtIndex:self.indexForSelectedSegment];
}


#pragma mark - Configuring Pull-To-Refresh

- (void)endRefreshing {
    self.refreshing = NO;
    [self endRefreshAnimations];
}

- (void)startRefreshAnimations {
    [self.activityIndicator startAnimating];
}

- (void)endRefreshAnimations {
    [self.activityIndicator stopAnimating];
}

#pragma mark - Delegate

- (void)notifyDelegateOfContentControllerSelectionAtIndex:(NSInteger)index {
    if ([self respondsToSelector:@selector(profileViewController:didSelectContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didSelectContentControllerAtIndex:index];
    }
}

- (void)notifyDelegateOfProfilePictureSelection:(UIImageView *)imageView {
    if ([self respondsToSelector:@selector(profileViewController:didSelectProfilePicture:)]) {
        [self.delegate profileViewController:self didSelectProfilePicture:imageView];
    }
}

- (void)notifyDelegateOfCoverPhotoSelection:(UIImageView *)imageView {
    if ([self respondsToSelector:@selector(profileViewController:didSelectCoverPhoto:)]) {
        [self.delegate profileViewController:self didSelectCoverPhoto:imageView];
    }
}

- (void)notifyDelegateOfPullToRefresh {
    if ([self respondsToSelector:@selector(profileViewControllerDidPullToRefresh:)]) {
        [self.delegate profileViewControllerDidPullToRefresh:self];
    }
}

#pragma mark - Container View Controller

- (CGRect)frameForContentViewController {
    return self.containerView.frame;
}

- (void)displayContentViewController:(DBProfileContentViewController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");
    [self addChildViewController:viewController];
    viewController.view.frame = [self frameForContentViewController];
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.navigationView];
    [self buildContentViewController:viewController];
}

- (void)hideContentViewController:(DBProfileContentViewController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");
    
    UIScrollView *scrollView = [viewController contentScrollView];
    
    // Cache content offset
    CGFloat topInset = CGRectGetMaxY(self.navigationView.frame) + CGRectGetHeight(self.segmentedControlView.frame);
    if (self.automaticallyAdjustsScrollViewInsets) topInset = CGRectGetHeight(self.segmentedControlView.frame);
    _shouldScrollToTop = scrollView.contentOffset.y >= -topInset;
    _sharedContentOffset = scrollView.contentOffset;
    
    [self cacheContentOffset:scrollView.contentOffset forKey:viewController.title];
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)buildContentViewController:(DBProfileContentViewController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");

    UIScrollView *scrollView = [viewController contentScrollView];
    
    [self.coverPhotoView removeFromSuperview];
    [self.detailsView removeFromSuperview];
    [self.profilePictureView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    [self.activityIndicator removeFromSuperview];
    
    self.coverPhotoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.profilePictureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControlView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [scrollView addSubview:self.detailsView];
    
    NSInteger numberOfSegments = [self.dataSource numberOfContentControllersForProfileViewController:self];
    
    // Segmented control ?
    if (numberOfSegments > 1) {
        [scrollView addSubview:self.segmentedControlView];
        [self configureSegmentedControlViewLayoutConstraintsWithSuperview:scrollView];
    } else {
        self.segmentedControlView.frame = CGRectZero;
    }

    // Cover photo ?
    if (!self.coverPhotoHidden) {
        [scrollView addSubview:self.coverPhotoView];
        [self configureCoverPhotoViewLayoutConstraintsWithSuperview:scrollView];
        
        // Pull-to-refresh ?
        if (self.allowsPullToRefresh) {
            [self.coverPhotoView addSubview:self.activityIndicator];
            [self configureActivityIndicatorLayoutConstraints];
        }
        
        if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) {
            [scrollView insertSubview:self.detailsView aboveSubview:self.coverPhotoView];
        }
    } else {
        self.coverPhotoView.frame = CGRectZero;
    }
    
    [scrollView addSubview:self.profilePictureView];
    
    [self configureDetailsViewLayoutConstraintsWithSuperview:scrollView];
    [self configureProfilePictureViewLayoutConstraintsWithSuperview:scrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self.view setNeedsUpdateConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:scrollView];
    
    // Begin observing contentOffset
    [self beginObservingContentOffsetForScrollView:scrollView];
    
    // Reset the content offset
    if (_shouldScrollToTop) {
        [self resetContentOffsetForScrollView:scrollView];
        
        // Restore content offset for scroll view from cache
        CGPoint cachedContentOffset = [self cachedContentOffsetForKey:viewController.title];
        if (cachedContentOffset.y > scrollView.contentOffset.y && !CGPointEqualToPoint(CGPointZero, cachedContentOffset)) {
            [scrollView setContentOffset:cachedContentOffset];
        }
    } else {
        [scrollView setContentOffset:_sharedContentOffset];
    }
}

#pragma mark - Managing Content Offset

- (void)cacheContentOffset:(CGPoint)contentOffset forKey:(NSString *)key {
    [self.contentOffsetCache setObject:[NSValue valueWithCGPoint:contentOffset] forKey:key];
}

- (CGPoint)cachedContentOffsetForKey:(NSString *)key {
    return [[self.contentOffsetCache objectForKey:key] CGPointValue];
}

- (void)scrollContentViewControllerToTop:(DBProfileContentViewController *)viewController {
    UIScrollView *scrollView = [viewController contentScrollView];
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top)];
}

- (void)resetContentOffsetForScrollView:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = -(CGRectGetMaxY(self.navigationView.frame) + CGRectGetHeight(self.segmentedControlView.frame));
    [scrollView setContentOffset:contentOffset];
}

#pragma mark - Managing Content Inset

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.coverPhotoView.frame);
    
    // Calculate scroll view top inset
    UIEdgeInsets contentInset = scrollView.contentInset;
    if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) topInset -= CGRectGetHeight(self.detailsView.frame);
    contentInset.top = (self.automaticallyAdjustsScrollViewInsets) ? topInset + [self.topLayoutGuide length] : topInset;
    
    // Calculate scroll view bottom inset
    CGFloat minimumContentSizeHeight = CGRectGetHeight(scrollView.frame) - CGRectGetHeight(self.segmentedControlView.frame);
    
    switch (self.view.traitCollection.verticalSizeClass) {
        case UIUserInterfaceSizeClassCompact:
            minimumContentSizeHeight -= DBProfileViewControllerNavigationBarHeightCompact;
            break;
        default:
            minimumContentSizeHeight -= DBProfileViewControllerNavigationBarHeightRegular;
            break;
    }
    
    if (scrollView.contentSize.height < minimumContentSizeHeight) {
        contentInset.bottom = minimumContentSizeHeight - scrollView.contentSize.height;
    }
    
    scrollView.contentInset = contentInset;
    
    // Calculate cover photo inset
    self.coverPhotoViewTopConstraint.constant = -topInset;
    
    // Calculate details view inset
    if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) {
        topInset -= (CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetHeight(self.detailsView.frame));
        [scrollView insertSubview:self.detailsView aboveSubview:self.coverPhotoView];
    } else {
        topInset -= CGRectGetHeight(self.coverPhotoView.frame);
    }
    self.detailsViewTopConstraint.constant = -topInset;
}

#pragma mark - KVO

- (void)beginObservingContentOffsetForScrollView:(UIScrollView *)scrollView {
    if (scrollView) {
        [scrollView addObserver:self
                     forKeyPath:DBProfileViewControllerContentOffsetKeyPath
                        options:0
                        context:&DBProfileViewControllerContentOffsetKVOContext];
    }
}


- (void)endObservingContentOffsetForScrollView:(UIScrollView *)scrollView {
    if (scrollView) {
        [scrollView removeObserver:self
                        forKeyPath:DBProfileViewControllerContentOffsetKeyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:DBProfileViewControllerContentOffsetKeyPath] && context == DBProfileViewControllerContentOffsetKVOContext) {
        UIScrollView *scrollView = (UIScrollView *)object;
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y += scrollView.contentInset.top;
        [self updateSubviewsWithContentOffset:contentOffset];
        [self handlePullToRefreshWithScrollView:scrollView];
        
        if (self.coverPhotoMimicsNavigationBar && !(self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend)) {
            if (contentOffset.y < CGRectGetHeight(self.coverPhotoView.frame) - self.coverPhotoViewBottomConstraint.constant) {
                [scrollView insertSubview:self.profilePictureView aboveSubview:self.coverPhotoView];
            } else {
                [scrollView insertSubview:self.coverPhotoView aboveSubview:self.profilePictureView];
            }
        }
    }
}

#pragma mark - Pull To Refresh

- (void)handlePullToRefreshWithScrollView:(UIScrollView *)scrollView {
    if (!self.allowsPullToRefresh) return;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y += scrollView.contentInset.top;
    if (scrollView.isDragging && contentOffset.y < 0) {
        [self startRefreshAnimations];
    } else if (!scrollView.isDragging && !self.refreshing && contentOffset.y < -DBProfileViewControllerPullToRefreshDistance) {
        self.refreshing = YES;
        [self notifyDelegateOfPullToRefresh];
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

#pragma mark - Updating Subviews On Scroll

- (void)updateSubviewsWithContentOffset:(CGPoint)contentOffset {
    [self updateCoverPhotoViewWithContentOffset:contentOffset];
    [self updateProfilePictureViewWithContentOffset:contentOffset];
    [self updateTitleViewWithContentOffset:contentOffset];
}

- (void)updateCoverPhotoViewWithContentOffset:(CGPoint)contentOffset {
    if (self.isUpdating) return;
    
    CGFloat distance = CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetMaxY(self.navigationView.frame);
    
    if (contentOffset.y <= 0) {
        if (self.coverPhotoOptions & DBProfileCoverPhotoOptionStretch) {
            self.coverPhotoViewHeightConstraint.constant = -contentOffset.y;
        }
        distance *= 0.5;
    }
    
    if (self.automaticallyAdjustsScrollViewInsets) distance += [self.topLayoutGuide length];
    
    CGFloat percent = MAX(MIN(1 - (distance - fabs(contentOffset.y))/distance, 1), 0);
    UIImage *blurredImage = [self blurredImageAt:percent];
    if (blurredImage) self.coverPhotoView.imageView.image = blurredImage;
}

- (void)updateProfilePictureViewWithContentOffset:(CGPoint)contentOffset {
    if (self.coverPhotoHidden || self.isUpdating) return;
    CGFloat coverPhotoOffset = CGRectGetHeight(self.coverPhotoView.frame);
    CGFloat coverPhotoOffsetPercent = 0;
    if (self.coverPhotoMimicsNavigationBar) {
        coverPhotoOffset -= CGRectGetMaxY(self.navigationView.frame);
    }
    coverPhotoOffsetPercent = MIN(1, contentOffset.y / coverPhotoOffset);

    if (self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend) {
        CGFloat alpha = 1 - coverPhotoOffsetPercent * 1.10;
        self.profilePictureView.alpha = self.detailsView.alpha = alpha;
        
    } else {
        CGFloat profilePictureScale = MIN(1 - coverPhotoOffsetPercent * 0.3, 1);
        CGAffineTransform transform = CGAffineTransformMakeScale(profilePictureScale, profilePictureScale);
        CGFloat profilePictureOffset = self.profilePictureInset.bottom + self.profilePictureInset.top;
        transform = CGAffineTransformTranslate(transform, 0, MAX(profilePictureOffset * coverPhotoOffsetPercent, 0));
        
        self.profilePictureView.transform = transform;
    }
}

- (void)updateTitleViewWithContentOffset:(CGPoint)contentOffset {
    if (!self.coverPhotoMimicsNavigationBar) return;
    CGFloat titleViewOffset = ((CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetMaxY(self.navigationView.frame)) + CGRectGetHeight(self.segmentedControlView.frame));
    
    if (!(self.coverPhotoOptions & DBProfileCoverPhotoOptionExtend)) {
        // FIXME: Adding arbitrary padding to titleViewOffset
        CGFloat profilePictureOffset = self.profilePictureInset.top - self.profilePictureInset.bottom;
        titleViewOffset += (CGRectGetHeight(self.profilePictureView.frame) + profilePictureOffset + 30);
    }
    
    CGFloat titleViewOffsetPercent = 1 - contentOffset.y / titleViewOffset;
    
    if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self.navigationView.navigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, -4)
                                                                forBarMetrics:UIBarMetricsCompact];
    } else {
        [self.navigationView.navigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, 0)
                                                            forBarMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - Notifications

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self.blurredImageCache removeAllObjects];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    UIImage *coverPhoto = self.coverPhotoView.imageView.image;
    if (coverPhoto) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fillBlurredImageCacheWithImage:coverPhoto];
        });
    }
}

#pragma mark - Updating Constraints

- (void)updateCoverPhotoViewLayoutConstraints {    
    if (self.coverPhotoViewBottomConstraint &&
        self.coverPhotoViewTopSuperviewConstraint &&
        self.coverPhotoViewTopLayoutGuideConstraint) {
        
        switch (self.view.traitCollection.verticalSizeClass) {
            case UIUserInterfaceSizeClassCompact:
                self.coverPhotoViewBottomConstraint.constant = DBProfileViewControllerNavigationBarHeightCompact;
                break;
            default:
                self.coverPhotoViewBottomConstraint.constant = DBProfileViewControllerNavigationBarHeightRegular;
                break;
        }
        
        if (self.coverPhotoMimicsNavigationBar) {
            [NSLayoutConstraint activateConstraints:@[self.coverPhotoViewBottomConstraint, self.coverPhotoViewTopSuperviewConstraint]];
            [NSLayoutConstraint deactivateConstraints:@[self.coverPhotoViewTopLayoutGuideConstraint]];
        } else {
            [NSLayoutConstraint activateConstraints:@[self.coverPhotoViewTopLayoutGuideConstraint]];
            [NSLayoutConstraint deactivateConstraints:@[self.coverPhotoViewBottomConstraint, self.coverPhotoViewTopSuperviewConstraint]];
        }
    }
}

- (void)updateProfilePictureViewLayoutConstraints {
    if (self.profilePictureViewLeftConstraint && self.profilePictureViewCenterXConstraint) {
        switch (self.profilePictureAlignment) {
            case DBProfilePictureAlignmentLeft:
                [NSLayoutConstraint activateConstraints:@[self.profilePictureViewLeftConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewRightConstraint, self.profilePictureViewCenterXConstraint]];
                break;
            case DBProfilePictureAlignmentRight:
                [NSLayoutConstraint activateConstraints:@[self.profilePictureViewRightConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint, self.profilePictureViewCenterXConstraint]];
                break;
            case DBProfilePictureAlignmentCenter:
                [NSLayoutConstraint activateConstraints:@[self.profilePictureViewCenterXConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint, self.profilePictureViewRightConstraint]];
                break;
            default:
                break;
        }
    }
    
    switch (self.profilePictureSize) {
        case DBProfilePictureSizeNormal:
            self.profilePictureViewWidthConstraint.constant = DBProfileViewControllerProfilePictureSizeNormal;
            self.profilePictureViewRightConstraint.constant = CGRectGetWidth(self.view.bounds) - DBProfileViewControllerProfilePictureSizeNormal + self.profilePictureInset.left - self.profilePictureInset.right;
            break;
        case DBProfilePictureSizeLarge:
            self.profilePictureViewWidthConstraint.constant = DBProfileViewControllerProfilePictureSizeLarge;
            self.profilePictureViewRightConstraint.constant = CGRectGetWidth(self.view.bounds) - DBProfileViewControllerProfilePictureSizeLarge + self.profilePictureInset.left - self.profilePictureInset.right;
            break;
        default:
            break;
    }
    
    self.profilePictureViewLeftConstraint.constant = self.profilePictureInset.left - self.profilePictureInset.right;
    self.profilePictureViewTopConstraint.constant = self.profilePictureInset.top - self.profilePictureInset.bottom;
}

#pragma mark - Auto Layout

- (void)configureNavigationViewLayoutConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)configureActivityIndicatorLayoutConstraints {
    [self.coverPhotoView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.coverPhotoView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.coverPhotoView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.coverPhotoView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)configureSegmentedControlViewLayoutConstraintsWithSuperview:(UIView *)scrollView  {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureDetailsViewLayoutConstraintsWithSuperview:(UIView *)scrollView  {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [scrollView addConstraint:self.detailsViewTopConstraint];
}

- (void)configureCoverPhotoViewLayoutConstraintsWithSuperview:(UIView *)scrollView {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.coverPhotoViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:self.coverPhotoHeightMultiplier constant:0];
    [self.view addConstraint:self.coverPhotoViewHeightConstraint];
    
    self.coverPhotoViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    self.coverPhotoViewTopConstraint.priority = UILayoutPriorityDefaultHigh;
    [scrollView addConstraints:@[self.coverPhotoViewTopConstraint]];
    
    self.coverPhotoViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:64];
    [self.view addConstraint:self.coverPhotoViewBottomConstraint];
    
    self.coverPhotoViewTopLayoutGuideConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationLessThanOrEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    self.coverPhotoViewTopLayoutGuideConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self.view addConstraint:self.coverPhotoViewTopLayoutGuideConstraint];
    
    self.coverPhotoViewTopSuperviewConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    self.coverPhotoViewTopSuperviewConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self.view addConstraint:self.coverPhotoViewTopSuperviewConstraint];
    
    if ([self.contentViewControllers count] > 1) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.coverPhotoView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
}

- (void)configureProfilePictureViewLayoutConstraintsWithSuperview:(UIView *)scrollView {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.profilePictureView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    // Customizing size
    self.profilePictureViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:DBProfileViewControllerProfilePictureSizeNormal];

    // Customizing horizontal alignment
    self.profilePictureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.profilePictureViewLeftConstraint.priority = UILayoutPriorityDefaultLow;

    self.profilePictureViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.profilePictureViewRightConstraint.priority = UILayoutPriorityDefaultLow;

    self.profilePictureViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    self.profilePictureViewCenterXConstraint.priority = UILayoutPriorityDefaultLow;

    // Customizing vertical alignment
    self.profilePictureViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [scrollView addConstraints:@[self.profilePictureViewWidthConstraint, self.profilePictureViewLeftConstraint, self.profilePictureViewRightConstraint, self.profilePictureViewCenterXConstraint, self.profilePictureViewTopConstraint]];
    
    [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint, self.profilePictureViewRightConstraint, self.profilePictureViewCenterXConstraint]];
}

@end

@implementation DBProfileViewController (Deprecated)

- (instancetype)initWithContentViewControllers:(NSArray *)contentViewControllers {
    self = [super init];
    if (self) {
        [self.contentViewControllers addObjectsFromArray:contentViewControllers];
        [self commonInit];
    }
    return self;
}

- (void)addContentViewControllers:(NSArray *)contentViewControllers { }

- (void)addContentViewController:(DBProfileContentViewController *)contentViewController { }

- (void)insertContentViewController:(DBProfileContentViewController *)contentViewController atIndex:(NSUInteger)index { }

- (void)removeContentViewControllerAtIndex:(NSUInteger)index { }

- (DBProfileContentViewController *)visibleContentViewController {
    return [self.contentViewControllers objectAtIndex:self.indexForSelectedSegment];
}

@end
