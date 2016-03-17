//
//  DBEditProfileInputTableViewCell.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-15.
//
//

#import <DBProfileViewController/DBEditProfileTableViewCell.h>

@interface DBEditProfileInputTableViewCell : DBEditProfileTableViewCell <UITextFieldDelegate>

@property (nonatomic, strong, readonly) UITextField *textField;

@end
