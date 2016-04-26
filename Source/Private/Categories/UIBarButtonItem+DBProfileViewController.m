//
//  UIBarButtonItem+DBProfileViewController.m
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-03-22.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "UIBarButtonItem+DBProfileViewController.h"
#import "NSBundle+DBProfileViewController.h"

@implementation UIBarButtonItem (DBProfileViewController)

+ (UIBarButtonItem *)db_backBarButtonItemWithTarget:(id)target action:(SEL)selector {
    NSString *regularImageName = @"db-profile-chevron";
    NSString *landscapeImageName = @"db-profile-chevron";
    
    UIImage *image = [UIImage imageNamed:regularImageName inBundle:[NSBundle db_profileViewControllerBundle] compatibleWithTraitCollection:nil];
    UIImage *landscapeImage = [UIImage imageNamed:landscapeImageName inBundle:[NSBundle db_profileViewControllerBundle] compatibleWithTraitCollection:nil];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                               landscapeImagePhone:landscapeImage
                                                             style:UIBarButtonItemStyleDone
                                                            target:target
                                                            action:selector];
    return item;
}

@end
