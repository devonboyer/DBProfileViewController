//
//  DBProfileNavigationView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-13.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@class DBProfileTitleView;

/*!
 @class DBProfileNavigationView
 @abstract The `DBProfileNavigationView` class displays a navigation bar.
 @discussion When using `coverPhotoMimicsNavigationBar` a `DBProfileNavigationView` is used in place of a UINavigationController's navigationBar. This gives the best possible push/pop animations.
 */
@interface DBProfileNavigationView : UIView

@property (nonatomic, strong, readonly) DBProfileTitleView *titleView;
@property (nonatomic, strong, readonly) UINavigationBar *navigationBar;
@property (nonatomic, strong, readonly) UINavigationItem *navigationItem;

@end
