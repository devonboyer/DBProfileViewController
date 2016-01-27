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
    self.profilePictureAlignment = DBProfilePictureAlignmentLeft;
    self.profilePictureSize = DBProfilePictureSizeNormal;
    self.profilePictureInset = UIEdgeInsetsMake(0, 15, 72/2.0 - 10, 0);
    self.allowsPullToRefresh = YES;
    
    [self addContentViewController:[[DBFollowersTableViewController alloc] init]];
    [self addContentViewController:[[DBPhotosTableViewController alloc] init]];
    [self addContentViewController:[[DBLikesTableViewController alloc] init]];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cover-photo.png"] animated:NO];
    [self setProfilePicture:[UIImage imageNamed:@"profile-picture.jpg"] animated:NO];
    
    // Setup details view
    DBProfileDetailsView *detailsView = (DBProfileDetailsView *)self.detailsView;
    detailsView.nameLabel.text = @"Devon Boyer";
    detailsView.usernameLabel.text = @"@devboyer";
    detailsView.descriptionLabel.text = @"CS @UWaterloo, iOS developer with a passion for mobile computing and great #uidesign.";
    detailsView.contentInset = UIEdgeInsetsMake(60, 15, 15, 15);
        
    [self setStyle:self.style];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    UIBarButtonItem *removeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    self.navigationView.navigationItem.rightBarButtonItems = @[addBarButtonItem, removeBarButtonItem];
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
