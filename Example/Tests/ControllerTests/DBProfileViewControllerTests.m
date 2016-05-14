//
//  DBProfileViewControllerTests.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DBProfileViewController/DBProfileViewController.h>

@interface DBProfileTestSegmentedControl : UISegmentedControl
@end

@implementation DBProfileTestSegmentedControl
@end

@interface DBTestProfileViewController : DBProfileViewController
@end

@implementation DBTestProfileViewController
@end
 
@interface DBProfileViewControllerTests : XCTestCase

@end

@implementation DBProfileViewControllerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Initialization Tests

- (void)testProfileViewControllerInit {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] init];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    XCTAssertNil(controller.dataSource, @"dataSource should be nil");
    XCTAssertNil(controller.delegate, @"delegate should be nil");

    XCTAssertNotNil(controller.overlayView, @"overlayView should not be nil");
    XCTAssertNil(controller.displayedContentController, @"displayedContentController should be nil");
    XCTAssertTrue([controller.segmentedControl isKindOfClass:[UISegmentedControl class]], @"segmentedControl should be kind of class %@", [UISegmentedControl class]);

    XCTAssertTrue(CGSizeEqualToSize(controller.headerReferenceSize, DBProfileViewControllerDefaultHeaderReferenceSize), @"headerReferenceSize should be equal to DBProfileViewControllerDefaultHeaderReferenceSize");
    XCTAssertTrue(CGSizeEqualToSize(controller.avatarReferenceSize, DBProfileViewControllerDefaultAvatarReferenceSize), @"avatarReferenceSize should be equal to DBProfileViewControllerDefaultAvatarReferenceSize");
}

- (void)testProfileViewControllerCustomSegementedControlInit {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] initWithSegmentedControlClass:[DBProfileTestSegmentedControl class]];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    XCTAssertTrue([controller.segmentedControl isKindOfClass:[DBProfileTestSegmentedControl class]], @"segmentedControl should be kind of class %@", [DBProfileTestSegmentedControl class]);
}

- (void)testProfileViewControllerSubclassInit {
    
    DBTestProfileViewController *controller = [[DBTestProfileViewController alloc] init];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    XCTAssertTrue([controller isKindOfClass:[DBTestProfileViewController class]], @"controller should be kind of class %@", [DBTestProfileViewController class]);
}

- (void)testProfileViewControllerStoryboardInit {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Test" bundle:nil];

    DBProfileViewController *controller = [storyboard instantiateInitialViewController];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    XCTAssertNil(controller.dataSource, @"dataSource should be nil");
    XCTAssertNil(controller.delegate, @"delegate should be nil");
    
    XCTAssertNotNil(controller.overlayView, @"overlayView should not be nil");
    XCTAssertNil(controller.displayedContentController, @"displayedContentController should be nil");
    XCTAssertTrue([controller.segmentedControl isKindOfClass:[UISegmentedControl class]], @"segmentedControl should be kind of class %@", [UISegmentedControl class]);
    
    XCTAssertTrue(CGSizeEqualToSize(controller.headerReferenceSize, DBProfileViewControllerDefaultHeaderReferenceSize), @"headerReferenceSize should be equal to DBProfileViewControllerDefaultHeaderReferenceSize");
    XCTAssertTrue(CGSizeEqualToSize(controller.avatarReferenceSize, DBProfileViewControllerDefaultAvatarReferenceSize), @"avatarReferenceSize should be equal to DBProfileViewControllerDefaultAvatarReferenceSize");
}

#pragma mark - Accessory View Registration Tests

- (void)testProfileViewControllerRegisterAvatarView {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] init];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    [controller registerClass:[DBProfileAccessoryView class] forAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    DBProfileAccessoryView *avatarView = [controller accessoryViewOfKind:DBProfileAccessoryKindAvatar];

    XCTAssertNotNil(avatarView, @"avatarView should not be nil");
    XCTAssertTrue([avatarView isKindOfClass:[DBProfileAccessoryView class]], @"avatarView should be kind of class %@", [DBProfileAccessoryView class]);
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [controller layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindAvatar];
    
    XCTAssertNotNil(layoutAttributes, @"layoutAttributes should not be nil");
    XCTAssertTrue([layoutAttributes isKindOfClass:[DBProfileAvatarViewLayoutAttributes class]], @"layoutAttributes should be kind of class %@", [DBProfileAvatarViewLayoutAttributes class]);
}

- (void)testProfileViewControllerRegisterHeaderView {
    
    DBProfileViewController *controller = [[DBProfileViewController alloc] init];
    
    [controller beginAppearanceTransition:YES animated:NO];
    [controller endAppearanceTransition];
    
    [controller registerClass:[DBProfileAccessoryView class] forAccessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    DBProfileAccessoryView *headerView = [controller accessoryViewOfKind:DBProfileAccessoryKindHeader];
    
    XCTAssertNotNil(headerView, @"headerView should not be nil");
    XCTAssertTrue([headerView isKindOfClass:[DBProfileAccessoryView class]], @"headerView should be kind of class %@", [DBProfileAccessoryView class]);
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [controller layoutAttributesForAccessoryViewOfKind:DBProfileAccessoryKindHeader];

    XCTAssertNotNil(layoutAttributes, @"layoutAttributes should not be nil");
    XCTAssertTrue([layoutAttributes isKindOfClass:[DBProfileHeaderViewLayoutAttributes class]], @"layoutAttributes should be kind of class %@", [DBProfileHeaderViewLayoutAttributes class]);
}

@end
