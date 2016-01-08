//
//  DBViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 12/18/2015.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBViewController.h"

@interface DBViewController ()

@end

@implementation DBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    
    [self addContentViewController:[[UITableViewController alloc] init] withTitle:@"Followers"];
    [self addContentViewController:[[UITableViewController alloc] init] withTitle:@"Photos"];
    [self addContentViewController:[[UITableViewController alloc] init] withTitle:@"Likes"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)add {
    [self addContentViewController:[[UITableViewController alloc] init] withTitle:@"Segment"];
}

- (void)remove {
    [self removeContentViewControllerAtIndex:0];
}

@end
