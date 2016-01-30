//
//  NSBundle+DBProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2016-01-30.
//
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
