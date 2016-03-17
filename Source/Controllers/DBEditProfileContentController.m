//
//  DBEditProfileContentController.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-12.
//
//

#import "DBEditProfileContentController.h"
#import "DBEditProfileTableViewCell.h"
#import "DBEditProfileInputTableViewCell.h"
#import "DBEditProfileMultilineInputTableViewCell.h"
#import "DBProfileItem.h"
#import "DBProfileItemChange.h"

static NSString * const DBEditProfileInputTableViewCellReuseIdentifier = @"DBEditProfileInputTableViewCellReuseIdentifier";
static NSString * const DBEditProfileMultilineInputTableViewCellReuseIdentifier = @"DBEditProfileMultilineInputTableViewCellReuseIdentifier";

@interface DBEditProfileContentController () <DBEditProfileMultilineInputTableViewCell>

@property (nonatomic, strong) NSMutableDictionary *heights;

@end

@implementation DBEditProfileContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heights = [[NSMutableDictionary alloc] init];
    
    [self.tableView registerClass:[DBEditProfileInputTableViewCell class] forCellReuseIdentifier:DBEditProfileInputTableViewCellReuseIdentifier];
    [self.tableView registerClass:[DBEditProfileMultilineInputTableViewCell class] forCellReuseIdentifier:DBEditProfileMultilineInputTableViewCellReuseIdentifier];

    self.tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:248/255.0 blue:250/255.0 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:204/255.0 green:214/255.0 blue:221/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)hasChanges {
    return NO;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsForEditProfileContentController:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource editProfileContentController:self numberOfItemsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBProfileItem *item = [self.dataSource editProfileContentController:self itemAtIndexPath:indexPath];

    if ([item.value isKindOfClass:[NSString class]]) {
        if (item.maxNumberOfLines > 1) {
            return ([self.heights valueForKey:[@(indexPath.row) stringValue]]) ? [self.heights[[@(indexPath.row) stringValue]] floatValue] : 48.0;
        }
    }
    
    return 48.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBEditProfileTableViewCell *cell;
    DBProfileItem *item = [self.dataSource editProfileContentController:self itemAtIndexPath:indexPath];
    
    if ([item.value isKindOfClass:[NSString class]]) {
        if (item.maxNumberOfLines > 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:DBEditProfileMultilineInputTableViewCellReuseIdentifier forIndexPath:indexPath];
            ((DBEditProfileMultilineInputTableViewCell *)cell).textView.text = item.value;
            UITextView *textView = ((DBEditProfileMultilineInputTableViewCell *)cell).textView;
            
            CGFloat padding = 14;
            self.heights[[@(indexPath.row) stringValue]] = @(MAX(round([textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)].height + padding), 48.0));

        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:DBEditProfileInputTableViewCellReuseIdentifier forIndexPath:indexPath];
            ((DBEditProfileInputTableViewCell *)cell).textField.text = item.value;
        }
    }
    
    cell.titleLabel.text = item.title;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - DBProfileContentPresenting

- (UIScrollView *)contentScrollView {
    return self.tableView;
}

#pragma mark - DBEditProfileMultilineInputTableViewCell

- (void)editProfileMultilineInputTableViewCell:(DBEditProfileMultilineInputTableViewCell *)cell textViewDidChange:(UITextView *)textView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CGFloat padding = 14;
    self.heights[[@(indexPath.row) stringValue]] = @(MAX(round([textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)].height + padding), 48.0));
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
