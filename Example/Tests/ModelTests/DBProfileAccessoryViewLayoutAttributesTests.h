//
//  DBProfileAccessoryViewLayoutAttributesTests.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-05-14.
//  Copyright © 2016 Devon Boyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DBProfileViewController/DBProfileViewController.h>

@interface DBProfileAccessoryViewLayoutAttributesTests : XCTestCase

- (Class)layoutAttributesClass;
- (NSString *)representedAccessoryKind;

- (void)_testAccessoryViewLayoutAttributesInit;
- (void)_testAccessoryViewLayoutAttributesEqual;

@end