//
//  DBProfileCoverPhotoView.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-08.
//
//

#import <UIKit/UIKit.h>

@class DBProfileNavigationBar;

@interface DBProfileCoverPhotoView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;

- (void)startRefreshing;
- (void)endRefreshing;

@end
