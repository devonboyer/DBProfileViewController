//
//  DBProfileViewControllerConstants.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-19.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBProfileViewControllerConstants.h"
#import "DBProfileViewController.h"

NSBundle *DBProfileViewControllerBundle() {
    NSString *resourcePath = [NSBundle bundleForClass:[DBProfileViewController class]].resourcePath;
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"DBProfileViewController.bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

CGFloat DBProfileViewControllerNavigationBarHeightForTraitCollection(UITraitCollection *traitCollection) {
    switch (traitCollection.verticalSizeClass) {
        case UIUserInterfaceSizeClassCompact:
            return 32;
        default:
            return 64;
    }
}

const CGFloat DBProfileViewControllerCoverPhotoMaxBlurRadius = 10.0;

const CGFloat DBProfileViewControllerAvatarSizeNormal = 72.0;

const CGFloat DBProfileViewControllerAvatarSizeLarge = 92.0;