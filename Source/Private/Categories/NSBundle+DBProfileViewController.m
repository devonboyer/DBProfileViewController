//
//  NSBundle+DBProfileViewController.m
//  Pods
//
//  Created by Devon Boyer on 2016-04-15.
//
//

#import "NSBundle+DBProfileViewController.h"
#import "DBProfileViewController.h"

@implementation NSBundle (DBProfileViewController)

+ (NSBundle *)db_profileViewControllerBundle
{
    NSString *resourcePath = [NSBundle bundleForClass:[DBProfileViewController class]].resourcePath;
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"DBProfileViewController.bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

@end
