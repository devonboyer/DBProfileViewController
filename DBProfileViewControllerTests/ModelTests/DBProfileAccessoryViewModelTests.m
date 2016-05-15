//
//  DBProfileAccessoryViewModelTests.m
//  DBProfileViewControllerTests
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DBProfileViewController/DBProfileViewController.h>
#import <DBProfileViewController/DBProfileAccessoryViewModel.h>
#import <DBProfileViewController/DBProfileBinding.h>

@interface DBProfileAccessoryViewModelTests : XCTestCase

@property (nonatomic) DBProfileAccessoryView *accessoryView;

@end

@implementation DBProfileAccessoryViewModelTests

- (void)setUp {
    [super setUp];
    
    self.accessoryView = [[DBProfileAccessoryView alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAccessoryViewModelInit {
    
    DBProfileAccessoryViewModel *viewModel = [[DBProfileAccessoryViewModel alloc] initWithAccessoryView:self.accessoryView layoutAttributes:[DBProfileHeaderViewLayoutAttributes layoutAttributesForAccessoryViewOfKind:@"Test"]];
    
    XCTAssertEqualObjects(viewModel.representedAccessoryKind, @"Test", @"representedAccessoryKind should be %@", @"Test");
    XCTAssertNotNil(viewModel.bindings, @"bindings should not be nil");
}

- (void)testAccessoryViewModelKeyPathsForBindings {
    
    DBProfileAccessoryViewModel *headerViewModel = [[DBProfileAccessoryViewModel alloc] initWithAccessoryView:self.accessoryView layoutAttributes:[DBProfileHeaderViewLayoutAttributes layoutAttributes]];

    XCTAssertEqualObjects([headerViewModel.bindings valueForKey:@"keyPath"],[DBProfileHeaderViewLayoutAttributes keyPathsForBindings],  @"invalid keyPaths for bindings");
    
    DBProfileAccessoryViewModel *avatarViewModel = [[DBProfileAccessoryViewModel alloc] initWithAccessoryView:self.accessoryView layoutAttributes:[DBProfileAvatarViewLayoutAttributes layoutAttributes]];
    
    XCTAssertEqualObjects([avatarViewModel.bindings valueForKey:@"keyPath"],[DBProfileAvatarViewLayoutAttributes keyPathsForBindings], @"invalid keyPaths for bindings");
}

@end
