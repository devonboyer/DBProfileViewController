//
//  DBProfileViewControllerDefaults.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DBProfileViewController.h"
#import "DBProfileAvatarImageView.h"

@interface DBProfileViewControllerDefaults : NSObject

+ (UIColor *)defaultSegmentedControlTintColor;

+ (UIImage *)defaultBackBarButtonItemImageForTraitCollection:(UITraitCollection *)traitCollection;

+ (DBProfileCoverPhotoOptions)defaultCoverPhotoOptions;

+ (DBProfileCoverPhotoScrollAnimationStyle)defaultCoverPhotoScrollAnimationStyle;

+ (CGFloat)defaultCoverPhotoHeightMultiplier;

+ (DBProfileAvatarAlignment)defaultAvatarAlignment;

+ (DBProfileAvatarSize)defaultAvatarSize;

+ (DBProfileAvatarStyle)defaultAvatarStyle;

+ (UIEdgeInsets)defaultAvatarInsets;

+ (CGFloat)defaultPullToRefreshTriggerDistance;

+ (BOOL)defaultHidesSegmentedControlForSingleContentController;

+ (BOOL)defaultCoverPhotoHidden;

+ (BOOL)defaultCoverPhotoMimicsNavigationBar;

+ (BOOL)defaultAllowsPullToRefresh;

@end
