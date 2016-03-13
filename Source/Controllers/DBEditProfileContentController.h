//
//  DBEditProfileContentController.h
//  Pods
//
//  Created by Devon Boyer on 2016-03-12.
//
//

#import <UIKit/UIKit.h>

#import "DBProfileContentPresenting.h"

@class DBEditProfileItem;
@class DBEditProfileContentController;

@protocol DBEditProfileContentControllerDataSource <NSObject>

- (NSUInteger)numberOfSectionsForEditProfileContentController:(DBEditProfileContentController *)editProfileContentController;

- (NSInteger)editProfileContentController:(DBEditProfileContentController *)editProfileContentController numberOfItemsInSection:(NSInteger)section;

- (DBEditProfileItem *)editProfileContentController:(DBEditProfileContentController *)editProfileContentController editProfileItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DBEditProfileContentController : UITableViewController <DBProfileContentPresenting>

@property (nonatomic, weak) id<DBEditProfileContentControllerDataSource> dataSource;

@property (nonatomic, assign, readonly) BOOL hasChanges;

@end