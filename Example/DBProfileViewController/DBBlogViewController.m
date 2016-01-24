//
//  DBBlogViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-15.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBBlogViewController.h"
#import "DBFollowersTableViewController.h"
#import "DBPhotosTableViewController.h"
#import "DBLikesTableViewController.h"

@interface DBBlogViewController () <DBProfileViewControllerDelegate>

@end

@implementation DBBlogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.coverPhotoHeightMultiplier = 1.0;
    self.coverPhotoStyle = DBProfileCoverPhotoStyleBackdrop;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeNormal;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.allowsPullToRefresh = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.coverPhotoMimicsNavigationBar = YES;
    
    [self addContentViewController:[[DBFollowersTableViewController alloc] init] withTitle:@"Details"];
    [self addContentViewController:[[DBPhotosTableViewController alloc] init] withTitle:@"Comments"];
    [self addContentViewController:[[DBLikesTableViewController alloc] init] withTitle:@"Related"];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cover-photo-blog.png"] animated:NO];
    [self setProfilePicture:[UIImage imageNamed:@"profile-picture.jpg"] animated:NO];
    
    // Setup details view
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.nameLabel.font = [UIFont boldSystemFontOfSize:40];
    detailsView.descriptionLabel.font = [UIFont systemFontOfSize:18];
    detailsView.nameLabel.text = @"Goals and\nGarter Snakes";
    detailsView.usernameLabel.text = nil;
    detailsView.descriptionLabel.text = @"A blog post about my transition from Queen's to UWaterloo.";
    detailsView.contentInset = UIEdgeInsetsMake(84, 15, 40, 15);
    detailsView.tintColor = [UIColor whiteColor];
    detailsView.editProfileButton.hidden = YES;
    
    self.title = @"Goals and Garter Snakes";
    self.subtitle = @"94 Views";
    
    self.profilePictureSize = DBProfilePictureSizeLarge;
    self.profilePictureView.style = DBProfilePictureStyleRound;
}

- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
