//
//  DBProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import "DBProfileViewController.h"
#import "DBProfileDetailsView.h"
#import "DBProfilePictureView.h"
#import "DBProfileCoverPhotoView.h"
#import "DBProfileTitleView.h"
#import "DBProfileSegmentedControlView.h"
#import "DBProfileNavigationView.h"
#import "DBProfileContentViewController.h"

const CGFloat DBProfileViewControllerProfilePictureSizeNormal = 72.0;
const CGFloat DBProfileViewControllerProfilePictureSizeLarge = 82.0;
const CGFloat DBProfileViewControllerPullToRefreshDistance = 80;

static const CGFloat DBProfileViewControllerNavigationBarHeightRegular = 64.0;
static const CGFloat DBProfileViewControllerNavigationBarHeightCompact = 44.0;

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;
static NSString * const DBProfileViewControllerContentOffsetKeyPath = @"contentOffset";

@interface DBProfileViewController ()
{
    BOOL _hasAppeared;
    BOOL _shouldScrollToTop;
    CGPoint _contentOffset;
}

@property (nonatomic, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, strong) NSMutableArray *mutableContentViewControllers;
@property (nonatomic, strong) NSMutableArray *mutableContentViewControllerTitles;

@property (nonatomic, strong) NSCache *contentOffsetCache;

// Views
@property (nonatomic, strong) UIViewController *contentContainerViewController;
@property (nonatomic, strong) DBProfileSegmentedControlView *segmentedControlView;
@property (nonatomic, strong) DBProfileNavigationView *navigationView;

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

@end

@implementation DBProfileViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithContentViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles {
    self = [super init];
    if (self) {
        NSAssert([viewControllers count] == [titles count], @"content view controllers must have a title");
        [self.mutableContentViewControllers addObjectsFromArray:viewControllers];
        [self.mutableContentViewControllers addObjectsFromArray:titles];
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _segmentedControlView = [[DBProfileSegmentedControlView alloc] init];
    _detailsView = [[DBProfileDetailsView alloc] init];
    _profilePictureView = [[DBProfilePictureView alloc] init];
    _coverPhotoView = [[DBProfileCoverPhotoView alloc] init];
    _navigationView = [[DBProfileNavigationView alloc] init];
    _contentContainerViewController = [[UIViewController alloc] init];
    _profilePictureTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfilePictureTapGesture:)];
    _coverPhotoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverPhotoTapGesture:)];
    
    NSCache *contentOffsetCache = [[NSCache alloc] init];
    contentOffsetCache.name = @"DBProfileViewController.contentOffsetCache";
    contentOffsetCache.countLimit = 200;
    _contentOffsetCache = contentOffsetCache;
}

- (void)dealloc {
    if (self.visibleContentViewController) {
        UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
        [self endObservingContentOffsetForScrollView:scrollView];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    [self addChildViewController:self.contentContainerViewController];
    [self.view addSubview:self.contentContainerViewController.view];
    [self.contentContainerViewController didMoveToParentViewController:self];
    
    [self.view addSubview:self.navigationView];
    
    [self.contentContainerViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.navigationView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Auto Layout
    [self configureContentContainerViewControllerLayoutConstraints];
    [self configureNavigationViewControllerLayoutConstraints];
    
    // Gestures
    [self.coverPhotoView addGestureRecognizer:self.coverPhotoTapGestureRecognizer];
    self.coverPhotoView.userInteractionEnabled = YES;
    
    [self.profilePictureView addGestureRecognizer:self.profilePictureTapGestureRecognizer];
    self.profilePictureView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.segmentedControlView.segmentedControl addTarget:self
                                                   action:@selector(segmentChanged:)
                                         forControlEvents:UIControlEventValueChanged];
    
    [self configureDefaults];
    [self configureContentViewControllers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self numberOfContentViewControllers] > 0 && !_hasAppeared) {
        [self setVisibleContentViewControllerAtIndex:0];
    }
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    if (self.coverPhotoMimicsNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSAssert([self numberOfContentViewControllers] > 0, @"`DBProfileViewController` must have at least one content view controller.");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_hasAppeared) {
        [self configureContentViewControllers];
        _hasAppeared = YES;
    }
}

