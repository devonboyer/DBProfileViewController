//
//  DBProfileAccessoryViewLayoutAttributes.m
//  Pods
//
//  Created by Devon Boyer on 2016-04-15.
//
//

#import "DBProfileAccessoryViewLayoutAttributes.h"
#import "DBProfileViewController.h"

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
        _size = DBProfileAvatarLayoutSizeNormal;
        _alignment = DBProfileAvatarLayoutAlignmentLeft;
        _insets = UIEdgeInsetsMake(0, 15, DBProfileViewControllerAvatarSizeNormal/2.0 - 15, 0);
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
