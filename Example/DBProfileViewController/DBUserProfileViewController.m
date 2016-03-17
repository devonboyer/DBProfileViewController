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

static const NSInteger DBUserProfileNumberOfContentControllers = 3;

typedef NS_ENUM(NSInteger, DBUserProfileContentControllerIndex) {
    DBUserProfileContentControllerIndexFollowers,
    DBUserProfileContentControllerIndexPhotos,
    DBUserProfileContentControllerIndexLikes
};

@interface DBUserProfileViewController () <DBProfileViewControllerDelegate, DBProfileViewControllerDataSource, DBEditProfileContentControllerDataSource>

@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (void)setStyle:(DBUserProfileViewControllerStyle)style {
    _style = style;
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.coverPhotoMimicsNavigationBar = YES;
    
    switch (style) {
        case DBUserProfileViewControllerStyle1:
            self.coverPhotoAnimationStyle = DBProfileCoverPhotoAnimationStyleNone;
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
    DBEditProfileViewController *editProfileVC = [[DBEditProfileViewController alloc] init];
    editProfileVC.contentController.dataSource = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editProfileVC] animated:YES completion:nil];
}

#pragma mark - DBEditProfileContentControllerDataSource

- (NSUInteger)numberOfSectionsForEditProfileContentController:(DBEditProfileContentController *)editProfileContentController {
    return 1;
}

- (NSInteger)editProfileContentController:(DBEditProfileContentController *)editProfileContentController numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (DBProfileItem *)editProfileContentController:(DBEditProfileContentController *)editProfileContentController itemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            return [[DBProfileItem alloc] initWithTitle:@"Name" value:@"Devon Boyer"];
        case 1: {
            DBProfileItem *item = [[DBProfileItem alloc] initWithTitle:@"Bio" value:@"CS @UWaterloo, iOS developer with a passion for mobile computing and #uidesign."];
            item.maxNumberOfLines = 5;
            return item;
        }
        case 2:
            return [[DBProfileItem alloc] initWithTitle:@"Location" value:@"Waterloo, Ontario"];
        case 3:
            return [[DBProfileItem alloc] initWithTitle:@"Website" value:@"http://devonboyer.com"];
        case 4:
            return [[DBProfileItem alloc] initWithTitle:@"Birthday" value:@"April 11, 1994"];
        default:
            return nil;
    }
}

#pragma mark - DBProfileViewControllerDataSource

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController {
    return DBUserProfileNumberOfContentControllers;
}

- (DBProfileContentController *)profileViewController:(DBProfileViewController *)profileViewController contentControllerAtIndex:(NSUInteger)index {

    switch (index) {
        case DBUserProfileContentControllerIndexFollowers:
            return [[DBFollowersTableViewController alloc] init];
        case DBUserProfileContentControllerIndexPhotos:
            return [[DBPhotosTableViewController alloc] init];
        case DBUserProfileContentControllerIndexLikes:
            return [[DBLikesTableViewController alloc] init];
        default:
            break;
    }
    return nil;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case DBUserProfileContentControllerIndexFollowers:
            return @"Followers";
        case DBUserProfileContentControllerIndexPhotos:
            return @"Photos";
        case DBUserProfileContentControllerIndexLikes:
            return @"Likes";
        default:
            break;
    }
    return nil;
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)index {
    switch (index) {
        case DBUserProfileContentControllerIndexFollowers:
            return @"20 Followers";
        case DBUserProfileContentControllerIndexPhotos:
            return @"12 Photos";
        case DBUserProfileContentControllerIndexLikes:
            return @"4 Likes";
        default:
            break;
    }
    return nil;
}

#pragma mark - DBProfileViewControllerDelegate

- (void)profileViewController:(DBProfileViewController *)profileViewController didHighlightCoverPhoto:(DBProfileCoverPhotoView *)coverPhotoView {
    NSLog(@"didHighlightCoverPhoto");
}

- (void)profileViewController:(DBProfileViewController *)profileViewController didUnhighlightCoverPhoto:(DBProfileCoverPhotoView *)coverPhotoView {
    NSLog(@"didUnhighlightCoverPhoto");
}

- (void)profileViewController:(DBProfileViewController *)profileViewController didDeselectCoverPhoto:(DBProfileCoverPhotoView *)coverPhotoView {
    NSLog(@"didDeselectCoverPhoto");
}

- (void)profileViewController:(DBProfileViewController *)profileViewController didSelectCoverPhoto:(DBProfileCoverPhotoView *)coverPhotoView {
    NSLog(@"didSelectCoverPhoto");
}

- (void)profileViewController:(DBProfileViewController *)viewController didSelectContentControllerAtIndex:(NSInteger)index { }

- (void)profileViewController:(DBProfileViewController *)viewController didPullToRefreshContentControllerAtIndex:(NSInteger)index {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