- (void)updateViewConstraints {
    [self updateCoverPhotoViewLayoutConstraints];
    [self updateProfilePictureViewLayoutConstraints];
    [super updateViewConstraints];
}

- (void)configureDefaults {
    self.coverPhotoStyle = DBProfileCoverPhotoStyleBackdrop;
    self.coverPhotoMimicsNavigationBar = NO;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeNormal;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, DBProfileViewControllerProfilePictureSizeNormal/2.0 - 10, 0);
    self.allowsPullToRefresh = YES;
    
    self.segmentedControlView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlView.segmentedControl.tintColor = [UIColor grayColor];
    
    self.coverPhotoView.clipsToBounds = YES;
    self.coverPhotoHeightMultiplier = 0.24;    
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Size Classes

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self configureContentViewControllers];
    
    switch (self.view.traitCollection.verticalSizeClass) {
        case UIUserInterfaceSizeClassCompact:
            self.coverPhotoViewBottomConstraint.constant = DBProfileViewControllerNavigationBarHeightCompact;
            break;
        default:
            self.coverPhotoViewBottomConstraint.constant = DBProfileViewControllerNavigationBarHeightRegular;
            break;
    }
    
    UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
    [scrollView setContentOffset:_contentOffset];
}

#pragma mark - Getters

- (NSArray *)contentViewControllers {
    return (NSArray *)self.mutableContentViewControllers;
}

- (NSArray *)contentViewControllerTitles {
    return (NSArray *)self.mutableContentViewControllerTitles;
}

- (NSMutableArray *)mutableContentViewControllers {
    if (!_mutableContentViewControllers) {
        _mutableContentViewControllers = [NSMutableArray array];
    }
    return _mutableContentViewControllers;
}

- (NSMutableArray *)mutableContentViewControllerTitles {
    if (!_mutableContentViewControllerTitles) {
        _mutableContentViewControllerTitles = [NSMutableArray array];
    }
    return _mutableContentViewControllerTitles;
}

#pragma mark - Setters

- (void)setCoverPhotoHeightMultiplier:(CGFloat)coverPhotoHeightMultiplier {
    NSAssert(coverPhotoHeightMultiplier > 0 && coverPhotoHeightMultiplier <= 1, @"`coverPhotoHeightMultiplier` must be greater than 0 or less that or equal to 1.");
    if (_coverPhotoHeightMultiplier == coverPhotoHeightMultiplier) return;
    _coverPhotoHeightMultiplier = coverPhotoHeightMultiplier;
    [self updateViewConstraints];
}

- (void)setCoverPhotoStyle:(DBProfileCoverPhotoStyle)coverPhotoStyle {
    if (self.coverPhotoStyle == DBProfileCoverPhotoStyleNone) {
        NSAssert(!self.coverPhotoMimicsNavigationBar || !self.allowsPullToRefresh, @"`DBProfileCoverPhotoStyleNone` is mutually exclusive with `coverPhotoMimicsNavigationBar` and `allowsPullToRefresh`");
    }
    if (_coverPhotoStyle == coverPhotoStyle) return;
    _coverPhotoStyle = coverPhotoStyle;
    [self updateViewConstraints];
}

- (void)setProfilePictureInset:(UIEdgeInsets)profilePictureInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_profilePictureInset, profilePictureInset)) return;
    _profilePictureInset = profilePictureInset;
    [self updateViewConstraints];
}

- (void)setProfilePictureAlignment:(DBProfilePictureAlignment)profilePictureAlignment {
    if (_profilePictureAlignment == profilePictureAlignment) return;
    _profilePictureAlignment = profilePictureAlignment;
    [self updateViewConstraints];
}

- (void)setProfilePictureSize:(DBProfilePictureSize)profilePictureSize {
    if (_profilePictureSize == profilePictureSize) return;
    _profilePictureSize = profilePictureSize;
    [self updateViewConstraints];
}

