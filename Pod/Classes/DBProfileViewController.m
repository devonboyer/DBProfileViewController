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
#import "DBProfileContentViewController.h"

// Constants
static const CGFloat DBProfileViewControllerCoverPhotoDefaultHeight = 667.0; // iPhone 6
static const CGFloat DBProfileViewControllerPullToRefreshDistance = 80;
static const CGFloat DBProfileViewControllerProfilePictureSizeDefault = 72.0;
static const CGFloat DBProfileViewControllerProfilePictureSizeLarge = 82.0;
static const CGFloat DBProfileViewControllerProfilePictureLeftRightMargin = 15.0;
static const CGFloat DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight = 64.0;

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;

@interface DBProfileViewController ()
{
    BOOL _hasAppeared;
    
    BOOL _shouldScrollToTop;
    CGPoint _contentOffset;
}

@property (nonatomic, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, strong) NSMutableArray *mutableContentViewControllers;
@property (nonatomic, strong) NSMutableArray *mutableContentViewControllerTitles;

// Views
@property (nonatomic, strong) UIViewController *contentContainerViewController;
@property (nonatomic, strong) DBProfileSegmentedControlView *segmentedControlView;
@property (nonatomic, strong) DBProfileTitleView *titleView;

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *segmentedControlViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *detailsViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewRightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewWidthConstraint;

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
    _titleView = [[DBProfileTitleView alloc] init];
    
    _contentContainerViewController = [[UIViewController alloc] init];

    _profilePictureTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProfilePicture)];
    _coverPhotoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCoverPhoto)];
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
    
    self.titleView.frame = CGRectMake(0, 0, 200, 50);
    self.navigationItem.titleView = self.titleView;
    
    [self addChildViewController:self.contentContainerViewController];
    [self.view addSubview:self.contentContainerViewController.view];
    [self.contentContainerViewController didMoveToParentViewController:self];

    [self.contentContainerViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Auto Layout
    [self configureContentContainerViewControllerLayoutConstraints];
    
    // Gestures
    [self.coverPhotoView addGestureRecognizer:self.coverPhotoTapGestureRecognizer];
    self.coverPhotoView.userInteractionEnabled = YES;
    
    [self.profilePictureView addGestureRecognizer:self.profilePictureTapGestureRecognizer];
    self.profilePictureView.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Actions
    [self.segmentedControlView.segmentedControl addTarget:self action:@selector(changeContent) forControlEvents:UIControlEventValueChanged];
    
    // Configuration
    [self configureDefaultAppearance];
    [self configureContentViewControllers];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self numberOfContentViewControllers] > 0 && !_hasAppeared) {
        [self setVisibleContentViewControllerAtIndex:0];
    }
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = [[UIImage alloc] init];
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.translucent = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_hasAppeared) {
        [self configureContentViewControllers];
        _hasAppeared = YES;
    }
}

#pragma mark - Overrides

- (void)updateViewConstraints {
    
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleNone:
            self.coverPhotoViewHeightConstraint.constant = 0;
            self.coverPhotoView.hidden = YES;
            break;
        case DBProfileCoverPhotoStyleDefault:
        case DBProfileCoverPhotoStyleStretch:
        case DBProfileCoverPhotoStyleBackdrop:
            self.coverPhotoViewHeightConstraint.constant = DBProfileViewControllerCoverPhotoDefaultHeight;
            self.coverPhotoView.hidden = NO;
            break;
        default:
            break;
    }
        
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
        case DBProfilePictureSizeDefault:
            self.profilePictureViewWidthConstraint.constant = DBProfileViewControllerProfilePictureSizeDefault;
            self.profilePictureViewRightConstraint.constant = CGRectGetWidth(self.view.bounds) - DBProfileViewControllerProfilePictureSizeDefault - DBProfileViewControllerProfilePictureLeftRightMargin;
            break;
        case DBProfilePictureSizeLarge:
            self.profilePictureViewWidthConstraint.constant = DBProfileViewControllerProfilePictureSizeLarge;
            self.profilePictureViewRightConstraint.constant = CGRectGetWidth(self.view.bounds) - DBProfileViewControllerProfilePictureSizeLarge - DBProfileViewControllerProfilePictureLeftRightMargin;
            break;
        default:
            break;
    }
    
    // Profile picture inset
    self.profilePictureViewLeftConstraint.constant = self.profilePictureInset.left - self.profilePictureInset.right;
    self.profilePictureViewTopConstraint.constant = self.profilePictureInset.top - self.profilePictureInset.bottom;
    
    [super updateViewConstraints];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self configureContentViewControllers];
}

