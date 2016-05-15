//
//  DBProfileHeaderViewLayoutAttributesTests.m
//  DBProfileViewControllerTests
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewLayoutAttributesTests.h"

@interface DBProfileHeaderViewLayoutAttributesTests : DBProfileAccessoryViewLayoutAttributesTests

@end

@implementation DBProfileHeaderViewLayoutAttributesTests

- (Class)layoutAttributesClass
{
    return [DBProfileHeaderViewLayoutAttributes class];
}

- (NSString *)representedAccessoryKind
{
    return DBProfileAccessoryKindHeader;
}

- (void)testHeaderViewLayoutAttributesInit {
    [super _testAccessoryViewLayoutAttributesInit];
}

- (void)testHeaderViewLayoutAttributesEqual {
    [super _testAccessoryViewLayoutAttributesEqual];
}

@end
