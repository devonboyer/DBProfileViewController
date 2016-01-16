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

@interface DBBlogViewController ()

@end

@implementation DBBlogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coverPhotoHeightMultiplier = 1;
    self.coverPhotoStyle = DBProfileCoverPhotoStyleBackdrop;
    self.coverPhotoMimicsNavigationBar = YES;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.allowsPullToRefresh = YES;
    
    [self addContentViewController:[[DBFollowersTableViewController alloc] init] withTitle:@"Details"];
    [self addContentViewController:[[DBPhotosTableViewController alloc] init] withTitle:@"Comments"];
    [self addContentViewController:[[DBLikesTableViewController alloc] init] withTitle:@"Related"];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cover-photo-blog.png"] animated:NO];
    [self setProfilePicture:[UIImage imageNamed:@"profile-picture.jpg"] animated:NO];
    
    // Setup details view
    self.detailsView.nameLabel.text = @"Goals and Garter Snakes";
    self.detailsView.usernameLabel.text = nil;
    self.detailsView.descriptionLabel.text = @"A blog post about my transition from Queen's to UWaterloo.";
    self.detailsView.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.detailsView.tintColor = [UIColor whiteColor];
    
    self.title = @"Goals and Garter Snakes";
    self.subtitle = @"94 Views";
}

@end
