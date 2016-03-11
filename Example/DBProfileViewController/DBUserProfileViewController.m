//
//  DBUserProfileViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-15.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBUserProfileViewController.h"
#import "DBFollowersTableViewController.h"
#import "DBPhotosTableViewController.h"
#import "DBLikesTableViewController.h"

@interface DBUserProfileViewController () <DBProfileViewControllerDelegate, DBProfileViewControllerDataSource> {
    DBFollowersTableViewController *followers;
    DBPhotosTableViewController *photos;
    DBLikesTableViewController *likes;
}
@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    followers = [[DBFollowersTableViewController alloc] init];
    photos = [[DBPhotosTableViewController alloc] init];
    likes = [[DBLikesTableViewController alloc] init];

    self.title = @"DBProfileViewController";
    
    self.delegate = self;
    self.dataSource = self;
    
    // Customize profile appearance
    self.coverPhotoOptions = DBProfileCoverPhotoOptionStretch;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, DBProfileViewControllerProfilePictureSizeNormal/2.0 - 10, 0);
    self.profilePictureView.borderWidth = 4;
    self.allowsPullToRefresh = YES;
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.nameLabel.text = @"DBProfileViewController";
    detailsView.usernameLabel.text = @"by @devboyer";
    detailsView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    [detailsView.editProfileButton addTarget:self action:@selector(editProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setProfilePicture:[UIImage imageNamed:@"demo-profile-picture"] animated:NO];
    [self setStyle:self.style];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Why isn't this working?
    [self setCoverPhoto:[UIImage imageNamed:@"demo-cover-photo-2"] animated:NO];
}

- (void)setStyle:(DBUserProfileViewControllerStyle)style {
    _style = style;
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.coverPhotoMimicsNavigationBar = YES;
    
    switch (style) {
        case DBUserProfileViewControllerStyle1:
            self.automaticallyAdjustsScrollViewInsets = YES;
            self.coverPhotoMimicsNavigationBar = NO;
        case DBUserProfileViewControllerStyle2:
            self.profilePictureView.style = DBProfilePictureStyleRoundedRect;
            self.profilePictureSize = DBProfilePictureSizeNormal;
            self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
            self.profilePictureView.borderWidth = 4;
            
            detailsView.contentInset = UIEdgeInsetsMake(70, 15, 15, 15);
            
            [self setCoverPhoto:[UIImage imageNamed:@"demo-cover-photo-2"] animated:NO];
            break;
        case DBUserProfileViewControllerStyle3:
            self.profilePictureView.style = DBProfilePictureStyleRound;
            self.profilePictureSize = DBProfilePictureSizeLarge;
            self.profilePictureAlignment = DBProfilePictureAlignmentCenter;
            
            detailsView.contentInset = UIEdgeInsetsMake(80, 15, 15, 15);
            detailsView.editProfileButton.hidden = YES;
            detailsView.nameLabel.textAlignment = NSTextAlignmentCenter;
            detailsView.usernameLabel.textAlignment = NSTextAlignmentCenter;
            detailsView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
            
            [self setCoverPhoto:[UIImage imageNamed:@"demo-cover-photo-2"] animated:NO];
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (void)editProfile:(id)sender {
    
    [self beginUpdates];
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.expanded = !detailsView.expanded;
    
    [self endUpdates];
}

#pragma mark - DBProfileViewControllerDataSource

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController {
    return 3;
}

- (DBProfileContentViewController *)profileViewController:(DBProfileViewController *)profileViewController contentViewControllerAtIndex:(NSUInteger)index {

    switch (index) {
        case 0:
            return [[DBFollowersTableViewController alloc] init];
        case 1:
            return [[DBPhotosTableViewController alloc] init];;
        case 2:
            return [[DBLikesTableViewController alloc] init];;
        default:
            break;
    }
    return nil;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"Followers";
        case 1:
            return @"Photos";
        case 2:
            return @"Likes";
        default:
            break;
    }
    return nil;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"20 Followers";
        case 1:
            return @"12 Photos";
        case 2:
            return @"4 Likes";
        default:
            break;
    }
    return nil;
}

#pragma mark - DBProfileViewControllerDelegate

- (void)profileViewController:(DBProfileViewController *)viewController didSelectContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)viewController didSelectCoverPhoto:(UIImageView *)imageView { }

- (void)profileViewController:(DBProfileViewController *)viewController didSelectProfilePicture:(UIImageView *)imageView { }

- (void)profileViewController:(DBProfileViewController *)viewController didPullToRefreshControllerAtIndex:(NSInteger)index {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