#pragma makr - Getters

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

- (CGFloat)segmentWidth {
    NSInteger numberOfSegments = [self numberOfContentViewControllers];
    return (CGRectGetWidth(self.view.bounds) * 0.8) / numberOfSegments;
}

#pragma mark - Setters

- (void)setCoverPhotoStyle:(DBProfileCoverPhotoStyle)coverPhotoStyle {
    if (coverPhotoStyle == DBProfileCoverPhotoStyleNone) {
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
        NSAssert(self.coverPhotoStyle != DBProfileCoverPhotoStyleNone, @"`DBProfileCoverPhotoStyleNone` is mutually exclusive with `coverPhotoMimicsNavigationBar` and `allowsPullToRefresh`");
    }
    _coverPhotoMimicsNavigationBar = coverPhotoMimicsNavigationBar;
    self.titleView.hidden = !coverPhotoMimicsNavigationBar;
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh {
    if (allowsPullToRefresh) {
        NSAssert(self.coverPhotoStyle != DBProfileCoverPhotoStyleNone, @"`DBProfileCoverPhotoStyleNone` is mutually exclusive with `coverPhotoMimicsNavigationBar` and `allowsPullToRefresh`");
    }
    _allowsPullToRefresh = allowsPullToRefresh;
}

- (void)setDetailsView:(DBProfileDetailsView *)detailsView {
    NSAssert(detailsView, @"detailsView cannot be nil");
    _detailsView = detailsView;
    [self configureVisibleViewController:self.visibleContentViewController];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    self.coverPhotoStyle = DBProfileCoverPhotoStyleBackdrop;
    self.coverPhotoMimicsNavigationBar = YES;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.profilePictureInset = UIEdgeInsetsMake(0, DBProfileViewControllerProfilePictureLeftRightMargin, DBProfileViewControllerProfilePictureSizeDefault/2.0 - 10, 0);
    self.allowsPullToRefresh = YES;
    
    self.segmentedControlView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlView.segmentedControl.tintColor = [UIColor grayColor];
    
    self.coverPhotoView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverPhotoView.clipsToBounds = YES;
}

#pragma mark - Actions

- (void)changeContent {
    NSInteger selectedSegmentIndex = [self.segmentedControlView.segmentedControl selectedSegmentIndex];
    [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex];
}

- (void)didTapProfilePicture {
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectProfilePicture:)]) {
        [self.delegate profileViewController:self didSelectProfilePicture:self.profilePictureView.imageView];
    }
}

- (void)didTapCoverPhoto {
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectProfilePicture:)]) {
        [self.delegate profileViewController:self didSelectProfilePicture:self.coverPhotoView.imageView];
    }
}

#pragma mark - Titles

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.titleView.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    self.titleView.subtitleLabel.text = subtitle;
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
}

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController withTitle:(NSString *)title atIndex:(NSUInteger)index {
    NSAssert([title length] > 0, @"content view controllers must have a title");
    NSAssert(viewController, @"content view controller cannot be nil");
    
    [self.mutableContentViewControllers insertObject:viewController atIndex:index];
    [self.mutableContentViewControllerTitles insertObject:title atIndex:index];
    
    [self configureContentViewControllers];
}

- (void)removeContentViewControllerAtIndex:(NSUInteger)index {
    if (index < [self numberOfContentViewControllers]) {
        [self.mutableContentViewControllers removeObjectAtIndex:index];
        [self.mutableContentViewControllerTitles removeObjectAtIndex:index];
    
        [self configureContentViewControllers];
    }
}

- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index {
    UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
    if (self.visibleContentViewController) {
        [self endObservingContentOffsetForScrollView:scrollView];
    }
    
    // Remove previous view controller from container
    [self removeViewControllerFromContainer:self.visibleContentViewController];
    
    UIViewController<DBProfileContentViewController> *visibleContentViewController = self.contentViewControllers[index];
    
    // Add visible view controller to container
    [self addViewControllerToContainer:visibleContentViewController];
    
    _shouldScrollToTop = self.segmentedControlViewTopConstraint.constant == 0;
    _contentOffset = scrollView.contentOffset;

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

- (NSInteger)numberOfContentViewControllers {
    return [self.contentViewControllers count];
}

#pragma mark - Refreshing Data

- (void)startRefreshing {
    self.refreshing = YES;
    if ([self.delegate respondsToSelector:@selector(profileViewControllerDidPullToRefresh:)]) {
        [self.delegate profileViewControllerDidPullToRefresh:self];
    }
}

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

#pragma mark - Managing Content Offset

// Sets content offset so that scroll view is scrolled to the top of the view
- (void)resetContentOffsetForScrollView:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = -(DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight + CGRectGetHeight(self.segmentedControlView.frame));
    [scrollView setContentOffset:contentOffset];
    [scrollView flashScrollIndicators];
}

#pragma mark - Private

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
    [scrollView addSubview:self.segmentedControlView];
    [scrollView addSubview:self.coverPhotoView];
    [scrollView addSubview:self.profilePictureView];

    [self configureCoverPhotoViewLayoutConstraintsWithScrollView:scrollView];
    [self configureDetailsViewLayoutConstraintsWithScrollView:scrollView];
    [self configureProfilePictureViewLayoutConstraintsWithScrollView:scrollView];
    [self configureSegmentedControlViewLayoutConstraintsWithScrollView:scrollView];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self updateViewConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:scrollView];
    
    // Begin observing contentOffset
    [self beginObservingContentOffsetForScrollView:scrollView];
    
    // Reset the content offset
    if (!_hasAppeared) {
        [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top)];
    } else if (!_shouldScrollToTop) {
        [self resetContentOffsetForScrollView:scrollView];
    } else {
        [scrollView setContentOffset:_contentOffset];
    }
}

- (void)configureContentViewControllers {
    
    // Keep track of the previously selected segment index
    NSInteger selectedSegmentIndex = self.segmentedControlView.segmentedControl.selectedSegmentIndex;
    
    [self.segmentedControlView.segmentedControl removeAllSegments];
    
    NSInteger index = 0;
    for (NSString *title in self.contentViewControllerTitles) {
        [self.segmentedControlView.segmentedControl insertSegmentWithTitle:title atIndex:index animated:NO];
        [self.segmentedControlView.segmentedControl setWidth:[self segmentWidth] forSegmentAtIndex:index];
        index++;
    }
    
    // Set the selected segment index
    if ([self numberOfContentViewControllers] > 0) {
        if (selectedSegmentIndex == UISegmentedControlNoSegment) {
            [self setVisibleContentViewControllerAtIndex:0];
        } else {
            [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex];
        }
    }
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailsView.frame) + self.coverPhotoViewHeightConstraint.constant;
    
    // Scroll view inset
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleBackdrop:
            topInset -= CGRectGetHeight(self.detailsView.frame);
            break;
        default:
            break;
    }
    
    contentInset.top = self.automaticallyAdjustsScrollViewInsets ? topInset + [self.topLayoutGuide length] : topInset;
    scrollView.contentInset = contentInset;

    // Cover photo inset
    self.coverPhotoViewTopConstraint.constant = -topInset;
    
    // Details view inset
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleBackdrop:
            topInset -= (self.coverPhotoViewHeightConstraint.constant - CGRectGetHeight(self.detailsView.frame));
            [scrollView bringSubviewToFront:self.detailsView];
            break;
        default:
            topInset -= self.coverPhotoViewHeightConstraint.constant;
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
                     forKeyPath:@"contentOffset"
                        options:0
                        context:&DBProfileViewControllerContentOffsetKVOContext];
    }
}


