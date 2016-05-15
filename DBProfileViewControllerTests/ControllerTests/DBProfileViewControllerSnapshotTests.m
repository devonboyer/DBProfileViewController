//
//  DBProfileViewControllerSnapshotTests.m
//  DBProfileViewControllerTests
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DBProfileViewController/DBProfileViewController.h>
#import <DBProfileViewController/UITableViewController+DBProfileContentPresenting.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>

@interface DBProfileTestAvatarView : DBProfileAccessoryView

@end

@interface DBProfileTestHeaderView : DBProfileAccessoryView

@end

@interface DBProfileViewControllerTestDataSource : NSObject <DBProfileViewControllerDataSource>

@end

@interface DBProfileViewControllerSnapshotTests : FBSnapshotTestCase

@end

@implementation DBProfileViewControllerSnapshotTests

- (void)setUp {
    [super setUp];
        
    [self suspendTestForSeconds:0.1];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testProfileViewControllerWithAvatarNoHeader { }

- (void)testProfileViewControllerWithHeaderNoAvatar {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] init];
    id dataSource = [[DBProfileViewControllerTestDataSource alloc] init];
    controller.dataSource = dataSource;
    controller.view.frame = [[UIScreen mainScreen] bounds];
    
    [controller registerClass:[DBProfileTestHeaderView class] forAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    controller.segmentedControl.tintColor = [UIColor grayColor];
    
    // FIXME: The controller must be reloaded to account for a bug that causes the contentInset to be wrong until the view appears.
    [controller reloadData];
    
    FBSnapshotVerifyView(controller.view, nil);
}

- (void)testProfileViewControllerWithNoHeaderNoAvatar {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] init];
    id dataSource = [[DBProfileViewControllerTestDataSource alloc] init];
    controller.dataSource = dataSource;
    controller.view.frame = [[UIScreen mainScreen] bounds];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    controller.segmentedControl.tintColor = [UIColor grayColor];
    
    // FIXME: The controller must be reloaded to account for a bug that causes the contentInset to be wrong until the view appears.
    [controller reloadData];
    
    FBSnapshotVerifyView(controller.view, nil);
}

- (void)testProfileViewControllerWithHeaderAndAvatar {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] init];
    id dataSource = [[DBProfileViewControllerTestDataSource alloc] init];
    controller.dataSource = dataSource;
    controller.view.frame = [[UIScreen mainScreen] bounds];
    
    [controller registerClass:[DBProfileTestAvatarView class] forAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    [controller registerClass:[DBProfileTestHeaderView class] forAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    controller.segmentedControl.tintColor = [UIColor grayColor];
    
    // FIXME: The controller must be reloaded to account for a bug that causes the contentInset to be wrong until the view appears.
    [controller reloadData];
    
    FBSnapshotVerifyView(controller.view, nil);
}

#pragma mark - Helpers

- (void)suspendTestForSeconds:(NSTimeInterval)timeoutSeconds
{
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:timeoutSeconds];
    while ([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
}

@end

@implementation DBProfileTestAvatarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end

@implementation DBProfileTestHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end

@implementation DBProfileViewControllerTestDataSource

- (NSUInteger)numberOfContentControllersForProfileViewController:(DBProfileViewController *)controller {
    return 3;
}

- (DBProfileContentController *)profileViewController:(DBProfileViewController *)controller contentControllerAtIndex:(NSUInteger)controllerIndex {
    UITableViewController *tvc = [[UITableViewController alloc] init];
    tvc.title = @"Test";
    return tvc;
}

- (NSString *)profileViewController:(DBProfileViewController *)controller titleForContentControllerAtIndex:(NSUInteger)controllerIndex
{
    return [NSString stringWithFormat:@"Test-%@", @(controllerIndex)];
}

@end
     
     
