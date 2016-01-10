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
static const CGFloat DBProfileViewControllerCoverPhotoDefaultHeight = 120.0;
static const CGFloat DBProfileViewControllerPullToRefreshDistance = 80;
static const CGFloat DBProfileViewControllerProfilePictureSizeDefault = 72.0;
static const CGFloat DBProfileViewControllerProfilePictureSizeLarge = 82.0;
static const CGFloat DBProfileViewControllerProfilePictureLeftRightMargin = 15.0;

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;

@interface DBProfileViewController ()
{
    BOOL _hasAppeared;
    CGFloat _navigationBarHeight; // cache height when using coverPhotoMimicsNavigationBar
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
    
    [self resetNavigationBarHeight];
    
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

- (void)updateViewConstraints {
    
    switch (self.coverPhotoStyle) {
        case DBProfileCoverPhotoStyleNone:
            self.coverPhotoViewHeightConstraint.constant = 0;
            self.coverPhotoView.hidden = YES;
            break;
        case DBProfileCoverPhotoStyleDefault:
        case DBProfileCoverPhotoStyleStretch:
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
    [self resetNavigationBarHeight];
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
    _coverPhotoMimicsNavigationBar = coverPhotoMimicsNavigationBar;
    self.titleView.hidden = !coverPhotoMimicsNavigationBar;
}

- (void)setDetailsView:(DBProfileDetailsView *)detailsView {
    NSAssert(detailsView, @"detailsView cannot be nil");
    _detailsView = detailsView;
    [self configureVisibleViewController:self.visibleContentViewController];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    self.coverPhotoStyle = DBProfileCoverPhotoStyleStretch;
    self.coverPhotoMimicsNavigationBar = YES;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.profilePictureInset = UIEdgeInsetsMake(0, DBProfileViewControllerProfilePictureLeftRightMargin, DBProfileViewControllerCoverPhotoDefaultHeight/2.0 - 10, 0);
    self.allowsPullToRefresh = YES;
    
    self.detailsView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlView.segmentedControl.tintColor = [UIColor grayColor];
    
    self.coverPhotoView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverPhotoView.clipsToBounds = YES;
}

#pragma mark - Actions

- (void)changeContent {
    NSUInteger selectedIndex = [self.segmentedControlView.segmentedControl selectedSegmentIndex];
    [self setVisibleContentViewControllerAtIndex:selectedIndex];
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

#pragma mark - Configuring Cover Photo

- (void)setCoverPhoto:(UIImage *)image animated:(BOOL)animated {
    self.coverPhotoView.imageView.image = image;
    
    if (animated) {
        self.coverPhotoView.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.coverPhotoView.imageView.alpha = 1;
        }];
    }
}

#pragma mark - Configuring Profile Picture

- (void)setProfilePicture:(UIImage *)image animated:(BOOL)animated {
    self.profilePictureView.imageView.image = image;

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
    if (self.visibleContentViewController) {
        UIScrollView *scrollView = [self.visibleContentViewController contentScrollView];
        [self endObservingContentOffsetForScrollView:scrollView];
    }
    
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

- (NSUInteger)selectedContentViewControllerIndex {
    return [self.segmentedControlView.segmentedControl selectedSegmentIndex];
}

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index {
    return [self.mutableContentViewControllerTitles objectAtIndex:index];
}

- (NSUInteger)indexForContentViewControllerWithTitle:(NSString *)title {
    return [self.mutableContentViewControllerTitles indexOfObject:title];
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


#pragma mark - Private

- (NSInteger)numberOfContentViewControllers {
    return [self.contentViewControllers count];
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
    [scrollView addSubview:self.segmentedControlView];
    [scrollView addSubview:self.coverPhotoView];
    [scrollView addSubview:self.profilePictureView];

    [self configureCoverPhotoViewLayoutConstraints];
    [self configureDetailsViewLayoutConstraints];
    [self configureProfilePictureViewLayoutConstraints];
    [self configureSegmentedControlViewLayoutConstraints];
    
    [scrollView setNeedsLayout];
    [scrollView layoutIfNeeded];
    
    [self updateViewConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:scrollView];
    
    // Begin observing contentOffset
    [self beginObservingContentOffsetForScrollView:scrollView];
    
    // Reset the content offset
    [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top)];
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
        if (selectedSegmentIndex == UISegmentedControlNoSegment || selectedSegmentIndex >= [self numberOfContentViewControllers]) {
            [self setVisibleContentViewControllerAtIndex:0];
        } else {
            [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex];
        }
    }
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    // Adjust top inset of scrollView to account for for segmented control, details view, and cover photo
    CGFloat topInset = CGRectGetHeight(self.segmentedControlView.frame) + CGRectGetHeight(self.detailsView.frame) + self.coverPhotoViewHeightConstraint.constant;
    
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = self.automaticallyAdjustsScrollViewInsets ? topInset + [self.topLayoutGuide length] : topInset;
    scrollView.contentInset = contentInset;
    
    // Set top constraint for cover photo to counteract top inset of the scroll view
    self.coverPhotoViewTopConstraint.constant = -topInset;
    
    // Set top constraint for details view to counteract top inset of the scroll view
    topInset -= self.coverPhotoViewHeightConstraint.constant;
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

- (void)resetNavigationBarHeight {
    _navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    if (![UIApplication sharedApplication].statusBarHidden) {
        _navigationBarHeight += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    }
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
        CGFloat top = scrollView.contentOffset.y + scrollView.contentInset.top;
        
        // Cover photo animations
        if (self.coverPhotoStyle == DBProfileCoverPhotoStyleStretch) {
            CGFloat delta = -top;
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
        }

        // Cover photo blur effect
        if (top < 0) {
            CGFloat pullToRefreshPercent = fabs(top) / 10;
            self.coverPhotoView.blurView.alpha = pullToRefreshPercent;
        } else {
            CGFloat pullToRefreshPercent = fabs(top) / 60;
            self.coverPhotoView.blurView.alpha = pullToRefreshPercent;
        }
        
        // Sticky cover photo to "mimic" navigation bar
        if (self.coverPhotoMimicsNavigationBar) {
            CGFloat height = self.coverPhotoViewHeightConstraint.constant - _navigationBarHeight;
            if (self.automaticallyAdjustsScrollViewInsets) {
                height += [self.topLayoutGuide length];
            }
            if (top > height) {
                CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.segmentedControlView.frame) + self.coverPhotoViewHeightConstraint.constant;
                self.coverPhotoViewTopConstraint.constant = MAX(-topInset + (top - height), -topInset);
                
                [scrollView insertSubview:self.profilePictureView belowSubview:self.coverPhotoView];
            } else {
                [scrollView insertSubview:self.coverPhotoView belowSubview:self.profilePictureView];
            }
        }
        
        // Sticky segmented control
        CGFloat segmentedControlOffset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.coverPhotoView.frame);
        if (self.coverPhotoMimicsNavigationBar) {
            segmentedControlOffset -= _navigationBarHeight;
            if (self.automaticallyAdjustsScrollViewInsets) {
                segmentedControlOffset += [self.topLayoutGuide length];
            }
        }
        self.segmentedControlViewTopConstraint.constant = (top > segmentedControlOffset) ? top - segmentedControlOffset : 0;
        
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
            coverPhotoOffset -= _navigationBarHeight;
        }
        if (self.automaticallyAdjustsScrollViewInsets) {
            coverPhotoOffsetPercent = MIN(1, top / (coverPhotoOffset - [self.topLayoutGuide length]));
        } else {
            coverPhotoOffsetPercent = MIN(1, top / coverPhotoOffset);
        }

        CGFloat profilePictureScale = MIN(1 - coverPhotoOffsetPercent * 0.3, 1);
        self.profilePictureView.transform = CGAffineTransformMakeScale(profilePictureScale, profilePictureScale);
        
        CGFloat profilePictureOffset = self.profilePictureInset.bottom + self.profilePictureInset.top;
        self.profilePictureViewTopConstraint.constant = MAX(MIN(-profilePictureOffset + (profilePictureOffset * coverPhotoOffsetPercent * 0.7), -profilePictureOffset * 0.3), -profilePictureOffset);
        
        // Title view animations
        CGFloat titleViewOffset = ((self.coverPhotoViewHeightConstraint.constant - _navigationBarHeight) + (DBProfileViewControllerProfilePictureSizeDefault - self.profilePictureInset.top + self.profilePictureInset.bottom)) + 4;
        CGFloat titleViewOffsetPercent = 1 - top / titleViewOffset;
        self.titleView.hidden = titleViewOffset < _navigationBarHeight;
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:MAX(titleViewOffset * titleViewOffsetPercent, 0)
                                                                      forBarMetrics:UIBarMetricsDefault];

    }
}

