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
    
    self.title = @"Devon Boyer";
    
    self.delegate = self;
        
    self.coverPhotoOptions = DBProfileCoverPhotoOptionStretch;
    self.profilePictureAlignment = DBProfilePictureAlignmentCenter;
    self.profilePictureView.style = DBProfilePictureStyleRound;
    self.profilePictureSize = DBProfilePictureSizeLarge;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 72/2.0 - 10, 0);
    self.profilePictureView.borderWidth = 5;
    self.allowsPullToRefresh = YES;
    
    [self addContentViewControllers:@[[[DBFollowersTableViewController alloc] init],
                                      [[DBPhotosTableViewController alloc] init],
                                      [[DBLikesTableViewController alloc] init]]];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cold-snow-winter-mountain.jpeg"] animated:NO];
    [self setProfilePicture:[UIImage imageNamed:@"demo-profile-picture"] animated:NO];
    
    // Setup details view
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.nameLabel.text = @"Devon Boyer";
    detailsView.usernameLabel.text = @"@devboyer";
    detailsView.descriptionLabel.text = @"A customizable library for creating stunning user profiles.";
    detailsView.contentInset = UIEdgeInsetsMake(80, 15, 15, 15);
    detailsView.editProfileButton.hidden = YES;
    detailsView.nameLabel.textAlignment = NSTextAlignmentCenter;
    detailsView.usernameLabel.textAlignment = NSTextAlignmentCenter;
    detailsView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        
    [self setStyle:self.style];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    UIBarButtonItem *removeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    //self.navigationView.navigationItem.rightBarButtonItems = @[addBarButtonItem, removeBarButtonItem];
}

- (void)setStyle:(DBUserProfileViewControllerStyle)style {
    _style = style;
    
    switch (style) {
        case DBUserProfileViewControllerStyle1:
            self.automaticallyAdjustsScrollViewInsets = YES;
            self.coverPhotoMimicsNavigationBar = NO;
            break;
        case DBUserProfileViewControllerStyle2:
            self.automaticallyAdjustsScrollViewInsets = NO;
            self.coverPhotoMimicsNavigationBar = YES;
            break;
        default:
            break;
    }
}

- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

- (void)add {
    [self addContentViewController:[[DBFollowersTableViewController alloc] init]];
}

- (void)remove {
    [self removeContentViewControllerAtIndex:0];
}

@end
