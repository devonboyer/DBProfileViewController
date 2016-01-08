//
//  DBProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import "DBProfileViewController.h"

#import "DBProfileDetailsView.h"
#import "DBProfileSegmentedControlContainerView.h"

const CGFloat DBProfileViewControllerCoverImageDefaultHeight = 130.0;

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;

@interface DBProfileViewController ()
{
    BOOL hasAppeared;
}

@property (nonatomic, strong) UIViewController *contentContainerViewController;
@property (nonatomic, strong) DBProfileSegmentedControlContainerView *segmentedControlContainerView;

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *coverImageViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *coverImageViewHeightConstraint;

@property (nonatomic, strong) NSLayoutConstraint *profileImageViewLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *profileImageViewCenterXConstraint;

@property (nonatomic, strong) NSLayoutConstraint *detailsViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentSegmentedControlContainerViewTopConstraint;

@property (nonatomic, strong) NSMutableArray *mutableContentViewControllers;
@property (nonatomic, strong) NSMutableArray *mutableContentViewControllerTitles;

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
        [self.mutableContentViewControllers addObjectsFromArray:viewControllers];
        [self.mutableContentViewControllers addObjectsFromArray:titles];
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _segmentedControlContainerView = [[DBProfileSegmentedControlContainerView alloc] init];
    _detailsView = [[DBProfileDetailsView alloc] init];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _profileImageView = [[UIImageView alloc] init];
    _coverImageView = [[UIImageView alloc] init];
    
    _contentContainerViewController = [[UIViewController alloc] init];
}