- (void)setCoverPhotoMimicsNavigationBar:(BOOL)coverPhotoMimicsNavigationBar {
    if (coverPhotoMimicsNavigationBar) {
        //NSAssert(self.coverPhotoStyle != DBProfileCoverPhotoStyleNone, @"`DBProfileCoverPhotoStyleNone` is mutually exclusive with `coverPhotoMimicsNavigationBar` and `allowsPullToRefresh`");
    }
    if (coverPhotoMimicsNavigationBar && self.automaticallyAdjustsScrollViewInsets) {
        NSLog(@"Warning: `automaticallyAdjustsScrollViewInsets` should be set to NO when using coverPhotoMimicsNavigationBar");
    }
    _coverPhotoMimicsNavigationBar = coverPhotoMimicsNavigationBar;
    self.navigationView.hidden = !coverPhotoMimicsNavigationBar;
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh {
    if (allowsPullToRefresh) {
        //NSAssert(self.coverPhotoStyle != DBProfileCoverPhotoStyleNone, @"`DBProfileCoverPhotoStyleNone` is mutually exclusive with `coverPhotoMimicsNavigationBar` and `allowsPullToRefresh`");
    }
    _allowsPullToRefresh = allowsPullToRefresh;
}

- (void)setDetailsView:(DBProfileDetailsView *)detailsView {
    NSAssert(detailsView, @"detailsView cannot be nil");
    _detailsView = detailsView;
    [self configureVisibleViewController:self.visibleContentViewController];
}

#pragma mark - Actions

- (void)segmentChanged:(id)sender {
    NSInteger selectedSegmentIndex = [self.segmentedControlView.segmentedControl selectedSegmentIndex];
    [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex];
    [self updateViewConstraints];
}

- (void)handleProfilePictureTapGesture:(UITapGestureRecognizer *)sender {
    [self notifyDelegateOfProfilePictureSelection:self.profilePictureView.imageView];
}

- (void)handleCoverPhotoTapGesture:(UITapGestureRecognizer *)sender {
    [self notifyDelegateOfCoverPhotoSelection:self.coverPhotoView.imageView];
}

#pragma mark - Titles

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationView.titleView.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    self.navigationView.titleView.subtitleLabel.text = subtitle;
}

#pragma mark - Configuring Cover Photo

- (void)setCoverPhoto:(UIImage *)coverPhoto animated:(BOOL)animated {
    self.coverPhotoView.imageView.image = coverPhoto;
    
    if (animated) {
        self.coverPhotoView.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.coverPhotoView.imageView.alpha = 1;
        }];
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

#pragma mark - Managing Content View Controllers

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController withTitle:(NSString *)title {
    NSAssert([title length] > 0, @"content view controllers must have a title");
    NSAssert(viewController, @"content view controller cannot be nil");
    
    [self.mutableContentViewControllers addObject:viewController];
    [self.mutableContentViewControllerTitles addObject:title];
    
    [self configureContentViewControllers];
    [self scrollVisibleContentViewControllerToTop];
}

- (void)insertContentViewController:(UIViewController<DBProfileContentViewController> *)viewController withTitle:(NSString *)title atIndex:(NSUInteger)index {
    NSAssert([title length] > 0, @"content view controllers must have a title");
    NSAssert(viewController, @"content view controller cannot be nil");
    
    [self.mutableContentViewControllers insertObject:viewController atIndex:index];
    [self.mutableContentViewControllerTitles insertObject:title atIndex:index];
    
    [self configureContentViewControllers];
    [self scrollVisibleContentViewControllerToTop];
}

- (void)removeContentViewControllerAtIndex:(NSUInteger)index {
    if (index < [self numberOfContentViewControllers]) {
        [self.mutableContentViewControllers removeObjectAtIndex:index];
        [self.mutableContentViewControllerTitles removeObjectAtIndex:index];
        [self configureContentViewControllers];
        [self scrollVisibleContentViewControllerToTop];
    }
}

- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index {
    UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
    if (self.visibleContentViewController) {
        [self endObservingContentOffsetForScrollView:scrollView];
    }
    
    CGFloat topInset = CGRectGetMaxY(self.navigationView.frame) + CGRectGetHeight(self.segmentedControlView.frame);
    _shouldScrollToTop = scrollView.contentOffset.y < topInset;
    _contentOffset = scrollView.contentOffset;
    
    // Cache content offset of disappearing scroll view
    [self cacheContentOffset:scrollView.contentOffset forKey:[self titleForVisibleContentViewController]];
    
    // Remove previous view controller from container
    [self removeViewControllerFromContainer:self.visibleContentViewController];
    
    UIViewController<DBProfileContentViewController> *visibleContentViewController = self.contentViewControllers[index];
    
    // Add visible view controller to container
    [self addViewControllerToContainer:visibleContentViewController];

    _visibleContentViewController = visibleContentViewController;

    [self.segmentedControlView.segmentedControl setSelectedSegmentIndex:index];
    [self configureVisibleViewController:visibleContentViewController];
}

#pragma mark - Getting Content View Controller Information

- (NSUInteger)visibleContentViewControllerIndex {
    return [self.segmentedControlView.segmentedControl selectedSegmentIndex];
}

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index {
    return [self.mutableContentViewControllerTitles objectAtIndex:index];
}

- (NSUInteger)indexForContentViewControllerWithTitle:(NSString *)title {
    return [self.mutableContentViewControllerTitles indexOfObject:title];
}

- (NSString *)titleForVisibleContentViewController {
    return self.visibleContentViewController.title;
}

- (NSInteger)numberOfContentViewControllers {
    return [self.contentViewControllers count];
}

#pragma mark - Refreshing Data

- (void)endRefreshing {
    self.refreshing = NO;
    [self endRefreshAnimations];
}

- (void)startRefreshAnimations {
    [self.coverPhotoView startRefreshing];
}

- (void)endRefreshAnimations {
    [self.coverPhotoView endRefreshing];
}

#pragma mark - Delegate

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

#pragma mark - Helpers

- (void)cacheContentOffset:(CGPoint)contentOffset forKey:(NSString *)key {
    [self.contentOffsetCache setObject:[NSValue valueWithCGPoint:contentOffset] forKey:key];
}

- (CGPoint)cachedContentOffsetForKey:(NSString *)key {
    return [[self.contentOffsetCache objectForKey:key] CGPointValue];
}

- (void)scrollVisibleContentViewControllerToTop {
    UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top)];
}

- (void)resetContentOffsetForScrollView:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = -(CGRectGetMaxY(self.navigationView.frame) + CGRectGetHeight(self.segmentedControlView.frame));
    [scrollView setContentOffset:contentOffset];
}

