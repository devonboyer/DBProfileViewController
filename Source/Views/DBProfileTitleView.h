//
//  DBProfileTitleView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2016-01-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

/*!
 @class DBProfileTitleView
 @abstract The `DBProfileTitleView` class displays a profile's title and subtitle.
 */
@interface DBProfileTitleView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;

@end