#pragma mark - Auto Layout

- (void)configureContentContainerViewControllerLayoutConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureSegmentedControlViewLayoutConstraints {
    UIView *superview = self.segmentedControlView.superview;
    NSAssert(superview, @"segmented control view must be added to a content view controller");
    
    self.segmentedControlViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [superview addConstraint:self.segmentedControlViewTopConstraint];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

- (void)configureDetailsViewLayoutConstraints {
    UIView *superview = self.detailsView.superview;
    NSAssert(superview, @"details view must be added to a content view controller");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superview addConstraint:self.detailsViewTopConstraint];
}

- (void)configureCoverPhotoViewLayoutConstraints {
    UIView *superview = self.coverPhotoView.superview;
    NSAssert(superview, @"cover photo must be added to a content view controller");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.coverPhotoViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [superview addConstraint:self.coverPhotoViewHeightConstraint];
    
    self.coverPhotoViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superview addConstraint:self.coverPhotoViewTopConstraint];
}

- (void)configureProfilePictureViewLayoutConstraints {
    UIView *superview = self.profilePictureView.superview;
    NSAssert(superview, @"profile picture must be added to a content view controller");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.profilePictureView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    // Width
    self.profilePictureViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [superview addConstraint:self.profilePictureViewWidthConstraint];
    
    // Left
    self.profilePictureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.profilePictureViewLeftConstraint.priority = UILayoutPriorityDefaultLow;
    [superview addConstraint:self.profilePictureViewLeftConstraint];

    // Right
    self.profilePictureViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    self.profilePictureViewRightConstraint.priority = UILayoutPriorityDefaultLow;
    [superview addConstraint:self.profilePictureViewRightConstraint];

    // CenterX
    self.profilePictureViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    self.profilePictureViewCenterXConstraint.priority = UILayoutPriorityDefaultLow;
    [superview addConstraint:self.profilePictureViewCenterXConstraint];

    // Top
    self.profilePictureViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superview addConstraint:self.profilePictureViewTopConstraint];
    
    [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint, self.profilePictureViewRightConstraint, self.profilePictureViewCenterXConstraint]];
}

@end
