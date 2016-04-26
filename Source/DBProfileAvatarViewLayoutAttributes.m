//
//  DBProfileAvatarViewLayoutAttributes.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAvatarViewLayoutAttributes.h"

@implementation DBProfileAvatarViewLayoutAttributes

- (instancetype)init
{
    self = [super init];
    if (self) {
        _alignment = DBProfileAvatarLayoutAlignmentLeft;
        _insets = UIEdgeInsetsMake(0, 15, 72/2.0 - 15, 0);
    }
    return self;
}


@end
