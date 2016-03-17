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
#import "DBProfileContentControllerObserver.h"
#import "DBProfileDetailsView.h"
#import "DBProfilePictureView.h"
#import "DBProfileCoverPhotoView.h"
#import "DBProfileTitleView.h"
#import "DBProfileSegmentedControlView.h"
#import "DBProfileNavigationView.h"
#import "DBProfileImageEffects.h"
#import "DBProfileBlurImageOperation.h"
#import "DBProfileViewControllerDefaults.h"

#pragma mark - Constants

const CGFloat DBProfileViewControllerProfilePictureSizeEditProfile = 62.0;
const CGFloat DBProfileViewControllerProfilePictureSizeNormal = 72.0;
const CGFloat DBProfileViewControllerProfilePictureSizeLarge = 92.0;

static const CGFloat DBProfileViewControllerNavigationBarHeightRegular = 64.0;
static const CGFloat DBProfileViewControllerNavigationBarHeightCompact = 44.0;

static NSString * const DBProfileViewControllerContentOffsetCacheName = @"DBProfileViewController.contentOffsetCache";
static NSString * const DBProfileViewControllerOperationQueueName = @"DBProfileViewController.operationQueue";

@interface DBProfileViewController () <DBProfileCoverPhotoViewDelegate, DBProfilePictureViewDelegate, DBProfileContentControllerObserverDelegate>
{
    BOOL _shouldScrollToTop;
    CGPoint _sharedContentOffset;
    UIEdgeInsets _cachedContentInset;
}

@property (nonatomic, assign) Class segmentedControlClass;

@property (nonatomic, assign) CGFloat oldDetailsViewHeight;
@property (nonatomic, assign) NSUInteger indexForSelectedContentController;
@property (nonatomic, getter=isUpdating) BOOL updating;
@property (nonatomic, getter=isRefreshing) BOOL refreshing;

// Data
@property (nonatomic, strong) NSMutableArray<DBProfileContentController *> *contentControllers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, DBProfileContentControllerObserver *> *observers;
@property (nonatomic, strong) NSCache *contentOffsetCache;
@property (nonatomic, strong) NSDictionary *blurredImages;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

// Views
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) DBProfileNavigationView *navigationView;
@property (nonatomic, strong) DBProfileSegmentedControlView *segmentedControlView;

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

@end

@implementation DBProfileViewController

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
    _detailsView = [[DBProfileDetailsView alloc] initWithStyle:DBProfileDetailsViewStyleDefault];
    _segmentedControlView = [[DBProfileSegmentedControlView alloc] init];
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
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 10;
    self.operationQueue.name = DBProfileViewControllerOperationQueueName;
    
    self.containerView = [[UIView alloc] init];
    
    self.segmentedControlClass = [UISegmentedControl class];
    
    self.coverPhotoView.delegate = self;
    self.profilePictureView.delegate = self;
    
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
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    self.containerView.frame = self.view.frame;
    [self.view addSubview:self.containerView];
    
    [self.view addSubview:self.navigationView];

    [self.navigationView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Auto Layout
    [self configureNavigationViewLayoutConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.segmentedControl addTarget:self
                              action:@selector(segmentChanged:)
                    forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
    
    // Scroll displayed content controller to top
    if ([self.contentControllers count]) {
        DBProfileContentController *displayedViewController = [self.contentControllers objectAtIndex:self.indexForSelectedContentController];
        [self scrollContentControllerToTop:displayedViewController];
    }
    
    if (self.coverPhotoMimicsNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.operationQueue cancelAllOperations];
}

- (void)updateViewConstraints {
    [self updateCoverPhotoViewLayoutConstraints];
    [self updateProfilePictureViewLayoutConstraints];
    [super updateViewConstraints];
}

- (void)configureDefaults {
    _hidesSegmentedControlForSingleContentController = [[DBProfileViewControllerDefaults sharedDefaults] defaultHidesSegmentedControlForSingleContentController];
    _coverPhotoOptions = [[DBProfileViewControllerDefaults sharedDefaults] defaultCoverPhotoOptions];
    _coverPhotoHidden = [[DBProfileViewControllerDefaults sharedDefaults] defaultCoverPhotoHidden];
    _coverPhotoMimicsNavigationBar = [[DBProfileViewControllerDefaults sharedDefaults] defaultCoverPhotoMimicsNavigationBar];
    _coverPhotoScrollAnimationStyle = [[DBProfileViewControllerDefaults sharedDefaults] defaultCoverPhotoScrollAnimationStyle];
    _coverPhotoHeightMultiplier = [[DBProfileViewControllerDefaults sharedDefaults] defaultCoverPhotoHeightMultiplier];
    _profilePictureAlignment = [[DBProfileViewControllerDefaults sharedDefaults] defaultProfilePictureAlignment];
    _profilePictureSize = [[DBProfileViewControllerDefaults sharedDefaults] defaultProfilePictureSize];
    _profilePictureInset = [[DBProfileViewControllerDefaults sharedDefaults] defaultProfilePictureInsets];
    _allowsPullToRefresh = [[DBProfileViewControllerDefaults sharedDefaults] defaultAllowsPullToRefresh];
    self.segmentedControl.tintColor = [[DBProfileViewControllerDefaults sharedDefaults] defaultSegmentedControlTintColor];
    self.coverPhotoMimicsNavigationBarNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[DBProfileViewControllerDefaults sharedDefaults] defaultBackBarButtonItemImageForTraitCollection:self.traitCollection] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
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
}