- (void)endObservingContentOffsetForScrollView:(UIScrollView *)scrollView {
    if (scrollView) {
        [scrollView removeObserver:self
                        forKeyPath:@"contentOffset"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"] && context == DBProfileViewControllerContentOffsetKVOContext) {
        UIScrollView *scrollView = (UIScrollView *)object;
        [self configureSubviewsWithScrollView:scrollView];
    }
}

#pragma mark -

- (void)configureSubviewsWithScrollView:(UIScrollView *)scrollView {
    CGFloat top = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    // Cover photo animations
    CGFloat delta = -top;
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleStretch:
        case DBProfileCoverPhotoStyleBackdrop:
            if (top < 0) {
                if (self.automaticallyAdjustsScrollViewInsets) {
                    self.coverPhotoViewTopConstraint.constant = -(scrollView.contentInset.top - [self.topLayoutGuide length]) - delta;
                } else {
                    self.coverPhotoViewTopConstraint.constant = -scrollView.contentInset.top - delta;
                }
                self.coverPhotoViewHeightConstraint.constant = MAX(DBProfileViewControllerCoverPhotoDefaultHeight, DBProfileViewControllerCoverPhotoDefaultHeight + delta);
            } else {
                [self adjustContentInsetForScrollView:scrollView];
            }
            break;
        default:
            [self adjustContentInsetForScrollView:scrollView];
            break;
    }
    
    // Cover photo blur effect
    if (top < 0) {
        switch (self.coverPhotoStyle) {
            case DBProfileCoverPhotoStyleBackdrop:
                self.detailsViewTopConstraint.constant = -(CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailsView.frame)) - delta;
                break;
            default:
                break;
        }
        
        CGFloat pullToRefreshPercent = fabs(top) / 10;
        self.coverPhotoView.blurView.alpha = pullToRefreshPercent;
    } else {
        CGFloat pullToRefreshPercent = fabs(top) / 60;
        self.coverPhotoView.blurView.alpha = pullToRefreshPercent;
    }
    
    // Sticky cover photo to "mimic" navigation bar
    if (self.coverPhotoMimicsNavigationBar) {
        CGFloat height = self.coverPhotoViewHeightConstraint.constant - DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight;
        if (self.automaticallyAdjustsScrollViewInsets) {
            height += [self.topLayoutGuide length];
        }
        if (top > height) {
            CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.segmentedControlView.frame) + self.coverPhotoViewHeightConstraint.constant;
            
            switch (self.coverPhotoStyle) {
                case DBProfileCoverPhotoStyleBackdrop:
                    topInset -= CGRectGetHeight(self.detailsView.frame);
                    break;
                default:
                    break;
            }
            
            self.coverPhotoViewTopConstraint.constant = MAX(-topInset + (top - height), -topInset);
            
            [scrollView insertSubview:self.profilePictureView belowSubview:self.coverPhotoView];
        } else {
            [scrollView insertSubview:self.coverPhotoView belowSubview:self.profilePictureView];
        }
    }
    
    // Sticky segmented control
    CGFloat segmentedControlOffset = CGRectGetHeight(self.detailsView.frame) + self.coverPhotoViewHeightConstraint.constant;
    
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleBackdrop:
            segmentedControlOffset -= CGRectGetHeight(self.detailsView.frame);
            break;
        default:
            break;
    }
    
    if (self.coverPhotoMimicsNavigationBar) {
        segmentedControlOffset -= DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight;
        if (self.automaticallyAdjustsScrollViewInsets) {
            segmentedControlOffset += [self.topLayoutGuide length];
        }
    }
    
    self.segmentedControlViewTopConstraint.constant = (top > segmentedControlOffset) ? top - segmentedControlOffset : 0;
    _shouldScrollToTop = top > segmentedControlOffset;
    
    if (self.allowsPullToRefresh) {
        // Pull-To-Refresh animations
        if (scrollView.isDragging && top < 0) {
            [self startRefreshAnimations];
        } else if (!scrollView.isDragging && !self.refreshing && top < -DBProfileViewControllerPullToRefreshDistance) {
            [self startRefreshing];
        } else if (!scrollView.isDragging && !self.refreshing && self.coverPhotoView.activityIndicator.isAnimating) {
            [self endRefreshAnimations];
        }
    }
    
    // Profile picture animations
    CGFloat coverPhotoOffset = self.coverPhotoViewHeightConstraint.constant;
    CGFloat coverPhotoOffsetPercent = 0;
    if (self.coverPhotoMimicsNavigationBar) {
        coverPhotoOffset -= DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight;
    }
    if (self.automaticallyAdjustsScrollViewInsets) {
        coverPhotoOffsetPercent = MIN(1, top / (coverPhotoOffset - [self.topLayoutGuide length]));
    } else {
        coverPhotoOffsetPercent = MIN(1, top / coverPhotoOffset);
    }
    
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleBackdrop:
            self.profilePictureView.alpha = 1 - coverPhotoOffsetPercent * 1.6;
            self.detailsView.alpha = 1 - coverPhotoOffsetPercent * 1.6;
            break;
        default: {
            CGFloat profilePictureScale = MIN(1 - coverPhotoOffsetPercent * 0.3, 1);
            self.profilePictureView.transform = CGAffineTransformMakeScale(profilePictureScale, profilePictureScale);
            
            CGFloat profilePictureOffset = self.profilePictureInset.bottom + self.profilePictureInset.top;
            self.profilePictureViewTopConstraint.constant = MAX(MIN(-profilePictureOffset + (profilePictureOffset * coverPhotoOffsetPercent * 0.7), -profilePictureOffset * 0.3), -profilePictureOffset);
            break;
        }
    }
    
    // Title view animations
    if (self.coverPhotoMimicsNavigationBar) {
        CGFloat titleViewOffset = ((self.coverPhotoViewHeightConstraint.constant - DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight) + CGRectGetHeight(self.segmentedControlView.frame));
        // + (DBProfileViewControllerProfilePictureSizeDefault - self.profilePictureInset.top + self.profilePictureInset.bottom)) + 4;
        CGFloat titleViewOffsetPercent = 1 - top / titleViewOffset;
        self.titleView.hidden = top < DBProfileViewControllerCoverPhotoMimicsNavigationBarHeight;
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, 0)
                                                                      forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)configureCoverPhotoViewConstraintsWithContentOffset:(CGPoint)contentOffset {}
