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
        self.size = CGSizeZero;
        self.center = CGPointZero;
        self.hidden = NO;
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
        self.zIndex = 0;
        
        if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindHeader]) {
            self.referenceSize = DBProfileAccessoryViewLayoutAttributesDefaultHeaderReferenceSize();
        }
        else if ([accessoryViewKind isEqualToString:DBProfileAccessoryKindAvatar]) {
            self.referenceSize = DBProfileAccessoryViewLayoutAttributesDefaultAvatarReferenceSize();
        }
    }
    return self;
}

- (void)uninstallConstraints {
    self.hasInstalledConstraints = NO;
    self.leadingConstraint = nil;
    self.trailingConstraint = nil;
    self.leftConstraint = nil;
    self.rightConstraint = nil;
    self.topConstraint = nil;
    self.bottomConstraint = nil;
    self.widthConstraint = nil;
    self.heightConstraint = nil;
    self.centerXConstraint = nil;
    self.centerYConstraint = nil;
    self.firstBaselineConstraint = nil;
    self.lastBaselineConstraint = nil;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;
    DBProfileAccessoryViewLayoutAttributes *otherObject = (DBProfileAccessoryViewLayoutAttributes *)object;
    return
    [self.representedAccessoryKind isEqual:otherObject.representedAccessoryKind] &&
    CGRectEqualToRect(self.frame, otherObject.frame) &&
    CGRectEqualToRect(self.bounds, otherObject.bounds) &&
    CGAffineTransformEqualToTransform(self.transform, otherObject.transform) &&
    CGSizeEqualToSize(self.size, otherObject.size) &&
    CGSizeEqualToSize(self.referenceSize, otherObject.referenceSize) &&
    CGPointEqualToPoint(self.center, otherObject.center) &&
    self.hidden == otherObject.hidden &&
    self.alpha == otherObject.alpha &&
    self.zIndex == otherObject.zIndex &&
    self.hasInstalledConstraints == otherObject.hasInstalledConstraints;

}

@end
