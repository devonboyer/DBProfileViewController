//
//  NSBundle+DBProfileViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-30.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NSBundle+DBProfileViewController.h"
#import "DBProfileViewController.h"

@implementation NSBundle (DBProfileViewController)

+ (NSBundle *)db_resourcesBundle {
    NSString *bundleResourcePath = [NSBundle bundleForClass:[DBProfileViewController class]].resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:@"DBProfileViewController.bundle"];
    return [NSBundle bundleWithPath:assetPath];
}

@end