- (void)configureProfilePictureViewConstraintsWithContentOffset:(CGPoint)contentOffset { }
- (void)configureSegmentedControlViewConstraintsWithContentOffset:(CGPoint)contentOffset { }
- (void)configureTitleViewConstraintsWithContentOffset:(CGPoint)contentOffset { }

#pragma mark - Auto Layout

- (void)configureContentContainerViewControllerLayoutConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureSegmentedControlViewLayoutConstraintsWithScrollView:(UIScrollView *)scrollView  {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.segmentedControlViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [scrollView addConstraint:self.segmentedControlViewTopConstraint];
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
    
    self.coverPhotoViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    
    self.coverPhotoViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [scrollView addConstraints:@[self.coverPhotoViewHeightConstraint, self.coverPhotoViewTopConstraint]];
}

- (void)configureProfilePictureViewLayoutConstraintsWithScrollView:(UIScrollView *)scrollView {
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.profilePictureView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.profilePictureViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:DBProfileViewControllerCoverPhotoDefaultHeight];

    self.profilePictureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.profilePictureViewLeftConstraint.priority = UILayoutPriorityDefaultLow;

    self.profilePictureViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.profilePictureViewRightConstraint.priority = UILayoutPriorityDefaultLow;

    self.profilePictureViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    self.profilePictureViewCenterXConstraint.priority = UILayoutPriorityDefaultLow;

    self.profilePictureViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [scrollView addConstraints:@[self.profilePictureViewWidthConstraint, self.profilePictureViewLeftConstraint, self.profilePictureViewRightConstraint, self.profilePictureViewCenterXConstraint, self.profilePictureViewTopConstraint]];
    
    [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint, self.profilePictureViewRightConstraint, self.profilePictureViewCenterXConstraint]];
}

@end