#pragma mark - Getters

- (UISegmentedControl *)segmentedControl {
    return self.segmentedControlView.segmentedControl;
}

- (UINavigationItem *)coverPhotoMimicsNavigationBarNavigationItem {
    return self.navigationView.navigationItem;
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
    
    UIControl *segmentedControl = [[segmentedControlClass alloc] init];
    self.segmentedControlView.segmentedControl = segmentedControl;
}

- (void)setHidesSegmentedControlForSingleContentController:(BOOL)hidesSegmentedControlForSingleContentController {
    if (_hidesSegmentedControlForSingleContentController == hidesSegmentedControlForSingleContentController) return;
    _hidesSegmentedControlForSingleContentController = hidesSegmentedControlForSingleContentController;
    [self reloadData];
}

- (void)setCoverPhotoHeightMultiplier:(CGFloat)coverPhotoHeightMultiplier {
    NSAssert(coverPhotoHeightMultiplier > 0 && coverPhotoHeightMultiplier <= 1, @"`coverPhotoHeightMultiplier` must be greater than 0 or less than or equal to 1.");
    if (_coverPhotoHeightMultiplier == coverPhotoHeightMultiplier) return;
    _coverPhotoHeightMultiplier = coverPhotoHeightMultiplier;
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

- (void)setCoverPhotoOptions:(DBProfileCoverPhotoOptions)coverPhotoOptions {
    if (_coverPhotoOptions == coverPhotoOptions) return;
    _coverPhotoOptions = coverPhotoOptions;
    [self.view updateConstraintsIfNeeded];
}

- (void)setCoverPhotoHidden:(BOOL)coverPhotoHidden {
    if (_coverPhotoHidden == coverPhotoHidden) return;
    _coverPhotoHidden = coverPhotoHidden;
    [self.view updateConstraintsIfNeeded];
}

- (void)setCoverPhotoMimicsNavigationBar:(BOOL)coverPhotoMimicsNavigationBar {
    _coverPhotoMimicsNavigationBar = coverPhotoMimicsNavigationBar;
    self.navigationView.hidden = !coverPhotoMimicsNavigationBar;
    self.coverPhotoView.overlayView.hidden = !coverPhotoMimicsNavigationBar;
    [self.view updateConstraintsIfNeeded];
}

- (void)setDetailsView:(UIView *)detailsView {
    NSAssert(detailsView, @"detailsView cannot be nil");
    _detailsView = detailsView;
    [self reloadData];
}

- (void)setAllowsPullToRefresh:(BOOL)allowsPullToRefresh {
    if (_allowsPullToRefresh == allowsPullToRefresh) return;
    _allowsPullToRefresh = allowsPullToRefresh;
    [self reloadData];
}

#pragma mark - Action Responders

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentChanged:(id)sender {
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
    if ([self.delegate respondsToSelector:@selector(profileViewController:DidSelectContentControllerAtIndex:)]) {
        [self.delegate profileViewController:self didSelectContentControllerAtIndex:selectedSegmentIndex];
    }
}

#pragma mark - Public Methods

- (void)beginUpdates {
    self.updating = YES;
    
    // Cache the heights of subviews before updates occur
    self.oldDetailsViewHeight = [self.detailsView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [self.view invalidateIntrinsicContentSize];
}

- (void)endUpdates {
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self setIndexForSelectedContentController:self.indexForSelectedContentController];
        
        // Calculate the difference between heights of subviews from before updates to after updates
        CGFloat oldHeight = self.oldDetailsViewHeight;
        CGFloat newHeight = [self.detailsView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // Adjust content offset to account for difference in heights of subviews from before updates to after updates
        if (round(oldHeight) != round(newHeight)) {
            DBProfileContentController *viewController = [self.contentControllers objectAtIndex:self.indexForSelectedContentController];
            UIScrollView *scrollView = [viewController contentScrollView];
            
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y += (oldHeight - newHeight);
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

- (void)setCoverPhoto:(UIImage *)coverPhoto animated:(BOOL)animated {
    if (!coverPhoto) return;
    
    __weak DBProfileViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *croppedImage = [DBProfileImageEffects imageByCroppingImage:coverPhoto
                                                                   withSize:CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) *self.coverPhotoHeightMultiplier)];
        dispatch_async( dispatch_get_main_queue(), ^{
            
            weakSelf.coverPhotoView.imageView.image = croppedImage;
            
            if (animated) {
                weakSelf.coverPhotoView.imageView.alpha = 0;
                [UIView animateWithDuration: 0.3 animations:^{
                    weakSelf.coverPhotoView.imageView.alpha = 1;
                }];
            }
            
            DBProfileBlurImageOperation *operation = [[DBProfileBlurImageOperation alloc] initWithImageToBlur:croppedImage];
            [operation setBlurImageCompletionBlock:^(NSDictionary *blurredImages) {
                weakSelf.blurredImages = blurredImages;
            }];
            [weakSelf.operationQueue addOperation:operation];
            
        });
    });
}

