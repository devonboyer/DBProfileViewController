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

@interface DBUserProfileViewController ()

@end

@implementation DBUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coverPhotoHeightMultiplier = 0.24;
    self.coverPhotoStyle = DBProfileCoverPhotoStyleStretch;
    self.coverPhotoMimicsNavigationBar = YES;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 72/2.0 - 10, 0);
    self.allowsPullToRefresh = YES;
    
    [self addContentViewController:[[DBFollowersTableViewController alloc] init] withTitle:@"Followers"];
    [self addContentViewController:[[DBPhotosTableViewController alloc] init] withTitle:@"Photos"];
    [self addContentViewController:[[DBLikesTableViewController alloc] init] withTitle:@"Likes"];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cover-photo-user.png"] animated:NO];
    [self setProfilePicture:[UIImage imageNamed:@"profile-picture.jpg"] animated:NO];
    
    // Setup details view
    self.detailsView.nameLabel.text = @"Devon Boyer";
    self.detailsView.usernameLabel.text = @"@devboyer";
    self.detailsView.descriptionLabel.text = @"CS @UWaterloo, iOS developer with a passion for mobile computing and great #uidesign.";
    self.detailsView.contentInset = UIEdgeInsetsMake(60, 15, 15, 15);
    
    self.title = @"Devon Boyer";
    self.subtitle = @"@devboyer";
}

@end
