//
//  DBProfileTitleView.h
//  Pods
//
//  Created by Devon Boyer on 2016-01-10.
//
//

#import <UIKit/UIKit.h>

/*!
 @class DBProfileTitleView
 @abstract The `DBProfileTitleView` class displays a profile's title and subtitle.
 */
@interface DBProfileTitleView : UIView

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;

@end