- (void)setProfilePicture:(UIImage *)profilePicture animated:(BOOL)animated {
    if (!profilePicture) return;

    self.profilePictureView.imageView.image = profilePicture;
    
    if (animated) {
        self.profilePictureView.imageView.alpha = 0;
        [UIView animateWithDuration: 0.3 animations:^{
            self.profilePictureView.imageView.alpha = 1;
        }];
    }
}

- (void)endRefreshing {
    self.refreshing = NO;
    [self endRefreshAnimations];
}

- (void)selectContentControllerAtIndex:(NSInteger)index {
    self.indexForSelectedContentController = index;
}

- (void)selectCoverPhotoAnimated:(BOOL)animated {
    [self.coverPhotoView setSelected:YES animated:animated];
}

- (void)deselectCoverPhotoAnimated:(BOOL)animated {
    [self.coverPhotoView setSelected:NO animated:animated];
}

- (void)selectProfilePictureAnimated:(BOOL)animated {
    [self.profilePictureView setSelected:YES animated:animated];
}

- (void)deselectProfilePictureAnimated:(BOOL)animated {
    [self.profilePictureView setSelected:NO animated:animated];
}

- (void)setIndexForSelectedContentController:(NSUInteger)indexForSelectedContentController {
    if (![self.contentControllers count]) return;
    
    // Hide the currently selected content controller and remove observer
    DBProfileContentController *hideVC = [self.contentControllers objectAtIndex:_indexForSelectedContentController];
    if (hideVC) {
        [self hideContentController:hideVC];
        NSString *key = [self uniqueKeyForContentControllerAtIndex:_indexForSelectedContentController];
        if ([self.observers valueForKey:key]) {
            DBProfileContentControllerObserver *observer = self.observers[key];
            [observer stopObserving];
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
        DBProfileContentControllerObserver *observer = [[DBProfileContentControllerObserver alloc] initWithContentController:displayVC delegate:self];
        [observer startObserving];
        self.observers[key] = observer;
    }
    
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
    
    // Update titles
    self.navigationView.titleView.titleLabel.text = self.title;
    self.navigationView.titleView.subtitleLabel.text = [self subtitleForContentControllerAtIndex:self.indexForSelectedContentController];
}

#pragma mark - Pull-To-Refresh Animations

- (void)startRefreshAnimations {
    [self.activityIndicator startAnimating];
}

- (void)endRefreshAnimations {
    [self.activityIndicator stopAnimating];
}

#pragma mark - Delegate / Data Source

- (void)didSelectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was selected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectCoverPhoto:)]) {
        [self.delegate profileViewController:self didSelectCoverPhoto:coverPhotoView];
    }
    
    if (self.profilePictureView.isSelected) [self.profilePictureView setSelected:NO animated:YES];
}

