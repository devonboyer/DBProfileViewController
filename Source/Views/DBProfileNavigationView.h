//
//  DBProfileNavigationView.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-13.
//
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
