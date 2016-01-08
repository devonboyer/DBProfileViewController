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

static void * DBProfileViewControllerContentOffsetKVOContext = &DBProfileViewControllerContentOffsetKVOContext;

@interface DBProfileViewController ()
{
    BOOL hasAppeared;
}

@property (nonatomic, strong) UIViewController *contentContainerViewController;
@property (nonatomic, strong) DBProfileSegmentedControlContainerView *segmentedControlContainerView;

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
    
    [self.view addSubview:self.profileImageView];
    [self.view addSubview:self.coverImageView];
    
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControlContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.profileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentContainerViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.coverImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Auto Layout
    [self configureContentContainerViewControllerLayoutConstraints];
    [self configureProfileImageViewLayoutConstraints];
    [self configureCoverImageViewLayoutConstraints];
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
    [super updateViewConstraints];
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

#pragma mark - Actions

- (void)changeContent {
    NSUInteger selectedIndex = [self.contentSegmentedControl selectedSegmentIndex];
    [self setVisibleContentViewControllerAtIndex:selectedIndex animated:NO];
}

#pragma mark - Defaults

- (void)configureDefaultAppearance {
    
    self.detailsView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlContainerView.backgroundColor = [UIColor whiteColor];
    self.segmentedControlContainerView.segmentedControl.tintColor = [UIColor grayColor];
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
    
    UITableViewController *visibleContentViewController = self.contentViewControllers[index];
    
    // Remove previous view controller from container
    [self removeViewControllerFromContainer:visibleContentViewController];
    
    _visibleContentViewController = visibleContentViewController;
    
    // Add visible view controller to container
    [self addViewControllerToContainer:self.visibleContentViewController];

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
    
    [self.detailsView removeFromSuperview];
    [self.segmentedControlContainerView removeFromSuperview];
    
    [self.detailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.segmentedControlContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [tableView addSubview:self.detailsView];
    [tableView addSubview:self.segmentedControlContainerView];
    
    [self configureDetailsViewLayoutConstraints];
    [self configureSegmentedControlContainerViewLayoutConstraints];
    
    [tableView layoutIfNeeded];
    [tableView setNeedsLayout];
    
    // Adjust contentInset
    [self adjustContentInsetForScrollView:tableView];
    
    // Begin observing contentOffset
    [self beginObservingContentOffsetForScrollView:tableView];
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
        if (selectedSegmentIndex == UISegmentedControlNoSegment) {
            [self setVisibleContentViewControllerAtIndex:0 animated:YES];
        } else {
            [self setVisibleContentViewControllerAtIndex:selectedSegmentIndex animated:YES];
        }
    }
}

- (void)adjustContentInsetForScrollView:(UIScrollView *)scrollView {
    CGFloat topInset = CGRectGetHeight(self.detailsView.frame) + CGRectGetHeight(self.segmentedControlContainerView.frame);
    
    // FIXME: Destroys original content inset of scrollView
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = topInset;
    scrollView.contentInset = contentInset;
    
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
        
        // FIXME: This math is close but not correct
        CGFloat top = scrollView.contentOffset.y + scrollView.contentInset.top;
        CGFloat topInset = CGRectGetHeight(self.detailsView.frame) - [self.topLayoutGuide length];
        self.contentSegmentedControlContainerViewTopConstraint.constant = (top > topInset) ? top - topInset : 0;
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
    UIView *superview = self.detailsView.superview;
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
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200]];
    
    self.detailsViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [superview addConstraint:self.detailsViewTopConstraint];
}

- (void)configureCoverImageViewLayoutConstraints {
    
}

- (void)configureProfileImageViewLayoutConstraints {
    
}

@end