- (void)didDeselectCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was deselected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didDeselectCoverPhoto:)]) {
        [self.delegate profileViewController:self didDeselectCoverPhoto:coverPhotoView];
    }
}

- (void)didHighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was highlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didHighlightCoverPhoto:)]) {
        [self.delegate profileViewController:self didHighlightCoverPhoto:coverPhotoView];
    }
    
    if (self.profilePictureView.isSelected) [self.profilePictureView setSelected:NO animated:YES];
}

- (void)didUnhighlightCoverPhotoView:(DBProfileCoverPhotoView *)coverPhotoView {
    // Inform delegate that the cover photo was unhighlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didUnhighlightCoverPhoto:)]) {
        [self.delegate profileViewController:self didUnhighlightCoverPhoto:coverPhotoView];
    }
}

- (void)didSelectProfilePictureView:(DBProfilePictureView *)profilePictureView {
    // Inform delegate that the profile picture was selected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didSelectProfilePicture:)]) {
        [self.delegate profileViewController:self didSelectProfilePicture:profilePictureView];
    }
    
    if (self.coverPhotoView.isSelected) [self.coverPhotoView setSelected:NO animated:YES];
}

- (void)didDeselectProfilePictureView:(DBProfilePictureView *)profilePictureView {
    // Inform delegate that the profile picture was deselected
    if ([self.delegate respondsToSelector:@selector(profileViewController:didDeselectProfilePicture:)]) {
        [self.delegate profileViewController:self didDeselectProfilePicture:profilePictureView];
    }
}

- (void)didHighlightProfilePictureView:(DBProfilePictureView *)profilePictureView {
    // Inform delegate that the profile picture was highlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didHighlightProfilePicture:)]) {
        [self.delegate profileViewController:self didHighlightProfilePicture:profilePictureView];
    }
    
    if (self.coverPhotoView.isSelected) [self.coverPhotoView setSelected:NO animated:YES];
}

- (void)didUnhighlightProfilePictureView:(DBProfilePictureView *)profilePictureView {
    // Inform delegate that the profile picture was unhighlighted
    if ([self.delegate respondsToSelector:@selector(profileViewController:didUnhighlightProfilePicture:)]) {
        [self.delegate profileViewController:self didUnhighlightProfilePicture:profilePictureView];
    }
}

- (void)notifyDelegateOfPullToRefreshOfContentControllerAtIndex:(NSInteger)index  {
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
    [self.view bringSubviewToFront:self.navigationView];
    [self buildContentController:viewController];
}

- (void)hideContentController:(DBProfileContentController *)viewController {
    NSAssert(viewController, @"viewController cannot be nil");
    
    UIScrollView *scrollView = [viewController contentScrollView];
    
    // Cache content offset
    CGFloat topInset = CGRectGetMaxY(self.navigationView.frame) + CGRectGetHeight(self.segmentedControlView.frame);
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
    [self.profilePictureView removeFromSuperview];
    [self.segmentedControlView removeFromSuperview];
    [self.activityIndicator removeFromSuperview];
    
    self.coverPhotoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.profilePictureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControlView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [scrollView addSubview:self.detailsView];
    
    NSInteger numberOfSegments = [self numberOfContentControllers];
    
    // Segmented control ?
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
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
        if ((scrollView.contentOffset.y + scrollView.contentInset.top) < CGRectGetHeight(self.coverPhotoView.frame) - self.coverPhotoViewBottomConstraint.constant) {
            [scrollView insertSubview:self.profilePictureView aboveSubview:self.coverPhotoView];
        } else {
            [scrollView insertSubview:self.coverPhotoView aboveSubview:self.profilePictureView];
        }
    }
    
    scrollView.delaysContentTouches = NO;
}

