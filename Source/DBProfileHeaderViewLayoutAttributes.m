//
//  DBProfileHeaderViewLayoutAttributes.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileHeaderViewLayoutAttributes.h"

@implementation DBProfileHeaderViewLayoutAttributes

- (instancetype)init
{
    self = [super init];
    if (self) {
        _navigationItem = [[UINavigationItem alloc] init];
        _style = DBProfileHeaderLayoutStyleNavigation;
        _options = DBProfileHeaderLayoutOptionStretch;
    }
    return self;
}

@end