- (void)configureVisibleViewController:(UIViewController<DBProfileContentViewController> *)visibleViewController {
    UIScrollView *scrollView = [visibleViewController contentScrollView];
    
    [self.coverPhotoView removeFromSuperview];
    [self.detailsView removeFromSuperview];
    [self.profilePictureView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    
    [self.coverPhotoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.profilePictureView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControlView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [scrollView addSubview:self.detailsView];
    [scrollView addSubview:self.coverPhotoView];
    [scrollView addSubview:self.profilePictureView];
    
    // Check if we need to install the segmented control
    if ([self numberOfContentViewControllers] > 1) {
        [scrollView addSubview:self.segmentedControlView];
        [self configureSegmentedControlViewLayoutConstraintsWithScrollView:scrollView];
    } else {
        self.segmentedControlView.frame = CGRectZero;
    }
    
    [self configureCoverPhotoViewLayoutConstraintsWithScrollView:scrollView];
    [self configureDetailsViewLayoutConstraintsWithScrollView:scrollView];
    [self configureProfilePictureViewLayoutConstraintsWithScrollView:scrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self updateViewConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:scrollView];
    
    // Begin observing contentOffset
    [self beginObservingContentOffsetForScrollView:scrollView];
    
    // Reset the content offset
    if (!_hasAppeared) {
        [self scrollVisibleContentViewControllerToTop];
    } else if (!_shouldScrollToTop) {
        [self resetContentOffsetForScrollView:scrollView];
        
        // TOOD: Check if content size is too small (not enough rows to fill the screen)
    
        // Restore content offset for scroll view from cache
        CGPoint contentOffset = [self cachedContentOffsetForKey:[self titleForVisibleContentViewController]];
        if (contentOffset.y > scrollView.contentOffset.y && !self.automaticallyAdjustsScrollViewInsets) {
            [scrollView setContentOffset:contentOffset];
        }
    } else {
        [scrollView setContentOffset:_contentOffset];
    }
    [scrollView flashScrollIndicators];
}

- (void)configureContentViewControllers {
    NSInteger selectedSegmentIndex = self.segmentedControlView.segmentedControl.selectedSegmentIndex;
    
    [self.segmentedControlView.segmentedControl removeAllSegments];
    
    NSInteger numberOfSegments = [self numberOfContentViewControllers];
    CGFloat segmentWidth = (CGRectGetWidth(self.view.bounds) * 0.9) / numberOfSegments;
    
    NSInteger index = 0;
    for (NSString *title in self.contentViewControllerTitles) {
        [self.segmentedControlView.segmentedControl insertSegmentWithTitle:title atIndex:index animated:NO];
        [self.segmentedControlView.segmentedControl setWidth:segmentWidth forSegmentAtIndex:index];
        index++;
    }
    
    // Set the selected segment index
    if (numberOfSegments > 0) {
        if (selectedSegmentIndex == UISegmentedControlNoSegment) {
            [self setVisibleContentViewControllerAtIndex:0];
        } else {
            [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex];
        }
    }
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.coverPhotoView.frame);
    
    UIEdgeInsets contentInset = scrollView.contentInset;
    if (self.coverPhotoStyle == DBProfileCoverPhotoStyleBackdrop) topInset -= CGRectGetHeight(self.detailsView.frame);
    contentInset.top = (self.automaticallyAdjustsScrollViewInsets) ? topInset + [self.topLayoutGuide length] : topInset;
    
    scrollView.contentInset = contentInset;
    
    // Cover photo inset
    self.coverPhotoViewTopConstraint.constant = -topInset;
    
    // Details view inset
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleBackdrop:
            topInset -= (CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetHeight(self.detailsView.frame));
            [scrollView insertSubview:self.detailsView aboveSubview:self.coverPhotoView];
            break;
        default:
            topInset -= CGRectGetHeight(self.coverPhotoView.frame);
            break;
    }
    self.detailsViewTopConstraint.constant = -topInset;
}

- (void)addViewControllerToContainer:(UIViewController *)viewController {
    [self.contentContainerViewController addChildViewController:viewController];
    [self.contentContainerViewController.view addSubview:viewController.view];
    viewController.view.frame = self.contentContainerViewController.view.frame;
    [viewController didMoveToParentViewController:self];
}

- (void)removeViewControllerFromContainer:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
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
        
        if (self.coverPhotoMimicsNavigationBar) {
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
    
    BOOL shouldEndRefreshAnimations = !self.refreshing && self.coverPhotoView.activityIndicator.isAnimating;
    if (!scrollView.isDragging && contentOffset.y >= 0 && shouldEndRefreshAnimations) {
        [self endRefreshAnimations];
    }
}

#pragma mark - Updating Subviews On Scroll

- (void)updateSubviewsWithContentOffset:(CGPoint)contentOffset {
    [self updateCoverPhotoViewWithContentOffset:contentOffset];
    [self updateProfilePictureViewWithContentOffset:contentOffset];
    [self updateTitleViewWithContentOffset:contentOffset];
}

