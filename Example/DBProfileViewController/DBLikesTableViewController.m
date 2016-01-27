//
//  DBLikesTableViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBLikesTableViewController.h"

@implementation DBLikesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Likes";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"Like";
    return cell;
}

#pragma mark - DBProfileContentPresenting

- (UIScrollView *)contentScrollView {
    return self.tableView;
}

- (NSString *)contentTitle {
    return @"Likes";
}

- (NSString *)contentSubtitle {
    return @"4 Likes";
}

@end
