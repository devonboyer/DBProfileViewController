//
//  DBProfileHeaderViewLayoutAttributes.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileHeaderViewLayoutAttributes.h"
#import "DBProfileViewController.h"

@implementation DBProfileHeaderViewLayoutAttributes

- (instancetype)initWithAccessoryViewKind:(NSString *)accessoryViewKind
{
    self = [super initWithAccessoryViewKind:accessoryViewKind];
    if (self) {
        _headerStyle = DBProfileHeaderStyleNavigation;
        _headerOptions = DBProfileHeaderOptionStretch;
    }
    return self;
}

- (void)uninstallConstraints {
    [super uninstallConstraints];
    self.navigationConstraint = nil;
    self.topLayoutGuideConstraint = nil;
    self.topSuperviewConstraint = nil;
}

@end
