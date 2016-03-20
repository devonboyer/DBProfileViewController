//
//  DBProfileViewControllerDefaults.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-16.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
#import "DBProfileViewControllerDefaults.h"
#import "NSBundle+DBProfileViewController.h"

@implementation DBProfileViewControllerDefaults

+ (UIColor *)defaultSegmentedControlTintColor {
    return [UIColor grayColor];
}

+ (UIImage *)defaultBackBarButtonItemImageForTraitCollection:(UITraitCollection *)traitCollection {
    return [UIImage imageNamed:@"db-profile-chevron" inBundle:[NSBundle db_resourcesBundle] compatibleWithTraitCollection:traitCollection];
}

+ (DBProfileCoverPhotoOptions)defaultCoverPhotoOptions {
    return DBProfileCoverPhotoOptionStretch;
}

+ (DBProfileCoverPhotoScrollAnimationStyle)defaultCoverPhotoScrollAnimationStyle {
    return DBProfileCoverPhotoScrollAnimationStyleBlur;
}

+ (CGFloat)defaultCoverPhotoHeightMultiplier {
    return 0.18;
}

+ (DBProfileAvatarAlignment)defaultAvatarAlignment {
    return DBProfileAvatarAlignmentLeft;
}

+ (DBProfileAvatarSize)defaultAvatarSize {
    return DBProfileAvatarSizeNormal;
}

+ (DBProfileAvatarStyle)defaultAvatarStyle {
    return DBProfileAvatarStyleRoundedRect;
}

+ (UIEdgeInsets)defaultAvatarInsets {
    return UIEdgeInsetsMake(0, 15, DBProfileViewControllerAvatarSizeNormal/2.0 - 15, 0);
}

+ (CGFloat)defaultPullToRefreshTriggerDistance {
    return 80.0;
}

+ (BOOL)defaultHidesSegmentedControlForSingleContentController {
    return YES;
}

+ (BOOL)defaultCoverPhotoHidden {
    return NO;
}

+ (BOOL)defaultCoverPhotoMimicsNavigationBar {
    return YES;
}

+ (BOOL)defaultAllowsPullToRefresh {
    return YES;
}

@end
