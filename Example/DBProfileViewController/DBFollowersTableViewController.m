//
//  DBFollowersTableViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBFollowersTableViewController.h"

@implementation DBFollowersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Followers";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"Follower";
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didHighlightRowAtIndexPath");
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didUnhighlightRowAtIndexPath");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didDeselectRowAtIndexPath");
}

#pragma mark - DBProfileContentPresenting

- (UIScrollView *)contentScrollView {
    return self.tableView;
}

@end
