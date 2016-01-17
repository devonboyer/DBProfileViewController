//
//  DBRecipeViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-16.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBRecipeViewController.h"
#import "DBFollowersTableViewController.h"
#import "DBPhotosTableViewController.h"
#import "DBLikesTableViewController.h"

@interface DBRecipeViewController () <DBProfileViewControllerDelegate>

@end

@implementation DBRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.coverPhotoHeightMultiplier = 1;
    self.coverPhotoStyle = DBProfileCoverPhotoStyleBackdrop;
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeDefault;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.allowsPullToRefresh = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.coverPhotoMimicsNavigationBar = YES;
    
    [self addContentViewController:[[DBFollowersTableViewController alloc] init] withTitle:@"Ingredients"];
    [self addContentViewController:[[DBPhotosTableViewController alloc] init] withTitle:@"Steps"];
    [self addContentViewController:[[DBLikesTableViewController alloc] init] withTitle:@"Comments"];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cover-photo-recipe.png"] animated:NO];
    
    // Setup details view
    self.detailsView.nameLabel.font = [UIFont boldSystemFontOfSize:32];
    self.detailsView.descriptionLabel.font = [UIFont systemFontOfSize:18];
    self.detailsView.nameLabel.text = @"Peppermint Chocolate Almond Bark";
    self.detailsView.usernameLabel.text = nil;
    self.detailsView.descriptionLabel.text = @"A healthy chocolate almond bark, is that possible? Yep, you bet.";
    self.detailsView.contentInset = UIEdgeInsetsMake(30, 15, 30, 15);
    self.detailsView.editProfileButton.hidden = YES;
    self.detailsView.tintColor = [UIColor whiteColor];
    self.detailsView.backgroundColor = [UIColor colorWithRed:1 green:51/255.0 blue:102/255.0 alpha:1];
    
    // Setup profile picture
    self.profilePictureView.style = DBProfilePictureStyleNone;
    
    self.title = @"Peppermint Chocolate Almond Bark";
    self.subtitle = @"38 Likes";
}

- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
