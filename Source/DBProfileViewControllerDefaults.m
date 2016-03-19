//
//  DBProfileViewControllerDefaults.m
//  Pods
//
//  Created by Devon Boyer on 2016-03-16.
//
//

#import "DBProfileViewControllerDefaults.h"
#import "NSBundle+DBProfileViewController.h"

@implementation DBProfileViewControllerDefaults

+ (instancetype)sharedDefaults {
    static DBProfileViewControllerDefaults *sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[self alloc] init];
    });
    return sharedDefaults;
}

- (UIColor *)defaultSegmentedControlTintColor {
    return [UIColor grayColor];
}

- (UIImage *)defaultBackBarButtonItemImageForTraitCollection:(UITraitCollection *)traitCollection {
    return [UIImage imageNamed:@"db-profile-chevron" inBundle:[NSBundle db_resourcesBundle] compatibleWithTraitCollection:traitCollection];
}

- (DBProfileCoverPhotoOptions)defaultCoverPhotoOptions {
    return DBProfileCoverPhotoOptionStretch;
}

- (DBProfileCoverPhotoScrollAnimationStyle)defaultCoverPhotoScrollAnimationStyle {
    return DBProfileCoverPhotoScrollAnimationStyleBlur;
}

- (CGFloat)defaultCoverPhotoHeightMultiplier {
    return 0.18;
}

- (DBProfilePictureAlignment)defaultProfilePictureAlignment {
    return DBProfilePictureAlignmentLeft;
}

- (DBProfilePictureSize)defaultProfilePictureSize {
    return DBProfilePictureSizeNormal;
}

- (DBProfileAvatarStyle)defaultAvatarStyle {
    return DBProfileAvatarStyleRoundedRect;
}

- (UIEdgeInsets)defaultProfilePictureInsets {
    return UIEdgeInsetsMake(0, 15, DBProfileViewControllerProfilePictureSizeNormal/2.0 - 15, 0);
}

- (CGFloat)defaultPullToRefreshTriggerDistance {
    return 80.0;
}

- (BOOL)defaultRememberIndexForSelectedContentController {
    return YES;
}

- (BOOL)defaultHidesSegmentedControlForSingleContentController {
    return YES;
}

- (BOOL)defaultCoverPhotoHidden {
    return NO;
}

- (BOOL)defaultCoverPhotoMimicsNavigationBar {
    return YES;
}

- (BOOL)defaultAllowsPullToRefresh {
    return YES;
}

@end