- (void)dealloc {
    if (self.visibleContentViewController) {
        UITableView *tableView = ((UITableViewController *)self.visibleContentViewController).tableView;
        [self endObservingContentOffsetForScrollView:tableView];
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
    [self.refreshControl addTarget:self action:@selector(startRefreshing) forControlEvents:UIControlEventValueChanged];
    
    [self.contentSegmentedControl addTarget:self action:@selector(changeContent) forControlEvents:UIControlEventValueChanged];
    
    // Configuration
    [self configureDefaultAppearance];
    [self configureContentViewControllers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.contentViewControllerTitles count] > 0) {
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
    
    switch (self.coverImageStyle) {
        case DBProfileCoverImageStyleNone:
            self.coverImageViewHeightConstraint.constant = 0;
            self.coverImageView.hidden = YES;
            break;
        case DBProfileCoverImageStyleDefault:
        case DBProfileCoverImageStyleStretch:
            self.coverImageViewHeightConstraint.constant = DBProfileViewControllerCoverImageDefaultHeight;
            self.coverImageView.hidden = NO;
            break;
        default:
            break;
    }
        
    if (self.profileImageViewLeftConstraint && self.profileImageViewCenterXConstraint) {
        switch (self.profileImageAlignment) {
            case DBProfileImageAlignmentLeft:
                [NSLayoutConstraint activateConstraints:@[self.profileImageViewLeftConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[self.profileImageViewCenterXConstraint]];
                break;
            case DBProfileImageAlignmentCenter:
                [NSLayoutConstraint activateConstraints:@[self.profileImageViewCenterXConstraint]];
                [NSLayoutConstraint deactivateConstraints:@[self.profileImageViewLeftConstraint]];
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

- (UISegmentedControl *)contentSegmentedControl {
    return self.segmentedControlContainerView.segmentedControl;
}

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

- (void)setCoverImageStyle:(DBProfileCoverImageStyle)coverImageStyle {
    _coverImageStyle = coverImageStyle;
    [self updateViewConstraints];
}

- (void)setProfileImageAlignment:(DBProfileImageAlignment)profileImageAlignment {
    _profileImageAlignment = profileImageAlignment;
    [self updateViewConstraints];
}

#pragma mark - Actions

- (void)changeContent {
    NSUInteger selectedIndex = [self.contentSegmentedControl selectedSegmentIndex];
    [self setVisibleContentViewControllerAtIndex:selectedIndex animated:NO];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    
    self.coverImageStyle = DBProfileCoverImageStyleStretch;
    self.profileImageAlignment = DBProfileImageAlignmentLeft;
    
    self.detailsView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlContainerView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlContainerView.segmentedControl.tintColor = [UIColor grayColor];
    
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.cornerRadius = 8;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 4;
}

#pragma mark - Managing Content View Controllers

- (void)addContentViewController:(UIViewController *)viewController withTitle:(NSString *)title {
    NSAssert([title length] > 0, @"content view controllers must have a title");
    NSAssert(viewController, @"content view controller cannot be nil");
    
    [self.mutableContentViewControllers addObject:viewController];
    [self.mutableContentViewControllerTitles addObject:title];
    
    [self configureContentViewControllers];
}

- (void)addContentViewController:(UIViewController *)viewController atIndex:(NSUInteger)index withTitle:(NSString *)title {
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
        UITableView *tableView = ((UITableViewController *)self.visibleContentViewController).tableView;
        [self endObservingContentOffsetForScrollView:tableView];
    }
    
    // Remove previous view controller from container
    [self removeViewControllerFromContainer:self.visibleContentViewController];
    
    UITableViewController *visibleContentViewController = self.contentViewControllers[index];
    
    // Add visible view controller to container
    [self addViewControllerToContainer:visibleContentViewController];
    
    _visibleContentViewController = visibleContentViewController;

    [self.contentSegmentedControl setSelectedSegmentIndex:index];
    [self configureVisibleViewController:visibleContentViewController];
}

- (NSString *)titleForContentViewControllerAtIndex:(NSUInteger)index {
    return [self.mutableContentViewControllerTitles objectAtIndex:index];
}

#pragma mark - Refreshing Data

- (void)startRefreshing {
    // override in subclass
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - Private

- (NSInteger)numberOfContentViewControllers {
    return [self.contentViewControllers count];
}

- (void)configureVisibleViewController:(UITableViewController *)visibleViewController {
    UITableView *tableView = visibleViewController.tableView;
    
    [self.coverImageView removeFromSuperview];
    [self.detailsView removeFromSuperview];
    [self.profileImageView removeFromSuperview];
    [self.segmentedControlContainerView removeFromSuperview];
    
    [self.profileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.coverImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.profileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControlContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [tableView addSubview:self.coverImageView];
    [tableView addSubview:self.detailsView];
    [tableView addSubview:self.profileImageView];
    [tableView addSubview:self.segmentedControlContainerView];
    
    [self configureCoverImageViewLayoutConstraints];
    [self configureDetailsViewLayoutConstraints];
    [self configureProfileImageViewLayoutConstraints];
    [self configureSegmentedControlContainerViewLayoutConstraints];
    
    [tableView layoutIfNeeded];
    [tableView setNeedsLayout];
    
    [self updateViewConstraints];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:tableView];
    
    // Begin observing contentOffset
    [self beginObservingContentOffsetForScrollView:tableView];
    
    // Reset the content offset
    [tableView setContentOffset:CGPointMake(0, -tableView.contentInset.top)];
}

- (void)configureContentViewControllers {
    
    // Keep track of the previously selected segment index
    NSInteger selectedSegmentIndex = self.contentSegmentedControl.selectedSegmentIndex;
    
    [self.contentSegmentedControl removeAllSegments];
    
    NSInteger numberOfSegments = [self numberOfContentViewControllers];
    CGFloat segmentWidth = (CGRectGetWidth(self.view.bounds) * 0.8) / numberOfSegments;
    
    NSInteger index = 0;
    for (NSString *title in self.contentViewControllerTitles) {
        [self.contentSegmentedControl insertSegmentWithTitle:title atIndex:index animated:NO];
        [self.contentSegmentedControl setWidth:segmentWidth forSegmentAtIndex:index];
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
    CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.segmentedControlContainerView.frame) + self.coverImageViewHeightConstraint.constant + [self.topLayoutGuide length];
    
    // FIXME: Destroys original content inset of scrollView
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = topInset;
    scrollView.contentInset = contentInset;
    scrollView.scrollIndicatorInsets = contentInset;
    
    self.coverImageViewTopConstraint.constant = -topInset + [self.topLayoutGuide length];
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
    
    static CGFloat coverImageViewTopInsetSnapshot = 0;
    
    if ([keyPath isEqualToString:@"contentOffset"] && context == DBProfileViewControllerContentOffsetKVOContext) {
        UIScrollView *scrollView = (UIScrollView *)object;
        CGFloat top = scrollView.contentOffset.y + scrollView.contentInset.top;
        CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.coverImageView.frame);
        self.contentSegmentedControlContainerViewTopConstraint.constant = (top > topInset) ? top - topInset : 0;
        
        if (self.coverImageStyle == DBProfileCoverImageStyleStretch) {
            CGFloat delta = -top;
            if (top < 0) {
                self.coverImageViewTopConstraint.constant = coverImageViewTopInsetSnapshot - delta;
                self.coverImageViewHeightConstraint.constant = MAX(DBProfileViewControllerCoverImageDefaultHeight, DBProfileViewControllerCoverImageDefaultHeight + delta);
            } else {
                coverImageViewTopInsetSnapshot = self.coverImageViewTopConstraint.constant;
                [self adjustContentInsetForScrollView:scrollView];
            }
        }
    }
}

#pragma mark - Auto Layout

- (void)configureContentContainerViewControllerLayoutConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

- (void)configureSegmentedControlContainerViewLayoutConstraints {
    UIView *superview = self.segmentedControlContainerView.superview;
    NSAssert(superview, @"");
    
    self.contentSegmentedControlContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.segmentedControlContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [superview addConstraint:self.contentSegmentedControlContainerViewTopConstraint];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControlContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

- (void)configureDetailsViewLayoutConstraints {
    UIView *superview = self.detailsView.superview;
    NSAssert(superview, @"");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:180]];
    
    self.detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.coverImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [superview addConstraint:self.detailsViewTopConstraint];
}

- (void)configureCoverImageViewLayoutConstraints {
    UIView *superview = self.coverImageView.superview;
    NSAssert(superview, @"");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.coverImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [superview addConstraint:self.coverImageViewHeightConstraint];
    
    self.coverImageViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.coverImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superview addConstraint:self.coverImageViewTopConstraint];
}

- (void)configureProfileImageViewLayoutConstraints {
    UIView *superview = self.profileImageView.superview;
    NSAssert(superview, @"");
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.coverImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.profileImageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    self.profileImageViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.profileImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1 constant:20];
    self.profileImageViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.profileImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    [NSLayoutConstraint deactivateConstraints:@[self.profileImageViewLeftConstraint, self.profileImageViewCenterXConstraint]];
    
    [superview addConstraint:self.profileImageViewLeftConstraint];
    [superview addConstraint:self.profileImageViewCenterXConstraint];
}

@end
