//
//  DBEditProfileViewController.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-12.
//
//

#import <DBProfileViewController/DBProfileViewController.h>

@class DBEditProfileViewController;
@class DBEditProfileContentController;
@class DBProfileItemChange;

@protocol DBEditProfileViewControllerDelegate <NSObject>

- (void)editProfileViewController:(DBEditProfileViewController *)editProfileViewController didFinishEditingWithChanges:(NSArray<DBProfileItemChange *> *)changes;

@optional

- (void)editProfileViewControllerDidCancel:(DBEditProfileViewController *)editProfileViewController;

@end

@interface DBEditProfileViewController : DBProfileViewController <DBProfileViewControllerDataSource>

@property (nonatomic, weak) id<DBProfileViewControllerDelegate, DBEditProfileViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) DBEditProfileContentController *contentController;

@property (nonatomic, strong, readonly) UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic, strong, readonly) UIBarButtonItem *doneBarButtonItem;

@end
