//
//  DBProfileViewControllerDefaults.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-16.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "DBProfileViewControllerConstants.h"

@interface DBProfileViewControllerDefaults : NSObject

+ (UIColor *)defaultSegmentedControlTintColor;

///---------------------------------------------
/// @name Cover Photo Defaults
///---------------------------------------------

+ (DBProfileCoverPhotoOptions)defaultCoverPhotoOptions;

+ (CGFloat)defaultCoverPhotoHeightMultiplier;

+ (BOOL)defaultCoverPhotoHidden;

+ (BOOL)defaultCoverPhotoMimicsNavigationBar;

///---------------------------------------------
/// @name Avatar Defaults
///---------------------------------------------

+ (DBProfileAvatarAlignment)defaultAvatarAlignment;

+ (DBProfileAvatarSize)defaultAvatarSize;

+ (DBProfileAvatarStyle)defaultAvatarStyle;

+ (UIEdgeInsets)defaultAvatarInsets;

///---------------------------------------------
/// @name Other
///---------------------------------------------

+ (CGFloat)defaultPullToRefreshTriggerDistance;

+ (BOOL)defaultAllowsPullToRefresh;

+ (BOOL)defaultHidesSegmentedControlForSingleContentController;


// navigationBarHeightForSizeClass interfaceIdiom

@end
