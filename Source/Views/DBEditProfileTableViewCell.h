//
//  DBEditProfileTableViewCell.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-13.
//
//

#import <UIKit/UIKit.h>

@class DBEditProfileTableViewCell;

@protocol DBEditProfileTableViewCellDelegate <NSObject>

@end

@interface DBEditProfileTableViewCell : UITableViewCell

@property (nonatomic, weak) id<DBEditProfileTableViewCellDelegate> delegate;

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, assign, readonly) BOOL hasChanges;

@property (nonatomic, assign, getter=isEditable, readonly) BOOL editable;

@end