//
//  DBAccountSummaryViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-16.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBAccountSummaryViewController.h"
#import "DBTransactionsViewController.h"
#import "DBCreditCardView.h"

@implementation DBAccountSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.allowsPullToRefresh = NO;
    
    self.detailsView = nil;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self registerClass:[DBCreditCardView class] forAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileHeaderViewLayoutAttributes *layoutAttributes = (DBProfileHeaderViewLayoutAttributes *)[self layoutAtttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    layoutAttributes.options = DBProfileHeaderLayoutOptionNone;
}

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)profileViewController
{
    return 1;
}

- (DBProfileContentController *)profileViewController:(DBProfileViewController *)profileViewController contentControllerAtIndex:(NSUInteger)index
{
    return [[DBTransactionsViewController alloc] init];
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController titleForContentControllerAtIndex:(NSUInteger)index
{
    return @"Transactions";
}

- (NSString *)profileViewController:(DBProfileViewController *)profileViewController subtitleForContentControllerAtIndex:(NSUInteger)index
{
    return nil;
}

@end
