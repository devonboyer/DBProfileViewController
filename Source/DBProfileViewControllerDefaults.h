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

@interface DBProfileViewControllerDefaults : NSObject

+ (instancetype)sharedDefaults;

- (UIColor *)defaultSegmentedControlTintColor;

- (UIImage *)defaultBackBarButtonItemImageForTraitCollection:(UITraitCollection *)traitCollection;

- (DBProfileCoverPhotoOptions)defaultCoverPhotoOptions;

- (CGFloat)defaultCoverPhotoHeightMultiplier;

- (DBProfilePictureAlignment)defaultProfilePictureAlignment;

- (DBProfilePictureSize)defaultProfilePictureSize;

- (UIEdgeInsets)defaultProfilePictureInsets;

- (CGFloat)defaultPullToRefreshTriggerDistance;

- (BOOL)defaultHidesSegmentedControlForSingleContentController;

- (BOOL)defaultCoverPhotoHidden;

- (BOOL)defaultCoverPhotoMimicsNavigationBar;

- (BOOL)defaultAllowsPullToRefresh;

@end
