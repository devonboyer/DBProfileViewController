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

+ (instancetype)db_profileViewControllerBundle
{
    static NSBundle *resourceBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *resourceBundlePath = [[NSBundle bundleForClass:[DBProfileViewController class]] pathForResource:@"DBProfileViewController" ofType:@"bundle"];
        resourceBundle = [self bundleWithPath:resourceBundlePath];
    });
    return resourceBundle;
}

@end
