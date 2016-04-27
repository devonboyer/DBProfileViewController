//
//  DBProfileAccessoryViewLayoutAttributes.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-15.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBProfileAccessoryViewLayoutAttributes.h"
#import "DBProfileViewController.h"

static CGSize DBProfileAccessoryViewLayoutAttributesDefaultAvatarReferenceSize()
{
    return CGSizeMake(0, 72);
}

static CGSize DBProfileAccessoryViewLayoutAttributesDefaultHeaderReferenceSize()
{
    return CGSizeMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) * 0.18);
}

@implementation DBProfileAccessoryViewLayoutAttributes

+ (instancetype)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryViewKind
{
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [[[self class] alloc] initWithAccessoryViewKind:accessoryViewKind];
    return layoutAttributes;
}

- (instancetype)initWithAccessoryViewKind:(NSString *)accessoryViewKind
{
    self = [super init];
    if (self) {
        _representedAccessoryKind = accessoryViewKind;

        self.frame = CGRectZero;
        self.bounds = CGRectZero;
        self.hidden = NO;
        self.transform = CGAffineTransformIdentity;
        
        if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
            self.referenceSize = DBProfileAccessoryViewLayoutAttributesDefaultHeaderReferenceSize();
        }
        else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
            self.referenceSize = DBProfileAccessoryViewLayoutAttributesDefaultAvatarReferenceSize();
        }
    }
    return self;
}

@end
