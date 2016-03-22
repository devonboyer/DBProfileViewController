//
//  DBProfileCustomNavigationBar.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-13.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@class DBProfileTitleView;

@interface DBProfileCustomNavigationBar : UINavigationBar

@property (nonatomic, strong, readonly) UINavigationItem *navigationItem;

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

@end