#pragma mark - Managing Content Offset

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

- (void)scrollContentControllerToTop:(DBProfileContentController *)viewController {
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
    
    if (scrollView.contentSize.height < minimumContentSizeHeight && ([self.contentControllers count] > 1 ||
        ([self.contentControllers count] == 1 && !self.hidesSegmentedControlForSingleContentController))) {
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

#pragma mark - DBProfileContentControllerObserverDelegate

- (void)contentControllerObserver:(DBProfileContentControllerObserver *)observer contentControllerScrollViewDidScroll:(UIScrollView *)scrollView {
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

#pragma mark - Updating Subviews On Scroll

- (void)handlePullToRefreshWithScrollView:(UIScrollView *)scrollView {
    if (!self.allowsPullToRefresh) return;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y += scrollView.contentInset.top;
    if (scrollView.isDragging && contentOffset.y < 0) {
        [self startRefreshAnimations];
    } else if (!scrollView.isDragging && !self.refreshing && contentOffset.y < -[[DBProfileViewControllerDefaults sharedDefaults] defaultPullToRefreshTriggerDistance]) {
        self.refreshing = YES;
        [self notifyDelegateOfPullToRefreshOfContentControllerAtIndex:self.indexForSelectedContentController];
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
    
    if (self.coverPhotoScrollAnimationStyle == DBProfileCoverPhotoScrollAnimationStyleBlur) {
        if (self.automaticallyAdjustsScrollViewInsets) distance += [self.topLayoutGuide length];
        CGFloat percent = MAX(MIN(1 - (distance - fabs(contentOffset.y))/distance, 1), 0);
        UIImage *blurredImage = [self blurredImageAt:percent];
        if (blurredImage) self.coverPhotoView.imageView.image = blurredImage;
    }
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
        const CGFloat padding = 30.0;
        CGFloat profilePictureOffset = self.profilePictureInset.top - self.profilePictureInset.bottom;
        titleViewOffset += (CGRectGetHeight(self.profilePictureView.frame) + profilePictureOffset + padding);
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

- (UIImage *)blurredImageAt:(CGFloat)percent {
    NSNumber *keyNumber = @(round(percent * DBProfileBlurImageOperationNumberOfBlurredImages));
    if ([self.blurredImages valueForKey:[keyNumber stringValue]]) {
        return [self.blurredImages objectForKey:[keyNumber stringValue]];
    }
    return nil;
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
    
    CGFloat profilePictureSize;
    
    switch (self.profilePictureSize) {
        case DBProfilePictureSizeEditProfile:
            profilePictureSize = DBProfileViewControllerProfilePictureSizeEditProfile;
            break;
        case DBProfilePictureSizeNormal:
            profilePictureSize = DBProfileViewControllerProfilePictureSizeNormal;
            break;
        case DBProfilePictureSizeLarge:
            profilePictureSize = DBProfileViewControllerProfilePictureSizeLarge;
            break;
        default:
            break;
    }
    
    self.profilePictureViewWidthConstraint.constant = profilePictureSize;
    self.profilePictureViewRightConstraint.constant = CGRectGetWidth(self.view.bounds) - profilePictureSize + self.profilePictureInset.left - self.profilePictureInset.right;
    
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
    
    if ([self.contentControllers count] > 1 || !self.hidesSegmentedControlForSingleContentController) {
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
    
    [NSLayoutConstraint deactivateConstraints:@[self.profilePictureViewLeftConstraint,
                                                self.profilePictureViewRightConstraint,
                                                self.profilePictureViewCenterXConstraint]];
}

@end
