//
//  DBProfileDetailsView.h
//  Pods
//
//  Created by Devon Boyer on 2015-12-18.
//
//

#import <UIKit/UIKit.h>

/*!
 @class DBProfileDetailsView
 @abstract The `DBProfileDetailsView` class displays profile details such as name, username, and description.
 */
@interface DBProfileDetailsView : UIView

@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *usernameLabel;
@property (nonatomic, strong, readonly) UILabel *descriptionLabel;
@property (nonatomic, strong, readonly) UIButton *editProfileButton;

@end
