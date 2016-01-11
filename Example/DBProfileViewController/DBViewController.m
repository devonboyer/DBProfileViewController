//
//  DBViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 12/18/2015.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBViewController.h"

#import "DBFollowersTableViewController.h"
#import "DBPhotosTableViewController.h"
#import "DBLikesTableViewController.h"

@interface DBViewController () <DBProfileViewControllerDelegate>
@end

@implementation DBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];

    [self addContentViewController:[[DBFollowersTableViewController alloc] init] withTitle:@"Followers"];
    [self addContentViewController:[[DBPhotosTableViewController alloc] init] withTitle:@"Photos"];
    [self addContentViewController:[[DBLikesTableViewController alloc] init] withTitle:@"Likes"];
        
    [self setCoverPhoto:[UIImage imageNamed:@"backdrop.png"] animated:NO];
    [self setProfilePicture:[UIImage imageNamed:@"profile-picture.jpg"] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)search {
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - DBProfileViewControllerDelegate

- (void)profileViewControllerDidPullToRefresh:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