- (void)updateCoverPhotoViewWithContentOffset:(CGPoint)contentOffset {
    if (contentOffset.y <= 0) {
        switch (self.coverPhotoStyle) {
            case DBProfileCoverPhotoStyleStretch:
            case DBProfileCoverPhotoStyleBackdrop:
                self.coverPhotoViewHeightConstraint.constant = -contentOffset.y;
                break;
            default:
                break;
        }
        self.coverPhotoView.blurView.alpha = fabs(contentOffset.y) / 10;
    } else {
        self.coverPhotoView.blurView.alpha = fabs(contentOffset.y) / 80;
    }
}

- (void)updateProfilePictureViewWithContentOffset:(CGPoint)contentOffset {
    CGFloat coverPhotoOffset = CGRectGetHeight(self.coverPhotoView.frame);
    CGFloat coverPhotoOffsetPercent = 0;
    if (self.coverPhotoMimicsNavigationBar) {
        coverPhotoOffset -= CGRectGetMaxY(self.navigationView.frame);
    }
    coverPhotoOffsetPercent = MIN(1, contentOffset.y / coverPhotoOffset);

    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleBackdrop: {
            CGFloat alpha = 1 - coverPhotoOffsetPercent * 1.10;
            self.profilePictureView.alpha = self.detailsView.alpha = alpha;
            break;
        }
        default: {
            CGFloat profilePictureScale = MIN(1 - coverPhotoOffsetPercent * 0.3, 1);
            
            CGAffineTransform transform = CGAffineTransformMakeScale(profilePictureScale, profilePictureScale);
            CGFloat profilePictureOffset = self.profilePictureInset.bottom + self.profilePictureInset.top;
            transform = CGAffineTransformTranslate(transform, 0, MAX(profilePictureOffset * coverPhotoOffsetPercent, 0));

            self.profilePictureView.transform = transform;
            break;
        }
    }
}

- (void)updateTitleViewWithContentOffset:(CGPoint)contentOffset {
    if (!self.coverPhotoMimicsNavigationBar) return;
    CGFloat titleViewOffset = ((CGRectGetHeight(self.coverPhotoView.frame) - CGRectGetMaxY(self.navigationView.frame)) + CGRectGetHeight(self.segmentedControlView.frame));
    
    if (self.coverPhotoStyle != DBProfileCoverPhotoStyleBackdrop) {
        CGFloat profilePictureOffset = self.profilePictureInset.top - self.profilePictureInset.bottom;
        titleViewOffset += (CGRectGetHeight(self.profilePictureView.frame) + profilePictureOffset + 30);
    }
    
    CGFloat titleViewOffsetPercent = 1 - contentOffset.y / titleViewOffset;
    
    if (self.view.traitCollection.verticalSizeClass == UIBarMetricsCompact) {
        [self.navigationView.navigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, -4)
                                                                forBarMetrics:UIBarMetricsCompact];
    } else {
        [self.navigationView.navigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, 0)
                                                            forBarMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - Updating Constraints

- (void)updateCoverPhotoViewLayoutConstraints {
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleNone:
            // FIXME: Setting the coverPhotoHeightMultiplier to 0 will erase what it was before.
            self.coverPhotoView.hidden = YES;
            break;
        default:
            self.coverPhotoView.hidden = NO;
            break;
    }
    
    if (self.coverPhotoViewBottomConstraint &&
        self.coverPhotoViewTopSuperviewConstraint &&
        self.coverPhotoViewTopLayoutGuideConstraint) {
        
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

#pragma mark - Configuring Constraints

- (void)configureNavigationViewControllerLayoutConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)configureContentContainerViewControllerLayoutConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureSegmentedControlViewLayoutConstraintsWithScrollView:(UIScrollView *)scrollView  {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:[self topLayoutGuide] attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.coverPhotoView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureDetailsViewLayoutConstraintsWithScrollView:(UIScrollView *)scrollView  {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [scrollView addConstraint:self.detailsViewTopConstraint];
}

- (void)configureCoverPhotoViewLayoutConstraintsWithScrollView:(UIScrollView *)scrollView {
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
}

- (void)configureProfilePictureViewLayoutConstraintsWithScrollView:(UIScrollView *)scrollView {
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
