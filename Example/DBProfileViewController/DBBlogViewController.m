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
    self.profilePictureSize = DBProfilePictureSizeDefault;
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
    self.detailsView.nameLabel.font = [UIFont boldSystemFontOfSize:40];
    self.detailsView.descriptionLabel.font = [UIFont systemFontOfSize:18];
    self.detailsView.nameLabel.text = @"Goals and\nGarter Snakes";
    self.detailsView.usernameLabel.text = nil;
    self.detailsView.descriptionLabel.text = @"A blog post about my transition from Queen's to UWaterloo.";
    self.detailsView.contentInset = UIEdgeInsetsMake(84, 15, 40, 15);
    self.detailsView.tintColor = [UIColor whiteColor];
    self.detailsView.editProfileButton.hidden = YES;
    
    self.title = @"Goals and Garter Snakes";
    self.subtitle = @"94 Views";
}

- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
