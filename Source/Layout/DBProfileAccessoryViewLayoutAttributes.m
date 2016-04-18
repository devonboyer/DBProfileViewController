//
//  DBProfileAccessoryViewLayoutAttributes.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-04-15.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
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
    self = [self init];
    if (self) {
        _representedAccessoryKind = accessoryViewKind;
        
        if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
            _referenceSize = DBProfileAccessoryViewLayoutAttributesDefaultHeaderReferenceSize();
        }
        else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
            _referenceSize = DBProfileAccessoryViewLayoutAttributesDefaultAvatarReferenceSize();
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frame = CGRectZero;
        _bounds = CGRectZero;
        _hidden = NO;
    }
    return self;
}

@end

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
