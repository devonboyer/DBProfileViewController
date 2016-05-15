//
//  DBProfileAccessoryViewTests.m
//  DBProfileViewControllerTests
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DBProfileViewController/DBProfileViewController.h>

@interface DBProfileAccessoryViewTests : XCTestCase

@end

@implementation DBProfileAccessoryViewTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAccessoryViewInit {
    
    DBProfileAccessoryView *accessoryView = [[DBProfileAccessoryView alloc] init];
    
    XCTAssertNotNil(accessoryView.longPressGestureRecognizer, @"longPressGestureRecognizer should not be nil");
    XCTAssertNotNil(accessoryView.tapGestureRecognizer, @"tapGestureRecognizer should not be nil");
}

- (void)testApplyLayoutAttributes {
    
    DBProfileAccessoryView *accessoryView = [[DBProfileAccessoryView alloc] init];

    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [DBProfileAccessoryViewLayoutAttributes layoutAttributesForAccessoryViewOfKind:@"Test"];
    
    layoutAttributes.hidden = YES;
    
    [accessoryView applyLayoutAttributes:layoutAttributes];
    
    XCTAssertTrue(accessoryView.hidden, @"accessoryView.hidden should be true");
}

@end
