//
//  DBPhotosTableViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBPhotosTableViewController.h"

@implementation DBPhotosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Photos";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"Photo";
    return cell;
}

#pragma mark - DBProfileContentViewController

- (UIScrollView *)contentScrollView {
    return self.tableView;
}

@end
