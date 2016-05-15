//
//  DBProfileAccessoryViewLayoutAttributesTests.m
//  DBProfileViewControllerTests
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewLayoutAttributesTests.h"

@implementation DBProfileAccessoryViewLayoutAttributesTests

- (Class)layoutAttributesClass
{
    return nil;
}

- (NSString *)representedAccessoryKind
{
    return nil;
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)_testAccessoryViewLayoutAttributesInit {
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [[self layoutAttributesClass] layoutAttributesForAccessoryViewOfKind:[self representedAccessoryKind]];
    
    XCTAssertEqualObjects(layoutAttributes.representedAccessoryKind, [self representedAccessoryKind], @"representedAccessoryKind should be %@", [self layoutAttributesClass]);
    XCTAssertTrue([layoutAttributes isKindOfClass:[self layoutAttributesClass]], @"layoutAttributes should be kind of class %@", [self layoutAttributesClass]);
    XCTAssertNotNil(layoutAttributes, @"layoutAttributes should not be nil");
}

- (void)_testAccessoryViewLayoutAttributesEqual {
    
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [[self layoutAttributesClass] layoutAttributesForAccessoryViewOfKind:[self representedAccessoryKind]];
    
    DBProfileAccessoryViewLayoutAttributes *copy = [layoutAttributes copy];
    
    XCTAssertEqualObjects(layoutAttributes, copy, @"Copied layoutAttributes should be equal");
    XCTAssertEqualObjects(layoutAttributes, layoutAttributes, @"layoutAttributes should be equal to itself");
}

@end





