//
//  DBTransactionsViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-16.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBTransactionsViewController.h"
#import "DBTransactionTableViewCell.h"
#import "DBTransactionsSectionHeader.h"

static NSString * const DBTransactionTableViewCellIdentifier = @"DBTransactionTableViewCellIdentifier";
static NSString * const DBTransactionsSectionHeaderIdentifier = @"DBTransactionsSectionHeaderIdentifier";

@implementation DBTransactionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[DBTransactionTableViewCell class] forCellReuseIdentifier:DBTransactionTableViewCellIdentifier];
    [self.tableView registerClass:[DBTransactionsSectionHeader class] forHeaderFooterViewReuseIdentifier:DBTransactionsSectionHeaderIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DBTransactionTableViewCellIdentifier forIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DBTransactionsSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:DBTransactionsSectionHeaderIdentifier];
    header.dateLabel.text = @"Thursday, January 21";
    return header;
}

- (UIScrollView *)contentScrollView
{
    return self.tableView;
}

@end
