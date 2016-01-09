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
#import "DBProfileSegmentedControlView.h"
#import "DBProfileContentViewController.h"

const CGFloat DBProfileViewControllerCoverPhotoDefaultHeight = 130.0;
const CGFloat DBProfileViewControllerProfilePictureLeftRightMargin = 15.0;
const CGFloat DBProfileViewControllerPullToRefreshDistance = 80;

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;

@interface DBProfileViewController ()
{
    BOOL hasAppeared;
}

@property (nonatomic, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, strong) UIViewController *contentContainerViewController;
@property (nonatomic, strong) DBProfileSegmentedControlView *segmentedControlView;

@property (nonatomic, strong) NSMutableArray *mutableContentViewControllers;
@property (nonatomic, strong) NSMutableArray *mutableContentViewControllerTitles;

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverPhotoViewHeightConstraint;

@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profilePictureViewCenterYConstraint;

@property (nonatomic, strong) NSLayoutConstraint *detailsViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *segmentedControlViewTopConstraint;

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
    
    _contentContainerViewController = [[UIViewController alloc] init];
}

- (void)dealloc {
    if (self.visibleContentViewController) {
        UIScrollView *scrollView = [self.visibleContentViewController scrollView];
        [self endObservingContentOffsetForScrollView:scrollView];
    }
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    [self addChildViewController:self.contentContainerViewController];
    [self.view addSubview:self.contentContainerViewController.view];
    [self.contentContainerViewController didMoveToParentViewController:self];
    
    [self.contentContainerViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Auto Layout
    [self configureContentContainerViewControllerLayoutConstraints];
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
    
    if ([self numberOfContentViewControllers] > 0) {
        [self setVisibleContentViewControllerAtIndex:0 animated:NO];
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!hasAppeared) {
        [self configureContentViewControllers];
        hasAppeared = YES;
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
                [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewCenterXConstraint]];
                break;
            case DBProfilePictureAlignmentCenter:
                [NSLayoutConstraint activateConstraints:@[self.profilePictureViewCenterXConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint]];
                break;
            default:
                break;
        }
    }
    
    [super updateViewConstraints];
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

#pragma mark - Setters

- (void)setCoverPhototyle:(DBProfileCoverPhotoStyle)coverPhotoStyle {
    _coverPhotoStyle = coverPhotoStyle;
    [self updateViewConstraints];
}

- (void)setProfilePictureAlignment:(DBProfilePictureAlignment)profilePictureAlignment {
    _profilePictureAlignment = profilePictureAlignment;
    [self updateViewConstraints];
}

#pragma mark - Actions

- (void)changeContent {
    NSUInteger selectedIndex = [self.segmentedControlView.segmentedControl selectedSegmentIndex];
    [self setVisibleContentViewControllerAtIndex:selectedIndex animated:NO];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    
    self.coverPhotoStyle = DBProfileCoverPhotoStyleStretch;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    
    self.detailsView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlView.segmentedControl.tintColor = [UIColor grayColor];
    
    self.coverPhotoView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverPhotoView.clipsToBounds = YES;
    
    self.profilePictureView.imageView.image = [UIImage imageNamed:@"profile-picture.jpg"];
    self.coverPhotoView.imageView.image = [UIImage imageNamed:@"cookies.jpg"];
}

#pragma mark - Managing Content View Controllers

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController withTitle:(NSString *)title {
    NSAssert([title length] > 0, @"content view controllers must have a title");
    NSAssert(viewController, @"content view controller cannot be nil");
    
    [self.mutableContentViewControllers addObject:viewController];
    [self.mutableContentViewControllerTitles addObject:title];
    
    [self configureContentViewControllers];
}

