//
//  DBEditProfileViewController.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-12.
//
//

#import <DBProfileViewController/DBProfileViewController.h>

@interface DBEditProfileViewController : DBProfileViewController <DBProfileViewControllerDataSource, DBProfileViewControllerDelegate>

@property (nonatomic, strong, readonly) UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic, strong, readonly) UIBarButtonItem *doneBarButtonItem;

@end
