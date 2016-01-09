//
//  DBViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 12/18/2015.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBViewController.h"
#import "UITableViewController+DBProfileContentViewController.h"

@interface DBViewController () <UITableViewDataSource, UITableViewDelegate, DBProfileViewControllerDelegate>

@end

@implementation DBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    self.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    
    UITableViewController *followers = [[UITableViewController alloc] init];
    [followers.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    followers.tableView.dataSource = self;
    followers.tableView.delegate = self;
    
    UITableViewController *photos = [[UITableViewController alloc] init];
    [photos.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    photos.tableView.dataSource = self;
    photos.tableView.delegate = self;
    
    UITableViewController *likes = [[UITableViewController alloc] init];
    [likes.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    likes.tableView.dataSource = self;
    likes.tableView.delegate = self;

    [self addContentViewController:followers withTitle:@"Followers"];
    [self addContentViewController:photos withTitle:@"Photos"];
    [self addContentViewController:likes withTitle:@"Likes"];
    
    [self setCoverPhoto:[UIImage imageNamed:@"cookies.jpg"]];
    [self setProfilePicture:[UIImage imageNamed:@"profile-picture.jpg"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)add {
    UITableViewController *tbvc = [[UITableViewController alloc] init];
    [tbvc.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    tbvc.tableView.dataSource = self;
    tbvc.tableView.delegate = self;
    
    [self addContentViewController:tbvc withTitle:@"Segment"];
}

- (void)remove {
    [self removeContentViewControllerAtIndex:0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - DBProfileViewControllerDelegate

- (void)profileViewControllerDidStartRefreshing:(DBProfileViewController *)viewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