- (void)addContentViewController:(UIViewController<DBProfileContentViewController> *)viewController atIndex:(NSUInteger)index withTitle:(NSString *)title {
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

- (void)setVisibleContentViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (self.visibleContentViewController) {
        UIScrollView *scrollView = [self.visibleContentViewController scrollView];
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

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index {
    return [self.mutableContentViewControllerTitles objectAtIndex:index];
}

#pragma mark - Refreshing Data

- (void)startRefreshing {
    [self.coverPhotoView startRefreshing];
}

- (void)endRefreshing {
    [self.coverPhotoView endRefreshing];
}

#pragma mark - Private

- (NSInteger)numberOfContentViewControllers {
    return [self.contentViewControllers count];
}

- (void)configureVisibleViewController:(UIViewController<DBProfileContentViewController> *)visibleViewController {
    UIScrollView *scrollView = [visibleViewController scrollView];
    
    [self.coverPhotoView removeFromSuperview];
    [self.detailsView removeFromSuperview];
    [self.profilePictureView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    
    [self.coverPhotoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.profilePictureView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControlView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [scrollView addSubview:self.coverPhotoView];
    [scrollView addSubview:self.detailsView];
    [scrollView addSubview:self.profilePictureView];
    [scrollView addSubview:self.segmentedControlView];
    
    [self configureCoverPhotoViewLayoutConstraints];
    [self configureDetailsViewLayoutConstraints];
    [self configureProfilePictureViewLayoutConstraints];
    [self configureSegmentedControlViewLayoutConstraints];
    
    [scrollView layoutIfNeeded];
    [scrollView setNeedsLayout];
    
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
    
    NSInteger numberOfSegments = [self numberOfContentViewControllers];
    CGFloat segmentWidth = (CGRectGetWidth(self.view.bounds) * 0.8) / numberOfSegments;
    
    NSInteger index = 0;
    for (NSString *title in self.contentViewControllerTitles) {
        [self.segmentedControlView.segmentedControl insertSegmentWithTitle:title atIndex:index animated:NO];
        [self.segmentedControlView.segmentedControl setWidth:segmentWidth forSegmentAtIndex:index];
        index++;
    }
    
    // Set the selected segment index
    if (numberOfSegments > 0) {
        if (selectedSegmentIndex == UISegmentedControlNoSegment || selectedSegmentIndex >= [self numberOfContentViewControllers]) {
            [self setVisibleContentViewControllerAtIndex:0 animated:YES];
        } else {
            [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex animated:YES];
        }
    }
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.segmentedControlView.frame) + self.coverPhotoViewHeightConstraint.constant + [self.topLayoutGuide length];
    
    // FIXME: Overwrites original content inset of scrollView
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = topInset;
    scrollView.contentInset = contentInset;
    
    self.coverPhotoViewTopConstraint.constant = -topInset + [self.topLayoutGuide length];
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
        CGFloat top = scrollView.contentOffset.y + scrollView.contentInset.top;
        CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.coverPhotoView.frame);
        self.segmentedControlViewTopConstraint.constant = (top > topInset) ? top - topInset : 0;
        
        // Cover photo animations
        if (self.coverPhotoStyle == DBProfileCoverPhotoStyleStretch) {
            CGFloat delta = -top;
            if (top < 0) {
                self.coverPhotoViewTopConstraint.constant = -(scrollView.contentInset.top - [self.topLayoutGuide length]) - delta;
                self.coverPhotoViewHeightConstraint.constant = MAX(DBProfileViewControllerCoverPhotoDefaultHeight, DBProfileViewControllerCoverPhotoDefaultHeight + delta);
            } else {
                [self adjustContentInsetForScrollView:scrollView];
            }
        }
        
        // Pull-To-Refresh animations
        if (scrollView.isDragging && !self.refreshing && top < -DBProfileViewControllerPullToRefreshDistance) {
            self.refreshing = YES;
            [self startRefreshing];
        }
        
        if (!scrollView.isDragging && self.refreshing) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.refreshing = NO;
                [self endRefreshing];
            });
        }
        
        // Profile picture animations
        CGFloat percent = MIN(1, top / (self.coverPhotoViewHeightConstraint.constant - [self.topLayoutGuide length]));
        CGFloat scale = MIN(1 - percent * 0.3, 1);
        self.profilePictureView.transform = CGAffineTransformMakeScale(scale, scale);
        self.profilePictureViewCenterYConstraint.constant = MAX((CGRectGetHeight(self.profilePictureView.frame) / 2) * percent, 10);
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
    NSAssert(superview, @"");
    
    self.segmentedControlViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [superview addConstraint:self.segmentedControlViewTopConstraint];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

- (void)configureDetailsViewLayoutConstraints {
    UIView *superview = self.detailsView.superview;
    NSAssert(superview, @"");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.coverPhotoView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [superview addConstraint:self.detailsViewTopConstraint];
}

- (void)configureCoverPhotoViewLayoutConstraints {
    UIView *superview = self.coverPhotoView.superview;
    NSAssert(superview, @"");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.coverPhotoViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [superview addConstraint:self.coverPhotoViewHeightConstraint];
    
    self.coverPhotoViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.coverPhotoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superview addConstraint:self.coverPhotoViewTopConstraint];
}

- (void)configureProfilePictureViewLayoutConstraints {
    UIView *superview = self.profilePictureView.superview;
    NSAssert(superview, @"");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:72]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.profilePictureView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.profilePictureViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.coverPhotoView attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    [superview addConstraint:self.profilePictureViewCenterYConstraint];
    
    self.profilePictureViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:DBProfileViewControllerProfilePictureLeftRightMargin];
    self.profilePictureViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.profilePictureView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint, self.profilePictureViewCenterXConstraint]];
    
    [superview addConstraint:self.profilePictureViewLeftConstraint];
    [superview addConstraint:self.profilePictureViewCenterXConstraint];
}

@end
