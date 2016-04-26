//
//  DBProfileAvatarViewLayoutAttributes.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAvatarViewLayoutAttributes.h"
#import "DBProfileViewController.h"

@implementation DBProfileAvatarViewLayoutAttributes

- (instancetype)initWithAccessoryViewKind:(NSString *)accessoryViewKind
{
    self = [super initWithAccessoryViewKind:accessoryViewKind];
    if (self) {
        _avatarAlignment = DBProfileAvatarAlignmentLeft;
        _edgeInsets = UIEdgeInsetsMake(0, 15, 72/2.0 - 15, 0);
    }
    return self;
}

@end
