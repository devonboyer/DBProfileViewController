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

@interface DBUserProfileViewController () <DBProfileViewControllerDelegate>
@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DBProfileViewController";
    
    self.delegate = self;
    
    // Add content view controllers
    [self addContentViewControllers:@[[[DBFollowersTableViewController alloc] init],
                                      [[DBPhotosTableViewController alloc] init],
                                      [[DBLikesTableViewController alloc] init]]];
    
    // Customize profile appearance
    self.coverPhotoOptions = DBProfileCoverPhotoOptionStretch;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, DBProfileViewControllerProfilePictureSizeNormal/2.0 - 10, 0);
    self.profilePictureView.borderWidth = 4;
    self.allowsPullToRefresh = YES;
    
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.nameLabel.text = @"DBProfileViewController";
    detailsView.usernameLabel.text = @"by @devboyer";
    detailsView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    
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
            self.automaticallyAdjustsScrollViewInsets = YES;
            self.coverPhotoMimicsNavigationBar = NO;
        case DBUserProfileViewControllerStyle2:
            self.profilePictureView.style = DBProfilePictureStyleRoundedRect;
            self.profilePictureSize = DBProfilePictureSizeNormal;
            self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
            self.profilePictureView.borderWidth = 4;
            
            detailsView.contentInset = UIEdgeInsetsMake(70, 15, 15, 15);
            
            [self setCoverPhoto:[UIImage imageNamed:@"demo-cover-photo-1"] animated:NO];
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

#pragma mark - DBProfileViewControllerDelegate

- (void)profileViewController:(DBProfileViewController *)viewController didSelectCoverPhoto:(UIImageView *)imageView { }

- (void)profileViewController:(DBProfileViewController *)viewController didSelectProfilePicture:(UIImageView *)imageView { }

- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
