//
//  DBEditProfileMultilineInputTableViewCell.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-15.
//
//

#import <DBProfileViewController/DBEditProfileTableViewCell.h>

@class DBEditProfileMultilineInputTableViewCell;

@protocol DBEditProfileMultilineInputTableViewCell <DBEditProfileTableViewCellDelegate>

- (void)editProfileMultilineInputTableViewCell:(DBEditProfileMultilineInputTableViewCell *)cell textViewDidChange:(UITextView *)textView;

@end

@interface DBEditProfileMultilineInputTableViewCell : DBEditProfileTableViewCell <UITextViewDelegate>

@property (nonatomic, weak) id<DBEditProfileMultilineInputTableViewCell> delegate;

@property (nonatomic, strong, readonly) UITextView *textView;

@property (nonatomic, assign) NSInteger maxNumberOfLines;

@end
