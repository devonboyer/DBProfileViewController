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

@implementation DBProfileViewControllerDefaults

+ (UIColor *)defaultSegmentedControlTintColor {
    return [UIColor colorWithRed:29/255.0 green:161/255.0 blue:242/255.0 alpha:1];
}

+ (DBProfileCoverPhotoOptions)defaultCoverPhotoOptions {
    return DBProfileCoverPhotoOptionStretch;
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
