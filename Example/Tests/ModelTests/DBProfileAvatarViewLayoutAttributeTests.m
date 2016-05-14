//
//  DBProfileAvatarViewLayoutAttributeTests.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewLayoutAttributesTests.h"

@interface DBProfileAvatarViewLayoutAttributeTests : DBProfileAccessoryViewLayoutAttributesTests

@end

@implementation DBProfileAvatarViewLayoutAttributeTests

- (Class)layoutAttributesClass
{
    return [DBProfileAvatarViewLayoutAttributes class];
}

- (NSString *)representedAccessoryKind
{
    return DBProfileAccessoryKindAvatar;
}

- (void)testAvatarViewLayoutAttributesInit {
    [super _testAccessoryViewLayoutAttributesInit];
}

- (void)testAvatarViewLayoutAttributesEqual {
    [super _testAccessoryViewLayoutAttributesEqual];
}

@end
