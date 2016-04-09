//
//  DBProfileAccessoryViewLayoutAttributes.m
//  Pods
//
//  Created by Devon Boyer on 2016-04-07.
//
//

#import "DBProfileAccessoryViewLayoutAttributes.h"
#include "DBProfileViewController.h"

@implementation DBProfileAccessoryViewLayoutAttributes

+ (instancetype)layoutAttributesForAccessoryViewOfKind:(NSString *)accessoryKind
{
    DBProfileAccessoryViewLayoutAttributes *layoutAttributes = [[[self class] alloc] initWithAccessoryKind:accessoryKind];
    return layoutAttributes;
}

- (instancetype)initWithAccessoryKind:(NSString *)accessoryKind
{
    self = [self init];
    if (self) {
        _representedAccessoryKind = accessoryKind;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frame = CGRectZero;
        _bounds = CGRectZero;
        _alpha = 1.0;
        _hidden = NO;
        _alignment = DBProfileAccessoryAlignmentLeft;
        _size = DBProfileAccessorySizeNormal;
    }
    return self;
}

@end

@implementation DBProfileCoverPhotoLayoutAttributes

+ (instancetype)layoutAttributes
{
    return [super layoutAttributesForAccessoryViewOfKind:DBProfileViewControllerAccessoryKindCoverPhoto];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _navigationItem = [[UINavigationItem alloc] init];
        _options = DBProfileCoverPhotoOptionStretch;
        _mimicsNavigationBar = YES;
    }
    return self;
}

@end
