//
//  DBProfileDetailsView.h
//  DBProfileViewController
//
//  Created by Devon Boyer on 2015-12-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @class DBProfileDetailsView
 @abstract The `DBProfileDetailsView` class displays profile details such as name, username, and description.
 */
@interface DBProfileDetailsView : UIView

/*!
 @abstract The content view of is the default superview for content displayed by the view.
 */
@property (nonatomic, strong, readonly) UIView *contentView;

/*!
 @abstract The label used to display a screen name.
 */
@property (nonatomic, strong, readonly) UILabel *nameLabel;

/*!
 @abstract The label used to display a username.
 */
@property (nonatomic, strong, readonly) UILabel *usernameLabel;

/*!
 @abstract The label used to display a description or bio.
 */
@property (nonatomic, strong, readonly) UILabel *descriptionLabel;

/*!
 @abstract The distance that the content view is inset from the enclosing view.
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

@end

NS_ASSUME_NONNULL_END
