//
//  DBEditProfileContentController.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-12.
//
//

#import "DBEditProfileContentController.h"
#import "DBEditProfileItem.h"

@implementation DBEditProfileContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:248/255.0 blue:250/255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:204/255.0 green:214/255.0 blue:221/255.0 alpha:1.0];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - DBProfileContentPresenting

- (UIScrollView *)contentScrollView {
    return self.tableView;
}

@end
